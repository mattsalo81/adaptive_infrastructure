use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;



my ($tech, $sms_csv, $po_table) = @ARGV;

my $usage = qq{

Usage : $0 <TECHNOLOGY> <old_adaptive_active_device_csv> <old_adaptive_rtg_options> 

compares options among equivalent effectivedb routings.  output can be piped through filter_out_known_opts
to get rid of new opts

};

die $usage unless ((defined $tech) && (defined $sms_csv) && (defined $po_table));

my $dev2eff = get_device_to_eff_rout($tech);
my $dev2rout = get_device_to_db_routing($sms_csv);
my $eff2opt = get_eff_rout_to_opt($tech);
my $rout2opt = get_db_rout_to_opt($po_table);

my %devices = (%{$dev2eff}, %{$dev2rout});
foreach my $device (keys %devices){
    my $eff = $dev2eff->{$device};
    my $rout = $dev2rout->{$device};
    if (defined $eff){
        if (defined $rout){
            my $new_opts = $eff2opt->{$eff};
            if(defined $new_opts){
                my $old_opts = $rout2opt->{$rout};
                if(defined $old_opts){
                    my %opts = (%{$new_opts}, %{$old_opts});
                    foreach my $opt (keys %opts){
                        unless(defined $new_opts->{$opt}){
                            print "$device,REMOVED_OPT,$opt\n";
                        }
                        unless(defined $old_opts->{$opt}){
                                print "$device,NEW_OPT,$opt\n";
                        }
                    }
                }else{
                    print "$device,DB_ROUT_NOT_IN_OLD_SYSTEM,\n";
                }
            }else{
                print "$device,EFF_ROUT_NOT_IN_NEW_SYSTEM,\n";
            }
        }else{
            print "$device,DEVICE_NOT_IN_OLD_SYSTEM,\n";
        }
    }else{
        print "$device,DEVICE_NOT_IN_NEW_SYSTEM,\n";
    }
}

sub get_eff_rout_to_opt{
    my ($tech) = @_;
    my $conn = Connect::read_only_connection('etest');
    my $sql = q{select po.effective_routing, po.process_option from
                effective_routing_to_options po
                where 
                po.technology = ?
    };
    my $sth = $conn->prepare($sql);
    $sth->execute($tech);
    my %eff2opt;
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        $eff2opt{$rec->{"EFFECTIVE_ROUTING"}} = {} unless defined $eff2opt{$rec->{"EFFECTIVE_ROUTING"}};
        $eff2opt{$rec->{"EFFECTIVE_ROUTING"}}->{$rec->{"PROCESS_OPTION"}} = 1;
    }
    return \%eff2opt;
}

sub get_db_rout_to_opt{
    my ($table) = @_;
    my $conn = Connect::read_only_connection('sd_limits');
    my $sql = qq{
        select * from $table
    };
    my $sth = $conn->prepare($sql);
    $sth->execute();
    my %rout2opt;
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        my $rout = $rec->{"ROUTING"};
        confess "weird table format" unless defined $rout;
        delete $rec->{"ROUTING"};
        $rout2opt{$rout} = {};
        foreach my $po (keys %{$rec}){
            if ((defined $rec->{$po}) && $rec->{$po}){
                $rout2opt{$rout}->{$po} = 1;
            }
        }
    }
    return \%rout2opt;
}

sub get_device_to_eff_rout{
    my ($tech) = @_;
    my $conn = Connect::read_only_connection('etest');
    my $sql = q{select sms.device, sms.effective_routing
                from daily_sms_extract sms where sms.technology = ? 
                and sms.area = 'PARAMETRIC'
    };
    my $sth = $conn->prepare($sql);
    $sth->execute($tech);
    my %dev2eff;
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        $dev2eff{$rec->{"DEVICE"}} = $rec->{"EFFECTIVE_ROUTING"};
    }
    return \%dev2eff;
}

# /export/home/kthmgr/waivers/../lbc5/active_dev_table_20180525.csv
sub get_device_to_db_routing{
    my ($sms_csv) = @_;
    # dev,family,class,routing,db routing,spec program,prod_grp,cot?,K5300
    open my $fh, $sms_csv or confess "could not open <$sms_csv> active device csv";
    my @lines = <$fh>;
    close $fh;
    @lines = map {$_ =~ s/\n//g; $_} @lines;
    @lines = grep {$_ !~ m/^\s*$/} @lines;
    my @header = split(/,/, shift @lines);
    my $dev_i = 0;
    my $db_rout_i = 4;
    confess "don't know where device is in active device table" unless $header[$dev_i] =~ m/dev/i;
    confess "don't know where db_rout is in active device table" unless $header[$db_rout_i] =~ m/db routing/i;
    my %dev2db;
    foreach my $line (@lines){
        my @line = split /,/, $line;
        $dev2db{ $line[$dev_i]} = $line[$db_rout_i];
    }
    return \%dev2db;
}
