package ProcessEncoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Database::Connect;
use ProcessOptions::ProcessDecoder;
use Logging;

my $table = "process_code_to_option";


# takes technology, code_number, and a lookup table (hashref)
# keys of lookup table are codes, values are array-refs of options
# ie :
# $lookup = {
#		'AB' 	-> 	['OPT1', 'OPT2'],
#		'BC' 	-> 	['OPT2', 'OPT3'],
# }
sub update_code{
	my ($tech, $code_num, $lookup) = @_;
	my $trans = Connect::new_transaction("etest");
	Logging::event("Updating ($tech - code $code_num) in database");
	eval{
		my $del_sth = get_delete_code_in_trans_sth($trans);
		unless($del_sth->execute($tech, $code_num)){
			confess "Could not empty codes ($tech - $code_num) in database";
		}
		my $u_sth = get_update_options_in_trans_sth($trans);
		foreach my $code (keys %{$lookup}){
			Logging::debug("Updating ($tech - $code_num - $code) in database");
			foreach my $option (@{$lookup->{$code}}){
				Logging::diag("Updating ($tech - $code_num - $code -> $option) in database");
				unless($u_sth->execute($tech, $code_num, $code, $option)){
					confess "Could not update ($tech - $code_num - $code -> $option) in database";
				}
			}
		}
		$trans->commit();
		1;
	} or do{
		my $e = $@;
		$trans->rollback();
		confess "Could not update codes ($tech - $code_num) in database because of : $e";
	};
}

sub get_update_options_in_trans_sth{
	my ($trans) = @_;
	my $sql = qq{
		insert into $table 
			(TECHNOLOGY, CODE_NUM, PROCESS_CODE, PROCESS_OPTION)
		values
			(?, ?, ?, ?)
	};
	my $sth = $trans->prepare($sql);
	unless (defined $sth){
		confess "Could not prepare get_update_options_in_trans_sth";
	}
	return $sth;
}

sub get_delete_code_in_trans_sth{
	my ($trans) = @_;
	my $sql = qq{
		delete from $table 
		where 
			technology = ?
			and code_num = ?
	};
	my $sth = $trans->prepare($sql);
        unless (defined $sth){
                confess "Could not prepare delete_code_in_trans_sth";
        }
        return $sth;
}

1;
