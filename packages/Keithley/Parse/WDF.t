use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::Parse::WDF;
use Data::Dumper;

my $wdf_text = get_text();

my $wdf = Parse::WDF->new($wdf_text);
$wdf->{"TEXT"} = "";
my $new_text = $wdf->get_new_text();
is($new_text, $wdf_text, "WDF parsed/loaded/printed without modification and without aid of original text");
is($wdf->get_alignment_mod(), "lbc5_scm_mod00", "get alignment mod");
ok(have_same_elements($wdf->get_real_modules(), [qw(lbc5_scm_mod00 lbc5_scm_esd01 lbc5_scm_exmod2)]), "Get all real modules");
my @all_mods = qw(lbc5_scm_mod00 lbc5_scm_esd01 some_dummy_mod);
$wdf->add_missing_modules(\@all_mods);
ok($wdf->get_new_text !~ m/lbc5_scm_mod00,0.005,0.005/, "Real module not added as dummy");
ok($wdf->get_new_text =~ m/some_dummy_mod,0.005,0.005/, "Missing module added as dummy");



sub get_text{
    return q{#Keithley Wafer Description File
Version,1.1
File,M06CDC65310C0.wdf
Date,06/08/2017
Comment,Generated For Adaptive Test
Project,Single
DiameterUnits,Metric
Diameter,200.0000
Units,Metric
DieSizeX,20.320
DieSizeY,21.150
Orientation,Notch,Left
WaferOffset,0,0
Axis,1
Origin,5,5
Target,5,5
AutoAlignLocation,0.0000,0.0000
Optimize,0
<EOH>
Pattern,STD
1,7,7
Pattern,WAS
2,7,3
3,3,4
4,3,7
5,5,5
Pattern,REL
6,5,8
7,8,5
8,5,2
9,2,5
Pattern,STD_ALT
10,5,1
11,7,2
<EOSITES>
Site,Single,Single
lbc5_scm_mod00,0,0
lbc5_scm_esd01,3.679,-4.230
lbc5_scm_exmod2,5.144,0.000
lbc5_scm_wlr05_v,0.005,0.005
lbc5_wlr2v,0.005,0.005
lbc5_wlr_mod02,0.005,0.005
<EOSUBSITES>};
}


