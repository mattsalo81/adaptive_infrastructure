use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use FactorySummary::ProcessSummary;
use Data::Dumper;

my $rec = ProcessSummary::get_f_summary_records_for_tech('LBC5');
print Dumper $rec;

