use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use SMS::Extract;
use DBI;

# get_technology_from_family
is(Extract::get_technology_from_family("TEST_family"), "TEST_TECH", "case insensitivity");
is(Extract::get_technology_from_family("TEST_family"), "TEST_TECH", "case insensitivity");
is(Extract::get_technology_from_family("I don't exist"), "UNDEF", 
				"returns string UNDEF (not undef) on entry not found");

# sms Extract
my $sth = Extract::get_device_extract_handle();
ok(defined($sth), "can properly get statement handle for sms Extract");
$sth->execute() or die "Could not run sms Extract statement handle";
my @record = $sth->fetchrow_array();
ok(@record > 0, "seeing if we get any data from sms Extract");
my $format = $sth->{"NAME_uc_hash"};
ok(defined $format->{"PROGRAM"}, "seeing if we got a particular field (program)");


# COT
my $record = {
	PROD_GRP	=>	'this is a COT device',
};
is(Extract::get_COT_from_record($record), 'Y', "Identifying COT devices by product group");
my $record = {
	PROD_GRP	=>	'this is not a SEE OH TEE device',
};
is(Extract::get_COT_from_record($record), 'N', "Identifying not-COT devices by product group");
my $record = {
	PRODuct_GRoup	=> 	'this is a bad record',
};
dies_ok(sub {Extract::get_COT_from_record($record)}, "Testing invalid records");

# clean_text
is(Extract::clean_text("routing"), "routing", "Cleaning text");
is(Extract::clean_text(""), "", "Cleaning empty text");
is(Extract::clean_text("Routing-./+"), "Routingdesp", "Cleaning text");
throws_ok(sub{Extract::clean_text("Routing-./+^D!@#\$\%^&*|\\??(")}, "clean", "Dies on undefined special characters");

# make recipe
is(Extract::make_recipe("FAM", "ROUT", "PROG"), "FAM__ROUT__PROG", "Able to make recipe");
is(Extract::make_recipe("FAM", "ROUT.", "PROG"), "FAM__ROUTe__PROG", "Cleans routing only");
dies_ok(sub{Extract::make_recipe("", "ROUT.", "PROG")}, "dies on empty inputs");
dies_ok(sub{Extract::make_recipe("FAM", "", "PROG")}, "dies on empty inputs");
dies_ok(sub{Extract::make_recipe("FAM", "ROUT.", "")}, "dies on empty inputs");
dies_ok(sub{Extract::make_recipe("FAM", "ROUT.!@#\$\%^&*(){}||\\][+_=-i\":';<>?.,/", "PROG")}, "dies on bad routings");

# get area from lpt opn

is(Extract::get_area_from_lpt_and_opn("9300", "8820"), "PARAMETRIC", "ability to check test area from logpoints");
is(Extract::get_area_from_lpt_and_opn("9999", "8820"), "UNDEF", "ability to check test area from logpoints");

# get parametric lpts and opns
my ($lpt, $opn) = Extract::get_parametric_logpoints_operations();
ok(scalar @{$lpt} > 0, "able to pull list of parametric logpoints");
ok(scalar @{$opn} > 0, "able to pull list of parametric operations");
