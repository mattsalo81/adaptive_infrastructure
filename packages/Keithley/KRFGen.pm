package KRFGen;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

sub get_text{
    my ($recipe, $cpf, $wdf, $klf, $device_string) = @_;
    $recipe = clean_filename($recipe, "krf");
    $cpf = clean_filename($cpf, "cpf");
    $wdf = clean_filename($wdf, "wdf");
    $klf = clean_filename($klf, "klf");
    my $date = get_date();
    my $text = qq{
        # Keithley Recipe Definition File
        Version,1.0
        File,$recipe.krf
        Date,$date
        Comment,Auto-generated by adaptive infrastructure
        RevID,\$Revision: 1.0 \$
        <EOH>
        cpf,$cpf.cpf
        wdf,$wdf.wdf
        klf,$klf.klf
    };
    if (defined $device_string && $device_string !~ m{^/*$}){
        $text .= "usrField2,$device_string\n" if defined $device_string
    }
    $text .= q{
        command_line,
        <EOR>
    };
    $text = join("\n", map {s/^\s*//; $_} grep {m/\S/} split(/\n/, $text));
    #append a newline so KRM works
    return $text . "\n";
}

# removes directory info and file extension
sub clean_filename{
    my ($filename, $fext) = @_;
    $filename =~ s#.*/##;
    $filename =~ s/\.$fext//i;
    return $filename;
}

sub get_date{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $nice_timestamp = sprintf ( "%02d/%02d/%04d", $mon+1, $mday, $year+1900);
    return $nice_timestamp;
}

1;
