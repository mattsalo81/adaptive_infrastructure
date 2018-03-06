use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use DBI;
use WCR::associate;

# can pull a wcf
throws_ok(sub{associate::get_wcf_for_coordref("I DO NOT EXIST")}, "Could not find", "nonexistant coordref");
is(associate::get_wcf_for_coordref("0301044b"), "DMOS5_3310LBC5.02LN_SN0301044B_20140407182905_wfcfg.xml", "existing coordref");
is(associate::get_wcf_for_coordref("0301044B"), "DMOS5_3310LBC5.02LN_SN0301044B_20140407182905_wfcfg.xml", "Case insensitivity");

# resolving multiple wcf
dies_ok(sub{associate::choose_latest_wcf()}, "trying to choose latest wcf from empty list");
my ($wcf1, $wcf2) = qw(DMOS5_18F05.24L_BF741698_20140407190107_wfcfg.xml DMOS5_18F05.24L_BF741698_20180201061305_wfcfg.xml);

is(associate::choose_latest_wcf($wcf1), $wcf1, "Choosing latest of list of 1");
is(associate::choose_latest_wcf($wcf1, $wcf2), $wcf2, "Choosing latest of list of 2");

my $wcf_err = "DMOS5_18F05.24L_BF741698_20140407190107_wfcfg.tar";
dies_ok(sub{associate::choose_latest_wcf($wcf_err)}, "Unrecognized filename");

$wcf_err = "DMOS5_18F05.24L_BF741698_201407190107_wfcfg.tar";
dies_ok(sub{associate::choose_latest_wcf($wcf_err)}, "Unexpected Date format");

# live test of resolving multiple wcf on same coordref
ok(associate::get_wcf_for_coordref("BF741698"), "Multiple WCF on same coordref");
