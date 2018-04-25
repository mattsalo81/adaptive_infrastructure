use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Components::ComponentPopulator;
use Logging;

Logging::set_level("DEBUG");
ComponentPopulator::update_components();
