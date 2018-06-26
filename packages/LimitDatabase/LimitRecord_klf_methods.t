use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use LimitDatabase::LimitRecord;

# disabled
my $l;
$l = LimitRecord->new_from_hash({DEACTIVATE=>"N"});
ok(!$l->is_disabled(), "DEACTIVATE = N, enabled");
$l = LimitRecord->new_from_hash({DEACTIVATE=>"Y"});
ok($l->is_disabled(), "DEACTIVATE = Y, disabled");
$l = LimitRecord->new_from_hash({DEACTIVATE=>undef});
ok(!$l->is_disabled(), "DEACTIVATE = undef, enabled");
$l = LimitRecord->new_from_hash({DEACTIVATE=>"UNKOWN"});
dies_ok(sub{$l->is_disabled()}, "DEACTIVATE = UNKOWN, dies");

# mapping
$l = LimitRecord->new_from_hash({REPROBE_MAP=>undef});
ok(!$l->uses_immediate_map(), "undef map");
$l = LimitRecord->new_from_hash({REPROBE_MAP=>"ALT"});
ok($l->uses_immediate_map(), "ALT map");
$l = LimitRecord->new_from_hash({REPROBE_MAP=>""});
ok(!$l->uses_immediate_map(), "blank map");
$l = LimitRecord->new_from_hash({REPROBE_MAP=>"REPORBE"});
dies_ok(sub{$l->uses_immediate_map()}, "'REPORBE' map");

# creating an entry
my $text;
my $entry;
my $template = {
    ETEST_NAME                  => "PARAMETER_1",
    DEACTIVATE                  => "N",
    SAMPLING_RATE               => 'RANDOM',
    DISPO                       => "N",
    PASS_CRITERIA_PERCENT       => 80,
    REPROBE_MAP                 => undef,
    DISPO_RULE                  => "OPAP",
    SPEC_UPPER                  => 10,
    SPEC_LOWER                  => -10,
    REVERSE_SPEC_LIMIT          => "N",
    RELIABILITY                 => "N",
    RELIABILITY_UPPER           => 1,
    RELIABILITY_LOWER           => -1,
    REVERSE_RELIABILITY_LIMIT   => 'N',
    BIT                         => undef,
};

$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();

my $expected = q{ID,PARAMETER_1
NAM,PARAMETER_1
CAT,t0
AF,0
AL,0
VAL,-9e+99,9e+99
SPC,-9e+99,9e+99
CNT,-9e+99,9e+99
ENG,-9e+99,9e+99
ena,1
<EOL>
};
is($text, $expected, "Got expected default limit");

$template->{"DISPO"} = "Y";
$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();
ok($text =~ m/\nCAT,t1/, "SPEC gets reported to testware");
ok($text =~ m/\nSPC,-10,10/, "Limits set to SPC");

$template->{"RELIABILITY"} = "Y";
$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();
ok($text =~ m/\nSPC,-1,1/, "Limits set to REL");

$template->{"SAMPLING_RATE"} = "5 SITE";
$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();
ok($text =~ m/\ncla,WASNRPT/, "set to WASNRPT on 5 site");

$template->{"SAMPLING_RATE"} = "9 SITE";
$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();
ok($text =~ m/\ncla,MAPNRPT/, "set to MAPNRPT on 9 site");

$template->{"REPROBE_MAP"} = "MAP";
$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();
ok($text =~ m/\ncla,MAP\n/, "set to MAPNRPT on 9 site with REPEAT");

$template->{"DEACTIVATE"} = "Y";
$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();
ok($text =~ m/\nusr1,N\n/, "Disabled the Limit");

$template->{"BIT"} = "12";
$l = LimitRecord->new_from_hash($template);
$entry = $l->get_klf_entry();
$text = $entry->get_text();
ok($text =~ m/\nusr2,12\n/, "set bit");

