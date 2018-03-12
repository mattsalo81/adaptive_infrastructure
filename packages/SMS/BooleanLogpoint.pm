package BooleanLogpoint;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Parse::RecDescent;
use SMS::LogpointRequirements;

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
AND		: /([&\.\+]|\band\b)/i
OR		: /(\|\bor\b)/i
XOR		: /(\^|\bxor\b)/
NOT		: /[-!~]/
LEFT_PAREN	: /\(/
RIGHT_PAREN	: /\)/

# Binary operators 

STD_BIN_OP	: AND
		{ $return = "&&"}
		| OR
		{ $return = "||"}
		| XOR
		{ $return = "xor"}

# Unary Operators
STD_UN_OP	: NOT
		{ $return = "!" }

# Expressions
EXPRESSION	: CHUNK ADDENDUM
		{ $return = eval {"$item[1] $item[2]"}}
		| CHUNK 
		{ $return = eval {"$item[1]"}}

ADDENDUM	: STD_BIN_OP CHUNK
		{ $return = "$item[1] $item[2]"}
		| STD_BIN_OP CHUNK ADDENDUM
		{ $return = "$item[1] $item[2] $item[3]"}

CHUNK		: LPT
		{ $return = LogpointRequirements::does_routing_use_lpt($BooleanLogpoint::current_routing, $item{"LPT"})}
		| LEFT_PAREN CHUNK RIGHT_PAREN
		{ $return = eval {"$item[2]"}}
		| LEFT_PAREN EXPRESSION RIGHT_PAREN
		{ $return = eval {"$item[2]"}}
		| STD_UN_OP EXPRESSION
		{ $return = eval {"$item[1] $item[2]"}}
		

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
	init();
	set_routing($routing);
	my $copy = $lpt_string;
	my $result = $parser->startrule(\$copy);
	unless (defined $result){
                confess "Parser failed to interpret <$lpt_string>";
        };
	return $result;
}

sub is_valid_lpt_string{
	my ($lpt_string) = @_;
	my $copy = $lpt_string;
	# store vars
	my @old = ($::RD_ERRORS, $::RD_WARN, $::RD_HINT);
	($::RD_ERRORS, $::RD_WARN, $::RD_HINT) = (0, 0, 0);
	init();
	set_routing("DUMMY");
	my $result = $parser->startrule(\$copy);
	print ($copy . "\n");
	($::RD_ERRORS, $::RD_WARN, $::RD_HINT) = @old;
	return defined $result;
}

1;
