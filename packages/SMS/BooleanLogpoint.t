use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use SMS::BooleanLogpoint;

ok(BooleanLogpoint::is_valid_lpt_string("9300"), "Interprets logpoints as valid");
ok(BooleanLogpoint::is_valid_lpt_string("9455"), "Interprets logpoints as valid");
ok(BooleanLogpoint::is_valid_lpt_string("     9300          "), "Ignores whitespace");
ok(!BooleanLogpoint::is_valid_lpt_string("9 300"), "unless whitespace separates something important");
ok(BooleanLogpoint::is_valid_lpt_string("(9300)"), "Interprets Parenthesis as valid");
ok(BooleanLogpoint::is_valid_lpt_string("((9300))"), "Interprets nested Parenthesis as valid");
ok(!BooleanLogpoint::is_valid_lpt_string("().9300"), "unless they're empty");
ok(!BooleanLogpoint::is_valid_lpt_string("(+++).9300"), "or full of operators");
ok(!BooleanLogpoint::is_valid_lpt_string(")9300("), "or facing the wrong way");


ok(BooleanLogpoint::is_valid_lpt_string("!9300"), "Can do nots");
ok(BooleanLogpoint::is_valid_lpt_string("!!!!!!!!!9300"), "Can do nots - so many");

ok(BooleanLogpoint::is_valid_lpt_string("9300.9455.1234.2345.3456"), "Can do and - .");
ok(BooleanLogpoint::is_valid_lpt_string("9300+9455 and 1234 and 2345&3456"), "Can do and - \"and\", &, and +");
ok(BooleanLogpoint::is_valid_lpt_string("9300and9455and1234and2345and3456"), "Can do and - .");
ok(!BooleanLogpoint::is_valid_lpt_string("9300also3456"), "Can not do also");


ok(BooleanLogpoint::is_valid_lpt_string("9300"), "Interprets logpoints as valid");
ok(BooleanLogpoint::is_valid_lpt_string("9300"), "Interprets logpoints as valid");
ok(BooleanLogpoint::is_valid_lpt_string("9300"), "Interprets logpoints as valid");
ok(BooleanLogpoint::is_valid_lpt_string("9300"), "Interprets logpoints as valid");
ok(BooleanLogpoint::is_valid_lpt_string("9300"), "Interprets logpoints as valid");
