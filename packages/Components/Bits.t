use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Components::Bits;

# STh
ok(Bits::get_undefined_sth(), "Got fully defined statement handle");
ok(Bits::get_bits_sth(), "Got fully defined statement handle");

# bit cleaning
my $bits = [3, 2, 1, 0, -1, -2, -3, 10];
my $good_bits = [3, 2, 1, 10];
my $cleaned_bits = Bits::remove_zero_or_negative_bits($bits);

ok(lists_identical($cleaned_bits, $good_bits), "Successfully cleaned bits from mixed list");
ok(lists_identical(Bits::remove_zero_or_negative_bits([]), []), "Zero width array okay");

# get_undefined_components_on_device
my $test_tech = 'TEST';
my $test_device_known = 'DEV2';
my $test_device_unknown = "DEV3";
my $unknown = ['NOT REAL COMP'];
my $bit_list = [22, 23];

my $undefined = Bits::get_undefined_components_on_device($test_tech, $test_device_known);
ok(lists_identical($undefined, []), "No missing components found on fully defined device");

$undefined = Bits::get_undefined_components_on_device($test_tech, $test_device_unknown);
ok(lists_identical($undefined, $unknown), "missing components found on undefined device");

#sub get_bits_for_device{
$bits = Bits::get_bits_for_device($test_tech, $test_device_known);
ok(lists_identical($bits, $bit_list), "Found correct bits on known device");

throws_ok(sub{Bits::get_bits_for_device($test_tech, $test_device_unknown)}, $Bits::not_associated_error, "Dies if component->bit not defined");
throws_ok(sub{Bits::get_bits_for_device($test_tech, "NOT A REAL THING")}, $Bits::no_comp_error, "Dies if device does not have components in the system");
