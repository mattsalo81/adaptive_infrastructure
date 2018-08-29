use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::RecipeGen;
use SMS::SMSDigest;


my $poss_arg = shift @ARGV;

die usage() . "\n" unless defined $poss_arg;

my $use_archive = 0;
if ($poss_arg =~ m/^-/){
    if ($poss_arg =~ m/^--?a(rchive)?$/i){
        $use_archive = 1;
    }elsif($poss_arg =~ m/^--?p(roject)?$/i){
        $use_archive = 0;
    }else{
        die "Unkown flag <$poss_arg>\n" . usage() . "\n";
    }
}else{
    unshift @ARGV, $poss_arg;
}

my @recipes = map {s/(\.krf|,v)//; $_} @ARGV;

my $sms_records = SMSDigest::get_recipe_gen_info_for_recipes(@recipes);
Keithley::RecipeGen::generate_recipes($sms_records, ['', '-R', 'ALL'], $use_archive);

sub usage{
    return qq{
        Usage : `perl $0 [-a|-p] <recipe1> [recipe2] ...

        Generates standard, -R, and ALL site recipes for all active devices with active WIP for given recipe, 
        
        -p is default, files are fetched/saved to the current project -- do NOT run in a legacy environment, this will
        overwrite production files.

        if -a is used, then PROD files will be fetched from the archive, and finished
        files will be commited to the archive with the PROD label.  krm -install will not be run.

    };
}
