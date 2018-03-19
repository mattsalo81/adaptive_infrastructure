package BooleanLogpoint;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Parse::RecDescent;
use SMS::LogpointRequirements;

# This package contains the logic for interpreting a boolean expression of logpoints
# expressions can have & (and) | (or) ^ (xor) ! (not) and parenthesis.
# this uses the RecDescent module from CPAN to parse + create an executable perl string
# this uses LogpointRequirements to query sms to see if logpoints are/are not in routing
#
# originally this was planned to also have -> (implication) <- (reverse implication) and <=> (equality) but ran into
# some trouble with the parser.  Apparently recursive descent parsers cannot parse a left-recursive language so I had to adapt + throw out some features


our $current_routing = "A6.0B4EDBS";
my $parser;

# Enable warnings within the Parse::RecDescent module.
$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.

my $grammar = q{
# Terminals (macros that can't expand further)
#

LPT		: /[0-9]{4}/		# logpoints
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
                { $return = "LogpointRequirements::does_routing_use_lpt('$BooleanLogpoint::current_routing', '$item{'LPT'}')"}
		| LEFT_PAREN EXPRESSION RIGHT_PAREN
                { $return = "( $item[2] )"}
		| STD_UN_OP EXPRESSION
                { $return = "$item[1] $item[2]"}
		

startrule	: EXPRESSION

};

sub init{
	$parser = Parse::RecDescent->new($grammar) unless defined $parser;
}

sub set_routing{
	my ($routing) = @_;
	$current_routing = $routing;
}

sub does_routing_match_lpt_string{
	my ($routing, $lpt_string) = @_;
       	my $result = get_eval($routing, $lpt_string); 
	my $value = eval($result);
	return $value;
}

sub is_valid_lpt_string{
	my ($lpt_string) = @_;
	my $copy = $lpt_string;
	# store vars
	my @old = ($::RD_ERRORS, $::RD_WARN, $::RD_HINT);
	# silence errors
	($::RD_ERRORS, $::RD_WARN, $::RD_HINT) = (0, 0, 0);
	init();
	set_routing("DUMMY");
	my $result = $parser->startrule(\$copy);
	($::RD_ERRORS, $::RD_WARN, $::RD_HINT) = @old;
	return defined $result && $copy =~ m/^\s*$/;
}

sub get_eval{
	my ($routing, $lpt_string) = @_;
        init();
        set_routing($routing);
        my $copy = $lpt_string;
        my $result = $parser->startrule(\$copy);
        unless (defined $result && $copy =~ m/^\s*$/){
                confess "Parser failed to interpret <$lpt_string>";
        };
        return $result;
}

1;
