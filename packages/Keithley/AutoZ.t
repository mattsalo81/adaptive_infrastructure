use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::AutoZ;

my $known_tech  = 'TEST';
my $known_area  = 'TEST';
my $known_autoz = 'TEST';
ok( Keithley::AutoZ::is_autoz_module($known_tech, $known_area, $known_autoz), "Found known module");
ok(!Keithley::AutoZ::is_autoz_module("I DO NOT EXIST", $known_area, $known_autoz), "Found non-autoz module");
ok(!Keithley::AutoZ::is_autoz_module($known_tech, "I DO NOT EXIST", $known_autoz), "Found non-autoz module");
ok(!Keithley::AutoZ::is_autoz_module($known_tech, $known_area, "I DO NOT EXIST"), "Found non-autoz module");
