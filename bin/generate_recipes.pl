use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::RecipeGen;
use SMS::SMSDigest;

my ($tech, $use_archive) = @ARGV;

unless (defined $tech){
    die usage() . "\n";
}

my $sms_records = SMSDigest::get_recipe_gen_info_for_tech($tech);

Keithley::RecipeGen::generate_recipes($sms_records, ['', '-R', 'ALL'], $use_archive);

sub usage{
    return qq{
        Usage : `perl $0 <TECHNOLOGY> [use_archive]`

        Generates standard, -R, and ALL site recipes for all active devices with active WIP for given technology.
        by default, files are fetched/saved to the current project -- do NOT run in a legacy environment, this will
        overwrite production files.

        if [use_archive] is provided and evaluates to TRUE, then PROD files will be fetched from the archive, and finished
        files will be commited to the archive with the PROD label.  krm -install will not be run.
    };
}
