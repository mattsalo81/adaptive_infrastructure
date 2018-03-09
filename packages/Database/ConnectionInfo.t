use Test::More "no_plan";
use strict;
use lib "/dm5/ki/adaptive_infrastructure/packages";
use Database::ConnectionInfo;
use DBI;

my @info = ConnectionInfo::get_info_for("etest");
is(@info, 3, "correct format for connection info");
DBI->connect(@info) or die "could not connect to etest";

my @info = ConnectionInfo::get_info_for("sd_limits");
is(@info, 3, "correct format for connection info");
DBI->connect(@info) or die "could not connect to sd_test";

my @info = ConnectionInfo::get_info_for("sms");
is(@info, 3, "correct format for connection info");
DBI->connect(@info) or die "could not connect to sms";

my @info = ConnectionInfo::get_info_for("wcrepo");
is(@info, 3, "correct format for connection info");
DBI->connect(@info) or die "could not connect to wcrepo";

