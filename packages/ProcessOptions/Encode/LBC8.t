use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Encode::LBC8;
use Data::Dumper;

my $three_char = 2;
my $char_4 = 3;

my $codes = Encode::LBC8::get_codes();

print Dumper $codes;
ok(defined $codes, "Codes are defined");

$three_char = $codes->[$three_char];
$char_4 = $codes->[$char_4];

ok(defined $three_char, "three_char code is defined");
ok(defined $char_4, "optional fourth char code is defined");
