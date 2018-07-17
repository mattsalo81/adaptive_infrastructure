use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Exceptions::ChangeEngine::Core;
use Logging;

Logging::set_level("DIAG");
Exceptions::ChangeEngine::Core::run();
