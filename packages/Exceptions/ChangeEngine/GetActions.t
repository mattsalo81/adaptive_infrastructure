use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Exceptions::ChangeEngine::GetActions;

my $sth =  Exceptions::ChangeEngine::GetActions::get_limits_sth();
ok(defined $sth, "get statement handle");

my $known_exception_number = 1;
my $known_action_numbers = [0];

my $actions = Exceptions::ChangeEngine::GetActions::for_limits($known_exception_number);
my $exp_num = scalar @{$known_action_numbers};
is(scalar @{$actions}, $exp_num, "found $exp_num action(s) on exception $known_exception_number");
for(my $i = 0; $i < $exp_num; $i++){
    my $action = $actions->[$i];
    my $num = $known_action_numbers->[$i];
    is($action->{"ACTION_NUMBER"}, $num, "retreive $num action");
}
