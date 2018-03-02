use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
use SMS::extract;
use DBI;

# get_technology_from_family
is(extract::get_technology_from_family("TEST_family"), "TEST_TECH", "case insensitivity");
is(extract::get_technology_from_family("TEST_family"), "TEST_TECH", "case insensitivity");
is(extract::get_technology_from_family("I don't exist"), "UNDEF", 
				"returns string UNDEF (not undef) on entry not found");

# sms extract
my $sth = extract::get_device_extract_handle();
ok(defined($sth), "can properly get statement handle for sms extract");
$sth->execute() or die "Could not run sms extract statement handle";
my @record = $sth->fetchrow_array();
ok(@record > 0, "seeing if we get any data from sms extract");
my $format = $sth->{"NAME_uc_hash"};
ok(defined $format->{"PROGRAM"}, "seeing if we got a particular field (program)");
