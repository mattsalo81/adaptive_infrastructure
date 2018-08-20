package ConvertTReport;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;



sub convert{
    my ($input_table, $output_tech) = @_;
    my $trans = Connect::new_transaction("etest");
    my $clr_sql = q{delete from f_summary where technology = ?};
    eval{
        # clear old stuff
        my $clr_sth = $trans->prepare($clr_sql);
        $clr_sth->execute($output_tech);

        # get parameter list
        my $conn = Connect::read_only_connection('sd_limits');
        my $sql = qq{select distinct gtest_name from sd_limits.$input_table};
        my $parm_sth = $conn->prepare($sql);
        $parm_sth->execute();
        my $parms = $parm_sth->fetchall_arrayref();
        my @parms = map {$_->[0]} @{$parms};
        
        # prepare upload
        my $up_sql = q{insert into f_summary (technology, etest_name, process_options, component, sampling_rate, deactivate, dispo, pass_criteria_percent,
                            spec_upper, spec_lower, reverse_spec_limit, reliability, reliability_upper, reliability_lower, reverse_reliability_limit)
                             values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)};
        my $up_sth = $trans->prepare($up_sql);

        foreach my $parm (@parms){
            # download t-report
            $sql = qq{select * from sd_limits.$input_table where gtest_name = ?};
            my $down_sth = $conn->prepare($sql);
            $down_sth->execute($parm);
            my %done;
            #  look through records
            while(my $rec = $down_sth->fetchrow_hashref("NAME_uc")){
                # Rel stuff
                my ($rel, $url, $lrl, $rio);
                my ($dispo, $pass, $usl, $lsl, $io);
                my $sampling = "RANDOM";
                if (defined ($rec->{"REL"}) && $rec->{"REL"} ne "N"){
                    unless(defined($rec->{"U_SPEC"}) && defined($rec->{"L_SPEC"})){
                        $rec->{"L_SPEC"} = -9e99;
                        $rec->{"U_SPEC"} = 9e99;
                    }
                    $rel = "Y";
                    $url = sprintf("%G", $rec->{"U_SPEC"});
                    $lrl = sprintf("%G", $rec->{"L_SPEC"});
                    $rio = "N";
                    $sampling = "9 SITE";
                } elsif (defined ($rec->{"WAS"}) && $rec->{"WAS"} ne "N"){
                    unless(defined($rec->{"U_SPEC"}) && defined($rec->{"L_SPEC"})){
                        $rec->{"L_SPEC"} =-9E99;
                        $rec->{"U_SPEC"} = 9E99;
                    }
                    $dispo = "Y";
                    $pass = ".75";
                    $usl = sprintf("%G", $rec->{"U_SPEC"});
                    $lsl = sprintf("%G", $rec->{"L_SPEC"});
                    $io = "N";
                    $sampling = "5 SITE";
                }
                # options
                my $options = $rec->{"OPTIONS"};
                $options = "BASELINE" if $options =~ m/baseline/i;
                # deactivate
                my $deactivate = "N";
                if (defined ($rec->{"REF_FLAG"}) && $rec->{"REF_FLAG"} eq "D"){
                    $deactivate = "Y";
                }
                # keep track of things done already
                my @stuff = ($output_tech, $parm, $options, $rec->{"COMMENTS"}, $sampling, $deactivate, $dispo, $pass, $usl, $lsl, $io, $rel, $url, $lrl, $rio);
                my $string = join("-", map {$_ ||= ""} @stuff);
                unless(defined $done{$string}){
                    # upload
                    $up_sth->execute($output_tech, $parm, $options, $rec->{"COMMENTS"}, $sampling, $deactivate, $dispo, $pass, $usl, $lsl, $io, $rel, $url, $lrl, $rio);
                    $done{$string} = "yep";
                }
            }
        }
        
        $trans->commit();
        1;
    } or do {
        my $e = $@;
        $trans->rollback();
        confess "Could not move T-report to factory summary because :\n$e";
    }
}

1;
