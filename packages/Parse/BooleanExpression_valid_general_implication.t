use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use Parse::BooleanExpression;

# helper functions -> process options resolve to true, logpoints die
sub my_eval{
	my ($expr) = @_;
	return BooleanExpression::get_result_general($expr, sub{die "Resolved to logpoint which is a killable offense"}, sub {die "ERROR" if $_[0] =~ m/DIE/; return $_[0] =~ m/T/});
}

ok(my_eval("T"), "true resolves to a process option, process options all true");
ok(!my_eval("!T"), "!true is false");
ok(!my_eval("F"), "False is false");


ok(BooleanExpression::is_valid_expression("A -> B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A->B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A-->B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A=>B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A==>B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<-B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<--B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<=B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<==B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A=B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A==B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<=>B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<==>B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<->B"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A<--> B"), "Syntax of implication/reverse implication/equality");
ok(!BooleanExpression::is_valid_expression("A -- B"), "Syntax of implication/reverse implication/equality");
ok(!BooleanExpression::is_valid_expression("A - B"), "Syntax of implication/reverse implication/equality");
ok(!BooleanExpression::is_valid_expression("A -> B -> C"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("(A -> B) -> C"), "Syntax of implication/reverse implication/equality");
ok(!BooleanExpression::is_valid_expression("-> B"), "Syntax of implication/reverse implication/equality");
ok(!BooleanExpression::is_valid_expression("A ->"), "Syntax of implication/reverse implication/equality");
ok(!BooleanExpression::is_valid_expression("A == B == C"), "Syntax of implication/reverse implication/equality");
ok(BooleanExpression::is_valid_expression("A == (B == C)"), "Syntax of implication/reverse implication/equality");

ok(my_eval("T -> T"), "True implies True");
ok(!my_eval("T -> F"), "True does not imply False");
ok(my_eval("F -> T"), "False implies True");
ok(my_eval("F -> F"), "False implies False");

ok(my_eval("T --> T"), "True implies True");
ok(!my_eval("T --> F"), "True does not imply False");

ok(my_eval("T => T"), "True implies True");
ok(!my_eval("T => F"), "True does not imply False");

ok(my_eval("T ==> T"), "True implies True");
ok(!my_eval("T ==> F"), "True does not imply False");

ok(my_eval("T <- T"), "True implied by True");
ok(my_eval("T <- F"), "True implied by False");
ok(!my_eval("F <- T"), "False not implied by True");
ok(my_eval("F <- F"), "False implied by False");

ok(my_eval("T <-- T"), "True implied by True");
ok(!my_eval("F <-- T"), "False not implied by True");

ok(my_eval("T <= T"), "True implied by True");
ok(!my_eval("F <= T"), "False not implied by True");

ok(my_eval("T <== T"), "True implied by True");
ok(!my_eval("F <== T"), "False not implied by True");


ok(my_eval("T = T"), "True eq True");
ok(!my_eval("T = F"), "True neq False");
ok(!my_eval("F = T"), "False neq True");
ok(my_eval("F = F"), "False eq False");


ok(my_eval("T == T"), "True eq True");
ok(!my_eval("F == T"), "False neq True");

ok(my_eval("T <-> T"), "True eq True");
ok(!my_eval("F <-> T"), "False neq True");

ok(my_eval("T <--> T"), "True eq True");
ok(!my_eval("F <--> T"), "False neq True");

ok(my_eval("T <=> T"), "True eq True");
ok(!my_eval("F <=> T"), "False neq True");

ok(my_eval("T <==> T"), "True eq True");
ok(!my_eval("F <==> T"), "False neq True");

# short circuiting

dies_ok(sub{my_eval("T -> DIE")}, "if p -> q and p, then evaluates q");
ok(my_eval("F -> DIE"), "if p -> q and !p, then short circuits and skips evaluating q");

dies_ok(sub{my_eval("DIE <- T")}, "if q <- p and p, then evaluates q");
ok(my_eval("DIE <- F"), "if q <- p and !p, then short circuits and skips evaluating q");

ok(my_eval("((T && F) | (F -> T) -> ( F <- T) ) <=> (F || T && T && T && T && F)"), "Everything");
