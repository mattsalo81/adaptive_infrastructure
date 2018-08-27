use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::RecipeGen;
use SMS::SMSDigest;

my ($tech, $use_archive) = @ARGV;

my $sms_records = SMSDigest::get_recipe_gen_info_for_tech($tech);

Keithley::RecipeGen::generate_recipes($sms_records, '', $use_archive);

