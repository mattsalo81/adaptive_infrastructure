package Keithley::CPFSel;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Parse::BooleanExpression;

my $rules_sth;
my %rules_for_tech;

sub get_cpf_for_sms_record_and_mods{
    my ($sms, $mod_list) = @_;
    my $rules = get_rules_for_tech($sms->{"TECHNOLOGY"});
    my $cpf;
    foreach my $rule (@{$rules}){
        if(verify_rule($sms, $mod_list, $rule)){
            $cpf = $rule->{"CPF_BASE"};
            Logging::debug("using $cpf") if defined $cpf;
        }
    }
    confess "No valid rule for CPF on " . Dumper($sms) . " and " . Dumper($mod_list) unless defined $cpf;
    return $cpf;
}

sub verify_rule{
    my ($sms, $mod_list, $rule) = @_;
    my $tech = $sms->{"TECHNOLOGY"};
    my $eff_rout = $sms->{"EFFECTIVE_ROUTING"};
    my $opt_str = $rule->{"PROCESS_OPTIONS"};
    if((defined $opt_str) && $opt_str ne ""){
        return 0 unless BooleanExpression::does_effective_routing_match_expression_using_database($tech, $eff_rout, $opt_str);
    }
    my $mod_str = $rule->{"MODULE_RULE"};
    if((defined $mod_str) && $mod_str ne ""){
        return 0 unless BooleanExpression::does_opt_list_match_opt_string($mod_list, $mod_str);
    }
    return 1;
}

sub get_rules_for_tech{
    my ($tech) = @_;
    unless (defined $rules_for_tech{$tech}){
        my $sth = get_rules_sth();
        $sth->execute($tech);
        my @rules;
        while (my $rec = $sth->fetchrow_hashref("NAME_uc")){
            push @rules, $rec;
        }
        $rules_for_tech{$tech} = \@rules;
    }
    return $rules_for_tech{$tech};
}

sub get_rules_sth{
    unless(defined $rules_sth){
        my $conn = Connect::read_only_connection('etest');
        my $sql = q{
            select
                *
            from
                cpf_rules
            where
                technology = ?
            order by
                priority
        };
        $rules_sth = $conn->prepare($sql);
    }
    unless(defined $rules_sth){
        confess "Could not get rules_sth";
    }
    return $rules_sth;
}

1;
