package KLFGen;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::Parse::WPF;
use Keithley::Parse::KTM;
use Keithley::Archive;
use LimitDatabase::GetLimit;

sub make_klf_for_wpf{
    my ($wpf_name, $tech, $area, $eff_rout, $prog) = @_;
    my $limits = GetLimit::get_all_limits($tech, $area, $eff_rout, $prog, undef);
    my $klf = make_klf_for_wpf_and_limits($wpf_name, $limits, $eff_rout);
    return $klf;
}

sub make_klf_for_wpf_and_limits{
    my ($wpf_name, $limit_records, $effective_routing) = @_;
    my $parms = get_parameters_from_prod_wpfs([$wpf_name]);
    my $klf = get_header($effective_routing, "Generated from Keithley::KLFGen for wpf $wpf_name");
    my $added = add_limit_record_list(\$klf, $limit_records);

    # add a dummy, disabled limit for everything not in the provided limit records.
    # limit records may already be filtered by functionality -> may not just be what's missed.
    foreach my $parm (keys %{$parms}){
        unless (defined $added->{$parm}){
            my $entry = KLFEntry->new($parm);
            $entry->set_test(0);
            $klf .= $entry->get_text();
        }
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

sub add_limit_record_list{
    my ($text_ref, $limit_records) = @_;
    my %added;
    foreach my $limit (@{$limit_records}){
        my $parm = $limit->get("ETEST_NAME");
        $added{$parm} = "yep";
        $$text_ref .= $limit->get_klf_entry()->get_text();
    }
    return \%added;
}

sub get_parameters_from_prod_wpfs{
    my ($wpfs) = @_;
    my %parms;
    my $current_file;
    eval{
        my %ktms;
        foreach my $wpf_name (@{$wpfs}){
            $current_file = $wpf_name;
            my $wpf_arch = Archive::get_std_rcs_file($wpf_name);
            my $wpf_text = Archive::read_prod($wpf_arch);
            my $wpf = Parse::WPF->new($wpf_text);
            my $ktms = $wpf->get_all_ktms();
            @ktms{@{$ktms}} = @{$ktms};
        }
        foreach my $ktm_name (keys %ktms){
            $current_file = $ktm_name;
            my $ktm_arch = Archive::get_std_rcs_file($ktm_name);
            my $ktm_text = Archive::read_prod($ktm_arch);
            my $ktm = Parse::KTM->new($ktm_text);
            my $parms = $ktm->get_parameters();
            @parms{@{$parms}} = @{$parms};
        }
        1;
    } or do {
        my $e = $@;
        confess "Could not get parameters from wpfs. Current file = <$current_file>. Error : $e";
    };
    return \%parms;
}



1;
