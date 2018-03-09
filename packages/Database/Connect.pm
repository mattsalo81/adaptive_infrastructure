package Connect;
use warnings;
use strict;
use Carp;
use DBI;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Database::ConnectionInfo;
use Logging;

my %connections;

sub read_only_connection{
	# static connection to a db so you don't have to pass it around
	# should only be used for reads
	my ($name) = @_;
	Logging::diag("Requesting read only connection to <$name>");
	unless(defined $connections{$name}){
		my @info = ConnectionInfo::get_info_for($name);
		$connections{$name} = DBI->connect(@info);
		Logging::debug("Creating new read only connection to <$name>");
		unless (defined $connections{$name}){
			confess "Could not connect to <$name>";
		}
		$connections{$name}->{"ReadOnly"} = 1;
	}
	return $connections{$name};
}

sub new_transaction{
	# unique connection without autocommit. pass it around between 
	# functions, make sure to commit changes when done
	my ($name) = @_;
	my @info = ConnectionInfo::get_info_for($name);
        my $conn = DBI->connect(@info,{AutoCommit => 0, RaiseError=>1});
	Logging::debug("Creating new transaction connection to <$name>");
	unless (defined $conn){
		confess "Could not connect to <$name>";
	}
	return $conn;
}

1;
