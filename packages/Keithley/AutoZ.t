use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::AutoZ;

my $known_tech  = 'TEST';
my $known_area  = 'TEST';
my $known_autoz = 'AUTO';
my $known_not_autoz = 'NO_AUTO';
ok( Keithley::AutoZ::is_autoz_module($known_tech, $known_area, $known_autoz), "Found known module");
ok(!Keithley::AutoZ::is_autoz_module($known_tech, $known_area, $known_not_autoz), "Found known module");
dies_ok(sub{Keithley::AutoZ::is_autoz_module("I DO NOT EXIST", $known_area, $known_autoz)}, "undefined tech");
dies_ok(sub{Keithley::AutoZ::is_autoz_module($known_tech, "I DO NOT EXIST", $known_autoz)}, "Undefined area");
dies_ok(sub{Keithley::AutoZ::is_autoz_module($known_tech, $known_area, "I DO NOT EXIST")}, "Undefined module");
