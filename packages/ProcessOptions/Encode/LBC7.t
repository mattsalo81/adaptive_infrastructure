use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Encode::Global;
use Data::Dumper;

my $main_code = 2;

my $codes = Encode::Global::get_codes("LBC7");

print Dumper $codes;
ok(defined $codes, "Codes are defined");

my $main = $codes->[$main_code];

ok(defined $main, "Main code is defined");
