use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use FactorySummary::ConvertTReport;

print "\n\nEnter name of table to copy from (ex : lbc5_t_report_parms) : ";
my $input_table = <STDIN>;
chomp $input_table;

print "Enter technology to copy to (ex : LBC5) : ";
my $tech = <STDIN>;
chomp $tech;

print "This script will DELETE anything in the current Factory summary and\n";
print "create the best match using the given t-report table\n";
print "ALL EXISTING FACTORY SUMMARY CONFIGURATION FOR $tech WILL BE LOST\n\n";
print "please retype the technology ($tech) to confirm you understand : ";
my $resp = <STDIN>;
chomp $resp;

if ($resp eq $tech){
    print "Matching $tech...\n";
    ConvertTReport::convert($input_table, $tech);
}else{
    print "Aborting...\n";
}

