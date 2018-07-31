use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $usage = qq{
    Audits the raw component information between old/new adaptive.
    Needs : New Adaptive Technology
    Needs : old adaptive component lookup

    Usage :      $0 <TECH> <comp_lookup.csv"
};

my ($tech, $file) = @ARGV;
die "$usage" unless (defined $tech) && (defined $file);

my $new = get_raw_comp_tech($tech);
my $old = read_old_dev_2_comp_csv($file);
my @all_dup = keys %{$new}, keys %{$old};
my %all;
@all{@all_dup} = @all_dup;
foreach my $device (keys %all){
    my $newc = $new->{$device};
    my $oldc = $old->{$device};
    if (defined $newc){
        if (defined $oldc){
            # added
            foreach my $comp (keys %{$newc}){
                print "$device,ADDED,$comp\n" unless defined $oldc->{$comp};
            }
            # removed
            foreach my $comp (keys %{$oldc}){
                print "$device,REMOVED,$comp\n" unless defined $newc->{$comp};
            }
        }else{
            print "$device,NEW_INFO,\n";
        }
    } else{
        print "$device,LOST_INFO,\n";
    }
}



sub get_raw_comp_tech{
    my ($tech) = @_;
    my $conn = Connect::read_only_connection("etest");
    my $sql = q{select device, component from device_component_info where technology = ?};
    my $sth = $conn->prepare($sql);
    $sth->execute($tech);
    my %comp;
    while (my $rec = $sth->fetchrow_hashref("NAME_uc")){
        my $dev = $rec->{"DEVICE"};
        confess "Device not defined in " . Dumper($rec) unless defined $dev;
        my $comp = $rec->{"COMPONENT"};
        confess "Component not defined in " . Dumper($rec) unless defined $comp;
        $comp{$dev} = {} unless defined $comp{$dev};
        $comp{$dev}->{$comp} = 1;
    }
    return \%comp;
}


# takes csv
# returns hash of all devices to a hash-set of components
sub read_old_dev_2_comp_csv{
    my ($csv) = @_;
    open my $fh, "$csv" or die "Could not open <$csv> for reading";
    my @lines = <$fh>;
    close $fh;

    # filter out blank and whitespace lines
    @lines = grep {$_ !~ m/^\s*$/} @lines;
    @lines = map {$_ =~ s/\n//g; $_} @lines;
    my @header = split(/,/, shift @lines);
    # Device,Coord File,Setup File,Setup Comp Dir Found,CompCount Found,File Used,BIDI25_12SCR
    # Device,Coord File,Setup File,Setup Comp Dir Found,CompCount Found,File Used,
    my ($device, $coord, $setup, $dir, $comp, $file, @components) = @header;
    confess "unexpected header, device" unless $device =~ m/device/i;
    confess "unexpected header, coord " unless $coord =~ m/coord file/i;
    confess "unexpected header, setup " unless $setup =~ m/setup file/i;
    confess "unexpected header, dir   " unless $dir =~ m/setup comp dir/i;
    confess "unexpected header, comp  " unless $comp =~ m/compcount found/i;
    confess "unexpected header, file  " unless $file =~ m/file/i;
    my %comp;
    foreach my $line (@lines){
        $line =~ s/\s//g;
        my ($dev, $coordref, $set, $d, $cmp, $fle, @comp) = split /,/, $line;
        my %my_comps;
        my $any_comps = 0;
        for(my $i = 0; $i < scalar @comp; $i++){
            if ($comp[$i]){
                $my_comps{$components[$i]} = 1;
                $any_comps = 1;
            }
        }
        if($any_comps){
            $comp{$dev} = \%my_comps;
        }
    }
    return \%comp;
}
