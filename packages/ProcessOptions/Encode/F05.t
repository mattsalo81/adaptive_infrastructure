use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Encode::F05;
use Data::Dumper;


my $codes = Encode::F05::get_codes();

print Dumper $codes;
ok(defined $codes, "Codes are defined");

