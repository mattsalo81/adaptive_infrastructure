use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use DBI;
use ONEPG::Reticles;


is(Reticles::convert_photomask_to_reticle(" E662-336"),"6408662336", "Successfully converted photomask");
is(Reticles::convert_photomask_to_reticle("662-336 "),"6401662336", "Successfully converted photomask, trailing whitespace");
dies_ok(sub{Reticles::convert_photomask_to_reticle("ASDF")}, "Successfully recognizes unexpected formats");
