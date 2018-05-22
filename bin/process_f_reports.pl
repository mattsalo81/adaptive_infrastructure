use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Logging;
use FactorySummary::Upload;
use SMS::SMSDigest;

foreach my $tech (@{SMSDigest::get_all_technologies()}){
    FactorySummary::Upload::update_technology_functional_and_limits($tech);
}
