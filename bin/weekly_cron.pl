use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Logging;
use Email::RedirectToEmail;
use ProcessOptions::ProcessEncoder;
use Components::ComponentPopulator;
use WCR::Associate;

RedirectToEmail::set_emails('d5pgtechs@list.ti.com');

ProcessEncoder::update_codes_for_all_techs();
ComponentPopulator::update_components();
WCR::Associate::update_lookup_table();
