use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::Encode::Global;
use Data::Dumper;

my $ml = Encode::Global::get_num_ml_codes();
my $area = Encode::Global::get_area_codes();

print Dumper($ml);
print Dumper($area);

ok(defined($area->{"PARAMETRIC"}), "got codes for PARAMETRIC");
my @codes = @{$area->{"PARAMETRIC"}};
my %areacodes;
@areacodes{@codes} = @codes;
ok(defined($areacodes{"AT_PARAMETRIC"}), "AT_PARAMETRIC");
ok(defined($areacodes{"BEEN_TO_PARAMETRIC"}), "BEEN_TO_PARAMETRIC");
ok(defined($areacodes{"BEEN_TO_METAL2"}), "BEEN_TO_METAL2");
ok(defined($areacodes{"AFTER_METAL2"}), "AFTER_METAL2");
ok(!defined($areacodes{"AFTER_PARAMETRIC"}), "AFTER_PARAMETRIC");

ok(defined($ml->{"4"}), "got codes for number of metal levels");
@codes = @{$ml->{"4"}};
my %ml4;
@ml4{@codes} = @codes;
ok(defined($ml4{"QLM"}), "Found QLM");
ok(!defined($ml4{"TLM"}), "not Found TLM");
ok(!defined($ml4{"PLM"}), "not Found PLM");
ok(defined($ml4{"3PLUS_LM"}), "Found 3PLUS_LM");
ok(defined($ml4{"4PLUS_LM"}), "Found 4PLUS_LM");
ok(!defined($ml4{"5PLUS_LM"}), "not found 5PLUS_LM");
