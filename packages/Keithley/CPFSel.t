use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::CPFSel;
use Data::Dumper;

my $test_tech = 'TEST';
my $test_rule = 0;
my $test_base = 'base';

# rule getting
my $rules = Keithley::CPFSel::get_rules_for_tech($test_tech);
is($rules->[$test_rule]->{"CPF_BASE"}, $test_base, "Found known rule");
my $prev = -1;
foreach my $rule (@{$rules}){
    ok($prev < $rule->{"PRIORITY"}, "Priorities pulled in order");
    $prev = $rule->{"PRIORITY"};
}

# rule eval
my $sms = {
    TECHNOLOGY          => "TEST",
    EFFECTIVE_ROUTING   => "EFF_ROUT_2",
};
my $mod_list = [];
is(Keithley::CPFSel::get_cpf_for_sms_record_and_mods($sms, $mod_list), "base", "Catchall with no rules");
$mod_list = [q(MOD1)];
is(Keithley::CPFSel::get_cpf_for_sms_record_and_mods($sms, $mod_list), "cpf2", "Overide catchall with cp2");
$sms->{"EFFECTIVE_ROUTING"} = "EFF_ROUT_1";
is(Keithley::CPFSel::get_cpf_for_sms_record_and_mods($sms, $mod_list), "cpf1", "Override cpf2 and catchall with cpf1");
$sms->{"TECHNOLOGY"} = "NONEXIST";
dies_ok(sub{Keithley::CPFSel::get_cpf_for_sms_record_and_mods($sms, $mod_list)}, "Unresolved cpf");

