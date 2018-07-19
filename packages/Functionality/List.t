use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Functionality::List;

my $l = Functionality::List->new();
ok(defined $l, "Constructor");


is($l->{"SPEC_FUNC"}, "NO", "Set spec funtional");
$l->set_functional();
is($l->{"SPEC_FUNC"}, "YES", "Set spec funtional");

is($l->{"NON_FUNC"}, "NO", "Set nonfuntional");
$l->set_nonfunctional();
is($l->{"NON_FUNC"}, "YES", "Set nonfuntional");

ok(lists_identical($l->{"NON_SPEC_FUNC"}, []), "starts with no nonspec functional");
$l->add_nonspec("NSF1", 5);
ok(lists_identical($l->{"NON_SPEC_FUNC"}, [undef, undef, undef, undef, undef, "NSF1"]), "Added nonspec functional");
$l->add_nonspec("NSF1", 5);
dies_ok(sub{$l->add_nonspec("NS2", 5)}, "adding comflicting nonspec");

# NF, NSF1, and SF
ok($l->evaluate_functionality("TOP", "SF"), "is spec functional");
ok(!$l->evaluate_functionality("TOP", "!SF"), "is spec functional");
ok(!$l->evaluate_functionality("TOP", "NF"), "is NON functional");
ok(!$l->evaluate_functionality("TOP", "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("TOP", "NSF2"), "is NON-SPEC functional");
ok($l->evaluate_functionality(undef, "SF"), "is spec functional");
ok(!$l->evaluate_functionality(undef, "NF"), "is NON functional");
ok(!$l->evaluate_functionality(undef, "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality(undef, "NSF2"), "is NON-SPEC functional");
ok($l->evaluate_functionality("ANY", "SF"), "is spec functional");
ok($l->evaluate_functionality("ANY", "NF"), "is NON functional");
ok($l->evaluate_functionality("ANY", "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("ANY", "NSF2"), "is NON-SPEC functional");
ok($l->evaluate_functionality("ANY", "!NSF2"), "is NON-SPEC functional");

$l->{"SPEC_FUNC"} = "NO";
# NF, NSF1
ok(!$l->evaluate_functionality("TOP", "SF"), "is spec functional");
ok(!$l->evaluate_functionality("TOP", "NF"), "is NON functional");
ok($l->evaluate_functionality("TOP", "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("TOP", "NSF2"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality(undef, "SF"), "is spec functional");
ok(!$l->evaluate_functionality(undef, "NF"), "is NON functional");
ok($l->evaluate_functionality(undef, "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality(undef, "NSF2"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("ANY", "SF"), "is spec functional");
ok($l->evaluate_functionality("ANY", "NF"), "is NON functional");
ok($l->evaluate_functionality("ANY", "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("ANY", "NSF2"), "is NON-SPEC functional");


# NSF1
$l->{"NON_FUNC"} = "NO";
ok(!$l->evaluate_functionality("TOP", "SF"), "is spec functional");
ok(!$l->evaluate_functionality("TOP", "NF"), "is NON functional");
ok($l->evaluate_functionality("TOP", "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("TOP", "NSF2"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality(undef, "SF"), "is spec functional");
ok(!$l->evaluate_functionality(undef, "NF"), "is NON functional");
ok($l->evaluate_functionality(undef, "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality(undef, "NSF2"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("ANY", "SF"), "is spec functional");
ok(!$l->evaluate_functionality("ANY", "NF"), "is NON functional");
ok($l->evaluate_functionality("ANY", "NSF1"), "is NON-SPEC functional");
ok(!$l->evaluate_functionality("ANY", "NSF2"), "is NON-SPEC functional");

dies_ok(sub{$l->evaluate_functionality("NAY", "SF");}, "Unkown scope");
