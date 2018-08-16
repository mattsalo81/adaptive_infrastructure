use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use WassistNST::Module;

my $mod = WassistNST::Module->new("RAW_NAME");
ok(defined $mod, "Constructor");


