package KLFGen;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::Parse::WPF;
use Keithley::Parse::KTM;
use Keithley::File;
use LimitDatabase::GetLimit;

sub make_klf{
    my ($sms_rec, $wpf_name, $use_archive) = @_;
    my $tech = $sms_rec->get("TECHNOLOGY");
    my $area = $sms_rec->get("AREA");
    my $eff_rout = $sms_rec->get("EFFECTIVE_ROUTING");
    my $prog = $sms_rec->get("PROGRAM");
    return make_klf_for_wpf($wpf_name, $tech, $area, $eff_rout, $prog, $use_archive);
}

sub make_klf_for_wpf{
    my ($wpf_name, $tech, $area, $eff_rout, $prog, $use_archive) = @_;
    my $limits = GetLimit::get_all_limits($tech, $area, $eff_rout, $prog, undef);
    my $klf = make_klf_for_wpf_and_limits($wpf_name, $limits, $eff_rout, $use_archive);
    return $klf;
}

sub make_klf_for_wpf_and_limits{
    my ($wpf_name, $limit_records, $effective_routing, $use_archive) = @_;
    my $parms = get_parameters_from_wpfs([$wpf_name], $use_archive);
    my $klf = get_header($effective_routing, "Generated from Keithley::KLFGen for wpf $wpf_name");
    
    # sort limits by parameter
    my %limits;
    foreach my $limit (@{$limit_records}){
        my $parm = $limit->get("ETEST_NAME");
        $limits{$parm} = $limit;
    }
   
    # add an entry for each test id in the wpf 
    foreach my $id (sort keys %{$parms}){
        my $parm = $parms->{$id};
        my $entry;
        # generate an entry
        if (defined $limits{$parm}){
            # generate entry from the record
            my $limit = $limits{$parm};
            $entry = $limit->get_klf_entry();
        }else{
            # generate dummy
            $entry = KLFEntry->new($parm);
            $entry->set_test(0);
        }
        # set id name
        $entry->set_test_name($id);
        $klf .= $entry->get_text();
    }
    
    return $klf;
}

sub get_header{
    my ($file_name, $comment) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $date = sprintf ( "%02d/%02d/%04d", $mon+1, $mday, $year+1900);

    my $text = qq{
        #Keithley Parameter Limits File
        Version,1.0
        File,$file_name
        Date,$date
        Comment,$comment
        RevID,\$Revision: 1.0 \$
        <EOH>
    };
    my @lines = split /\n/, $text;
    $text = "";
    foreach my $line (@lines){
        $line =~ s/^\s*//;
        $text .= $line . "\n" if $line !~ m/^$/;
    }
    return $text;
}

sub get_parameters_from_wpfs{
    my ($wpfs, $use_archive) = @_;
    my %parms;
    my $current_file;
    eval{
        my %ktms;
        foreach my $wpf_name (@{$wpfs}){
            $current_file = $wpf_name;
            my $wpf_text = Keithley::File::get_text($wpf_name, $use_archive);
            my $wpf = Parse::WPF->new($wpf_text);
            my $ktms = $wpf->get_all_ktms();
            @ktms{@{$ktms}} = @{$ktms};
        }
        foreach my $ktm_name (keys %ktms){
            $current_file = $ktm_name;
            my $ktm_text = Keithley::File::get_text($ktm_name, $use_archive);
            my $ktm = Parse::KTM->new($ktm_text);
            my $parms = $ktm->get_parameters();
            my $subsite = $ktm->get_subsite();
            @parms{map {$subsite . "x$_"} @{$parms}} = @{$parms};
        }
        1;
    } or do {
        my $e = $@;
        confess "Could not get parameters from wpfs. Current file = <$current_file>. Error : $e";
    };
    return \%parms;
}



1;
