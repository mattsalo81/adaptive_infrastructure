package Keithley::RecipeGen;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Components::DeviceString;
use Keithley::AutoZ;
use Keithley::CPFSel;
use Keithley::File;
use Keithley::KLFGen;
use Keithley::KRFGen;
use Keithley::ReducedSites;
use Keithley::Parse::CPF;
use Keithley::Parse::KTM;
use Keithley::Parse::WDF;
use Keithley::Parse::WPF;
use Keithley::Parse::KRF;
use SpecFiles::Deploy;
use SpecFiles::GenerateSpec;


# how recipe types correspond to wdf names
my %recipe_to_wdf_type = (
#  recipe_mod   =>      [wdf_mod, 9site=true allsite=false, use_std_alt=true no_std_alt=false]
    ""          =>      ["",    1, 0],
    "-R"        =>      ["_ns", 1, 0],
    "ALL"       =>      ["ALL", 0, 0],
);

sub generate_recipes{
    my ($sms_records, $recipe_types, $use_archive) = @_;
    my @successful_recipes;
    my @failed_recipes;
    foreach my $sms_rec (sort {$a->get("RECIPE") cmp $b->get("RECIPE")} @{$sms_records}){
        foreach my $recipe_type (@{$recipe_types}){
            eval{
                generate_recipe($sms_rec, $recipe_type, $use_archive);
                my $recipe = $sms_rec->get("RECIPE") . "$recipe_type";
                push @successful_recipes, $recipe;
                print "generated <$recipe>\n";
                1;
            }or do{
                my $e = $@;
                my $failed = $sms_rec->get("RECIPE") . "$recipe_type";
                warn "\n\n\nCould not generate recipe <$failed> because $e\n\n\n";
                push @failed_recipes, $failed;
            };
        }
    }
    print "The following recipes were successful:\n\n" . join("\n", @successful_recipes) . "\n\n";
    print "The following recipes failed:\n\n" . join("\n", @failed_recipes) . "\n\n";
    Keithley::File::commit($use_archive);
    SpecFiles::Deploy::commit();
}

sub generate_recipe{
    my ($sms_rec, $recipe_type, $use_archive) = @_;
    my $use_comp = 1;

    my $krf_name = $sms_rec->get("RECIPE") . $recipe_type. ".krf";

    # Create WDF name and Get text
    my $wdf_name = make_wdf_name($sms_rec, $recipe_type);
    my $orig_wdf_text;
    eval{
        # look for PROBERFILE<type>.wdf
        $orig_wdf_text = Keithley::File::get_text($wdf_name, $use_archive);
        1;
    } or do{ 
        # look for the previous version of the recipe and get wdf from that
        my $e1 = $@;
        my $orig_krf_text;
        # open KRF to get old wdf name
        eval{
            $orig_krf_text = Keithley::File::get_text($krf_name, $use_archive);
        } or do {
            my $e2 = $@;
            confess "Could neither get <$wdf_name> file or find a pre-existing recipe <$krf_name> : <$e1><$e2>";
        };
        my $krf_obj = Parse::KRF->new($orig_krf_text);
        # open old wdf to get info
        my $old_wdf_name = $krf_obj->get_wdf();
        eval{
            $orig_wdf_text = Keithley::File::get_text($old_wdf_name, $use_archive);
        } or do {
            my $e2 = $@;
            confess "Could not get <$wdf_name> or <$old_wdf_name>.  <$e1><$e2>";
        };
        # done getting WDFs
    };
    
    # start by getting information from wdf
    my $wdf_obj = Parse::WDF->new($orig_wdf_text);
    my $mod_list = $wdf_obj->get_real_modules();
    my $alignment_mod = $wdf_obj->get_alignment_mod();

    # get CPF/autoz using WDF info
    my $cpf_base = Keithley::CPFSel::get_cpf_for_sms_record_and_mods($sms_rec, $mod_list);
    my $cpf_name = $cpf_base;
    if(Keithley::AutoZ::is_autoz_module_sms_rec($sms_rec, $alignment_mod)){
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
        my $ktm_text = Keithley::File::get_text($ktm, $use_archive);
        my $ktm_obj = Parse::KTM->new($ktm_text);
        my $subsite = $ktm_obj->get_subsite();
        push @subsites, $subsite;
    }

    # generate KLF
    my $klf_text = KLFGen::make_klf($sms_rec, $wpf_name, $use_archive);
    my $klf_name = $sms_rec->get("PROGRAM") . ".klf";

    # generate specfile
    my $spec_text = GenerateSpec::get_spec_sms($sms_rec, $use_comp)->get_text();
    my $spec_name = "DMOS5_" . $sms_rec->get("TECHNOLOGY") . "_" . $sms_rec->get("PROGRAM") . ".spec";

    # generate device string
    my $device_string;
    if($use_comp){
        $device_string = DeviceString::get_device_string($sms_rec->get("TECHNOLOGY"), $sms_rec->get("PROGRAM"));
    }

    # generate KRF
    my $krf_text = KRFGen::get_text($krf_name, $cpf_name, $wdf_name, $klf_name, $device_string);
    
    # update WDF modules to include any missing dummy modules
    $wdf_obj->add_missing_modules(\@subsites);
    
    # update WDF patterns to match production assumptions
    my $wdf_info = $recipe_to_wdf_type{$recipe_type};
    unless (defined $wdf_info){
        confess "Could not get WDF information for recipe type <$recipe_type>";
    }
    my $nine_site = $wdf_info->[1];
    my $use_std_alt = $wdf_info->[2];
    my $inner5 = Keithley::ReducedSites::uses_inner_five_sites($sms_rec->get("TECHNOLOGY"));
    if ($nine_site){
        $wdf_obj->make_9_site($inner5, $use_std_alt);
    }else{
        $wdf_obj->make_all_site();
    }
    my $new_wdf_text = $wdf_obj->get_new_text();
    
    # save all my modified files... (must run Keithley::File::commit_all if running in archive)
    Keithley::File::save_text($krf_name, $krf_text, $use_archive);
    Keithley::File::save_text($klf_name, $klf_text, $use_archive);
    Keithley::File::save_text($wdf_name, $new_wdf_text, $use_archive);
    
    # deploy specfile
    SpecFiles::Deploy::save($sms_rec->get("PROGRAM"), $spec_name, $spec_text);
    
}

# updated WDF

sub make_wdf_name{
    my ($sms_rec, $recipe_type) = @_;
    my $proberfile = $sms_rec->get("PROBER_FILE");
    my $wdf_info = $recipe_to_wdf_type{$recipe_type};
    unless (defined $wdf_info){
        confess "WDF information not configured for recipt type <$recipe_type>";
    }
    my $wdf_type = $wdf_info->[0];
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
