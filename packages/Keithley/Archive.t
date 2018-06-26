use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::Archive;

my $known_ktm = "lbc5_scm_mod14_r06.ktm";

my $known_rcs_file = $ENV{"KI_ARCHIVE"} . "/uap/add_oee.uap,v";
my $text = Archive::read_prod($known_rcs_file);
ok((defined $text && $text =~ m/UAP/), "Got known RCS file");

my $std;
$std = Archive::get_std_rcs_file($known_ktm);
ok($std =~ m/\/ktm\/$known_ktm,v/, "found what appears to be the rcs file of a known ktm");
