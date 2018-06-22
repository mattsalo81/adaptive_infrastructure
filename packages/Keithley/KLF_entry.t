use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::KLF_entry;
use Data::Dumper;

my $l = KLF_entry->new("Parameter");

# enable/disable
$l->set_test(1);
ok($l->is_enabled(), "Test enabled");
$l->set_test(0);
ok(!$l->is_enabled(), "Test Disabled");
$l->set_test(1);
ok($l->is_enabled(), "Test enabled");
