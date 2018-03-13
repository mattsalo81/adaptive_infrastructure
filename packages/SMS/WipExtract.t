use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use DBI;
use SMS::WipExtract;

my $sth = WipExtract::get_wip_query() or die "Could not get wip query";
ok(defined $sth, "wip query is defined");
$sth->execute() or die "Could not execute wip query";
my $ref = $sth->fetchrow_hashref("NAME_uc");
ok(defined $ref->{"LOT"}, "got a lot using the wip query"); 
