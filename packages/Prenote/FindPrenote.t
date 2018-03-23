use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use Prenote::FindPrenote;
use Data::Dumper;

is(FindPrenote::get_coordref_from_prenote("/dm5pde_webdata/dm5pde/setup/1052yy/1052yy.201001050944.txt"), "T3664WY2", "Extracts from prenote okay");
is(FindPrenote::get_coordref_from_prenote("/dm5pde_webdata/dm5pde/setup/1050sdfasdfasdf1001050944.txt"), undef, "Returns undef on errors");
is(FindPrenote::get_coordref_from_prenote("/dm5pde_webdata/dm5pde/setup/2008canx/2008canx.txt"), undef, "Returns undef on errors");

my $coords = FindPrenote::get_coordrefs_from_prenote_dir("/dm5pde_webdata/dm5pde/setup/1052yy", "1052yy");
is(scalar @{$coords}, 1, "found all coordrefs");
is($coords->[0], "T3664WY2", "found correct coordref");

$coords = FindPrenote::get_coordrefs_from_prenote_dir("/dm5pde_webdata/dm5pde/setup/1050sdfaasdf", "1050asdfjasdf");
is(scalar @{$coords}, 0, "found all coordrefs");

ok(1);
