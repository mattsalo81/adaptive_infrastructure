use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Functionality::Valid;

my $sth = Functionality::Valid::get_check_coordref_sth();
ok(defined $sth, "check coordref sth");
$sth = Functionality::Valid::get_check_test_group_sth();
ok(defined $sth, "check testgroup sth");

my $known_tech = "WAV_TEST";
my $known_bad_tg = "INCOMPLETE_RESOLVE";
my $known_good_tg = "SIMPLE_RESOLVE";

ok(Functionality::Valid::check_test_group($known_tech, $known_good_tg), "Known good test group $known_good_tg");
ok(!Functionality::Valid::check_test_group($known_tech, $known_bad_tg), "Known bad test group $known_bad_tg");

my $known_good_cr = "TCOORD1";
my $known_bad_cr = "IDONOTEXIST";

ok( Functionality::Valid::check_coordref($known_tech, $known_good_cr), "Known good Coordref");
ok(!Functionality::Valid::check_coordref($known_tech, $known_bad_cr), "Known bad Coordref");

