use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use Parse::BooleanExpression;
use SMS::LogpointRequirements;


# any routing that goes through 9300, 0050, and 3355, but not 9455, 1234, or 9999
my $routing = "A72AF3A+";
my $string = "9300.0050.3355.!9455.!1234.!9999";
ok(LogpointRequirements::does_routing_match_lpt_lists($routing, ['9300', '0050', '3355'], ['9455', '1234', '9999']), "Double checking that routing uses correct logpoints");

# cross checking compatible string formats
ok(LogpointRequirements::does_routing_match_lpt_string($routing, $string), "Double checking that string is accepted by logpointRequirements");
ok(BooleanExpression::does_routing_match_lpt_string($routing, $string), "Is boolean logic compatible with old string formatting");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "9300"), "Test routing goes through 9300");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "0050"), "Test routing goes through 0050");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "3355"), "Test routing goes through 3355");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "1234"), "Test routing goes through 1234");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9999"), "Test routing goes through 9999");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9455"), "Test routing goes through 9455");

# single lpt rules
ok(BooleanExpression::does_routing_match_lpt_string($routing, "9300"), "Single lpt rule");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "!9300"), "Single lpt rule - not");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9455"), "Single lpt rule - false");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "!9455"), "Single lpt rule - not false");

# parenthesis
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(9300)"), "parenthesis");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "((!(9300)))"), "nested parenthesis w/ unary operator");

# ANDS
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(9300&&0050)&&3355"), "ANDS with nesting");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(9300 && 0050) & 3355"), "ANDS with nesting and whitespace");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "(9300 && 0050) & 9999"), "ANDS with nesting and whitespace");

# OR
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(9300 || 0050) || 9999"), "ORS with nesting and whitespace");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "(1234) || 9999"), "ORS with nesting and whitespace");

# XOR
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "(9300 ^ 0050)"), "XORS and whitespace");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(9300 ^ 9455)"), "XORS and whitespace");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "(9300 ^ 9455 ^ 0050)"), "XORS and whitespace");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(9300 ^ 9455 ^ 1234)"), "XORS and whitespace");

# PRECEDENCE
ok(BooleanExpression::does_routing_match_lpt_string($routing, "9300 && 0050 | 9455"), "AND OR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "9300 && 9455 | 0050"), "AND OR PRECEDENCE");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9455 && 9455 | 9455"), "AND OR PRECEDENCE");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9455 && 9455 | 9455 && 9455"), "AND OR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(0050 && 9300) | (9455 && 9455)"), "AND OR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(9455 && 9455) | (9300 && 0050)"), "AND OR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "0050 && 9300 | 9455 && 9455"), "AND OR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "9455 && 9455 | 9300 && 0050"), "AND OR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "0050 && 9300 ^ 9455 && 9455"), "AND XOR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "9455 && 9455 ^ 9300 && 0050"), "AND XOR PRECEDENCE");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9300 && 0050 ^ 9300 && 0050"), "AND XOR PRECEDENCE");

# OR/XOR precedence
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9300 || 0050 ^ 9300 || 0050"), "OR XOR PRECEDENCE");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "(9300 || 9455) ^ (9300 || 0050)"), "OR XOR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "((9300 || 9455) ^ 9300) || 0050"), "OR XOR PRECEDENCE");
ok(!BooleanExpression::does_routing_match_lpt_string($routing, "9300 || 9455 ^ 9300 || 0050"), "OR XOR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "(1234 || 9455) ^ (9300 || 0050)"), "OR XOR PRECEDENCE");
ok(BooleanExpression::does_routing_match_lpt_string($routing, "1234 || 9455 ^ 9300 || 0050"), "OR XOR PRECEDENCE");

# just everything
ok(BooleanExpression::does_routing_match_lpt_string($routing, "1234|1234||!9300|((9300) ^ (9300) ^ (9300&&9300.9300&!9455))"), "Everything all at once");
