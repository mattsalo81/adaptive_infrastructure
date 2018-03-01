use Test::More "no_plan";
use strict;
use lib "/dm5/ki/adaptive_infrastructure/packages";
use DATABASE::connection_info;

# copy my ENV
my %ENV_ORIGINAL = %ENV;

my @info = connection_info::get_info_for("sd_limits");
is(@info, 3, "correct format for connection info");
is($info[0], 'dbi:Oracle:d5pdedb', "correct database for pde");

is(%ENV, %ENV_ORIGINAL, "checking if ENV has changed in size");

