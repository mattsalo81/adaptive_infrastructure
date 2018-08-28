package Project;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my %filetype_lookup = (
    ktm         => "KI_KTXE_KTM",
    uap         => "KI_KTXE_UAP",
    cpf         => "KI_KTXE_CPF",
    krf         => "KI_KTXE_KRF",
    klf         => "KI_KTXE_KLF",
    wdf         => "KI_KTXE_WDF",
    wpf         => "KI_KTXE_WPF",
    ktm         => "KI_KTXE_KTM",
    gdf         => "KI_KTXE_GDF",
);

our $no_file_error = "File could not be found";

sub get_text{
    my ($file) = @_;
    my $path = get_local_file($file);
    unless (-f $path){
        confess "$no_file_error <$path>";
    }
    open my $fh, "$path" or confess "Could not read <$path>";
    my $text = "";
    while(my $line = <$fh>){
        $text .= $line;
    }
    close $fh;
    return $text;
}

sub get_local_file{
    my ($file) = @_;
    my $base_file = $file;
    $base_file =~ s#.*/##;
    my $fext;
    if($base_file =~ m/^([^\.]+).([^\.,]+)$/){
        ($base_file, $fext) = ($1, $2);
    }else{
        confess "Could not parse <$file> to get directory, base name, and file extension"
    }
    my $std_dir = $filetype_lookup{$fext};
    unless (defined $std_dir){
        confess "No standard file directory for file type $fext on file <$file>";
    }
    my $std = $ENV{$std_dir} . "/$base_file.$fext";
    return $std;
}

sub save_text{
    my ($file, $text) = @_;
    my $path = get_local_file($file);
    Logging::debug("Writing file <$file> in Project");
    open my $fh, "> $path" or confess "Could not open <$path> for writing";
    print $fh $text;
    close $fh;
}

1;
