package ProcessDecoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $options_for_code_sth;
my $placeholder_option = "PLACEHOLDER";
my $get_all_possible_options_for_code_sth;

sub get_options_for_code_sth{
	unless (defined $options_for_code_sth){
		Logging::debug("Creating new statement handle for getting process codes from process options");
		my $conn = Connect::read_only_connection("etest");
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
	unless(defined $code && defined $code_num && defined $technology){
		confess "Something is not defined correctly, probably programmer's fault";
	}
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
		push(@def_options, $opt) if defined $opt and $opt ne $placeholder_option;
	}
	return \@def_options;
}

# get every possibly option for every possible encoding scheme
# note, this is NOT the possible codes, but the possible options
# ie, if code_num 1 means metal levels, possible codes are 1,2,3,4,5, etc
#	but possible options might be SLM,DLM,TLM,QLM,PLM, etc
# 	this returns options
sub get_all_possible_options_for_code{
	my ($technology, $code_num) = @_;
        unless(defined $code_num && defined $technology){
                confess "Something is not defined correctly, probably programmer's fault";
        }
	my $sth = get_all_possible_options_for_code_query();
	$sth->execute($technology, $code_num);
	my $codes = $sth->fetchall_arrayref();
	my @codes = map {$_->[0]} @{$codes};
	return \@codes;
}

sub get_all_possible_options_for_code_query{
	unless(defined $get_all_possible_options_for_code_sth){
		my $conn = Connect::read_only_connection("etest");
		my $sql = q{
			select distinct 
				process_option
			from
				process_code_to_option
			where
				technology = ?
				and code_num = ?
		};
		$get_all_possible_options_for_code_sth = $conn->prepare($sql);
	}
	unless (defined $get_all_possible_options_for_code_sth){
		confess "Could not get get_all_possible_options_for_code_sth, probably programmer's fault";
	}
	return $get_all_possible_options_for_code_sth;
}

1;
