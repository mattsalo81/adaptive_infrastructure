package KLFGen;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;



sub get_header{
    my ($self, $file_name, $comment) = @_;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $date = sprintf ( "%02d/%02d/%04d", $mon+1, $mda, $year+1900);

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
`    return $text;
}

sub add_limit_record_list{
    my ($text_ref, $limit_records) = @_;
    my %added;
    foreach my $limit (@{$limit_records}){
        my $parm = $limit->get("ETEST_NAME");
        $added{$parm} = "yep";
        $$text_ref .= $limit->get_klf_entry();
    }
    return \%added;
}





1;
