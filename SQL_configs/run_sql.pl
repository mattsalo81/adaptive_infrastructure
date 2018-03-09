use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Database::Connect;
use DBI;

main();

sub main{
	my ($file, $database) = @ARGV;
	die "no file provided" unless defined $file;
	die "no database provided" unless defined $database;
	open my $fh, "$file" or die "could not open <$file>";
	my @lines = <$fh>;
	my $sql = join("", @lines);
	execute_sql_transaction($sql, $database);
}

sub execute_sql_transaction{
	my ($sql, $database) = @_;
	my $trans;
	eval{
		$trans = Connect::new_transaction($database);
		foreach my $statement (split(';', $sql)){
			next if $statement =~ m/^\s*$/;
			$statement =~ s/^\n*//;
			$statement =~ s/\n*$//;
			next if $statement =~ m/^--/;
			my $sth = $trans->prepare($statement) or die "Could not prepare <$statement>";
			$sth->execute() or die "Could not execure <$statement>";
		}
		$trans->commit();
		1;
	} or do {
                my $e = $@;
                die ("Was unable to execute sql because of : $e");
                $trans->rollback();
	};
}

