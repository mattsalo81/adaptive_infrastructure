use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Components::DeviceString;

my $test_tech = "TEST";
my $test_dev = "PROG2";
my $test_undef_dev = "PROG3";
my $test_string = "AAAGA";
my $test_undef_comp = "FUNCTIONAL COMP";

# val2char

is(DeviceString::val2char(0), 'A', "Successfully converted a value to a device string character");
is(DeviceString::val2char(1), 'B', "Successfully converted a value to a device string character");
dies_ok(sub{DeviceString::val2char(-1)}, "Dies on OOB error for device string");
dies_ok(sub{DeviceString::val2char(1000)}, "Dies on OOB error for device string");

# device string from bits
my $string;

$string = DeviceString::convert_bits_to_device_string([]);
is($string, "A", "Empty device string is all As");

$string = DeviceString::convert_bits_to_device_string([1, 2, 3, 4, 5, 6]);
is($string, "/A", "Full device char is /");

$string = DeviceString::convert_bits_to_device_string([1, 7, 13, 19, 25, 31]);
is($string, "ggggggA", "six 100000s");

dies_ok(sub{DeviceString::convert_bits_to_device_string([1..1000])}, "cannot handle huge arrays");

# device strings overall

$string = DeviceString::get_device_string($test_tech, $test_dev);
is($string, $test_string, "Successfully generated test device string");

$string = DeviceString::get_device_string($test_tech, "NOT REAL");
ok($string =~ m/^\/+$/, "Not real device -> all ///////");

throws_ok(sub{DeviceString::get_device_string($test_tech, $test_undef_dev)}, $test_undef_comp, "Dies and lists failing component");

