use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::LogpointOptions;

# dependent on TEST cases defined in the SQL config for the table
my @opts = sort @{LogpointOptions::get_all_options_for_tech("TEST")};
is(scalar @opts, 4, "Gets correct number of process options");
is($opts[0], "DANG", "gets correct options");
is($opts[1], "NICE", "gets correct options");
is($opts[2], "SHAZAM", "gets correct options");
is($opts[3], "WOW", "gets correct options");

