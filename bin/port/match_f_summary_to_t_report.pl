use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use FactorySummary::ConvertTReport;
use Logging;

my ($from_table, $to_tech) = @ARGV;


unless (defined $from_table){
	print ("Which t-report table? (ex: lbc5_t_report_parms) : ");
	$from_table = <STDIN>;
	chomp($from_table);
}
unless (defined $to_tech){
	print ("Which technology? (ex: LBC5) : ");
	$to_tech = <STDIN>;
	chomp($to_tech);
}



ConvertTReport::convert($from_table, $to_tech);
