package Keithley::RecipeGen;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::AutoZ;
use Keithley::CPFSel;
use Keithley::KRFGen;
use Keithley::Parse::WDF;
use Components::DeviceString;


# how recipe types correspond to wdf names
my %recipe_to_wdf_type = (
    ""          =>      "",
    "-R"        =>      "_ns",
    "ALL"       =>      "ALL",
);

sub generate_recipe{
    my ($sms_rec, $recipe_type, $use_archive) = @_;

    # Create WDF name and Get text
    my $wdf_name = make_wdf_name($sms_rec, $recipe_type);
    my $orig_wdf_text = Keithley::File::get_text($wdf_name, $use_archive);
    
    # start by getting information from wdf
    my $wdf_obj = Parse::WDF->new($orig_wdf_text);
    my $mod_list = $wdf_obj->get_real_modules();
    my $alignment_mod = $wdf_obj->get_alignment_mod();

    # get CPF/autoz using WDF info
    my $cpf_base = Keithley::CPFSel::get_cpf_for_sms_record_and_mods($sms_rec, $mod_list);
    my $cpf = $cpf_base;
    if(Keithley::AutoZ::is_autoz_module_sms_rec($sms_rec, $alignment_mod){
        $cpf .= "_AUTO.cpf";
    }else{
        $cpf .= "_NOAUTO.cpf";
    } 

    
}

# open cpf, get wpf
# open cpf, get ktms
# open ktms, get subsites for WDF generation
# give wpf to KLF generator
# generate specfile for FILE
# create KRF
# updated WDF

    # make recipe name
    my $krf_name = $sms_rec->get("RECIPE");
    $krf_name .= "$recipe_type.krf";
    
    my $krf_text = KRFGen::get_text($krf_name);
    
#    my ($recipe, $cpf, $wdf, $klf, $device_string) = @_;
 



    return ($krf_name, $krf_text, $klf_name, $klf_text, $wdf_name, $wdf_text, $spec_name, $spec_text);
}

sub make_wdf_name{
    my ($sms_rec, $recipe_type) = @_;
    my $proberfile = $sms_rec->get("PROBERFILE");
    my $wdf_type = $recipe_to_wdf_type{$recipe_type};
    unless (defined $wdf_type){
        confess "Could not get a valid WDF type for recipe type <$recipe_type>";
    }
    return $proberfile . $wdf_type . ".wdf";
}

sub make_krf_name{
    my ($sms_rec, $recipe_type) = @_;
    my $recipe = $sms_rec->get("RECIPE");
    my $krf = $recipe . "$recipe_type" . ".krf";
    return $krf;
}


1;
