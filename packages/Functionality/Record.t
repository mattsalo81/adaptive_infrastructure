use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Functionality::Record;

my $r = Functionality::Record->new({TEST_MOD=>"test"});
ok(defined $r, "Constructor");

# process/lpt

my $known_tech  = "TEST";
my $known_eff   = "EFF_ROUT_1";
my $known_rout  = "A72AF3A+";
my $po_str      = "OPTION1 && OPTION2";
my $lpt_str     = "9300 <-> 0050";

$r->set("TECHNOLOGY",           $known_tech);
$r->set("PROCESS_OPTION",       "");
$r->set("LOGPOINTS",            "");
ok($r->satisfies_lpt_and_po($known_eff, $known_rout), "Null po/lpt fields");
$r->set("PROCESS_OPTION",       $po_str);
$r->set("LOGPOINTS",            $lpt_str);
ok($r->satisfies_lpt_and_po($known_eff, $known_rout), "successful fields");
$r->set("PROCESS_OPTION",       "!($po_str)");
$r->set("LOGPOINTS",            $lpt_str);
ok(!$r->satisfies_lpt_and_po($known_eff, $known_rout), "successful fields");
$r->set("PROCESS_OPTION",       $po_str);
$r->set("LOGPOINTS",            "!($lpt_str)");
ok(!$r->satisfies_lpt_and_po($known_eff, $known_rout), "successful fields");
$r->set("PROCESS_OPTION",       "!($po_str)");
$r->set("LOGPOINTS",            "!($lpt_str)");
ok(!$r->satisfies_lpt_and_po($known_eff, $known_rout), "successful fields");
