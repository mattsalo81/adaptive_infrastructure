use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Database::Connect;

# checks if etest database is configured to read from current transaction or from committed info only

my $trans = Connect::new_transaction('etest');
# select
my $sel_sql = q{select * from trans_test};
my $sel_sth = $trans->prepare($sel_sql);
$sel_sth->execute();
my $result = $sel_sth->fetchall_arrayref();
my $num_orig = scalar @{$result};


# insert
my $ins_sql = q{insert into trans_test (my_data) values ('TESTING')};
my $ins_sth = $trans->prepare($ins_sql);
$ins_sth->execute();

# select again
$sel_sth->execute();
$result = $sel_sth->fetchall_arrayref();
my $num_new = scalar @{$result};

is($num_new, $num_orig + 1, "Finds a record added by current, uncommitted transaction");

$trans->rollback();

