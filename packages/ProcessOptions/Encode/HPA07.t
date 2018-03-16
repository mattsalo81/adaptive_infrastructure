use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Encode::HPA07;
use Data::Dumper;

my $main_code = 2;
my $flavor_code = 3;
my $isoj_code = 4;

my $codes = Encode::HPA07::get_codes();

print Dumper $codes;
ok(defined $codes, "Codes are defined");

my $main = $codes->[$main_code];
my $flavor = $codes->[$flavor_code];
my $isoj = $codes->[$isoj_code];
ok(defined $main, "Main code is defined");
ok(defined $flavor, "flavor is defined");
ok(defined $isoj, "isoj is defined");

