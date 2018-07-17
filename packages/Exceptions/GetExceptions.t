use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Exceptions::GetExceptions;

my $sth = GetExceptions::get_exceptions_sth();
ok(defined $sth, "get statement handle");

$sth = GetExceptions::get_exception_nums_sth();
ok(defined $sth, "get statement handle");

my $known_ex = 0;
my $known_dev = "TEST_DEV";
my $known_lpt = 0000;
my $known_opn = 0000;

my $ex = GetExceptions::for_exception_number($known_ex);
is(scalar @{$ex}, 1, "got known exception");
is($ex->[0]->{"DEVICE"}, $known_dev, "correct device");
is($ex->[0]->{"LPT"},    $known_lpt, "correct lpt");
is($ex->[0]->{"OPN"},    $known_opn, "correct opn");

my $ex_nums = GetExceptions::get_all_exception_numbers();
ok(in_list($known_ex, $ex_nums), "Found known exception number");
