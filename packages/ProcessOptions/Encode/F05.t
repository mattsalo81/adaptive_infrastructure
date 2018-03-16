use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Encode::Global;
use Data::Dumper;


my $codes = Encode::Global::get_codes("F05");

print Dumper $codes;
ok(defined $codes, "Codes are defined");

