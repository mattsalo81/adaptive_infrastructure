package Decoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::CompositeOptions;
use ProcessOptions::OptionAssertions;
use Database::Connect;

my $upload_sth;
my $table = "effective_routing_to_options";


sub upload_effective_routing_options_for_tech{
    my ($tech) = @_;
    my $trans = Connect::new_transaction("etest");
    Logging::event("Updating process options for effective routings in $tech");
    eval{
        # delete current info in transaction
        $trans->prepare("delete from $table where technology = ?")->execute($tech);
        # get relationship between routings and effective routings (supports multiple routings on eff_rout for later)
        my $eff2routs = get_active_effective_routings_to_routings_for_tech($tech);
        # get upload handle
        my $u_sth = $trans->prepare(qq{
                insert into $table (technology, effective_routing, process_option)
                values (?, ?, ?)
        });
        # try each effective routing
        foreach my $effective_routing (keys %{$eff2routs}){
            Logging::debug("Updating process options for effective routing <$effective_routing> in $tech");
            eval{
                my $options = get_options_for_possibly_conflicting_routings_on_effective_routing(
                            $tech, $eff2routs->{$effective_routing}, $effective_routing);
                # add BASELINE option
                my %options;
                @options{@{$options}} = @{$options};
                $options{"BASELINE"} = "BASELINE";
                
                foreach my $opt (keys %options){
                    $u_sth->execute($tech, $effective_routing, $opt);
                }
                1;
            } or do {
                my $e = $@;
                if ($e =~ m/(No options found for code <[^>]*> in database)/){
                    Logging::error($1);
                }elsif($e =~ m/(Given a code that was undef, but was not allowed to ignore it \([^)]*\))/){
                    Logging::error($1);
                }elsif($e =~ m/(No defined way to parse routings for technology <[^>]*>)/){
                    die($1);
                }else{
                    Logging::error("Could not update effective routing <$effective_routing> in tech <$tech> because : $e");
                }
            };
        }
        $trans->commit();
        1;
    } or do {
        my $e = $@;
        $trans->rollback();
        warn "Could not update effective routings for $tech because of : $e";
    };
}

sub get_active_effective_routings_to_routings_for_tech{
    my ($tech) = @_; 
        my $d_sql = q{
        select distinct 
            s.routing, 
            s.effective_routing 
        from 
            daily_sms_extract s
        --    inner join daily_wip_extract w
        --      on s.device = w.device
        where 
            s.technology = ?
    };
        my $conn = Connect::read_only_connection("etest");
        my $d_sth = $conn->prepare($d_sql);
    $d_sth->execute($tech) or confess "Could not get all routings/effective routings for $tech";
    my $matrix = $d_sth->fetchall_arrayref();
    my %lookup;
    foreach my $record (@{$matrix}){
        my ($routing, $effective_routing) = @{$record};
        unless(defined $lookup{$effective_routing}){
            $lookup{$effective_routing} = [];
        }
        push @{$lookup{$effective_routing}}, $routing;
    }
    return \%lookup;
}

sub get_options_for_possibly_conflicting_routings_on_effective_routing{
    my ($tech, $routings, $effective_routing) = @_;
    my @final_options;
    my $init_rout;
    my $i = 0;
    foreach my $routing (@{$routings}){
        my @options = sort @{get_options_for_routing_and_effective_routing($tech, $routing, $effective_routing)};
        if ($i == 0){
            @final_options = @options;
            $init_rout = $routing;
        }else{
            # check if routings do not conflict -> they have identical options
            unless((scalar @options == scalar @final_options) && (join("", @options) eq join("", @final_options))){
                die "Could not resolve conflicts on effective routing <$effective_routing> - <$init_rout> and <$routing> have conflicting process options!";
            }
        }
        $i++;
    }
    return \@final_options;
}

sub get_options_for_routing_and_effective_routing{
    my ($tech, $routing, $effective_routing) = @_;
    my $options = CompositeOptions::get_composite_options_for_routing_and_effective_routing($tech, $routing, $effective_routing);
    eval{
        OptionAssertions::try_all_assertions_against_routing_and_options($tech, $routing, $options);
        1;
    } or do {
        my $e = $@;
        confess "Could not get options because : $e";
    };
    return $options;
}

sub get_upload_query{
    unless(defined $upload_sth){
        my $conn = Connect::new_transaction("etest");
        my $sql = qq{

        };
        $upload_sth = $conn->prepare($sql);
    }
    unless(defined $upload_sth){
        confess "Could not get the sth to upload options";
    }
}


1;
