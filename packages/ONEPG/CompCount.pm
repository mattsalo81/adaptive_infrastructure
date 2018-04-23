package CompCount;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $components_for_reticle_base_sth;

sub get_components_for_reticle_base{
	my ($base) = @_;
	my $sth = get_components_for_reticle_base_sth();
	$sth->execute($base) or confess "Could not get components for reticle base $base";
	my $rows = $sth->fetchall_arrayref();
	my @comps = map {$_->[0]} @{$rows};
	return \@comps;
}

sub get_components_for_reticle_base_sth{
	unless (defined $components_for_reticle_base_sth){
		my $sql = q{
			select 
				CCC.NAME
			from
			       	RONADMIN.reticles R
			       	INNER JOIN RONADMIN.CHIPS_RETICLES CR
			       	      	on  CR.reticle_id = R.id
			       	INNER JOIN RONADMIN.PG_SOURCES PGS
			       	      	on  CR.pg_source_id = PGS.id
			       	INNER JOIN RONADMIN.CC_COMPS CCC
			       	      	on  CCC.cc_Product_Id = PGS.cc_Product_Id
			where r.reticle_base = ?
		};
		my $conn = Connect::read_only_connection("onepg");
		$components_for_reticle_base_sth = $conn->prepare($sql);
	}
	unless (defined $components_for_reticle_base_sth){
		confess "Could not get components_for_reticle_base_sth";
	};
	return $components_for_reticle_base_sth;
}

1;
