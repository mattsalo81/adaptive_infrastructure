use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use DATABASE::connect;
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
		$trans = connect::new_transaction($database);
		foreach my $statement (split(';', $sql)){
			next if $statement =~ m/^\s*$/;
			my $sth = $trans->prepare($statement);
			$sth->execute();
		}
		$trans->commit();
		1;
	} or do {
                my $e = $@;
                die ("Was unable to execute sql because of : $e");
                $trans->rollback();
	};
}

