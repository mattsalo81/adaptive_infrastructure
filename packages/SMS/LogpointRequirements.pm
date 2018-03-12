package LogpointRequirements;
use warnings;
use strict;
use Data::Dumper;
use DBI;
use Carp;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Logging;
use Database::Connect;

my %lpt_table;
my $lpt_sth;


# splits a logpoint string into a list of required/forbidden logpoints.
# supports ! (not) and . (and).  Could one day be upgraded for fully recursive parsing
sub parse_lpt_string{
        my ($string) = @_;
	my $forb_lpt = [];
	my $req_lpt = [];
        $string =~ s/\s//g;
        Logging::diag("parsing string <$string> header");
        my @logpoints = split /\./, $string;
        foreach my $logpoint (@logpoints){
                Logging::diag("parsing string <$string> part <$logpoint>");
                if ($logpoint =~ m/^!([0-9]{4})$/){
                        push @{$forb_lpt}, $1;
                }elsif($logpoint =~ m/^([0-9]{4})$/){
                        push @{$req_lpt}, $1;
                }else{
			confess "Unrecognized format in logpoint <$logpoint> of string <$string>";
		}
        }
	return ($req_lpt, $forb_lpt);
}

# takes a list of routings and returns only those that meet the lpt string requirements
sub get_list_of_routings_matching_lpt_string{
	my ($input_routings, $string) = @_;
	my @matching_routings;
	my ($req_lpt, $forb_lpt) = parse_lpt_string($string);
	return [] unless ((scalar @{$req_lpt} + scalar @{$forb_lpt}) > 0);
	ROUTING: foreach my $possible_routing(@{$input_routings}){
		Logging::debug("checking if $possible_routing matches $string");
		next ROUTING unless (does_routing_match_lpt_lists($possible_routing, $req_lpt, $forb_lpt));
		Logging::debug("it's good!");
		push @matching_routings, $possible_routing;
	}
	return \@matching_routings;
}

# takes a single routing, a list of required logpoints, and a list of forbidden logpoints
# returns true/false if that routing satisfies those requirements
sub does_routing_match_lpt_lists{
	my ($routing, $req_lpt, $forb_lpt) = @_;
	REQ_LPT: foreach my $lpt (@{$req_lpt}){
                Logging::diag("$routing must have $lpt");
                my $hash_ref = get_routing_list_at_lpt($lpt);
		unless (defined $hash_ref){
                	confess "Sub did not return as expected, probably programmer's fault";
		}
		return 0 unless (defined $hash_ref->{$routing});
        }
	FORB_LPT: foreach my $lpt (@{$forb_lpt}){
               	Logging::diag("cannot have $lpt");
                my $hash_ref = get_routing_list_at_lpt($lpt);
		unless (defined $hash_ref){
			die "somebody broke the logpoint automation";
		}
                return 0 if (defined $hash_ref->{$routing});
        }
	return 1;	
}

# used for the recursive Descent parser
# returns true if routing goes through LPT
sub does_routing_use_lpt{
	my ($routing, $lpt) = @_;
	return does_routing_match_lpt_lists($routing, [$lpt], []);
}

# takes a single routing and a logpoint string.
# returns true/false if that routing satisfies the string
sub does_routing_match_lpt_string{
	my ($routing, $string) = @_;
	return (scalar @{get_list_of_routings_matching_lpt_string([$routing], $string)} > 0);
}

# gets a list of all routings that go through the given logpoint
# benchmark test said that this was the fastest way to batch sms requrests, as usually
# one lpt string is used for many routings, so might as well know which ones go through that lpt
sub get_routing_list_at_lpt{
        my ($lpt) = @_;
        $lpt = sprintf("%04u",$lpt);
        unless (defined $lpt_table{$lpt}){
                Logging::debug("querying sms for routings that go through <$lpt>");
                my $sth = get_lpt_routing_list_sth();
                $sth->execute($lpt) or confess "could not execute routing/lpt query with logpoint <$lpt>";
                my %routings;
                while(my ($routing) = $sth->fetchrow()){
                        $routings{$routing} = 'yep';
                }
                $lpt_table{$lpt} = \%routings;
        }
	Logging::diag("Returning Cached logpoints for <$lpt>");
        return $lpt_table{$lpt};
}


sub get_lpt_routing_list_sth{
	unless (defined $lpt_sth){
        	my $sql = q{
        	select distinct
        	  rd.routing
        	from
        	  smsdw.routing_def rd
        	  INNER JOIN smsdw.routing_flw_def rfd
        	        on  rfd.facility = rd.facility
        	        and rfd.routing = rd.routing 
        	        and rfd.rev = rd.rev
        	        and rfd.lpt = ?
        	where
        	  rd.facility = 'DP1DM5' and
        	  rd.status = 'A'
		};
        	$lpt_sth = Connect::read_only_connection("sms")->prepare($sql) or confess "Could not prepare $sql";
	}
	unless (defined $lpt_sth){
		confess "Could not get statement handle for querying logpionts.  Probably programmer's fault";
	}
        return $lpt_sth;
}


1;
