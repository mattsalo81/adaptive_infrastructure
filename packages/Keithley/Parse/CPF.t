use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::Parse::CPF;

my $cpf_text = q{
#Keithley Cassette Plan Definition File
Version,1.0
File,dmos5_LBC5X_MLM_r06_AUTO.cpf
Date,02/08/2017
Comment,Check /dm5/ki/v520lx/msp/LBC5X_audit.xlsm
Engine,ktxe
Probe,MPRZxx.pcf
Wafer,dmos5_LBC5X_MLM_r06.wdf
Global,tidata_on.gdf
Global,dmos5_std.gdf
Global,Adaptive.gdf
Global,automation.gdf
UAPdefaults,ti_dm5_TIAdaptive_support.uap
UAPdefaults,MoreSitesLessTestsADDWASRepeatWASTestV11.uap
UAPdefaults,dmos5_lbc5_prod_autoz.uap
UAPdefaults,ti_common_slot_selection_support.uap
<EOH>
ALL,,dmos5_LBC5X_MLM_r06.wpf
<EOSLOTS>
<EOUAP>
};

my $expected_wpf = 'dmos5_LBC5X_MLM_r06.wpf';

my $cpf = Parse::CPF->new($cpf_text);
my $wpf = $cpf->get_wpf();

is($wpf, $expected_wpf, "Extract WPF");
