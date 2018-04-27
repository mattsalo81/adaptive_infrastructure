use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Components::ComponentXref;
use Logging;

Logging::set_level("DEBUG");
ComponentXref::update_component_info();
