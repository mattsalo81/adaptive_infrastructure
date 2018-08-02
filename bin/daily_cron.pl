use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Email::RedirectToEmail;
use Logging;
use SMS::SpecExtract;
use SMS::WipExtract;
use ProcessOptions::Decoder;
use SMS::SMSDigest;
use Components::ComponentXref;
use Components::ComponentPopulator;
use FactorySummary::Upload;
use Exceptions::RuleEngine;
use Exceptions::ChangeEngine::Core;

RedirectToEmail::set_emails('d5pgtechs@list.ti.com');

SpecExtract::update_sms_table();
WipExtract::update_wip_extract();
foreach my $tech (@{SMSDigest::get_all_technologies()}){
    Decoder::upload_effective_routing_options_for_tech($tech);
}
ComponentXref::update_component_info();
ComponentPopulator::update_effective_component_info();
foreach my $tech (@{SMSDigest::get_all_technologies()}){
    FactorySummary::Upload::update_technology_info_functional_and_limits($tech);
}
RuleEngine::run();
Exceptions::ChangeEngine::Core::run();
