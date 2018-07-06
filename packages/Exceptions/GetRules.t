use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Data::Dumper;
use Exceptions::GetRules;

my $known_exception = 0;
my $known_inactive  = 1;

my $exceptions = Exceptions::GetRules::get_all_active_exceptions();
ok(in_list($known_exception, $exceptions), "Retreives known exception");
ok(!in_list($known_inactive, $exceptions), "Doesn't Retreive known Inactive exception");