package ProcessDecoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use LOGGING;
use DATABASE::connect;

my $options_for_code_sth;

sub get_options_for_code_sth{
	unless (defined $options_for_code_sth){
		LOGGING::debug("Creating new statement handle for getting process codes from process options");
		my $conn = connect::read_only_connection("etest");
		my $sql = q{
			select distinct
				process_option
			from
				process_code_to_option
			where
				technology = ?
				and code_num = ?
				and process_code = ?
		};
		$options_for_code_sth = $conn->prepare($sql);		
	}
	unless (defined $options_for_code_sth){
		confess "Could not get statement handle to get process options from process code! Probably Programmer's fault\n";
	}
	return $options_for_code_sth;
}

sub get_options_for_code{
	my ($technology, $code_num, $code) = @_;
	my $sth = get_options_for_code_sth();
	$sth->execute($technology, $code_num, $code);
	my @options = @{$sth->fetchall_arrayref()};
	if (scalar @options == 0){
		confess "No options found for code <$technology, $code_num, $code> in database!";
	}
	# flatten deep array
	@options = sort map {$_->[0] =~ s/\s//g; $_->[0]} @options;
	my @def_options;
	foreach my $opt (@options){
		push(@def_options, $opt) if defined $opt;
	}
	return \@def_options;
}

1;
