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
push @required_fields, qw(coordref test_lpt test_opn lpt functionality PCD_REV);
@required_fields = map {tr/a-z/A-Z/; $_} @required_fields;


# This class uses the SMS/FastTable for filtering, which uses lambda functions to filter records
# a good portion of this class concerns itself with generating the lambda functions required for each rule


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
    PROCESS_OPTION      => ['INDEX', \&lambda_generator_process_options],
    LPT                 => ['INDEX', \&lambda_generator_logpoints],
    FUNCTIONALITY       => ['RECORD', undef];
    PCD_REV             => ['RECORD', undef];
);

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
    foreach my $field (@required_fields){
        my $value = $hash->{$field};
        $self->{$field} = "";
        $self->{$field} = $value if defined $value;
    }
    return $self;
}

sub filter_fasttable_by_rule{
    my ($self, $ft) = @_;
    foreach my $rule_key (keys %field_filter_actions){
        # create a lambda for Fast Table
        my ($filter_type, $lambda_generator) = $field_filter_actions{$rule_key};
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
            my ($index_value);
            return explicit_anchored_regex_with_numeric_comparison($index_value, $expression);
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
        return BooleanExpression::does_effective_routing_match_expression_using_database
                        ($technology, $effective_routing, $requirements);
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
        my ($record) = @_;
        my $routing = $record->{"ROUTING"};
        confess "Could not get Routing" unless defined $routing;
        return BooleanExpression::does_sms_routing_match_lpt_string($routing, $requirements);
    }
}

# should a rule cut down a fast table or a fast table cut down a rule?
# probably rule cuts down fast table
# okay, so need to provide INDEX -> lambda that takes index value or
#       RECORD -> lambda that takes record value

sub explicit_anchored_regex_with_numeric_comparison{
    my ($test, $expression) = @_;
    confess "Expression undefined" unless defined $expression;
    $expression =~ s/^\s*//;
    $expression =~ s/\s*$//;
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
    $test = "" unless defined $test;
    
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

1;
