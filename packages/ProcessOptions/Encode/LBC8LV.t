use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Encode::Global;
use Data::Dumper;

my $codes = Encode::Global::get_codes("LBC8LV");

print Dumper $codes;
ok(defined $codes, "Codes are defined");

ok(defined $codes->[2], "First char is defined");
ok(defined $codes->[3], "Second char is defined");
ok(defined $codes->[4], "Third char is defined");
ok(defined $codes->[5], "Fourth char is defined");
