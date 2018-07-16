use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SpecFiles::Spec;
use SpecFiles::GenerateSpec;

my $known_tech = "LBC5";
my $known_area = "PARAMETRIC";
my $known_rout = "LBC5_PARAMETRIC_3_A+";
my $known_prog = "M06BEC65310B0";
my $spec = GenerateSpec::get_spec($known_tech, $known_area, $known_rout, $known_prog);
my $text = $spec->get_text();
my @lines = split /\n+/, $text;
@lines = grep !/#/, @lines;
@lines = grep !/^\s*$/, @lines;
ok(scalar @lines > 10, "Found at least 10 entries on a real specfile");
print $text;
