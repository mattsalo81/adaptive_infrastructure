use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use Parse::BooleanExpression;


throws_ok(sub {BooleanExpression::get_result_general("OPTION && 1234", undef, undef)}, 
		"Encountered .* but have no way to check", "throws okay when finds something it can't evaluate");
throws_ok(sub {BooleanExpression::get_result_general("OPTION", sub {return 1}, undef)}, 
		"Encountered an option .* but have no way to check", "throws okay when finds option it can't evaluate");
throws_ok(sub {BooleanExpression::get_result_general("1234", undef, sub {return 1})}, 
		"Encountered a logpoint .* but have no way to check", "throws okay when finds something it can't evaluate");
ok(sub {BooleanExpression::get_result_general("1234 && OPTION", sub{return 1}, sub {return 1})}, 
		"1 && 1 using lambdas does not throw error");
ok(BooleanExpression::get_result_general("1234 && OPTION", sub{return 1}, sub {return 1}),
                "1 && 1 using lambdas is true");
ok(!BooleanExpression::get_result_general("1234 && OPTION", sub{return 0}, sub {return 1}),
                "0 && 1 using lambdas is false");
dies_ok(sub{BooleanExpression::get_result_general("1234 && OPTION", sub {die "THIS SHOULD NOT RUN BECAUSE && SHOULD SHORT CIRCUIT"}, sub{return 1})},
                "\"false && die\" short circuits and does not execute die");
ok(!BooleanExpression::get_result_general("1234 && OPTION", sub{return 0}, sub {die "THIS SHOULD NOT RUN BECAUSE && SHOULD SHORT CIRCUIT"}),
                "\"false && die\" short circuits and does not execute die");
