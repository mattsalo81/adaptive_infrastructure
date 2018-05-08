use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use DBI;
use SMS::Photomasks;

my $device = "M06ECDC65310C1";
my $known_photomask = "E685-001";
my $photomasks;

ok(defined Photomasks::get_photomasks_for_device_sth(), "STH generator returns something");

# see if we can get a known photomask from a known device
ok($photomasks = Photomasks::get_photomasks_for_device($device), "Sucessfully Ran code, and didn't die");

my $photomask_found = "";
foreach my $photomask (@{$photomasks}){
    if ($photomask eq $known_photomask){
        $photomask_found = $photomask;
    }
}

is ($photomask_found, $known_photomask, "Found expected photomask in <" . join(", ", @{$photomasks}) . ">");

