use Test::More "no_plan";
use strict;
use lib "/dm5/ki/adaptive_infrastructure/packages";
use DATABASE::connect;

ok( defined(connect::read_only_connection("sd_limits")), 
	"Checking if can connect to sd_limits");
my $conn1 = connect::read_only_connection("sd_limits");
my $conn2 = connect::read_only_connection("sd_limits");
is($conn1, $conn2, "See if multiple connections are same objects");

my $trans1 = connect::new_transaction("sd_limits");
my $trans2 = connect::new_transaction("sd_limits");
ok(defined $trans1 && defined $trans2, "can create transactions");
ok($trans1 != $trans2, "transactions are unique");
