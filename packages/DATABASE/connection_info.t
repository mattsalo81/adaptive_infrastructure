use Test::More "no_plan";
use strict;
use lib "/dm5/ki/adaptive_infrastructure/packages";
use DATABASE::connection_info;
use DBI;

my @info = connection_info::get_info_for("sd_limits");
is(@info, 3, "correct format for connection info");
DBI->connect(@info) or die "could not connect to sd_limits";

my @info = connection_info::get_info_for("sms");
is(@info, 3, "correct format for connection info");
DBI->connect(@info) or die "could not connect to sms";

