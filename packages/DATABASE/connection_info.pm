package connection_info;
use warnings;
use strict;
require "/dm5pde_webdata/dm5pde/perl/modules/SWAT/DATABASE.pm";
use Carp;

# Mark's database uses the sid's in his tnsnames.ora, which don't always match testware's
my %sid_conversion = (
	d5pdedb1	=> 'd5pdedb',
);

sub get_info_for{
	my ($name) = @_;
	unless (defined $name && $name ne ""){
		confess "database name not provided!";
	}
	# mark's perl package also sets his ENV so we need to preserve ours
	my %OLD_ENV = %ENV;
	my $obj = SWAT::DATABASE->new();
	my ($driver, $user, $pass) = $obj->database($name);
	
	# pull the sid out of the ENV + convert to tw name
	my $sid = $ENV{"ORACLE_SID"};
	if (defined $sid_conversion{$sid}){
		$sid = $sid_conversion{$sid};
	}
	
	# restore ENV
	%ENV = ();
	%ENV = %OLD_ENV;
	
	# append sid to driver
	$driver .= $sid;

	# Error checking
	unless (defined $driver && defined $user && defined $pass){
		confess "Could not get connection information for <$name> from SWAT::DATABASE";
	}
	my @connect_info = ($driver, $name, $pass);
	unless ($driver =~ m/^\w+:\w+:\w+$/ && $user =~ m/^\w+$/ && $pass =~ m/^\w+$/){
		confess "Connection information for <$name> does not look right! : <" . join("><", @connect_info) . ">"
	}
	return @connect_info;
}

1;
