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
use Keithley::Parse::CPF;
use Keithley::Parse::WPF;
use Keithley::Parse::WDF;
use Components::DeviceString;
use SpecFiles::GenerateSpec;


# how recipe types correspond to wdf names
my %recipe_to_wdf_type = (
    ""          =>      "",
    "-R"        =>      "_ns",
    "ALL"       =>      "ALL",
);

sub generate_recipe{
    my ($sms_rec, $recipe_type, $use_archive) = @_;
    my $use_comp = 1;

    # Create WDF name and Get text
    my $wdf_name = make_wdf_name($sms_rec, $recipe_type);
    my $orig_wdf_text = Keithley::File::get_text($wdf_name, $use_archive);
    
    # start by getting information from wdf
    my $wdf_obj = Parse::WDF->new($orig_wdf_text);
    my $mod_list = $wdf_obj->get_real_modules();
    my $alignment_mod = $wdf_obj->get_alignment_mod();

    # get CPF/autoz using WDF info
    my $cpf_base = Keithley::CPFSel::get_cpf_for_sms_record_and_mods($sms_rec, $mod_list);
    my $cpf_name = $cpf_base;
    if(Keithley::AutoZ::is_autoz_module_sms_rec($sms_rec, $alignment_mod){
        $cpf_name .= "_AUTO.cpf";
    }else{
        $cpf_name .= "_NOAUTO.cpf";
    }

    # get CPF text/wpf name
    my $cpf_text = Keithley::File::get_text($cpf_name, $use_archive);
    my $cpf_obj = Parse::CPF->new($cpf_text);
    my $wpf_name = $cpf_obj->get_wpf();

    # get wpf text
    my $wpf_text = Keithley::File::get_text($wpf_name, $use_archive);
    my $wpf_obj = Parse::WPF->new($wpf_text);
    my $ktms = $wpf_obj->get_all_ktms();

    # get subsites from ktms
    my @subsites;
    foreach my $ktm (@{$ktms}){
        my $ktm_text = Keithley::File::get_text($ktm_name, $use_archive);
        my $ktm_obj = Parse::KTM->new($ktm_text);
        my $subsite = $ktm_obj->get_subsite();
        push @subsites, $subsite;
    }

    # generate KLF
    my $klf_text = KLFGen::make_klf($sms_rec, $wpf_name, $use_archive);
    my $klf_name = $sms_rec->get("PROGRAM") . ".klf";

    # generate specfile
    my $spec_text = GenerateSpec::get_spec_sms($sms_rec, $use_comp);
    my $spec_name = "DMOS5_" . $sms_rec->get("TECHNOLOGY") . "_" . $sms_rec->get("PROGRAM") . ".spec";

    # generate device string
    my $device_string;
    if($use_comp){
        $device_string = DeviceString::get_device_string($sms_rec->get("TECHNOLOGY"), $sms_rec->get("PROGRAM"));
    }

    # generate KRF
    my $krf_name = $sms_rec->get("RECIPE") . ".krf";
    my $krf_text = KRFGen::get_text($krf_name, $cpf_name, $wdf_name, $klf_name, $device_string);
    
    # update WDF modules to include any missing dummy modules
    $wdf_obj->add_missing_modules(\@subsites);
    
    # update WDF patterns to match production assumptions
    
}

# updated WDF

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
