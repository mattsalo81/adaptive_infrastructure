use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use Parse::BooleanExpression;

ok(BooleanExpression::is_valid_expression("9300"), "Interprets logpoints as valid");
ok(BooleanExpression::is_valid_expression("9455"), "Interprets logpoints as valid");
ok(BooleanExpression::is_valid_expression("     9300          "), "Ignores whitespace");
ok(!BooleanExpression::is_valid_expression("9 300"), "unless whitespace separates something important");
ok(BooleanExpression::is_valid_expression("(9300)"), "Interprets Parenthesis as valid");
ok(BooleanExpression::is_valid_expression("((9300))"), "Interprets nested Parenthesis as valid");
ok(!BooleanExpression::is_valid_expression("().9300"), "unless they're empty");
ok(!BooleanExpression::is_valid_expression("(+++).9300"), "or full of operators");
ok(!BooleanExpression::is_valid_expression(")9300("), "or facing the wrong way");


ok(BooleanExpression::is_valid_expression("!9300"), "Can do nots");
ok(BooleanExpression::is_valid_expression("!!!!!!!!!9300"), "Can do nots - so many");

ok(BooleanExpression::is_valid_expression("9300.9455.1234.2345.3456"), "Can do and .");
ok(!BooleanExpression::is_valid_expression("9300also3456"), "Can not do also");

ok(BooleanExpression::is_valid_expression("9300.9455|1234.2345|3456"), "Can do |");

ok(BooleanExpression::is_valid_expression("9300.9455^1234.2345|3456"), "Can do ^");

ok(BooleanExpression::is_valid_expression("!(1234)^(1234|1234)^(1234.((~1234).(1234|1234))|(1234.1234|1234.1234))"), "Can do it all");
ok(!BooleanExpression::is_valid_expression("!(1234)^(1234|1234)^(1234.((~1234).(1234|1234))|1234.1234|1234.1234))"), "misplaced paren");
