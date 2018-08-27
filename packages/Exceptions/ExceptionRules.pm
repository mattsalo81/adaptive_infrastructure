package ExceptionRules;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Switch;
use Parse::BooleanExpression;

our $number_format = '[-+]?[0-9]*(\.)?[0-9]+([eE][-+]?[0-9]+)?';

# configuration variables
my @required_fields = qw(rule_number technology family dev_class prod_grp);
push @required_fields, qw(routing effective_routing program device process_option);
push @required_fields, qw(coordref test_lpt test_opn lpt functionality);
@required_fields = map {tr/a-z/A-Z/; $_} @required_fields;

# fields that are allowed but are not used for filtering
my @non_rule_fields = qw(RULE_NUMBER EXPIRATION_DATE PCD PCD_REV EXCEPTION_NUMBER RULE_NUMBER ACTIVE);
my %non_rule_fields;
@non_rule_fields{@non_rule_fields} = @non_rule_fields;


# This class uses the SMS/FastTable for filtering, which uses lambda functions to filter records
# a good portion of this class concerns itself with generating the lambda functions required for each rule

# order to execute rules in
my @field_filter_order = qw(
    TEST_LPT
    TEST_OPN
    COT
    TECHNOLOGY
    FAMILY
    DEV_CLASS
    PROD_GRP
    ROUTING
    EFFECTIVE_ROUTING
    COORDREF
    PROGRAM
    DEVICE
    PROCESS_OPTION
    LPT
    FUNCTIONALITY
);

# each field's filtering subroutine
our %field_filter_actions = (
    # FIELD             => [function_type, lambda generator for RuleTable (takes only $self)],
    TECHNOLOGY          => ['INDEX', lambda_generator_generator_explicit_index('TECHNOLOGY')],
    FAMILY              => ['INDEX', lambda_generator_generator_explicit_index('FAMILY')],
    DEV_CLASS           => ['INDEX', lambda_generator_generator_explicit_index('DEV_CLASS')],
    PROD_GRP            => ['INDEX', lambda_generator_generator_explicit_index('PROD_GRP')],
    ROUTING             => ['INDEX', lambda_generator_generator_explicit_index('ROUTING')],
    EFFECTIVE_ROUTING   => ['INDEX', lambda_generator_generator_explicit_index('EFFECTIVE_ROUTING')],
    PROGRAM             => ['INDEX', lambda_generator_generator_explicit_index('PROGRAM')],
    DEVICE              => ['INDEX', lambda_generator_generator_explicit_index('DEVICE')],
    COORDREF            => ['INDEX', lambda_generator_generator_explicit_index('COORDREF')],
    TEST_LPT            => ['INDEX', lambda_generator_generator_explicit_index('TEST_LPT')],
    TEST_OPN            => ['INDEX', lambda_generator_generator_explicit_index('TEST_OPN')],
    COT                 => ['INDEX', lambda_generator_generator_explicit_index('COT')],
    PROCESS_OPTION      => ['RECORD', \&lambda_generator_process_options],
    LPT                 => ['INDEX',  \&lambda_generator_logpoints],
    FUNCTIONALITY       => ['RECORD', \&lambda_generator_functionality],
);
check_field_filter_action_vs_order();

our %index_translator = (
    TECHNOLOGY  => "TECHNOLOGY",
    FAMILY      => "FAMILY",
    DEV_CLASS   => "DEV_CLASS",
    PROD_GRP    => "PROD_GRP",
    ROUTING     => "ROUTING",
    EFFECTIVE_ROUTING => "EFFECTIVE_ROUTING",
    PROGRAM     => "PROGRAM",
    DEVICE      => "DEVICE",
    COORDREF    => "COORDREF",
    TEST_LPT    => "LPT",
    TEST_OPN    => "OPN",
    COT         => "COT",
    PROCESS_OPTION => "EFFECTIVE_ROUTING",
    LPT         => "ROUTING",
);

