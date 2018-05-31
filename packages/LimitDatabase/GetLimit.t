use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use LimitDatabase::GetLimit;
use Data::Dumper;

# resolve limits table


my $limits = GetLimit::get_all_limits("LBC5", "PARAMETRIC__A72AF3BS-X", "M06CF140XXA0", "M06ECF140XXA1S");
print Dumper($limits);
