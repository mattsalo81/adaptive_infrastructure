use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::CSV;

my ($database, $csv) = @ARGV;
unless (defined $csv){
    die usage();
}

my $table = $csv;
$table =~ s#.*/##;
$table =~ s/\.csv.*//;
$table =~ s/--.*//;

Database::CSV::upload_csv($database, $table, $csv);

sub usage{
    return qq{

        Usage : $0 <database> <<table>[--stuff].csv>
        
        uploads the given CSV file to the given database. Database name
        must be in the format expected by Database::ConnectionInfo (ex. 'etest').
        CSV file must include the table name in it, but case does not matter.
        anything after two dashes is stripped, so you can use it to keep multiple csv
        files for the same table in the same directory. (ex. 'option_to_option--update.csv'
        will update the 'option_to_option' table).  First line of the CSV file must be a
        header with names that match the corresponding database table's attributes.  
        Not all attributes are required, except for those that are primary keys. When 
        INSERTing a new record, missing columns will take on the default value specified
        by the table's config.  when UPDATEing an existing record, missing columsn will not
        be modified, leaving the previous value.

        <Table> must have explicit primary key constraints.  The Oracle user_constraints
        table is referenced to determine the primary key attributes to determine if each
        record should be an INSERT or UPDATE.  This allows a csv upload to overwrite 
        existing records with the same primary key.


};
}
