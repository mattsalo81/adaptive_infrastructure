use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use DBI;
use SMS::Reticles;

my $device = "M06ECDC65310C1";
my $known_reticle = "E685-001";
my $reticles;

ok(defined Reticles::get_reticles_for_device_sth(), "STH generator returns something");

# see if we can get a known reticle from a known device
ok($reticles = Reticles::get_reticles_for_device($device), "Sucessfully Ran code, and didn't die");

my $reticle_found = "";
foreach my $reticle (@{$reticles}){
	if ($reticle eq $known_reticle){
		$reticle_found = $reticle;
	}
}

is ($reticle_found, $known_reticle, "Found expected reticle in <" . join(", ", @{$reticles}) . ">");

