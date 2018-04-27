package ProcessEncoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Database::Connect;
use ProcessOptions::ProcessDecoder;
use Logging;
use ProcessOptions::Encode::Global;

# This is the handler class for uploading process codes to the process code database

my $table = "process_code_to_option";

sub update_codes_for_all_techs{
	my $conn = Connect::read_only_connection("etest");
	my $sql = q{select distinct technology from daily_sms_extract};
	my $sth = $conn->prepare($sql);
	$sth->execute() or confess "Could not get list of technologies from daily_sms_extract";
	my $techs = $sth->fetchall_arrayref();
	my @techs = map{$_->[0]} @{$techs};
	foreach my $tech (@techs){
		eval{
			update_codes_for_tech($tech);
			Logging::event("Updated $tech process encoding");
			1;
		} or do {
			my $e = $@;
			warn "Could not update $tech process encoding because of : $e";
		}
	}
}

sub update_codes_for_tech{
	my ($tech) = @_;
	my $codes = Encode::Global::get_codes($tech);
	for( my $code_num = 0; $code_num < scalar @{$codes}; $code_num++){
		my $code = $codes->[$code_num];
		update_code($tech, $code_num, $code);
	}	
}

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
			my $num_opt = 0;
			foreach my $option (@{$lookup->{$code}}){
				if($code =~ m/[^a-z0-9\+\.\/_]/i or $option =~ m/[^a-z0-9\+\.\/_]/i){
					confess "Unexpected character in ($tech - $code_num - $code -> $option)";
				}
				Logging::diag("Updating ($tech - $code_num - $code -> $option) in database");
				unless($u_sth->execute($tech, $code_num, $code, $option)){
					confess "Could not update ($tech - $code_num - $code -> $option) in database";
				}
				$num_opt++;
			}
			# put a placeholder value in
			if ($num_opt == 0){
				$u_sth->execute($tech, $code_num, $code, $ProcessDecoder::placeholder_option) or confess "Could not add placeholder for ($tech - $code_num - $code)";
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
