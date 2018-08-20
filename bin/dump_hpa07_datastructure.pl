use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::Encode::Global;

my $encoding = Encode::Global::get_codes("HPA07");
print Dumper $encoding;

