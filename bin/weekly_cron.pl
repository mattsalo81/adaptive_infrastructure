use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Logging;
use Email::RedirectToEmail;
use ProcessOptions::ProcessEncoder;
use Components::ComponentPopulator;

ProcessEncoder::update_codes_for_all_techs();
ComponentPopulator::update_components();
