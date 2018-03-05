use warnings;
use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception; 

dies_ok(sub {die "dies"}, "can we die okay");
throws_ok(sub {die "error message"}, 'mess', "can we catch a specific error");
