package ProcessEncoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Database::Connect;
use ProcessOptions::ProcessDecoder;
use LOGGING;

my $delete_code_sth;
my $update_option_sth;
my $table = "process_code_to_option";

sub update_options{
	my ($trans, $tech, $code_num, $code, $options) = @_;
	unless (defined $update_option_sth){
		# need to somehow do this uniquely by transaction... one static sth will be very bad
		my $sql = qq{
			insert into $table 
				(TECHNOLOGY, CODE_NUM, PROCESS_CODE, PROCESS_OPTION)
			values
				(?, ?, ?, ?)
		};
	}
	
}

1;
