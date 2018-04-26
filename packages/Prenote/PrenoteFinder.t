use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Prenote::PrenoteFinder;

my $known_device = 'M2HREAFE8310C3';
my $known_prenote = 'AFE8310C3';

my $man_device = 'TEST_DEVICE';
my $man_prenote = 'TEST_PRENOTE';

my $prenotes;

$prenotes = PrenoteFinder::get_prenote_from_pde_db($known_device);
ok(in_list($known_prenote, $prenotes), "Found known prenote from pdedb");

$prenotes = PrenoteFinder::get_prenote_from_etest_db($man_device);
ok(in_list($man_prenote, $prenotes), "Found known manually configure prenote from etestdb");

my $folders = PrenoteFinder::find_prenotes_for_device($known_device);
ok(scalar keys %{$folders} > 0, "Found a prenote directory for a known device");

