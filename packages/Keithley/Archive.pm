package Archive;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my %filetype_lookup = (
    ktm         => "ktm",
    uap         => "uap",
    cpf         => "cpf",
    krf         => "recipe",
    klf         => "klf",
    wpf         => "wpf",
    ktm         => "ktm",
    gdf         => "gdf",
);

my $rcs_ext = ",v";
unless (defined $ENV{"KI_ARCHIVE"}){
    confess "KI_ARCHIVE environment variable is not set!";
}

our $no_file_error = "File could not be found";

sub read_prod{
    my ($file_path) = @_;
    unless (-f $file_path){
        confess "$no_file_error <$file_path>";
    }
    my $cmd = "co -pPROD $file_path 2> /dev/null |";
    open my $fh, "$cmd" or confess "Could not run '$cmd'";
    my @text = <$fh>;
    my $text = join("\n", @text);
    return $text;
}

sub get_std_rcs_file{
    my ($file) = @_;
    my $base_file = $file;
    $base_file =~ s#.*/##;
    my $fext;
    if($base_file =~ m/^([^\.]+).([^\.,]+)($rcs_ext)?$/){
        ($base_file, $fext) = ($1, $2);
    }else{
        confess "Could not parse <$file> to get directory, base name, and file extension"
    }
    my $std_dir = $filetype_lookup{$fext};
    unless (defined $std_dir){
        confess "No standard file directory for file type $fext on file <$file>";
    }
    my $std = $ENV{"KI_ARCHIVE"} . "/$std_dir/$base_file.$fext" . $rcs_ext;
    unless (-f $std){
        confess "$no_file_error <$std>";
    }
    return $std;
}

1;
