use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use DBI;
use ONEPG::CompCount;

my $sth = CompCount::get_components_for_reticle_base_sth();
ok(defined($sth), "Successfully got statement handle");

