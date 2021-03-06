use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SMS::SMSDigest;
use Data::Dumper;

my $known_tech = 'LBC5';
my $known_device = "M06ECDC65310C1"; # must be active and in known_tech
my $known_eff_rout = "LBC5_PARAMETRIC_3_BE";
my $known_prog = "M06CDC65310C0";

my $everything = SMSDigest::get_all_records();
ok(defined($everything), "Got all records (or something)");
my @all_devices = map {$_->{"DEVICE"}} @{$everything};
ok(in_list($known_device, \@all_devices), "Found $known_device in list of all records");

my $active = SMSDigest::get_all_records();
ok(defined($active), "Got all active records (or something)");
@all_devices = map {$_->{"DEVICE"}} @{$active};
ok(in_list($known_device, \@all_devices), "Found $known_device in list of all active records");

my $techs = SMSDigest::get_all_technologies();
ok(defined($techs), "Got something");
ok(in_list($known_tech, $techs), "Found $known_tech, at least");

my $dev = SMSDigest::get_all_devices();
ok(defined ($dev), "Got some devices");
ok(in_list($known_device, $dev), "Found $known_device in list");

$dev = SMSDigest::get_all_devices_in_tech($known_tech);
ok(defined ($dev), "Got some device for $known_tech");
ok(in_list($known_device, $dev), "Found $known_device in list from $known_tech");

$dev = SMSDigest::get_all_active_devices();
ok(defined ($dev), "Got some devices");
ok(in_list($known_device, $dev), "Found $known_device in active list");

$dev = SMSDigest::get_all_active_devices_in_tech($known_tech);
ok(defined ($dev), "Got some device for $known_tech");
ok(in_list($known_device, $dev), "Found $known_device in active list for $known_tech");

my $eff = SMSDigest::get_all_effective_routings_in_tech($known_tech);
ok(defined ($eff), "Got some device for $known_tech");
ok(in_list($known_eff_rout, $eff), "Found $known_eff_rout in active list for $known_tech");

my $rec = SMSDigest::get_entries_for_tech("$known_tech");
ok(scalar @{$rec} > 100, "Found at least 100 records for $known_tech");
is($rec->[0]->{"TECHNOLOGY"}, $known_tech, "NAME_uc hash format used");

$dev = SMSDigest::get_all_devices_for_prog($known_tech, $known_prog);
ok(in_list($known_device, $dev), "Found known device on known program");
