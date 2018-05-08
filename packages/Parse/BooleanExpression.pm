package BooleanExpression;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Parse::RecDescent;
use SMS::LogpointRequirements;

# This package contains the logic for interpreting a boolean expression of logpoints or process options
# expressions can have & (and) | (or) ^ (xor) ! (not) and parenthesis.
# this uses the RecDescent module from CPAN to parse + create an executable perl string
#
# originally this was planned to also have -> (implication) <- (reverse implication) and <=> (equality) but ran into
# some trouble with the parser.  Apparently recursive descent parsers cannot parse a left-recursive language so I had to adapt + throw out some features
# 
# admittedly, this package is a bit more complex than I'd like, as it uses lambda functions to evaluate whether a logpoint/opn is used
# But this was done to allow the one parser to be used everywhere
# there is a lambda function for evaluating logpoints and a lambda function for evaluating process options.  
# They must each take one parameter, being either the logpoint or the process option.


our $current_routing;
my $current_lpt_lambda;
my $current_opt_lambda;
my $static_parser;

# Enable warnings within the Parse::RecDescent module.
$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

my $grammar = q{
# Terminals (macros that can't expand further)
#

LPT		: /[0-9]{4}/		# logpoints
OPT		: /[0-9A-Z_]+/i		# process option
EQ		: /<(-|=){1,2}>|={1,2}/
IMP		: /(-|=){1,2}>/
RIMP		: /<(-|=){1,2}/
AND		: /[\.\+]|&&?/i
OR		: /\|\|?/i
XOR		: /\^/
NOT		: /[-!~]/
LEFT_PAREN	: /\(/
RIGHT_PAREN	: /\)/

# Binary operators 

STD_BIN_OR	: OR
                { $return = "||"}
        | XOR
                { $return = "xor"}

STD_BIN_AND	: AND
                { $return = "&&"}

# Unary Operators
STD_UN_OP	: NOT
                { $return = "!" }

# Expressions
STATEMENT	: EXPRESSION EQ EXPRESSION
        { $return = "$item[1] == $item[3]" }
        | EXPRESSION IMP EXPRESSION
        { $return = "BooleanExpression::implies(sub{return ($item[1])}, sub{return ($item[3])})" }
        | EXPRESSION RIMP EXPRESSION
        { $return = "BooleanExpression::implies(sub{return ($item[3])}, sub{return ($item[1])})" }
        | EXPRESSION
        { $return = "$item[1]" }
        
EXPRESSION	: TERM EXPRESSION_E
                { $return = "$item[1] $item[2]"}

EXPRESSION_E	: STD_BIN_OR TERM EXPRESSION_E(s)
                { $return = "$item[1] $item[2] " . join(' ', @{$item[3]})}
        | 
                { $return = ""}

TERM		: FACTOR TERM_E
                { $return = "$item[1] $item[2]"}

TERM_E		: STD_BIN_AND FACTOR TERM_E(s)
                { $return = "$item[1] $item[2] " . join(' ', @{$item[3]})}
        |
                { $return = ""}

FACTOR		: LPT
                { $return = "check_lpt('$item{'LPT'}')"}
        | OPT
        { $return = "check_opt('$item{'OPT'}')"}
        | LEFT_PAREN STATEMENT RIGHT_PAREN
                { $return = "( $item[2] )"}
        | LEFT_PAREN EXPRESSION RIGHT_PAREN
                { $return = "( $item[2] )"}
        | STD_UN_OP EXPRESSION
                { $return = "$item[1] $item[2]"}
        

startrule	: STATEMENT

};

# init the parser with the given lambdas (just in case we want to split this singleton into a class)
sub init{
    my ($lpt_lambda, $opt_lambda) = @_;
    $current_lpt_lambda = $lpt_lambda;
    $current_opt_lambda = $opt_lambda;
    $static_parser = Parse::RecDescent->new($grammar) unless defined $static_parser;
    return $static_parser;
}

# If the class lambda is defined (static), then pass it the option and return the result, otherwise die
# called by the evaluatable string produced by the parser
sub check_opt{
        my ($opt) = @_;
        if(defined $current_opt_lambda){
                my $success;
                eval{
                        $success = $current_opt_lambda->($opt);
                        1;
                }or do{
                        my $e = $@;
                        confess "Ran into error determining if option <$opt> was valid : $e";
                };
                return $success;
        }else{
                confess "Encountered an option <$opt> but have no way to check if valid";
        }
        return undef;
}

