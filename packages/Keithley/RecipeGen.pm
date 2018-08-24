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
    my ($sms_rec, $archive) = @_;
}

sub _parse_wdf_and_get_cpf_info{
    my ($sms_rec, $recipe_type, $orig_wdf_text) = @_;
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
    return ($wdf_obj, $mod_list, $cpf);
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

sub make_recipe_local{
    # gets local files, creates/updates local files (must be checked in manually)
    # get local files/read in
}

sub make_recipe_prod_archive{
    # gets archived files, checks any new things in
    # get prod files, read in
}

sub make_recipe_name


1;
