use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Functionality::Table;
use Data::Dumper;

# statement handle for populating table
my $sth = Functionality::Table::get_populate_sth();
ok(defined($sth), "get statement handle for populate");

my $known_tech = "WAV_TEST";
my $known_coord = "TCOORD1";
my $known_tg = "SIMPLE_RESOLVE";
my $known_mods = ["WAV_TEST_SIMPLE_whatever"];

my $t = Functionality::Table->new();
$t->populate($known_tech, $known_coord, $known_tg);
ok(defined $t, "constructor + db population");

ok(have_same_elements($t->get_unique_modules(), $known_mods), "Got modules from known coord");
