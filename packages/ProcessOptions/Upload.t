use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Decoder;
use Data::Dumper;

my $lookup = Decoder::get_effective_routings_to_routings_for_tech("LBC8");
ok(defined($lookup), "didn't die");
