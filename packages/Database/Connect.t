use Test::More "no_plan";
use strict;
use lib "/dm5/ki/adaptive_infrastructure/packages";
use Database::Connect;

ok( defined(Connect::read_only_connection("sd_limits")), 
    "Checking if can Connect to sd_limits");
my $conn1 = Connect::read_only_connection("sd_limits");
my $conn2 = Connect::read_only_connection("sd_limits");
is($conn1, $conn2, "See if multiple Connections are same objects");

my $trans1 = Connect::new_transaction("sd_limits");
my $trans2 = Connect::new_transaction("sd_limits");
ok(defined $trans1 && defined $trans2, "can create transactions");
ok($trans1 != $trans2, "transactions are unique");