# If the class lambda is defined (static), then pass it the lpt and return the result, otherwise die
# called by the evaluatable string produced by the parser
sub check_lpt{
    my ($lpt) = @_;
    if(defined $current_lpt_lambda){
        my $success;
        eval{
            $success = $current_lpt_lambda->($lpt);
            1;
        }or do{
            my $e = $@;
            confess "Ran into error determining if logpoint <$lpt> was valid : $e";
        };
        return $success;
    }else{
        confess "Encountered a logpoint <$lpt> but have no way to check if valid";
    }
    return undef;
}

sub does_sms_routing_and_options_match_expression{
    my ($routing, $opt_list, $expression) = @_;

    my $lpt_lambda = sub {
                my ($lpt) = @_;
                return LogpointRequirements::does_routing_use_lpt($routing, $lpt);
        };

    my %options;
    my @upper = map {tr/[a-z]/[A-Z]/; $_} @{$opt_list};
        @options{@upper} = @upper;
        my $opt_lambda = sub{
                my ($opt) = @_;
        $opt =~ tr/[a-z]/[A-Z]/;
                return defined $options{$opt};
        };

    return get_result_general($expression, $lpt_lambda, $opt_lambda);

}

# create the lambda for checking SMS routing and evaluate expression
sub does_sms_routing_match_lpt_string{
    my ($routing, $lpt_string) = @_;

    my $lpt_lambda = sub {
        my ($lpt) = @_;
        return LogpointRequirements::does_routing_use_lpt($routing, $lpt);
    };

    return get_result_general($lpt_string, $lpt_lambda, undef);
}

# create the lambda for checking if process option in a list
sub does_opt_list_match_opt_string{
    my ($opt_list, $opt_string) = @_;
    my %options;
    my @upper = map {tr/[a-z]/[A-Z]/; $_} @{$opt_list};
        @options{@upper} = @upper;
    my $opt_lambda = sub{
        my ($opt) = @_;
        $opt =~ tr/[a-z]/[A-Z]/;
        return defined $options{$opt};
    };

    return get_result_general($opt_string, undef, $opt_lambda);	
}


# evaluate expression with provided lambdas (undef means don't allow)
sub get_result_general{
    my ($expression, $lpt_lambda, $opt_lambda) = @_;
    my $parser = init($lpt_lambda, $opt_lambda);
    my $eval_text = get_eval($parser, $expression);
    my $value = eval($eval_text);
    my $e = $@;
    if ($e !~ m/^\s*$/ or not defined $value ){
        confess "Failed to interpret <$expression> because of : $e";
    }
    if (defined $value){
        return $value;
    }else{
        confess "Failed to interpret <$expression> with provided lambdas, got undef?";
    };
    return undef;
}

# parses the expression to make sure that all characters are accounted for.  Does not execute any code besides the parser
sub is_valid_expression{
    my ($lpt_string) = @_;
    my $copy = $lpt_string;
    # store vars
    my @old = ($::RD_ERRORS, $::RD_WARN, $::RD_HINT);
    # silence errors
    ($::RD_ERRORS, $::RD_WARN, $::RD_HINT) = (0, 0, 0);
    my $parser = init(undef, undef);
    my $result = $parser->startrule(\$copy);
    ($::RD_ERRORS, $::RD_WARN, $::RD_HINT) = @old;
    return defined $result && $copy =~ m/^\s*$/;
}

# uses the provided parser + expression to create an evaluatable perl string
sub get_eval{
    my ($parser, $expression) = @_;
        my $copy = $expression;
        my $eval_text = $parser->startrule(\$copy);
        unless (defined $eval_text && $copy =~ m/^\s*$/){
                confess "Parser failed to interpret <$expression>";
        };
        return $eval_text;
}

sub implies{
    # takes two lambda functions and returns p -> q.  evaluates p first, short circuits if false
    # ie. if p evaluates false, then q does not need to be evaluated, so it is not.
    my ($p, $q) = @_;
    my $p_val = $p->();
    if (! $p_val){
        return 1;
    }else{
        my $q_val = $q->();
        return $q_val;
    }
    return undef;
}

1;