sub new_empty{
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub new_from_hash{
    my ($class, $hash) = @_;
    my $self = $class->new_empty();
    foreach my $field (@required_fields, keys %{$hash}){
        my $value = $hash->{$field};
        $self->{$field} = "";
        $self->{$field} = $value if defined $value;
    }
    return $self;
}

sub validate_rule{
    my ($self) = @_;
    # check for extra fields
    foreach my $rule (keys %{$self}){
        if ((not defined $field_filter_actions{$rule}) && (not defined $non_rule_fields{$rule})){
            confess "Extra Rule for $rule that I don't know how to interpret";
        }
    }
}

sub filter_fasttable{
    my ($self, $ft) = @_;
    $self->validate_rule();
    foreach my $rule_key (@field_filter_order){
        # create a lambda for Fast Table
        my ($filter_type, $lambda_generator) = @{$field_filter_actions{$rule_key}};
        Logging::diag("Filtering fast table for $rule_key");
        if($filter_type eq "INDEX"){
            my $lambda = $self->$lambda_generator();
            my $index = $index_translator{$rule_key};
            confess "$rule_key is not defined in index_translator so cannot get equivalent sms-record key" unless defined $index;
            $ft->index_by($index);
            $ft->filter_indexes($lambda);
        }elsif($filter_type eq "RECORD"){
            my $lambda = $self->$lambda_generator();
            $ft->filter_records($lambda);
        }else{
            confess "Don't know how to create a rule for type <$filter_type>";
        }
    }
}

sub lambda_generator_generator_explicit_index{
    my ($rule_field) = @_;
    # lambda generator
    return sub {
        my ($self) = @_;
        my $expression = $self->{$rule_field};
        # lambda
        my $lambda = sub {
            my ($index_value) = @_;
            my $ret = explicit_anchored_regex_with_numeric_comparison($index_value, $expression);
            Logging::diag("returned $ret on <$index_value> matching expression <$expression>");
            return $ret;
        }
    };
}

# takes a rule and returns a lambda function for filtering a fasttable by process options
sub lambda_generator_process_options{
    my ($self) = @_;
    my $requirements = $self->{"PROCESS_OPTION"};
    confess "process option requirements not defined" unless defined $requirements;
    # return true for blank rules
    return sub{ 1 } if $requirements =~ m/^\s*$/;
    # lambda takes an SMS record
    return sub{
        my ($record) = @_;
        my $technology = $record->{"TECHNOLOGY"};
        confess "Could not get technology" unless defined $technology;
        my $effective_routing = $record->{"EFFECTIVE_ROUTING"};
        confess "Could not get Effective_routing" unless defined $effective_routing;
        my $success = 0;
        eval{
            $success = BooleanExpression::does_effective_routing_match_expression_using_database
                        ($technology, $effective_routing, $requirements);
            1;
        } or do {
            my $e = @_;
            warn "Could not get process options for <$technology> effective routing <$effective_routing>";
            Logging::diag("Could not get process options for <$technology> effective routing <$effective_routing> because $e");
            return 0;
        };
        return $success;
    }
}

# takes a rule and returns a lambda function for filtering a fasttable by logpoint
sub lambda_generator_logpoints{
    my ($self) = @_;
    my $requirements = $self->{"LPT"};
    confess "Logpoint requirements not defined" unless defined $requirements;
    # return true for no requirements
    return sub { 1 } if $requirements =~ m/^\s*$/;
    # lambda takes an SMS record
    return sub{
        my ($routing) = @_;
        confess "Could not get Routing" unless defined $routing;
        return BooleanExpression::does_sms_routing_match_lpt_string($routing, $requirements);
    }
}

sub lambda_generator_functionality{
    my ($self) = @_;
    my $requirements = $self->{"FUNCTIONALITY"};
    confess "Functionality requriements not defined" unless defined $requirements;
    
    if ($requirements =~ m/^\s*$/){
        return sub { 1 };
    }else{
        return sub{
            my ($record) = @_;
            return BooleanExpression::does_sms_record_satisfy_functionality($record, $requirements);
        }
    }
}

# should a rule cut down a fast table or a fast table cut down a rule?
# probably rule cuts down fast table
# okay, so need to provide INDEX -> lambda that takes index value or
#       RECORD -> lambda that takes record value

sub explicit_anchored_regex_with_numeric_comparison{
    my ($test, $expression) = @_;
    confess "Expression undefined" unless defined $expression;
    confess "Test undefined" unless defined $test;
    $expression =~ s/^\s*//;
    $expression =~ s/\s*$//;
    return 1 if ($expression eq ".*" || $expression =~ m/^\s*$/);
    if ($expression =~ m{^/(.*)/$}){
        return anchored_regex_with_numeric_comparison($test, $1);
    }else{
        return $test eq $expression;
    }
    confess "shouldn't get here";
}

sub anchored_regex_with_numeric_comparison{
    my ($test, $expression) = @_;
    # return if regex matches anything
    confess "Test undefined" unless defined $test;
    confess "Expression undefined" unless defined $expression;
    # scrub inputs
    $expression =~ s/^\s*//;
    $expression =~ s/\s*$//;
    return 1 if $expression eq "";
    return 1 if $expression eq ".*";
    if ($test =~ m/^$number_format$/ && $expression =~ m{^([<=>][<=>]?|!=)($number_format)$}){
        # numeric comparison
        my ($comparison_operator, $test_value) = ($1, $2);
        return numeric_comparison($test, $comparison_operator, $test_value);
    }else{
        return $test =~ m{^$expression$};
    }
    confess "shouldn't get here";
}

sub numeric_comparison{
    my ($test, $comparison_operator, $test_value) = @_;
    switch($comparison_operator){
        case '>'        {return ($test >  $test_value)}
        case '>='       {return ($test >= $test_value)}
        case '<'        {return ($test <  $test_value)}
        case '<='       {return ($test <= $test_value)}
        case '<='       {return ($test <= $test_value)}
        case '=='       {return ($test == $test_value)}
        case '='        {return ($test == $test_value)}
        case '=<'       {return ($test <= $test_value)}
        case '=>'       {return ($test >= $test_value)}
        case '!='       {return ($test != $test_value)}
        case '><'       {return ($test != $test_value)}
        case '<>'       {return ($test != $test_value)}
        case '>>'       {return ($test >  $test_value)}
        case '<<'       {return ($test <  $test_value)}
        default         {confess "Matched Comparison operator <$comparison_operator> but don't know how to handle it"}
    };
    confess "Should never get here";
}

# check if every field defined in the %field_filter_actions is defined in @field_filter_order
sub check_field_filter_action_vs_order{
    my %order_tmp;
    @order_tmp{@field_filter_order} = @field_filter_order;
    foreach my $order_key(keys %order_tmp){
        confess "<$order_key> is defined in the field_filter_order, but is not tied to an action in field_filter_action!, configuration issue" unless defined $field_filter_actions{$order_key};
    }
    foreach my $action_key(keys %field_filter_actions){
        confess "<$action_key> is defined in the field_filter_action, but is not given a precedence in field_filter_order!, configuration issue" unless defined $order_tmp{$action_key};
    }
}
1;
