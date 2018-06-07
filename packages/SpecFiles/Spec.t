use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SpecFiles::Spec;

my $spec = Spec->new();
ok(defined $spec, "got a blank specfile");
is(ref($spec), "Spec", "Specfile object of type Spec");

$spec->add_horizontal_rule();
$spec->add_entry(["parm", 1, "100", "200", 1, 2]);
print $spec->get_text();

