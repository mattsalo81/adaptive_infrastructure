use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use FactorySummary::Upload;
use Database::Connect;
use LimitDatabase::LimitRecord;

my $trans = Connect::new_transaction("etest");
ok(defined FactorySummary::Upload::get_insert_info_sth($trans), "got sth for parm info");
ok(defined FactorySummary::Upload::get_insert_functional_sth($trans), "got sth for functional parms");
ok(defined FactorySummary::Upload::get_insert_limit_sth($trans), "got sth for limits db");

my $info = [
    {
        TECHNOLOGY      => "TEST",
        ETEST_NAME      => "TEST",
        ETEST_NAME      => "TEST",
    },
];
my $limits = 
[
    bless {
        TECHNOLOGY      => "TEST",
        TEST_AREA       => "TEST",
        ITEM_TYPE       => "TECHNOLOGY",
        ITEM            => "TEST",
        ETEST_NAME      => "TEST",
        PRIORITY        => 0,
    }, "LimitRecord",
];

my $functional = 
[
    {
        TECHNOLOGY              => "TEST",
        TEST_AREA               => "TEST",
        EFFECTIVE_ROUTING       => "TEST",
        ETEST_NAME              => "TEST",
    },
];
ok(FactorySummary::Upload::update_parm_info_list($trans, "TEST", $info), "parm_info updated, not committed");
ok(FactorySummary::Upload::update_limit_list($trans, "TEST", $limits), "limits updated, not committed");
ok(FactorySummary::Upload::update_functional_list($trans, "TEST", $functional), "functional updated, not committed");

$trans->rollback();
