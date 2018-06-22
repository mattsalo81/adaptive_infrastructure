use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::KLF_entry;
use Data::Dumper;

my $l = KLF_entry->new("Parameter");

# enable/disable
ok(!$l->is_enabled(), "Limit starts off disabled");
$l->set_test(1);
ok($l->is_enabled(), "Test enabled");
$l->set_test(0);
ok(!$l->is_enabled(), "Test Disabled");
$l->set_test(1);
ok($l->is_enabled(), "Test enabled");

# bits
ok(!defined($l->get_bit()), "Limit starts without a bit");
foreach my $bit (qw( 1 10 100 2 235)){
    $l->set_bit($bit);
    is($l->get_bit(), $bit, "Bit set successfully");
} 
$l->set_bit();

# sampling
is($l->get_num_sites(), 1, "Limit starts off at MON sites");
foreach my $num (qw(5 1 5 9 1 0)){
    $l->set_num_sites($num);
    is($l->get_num_sites(), $num, "Set num sites");
}
$l->set_test(1);
dies_ok(sub {$l->set_num_sites(2)}, "weird num site");

# limits
foreach my $type (qw(v VaL VALId e ENG EnginEEring s SPC SPec C ctl ContROL)){
    foreach my $ll (qw(-1 1 -1e10)){
        foreach my $ul (qw(-1 1 1e10)){
            $l->set_limits($type, $ll, $ul);
            my ($nll, $nul) = $l->get_limits($type);
            is($nll, $ll, "lower limit for $type set");
            is($nul, $ul, "upper limit for $type set");
        }
    }
}

# reporting
ok(!$l->is_reporting_on_ms_screen(), "starts off not reporting data to ms");
$l->set_reporting_on_ms_screen(1);
ok($l->is_reporting_on_ms_screen(), "reporting data to ms");
$l->set_reporting_on_ms_screen(0);
ok(!$l->is_reporting_on_ms_screen(), "not reporting data to ms");



