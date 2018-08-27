package Archive;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

# package manages Archived files.  Files can be requested by name
# using get_text and the PROD versions will be retreived from the archive
#
# Files SAVED to the archive are put into a temporary directory, and at script end are installed into the archive

my %filetype_lookup = (
    ktm         => "ktm",
    uap         => "uap",
    cpf         => "cpf",
    krf         => "recipe",
    klf         => "klf",
    wpf         => "wpf",
    wdf         => "wdf",
    ktm         => "ktm",
    gdf         => "gdf",
);

# Configure
my $tmp_dir = "/tmp/.adaptive_infrastructure__Keithley__Archive";
mkdir $tmp_dir unless (-d $tmp_dir);

my $rcs_ext = ",v";
unless (defined $ENV{"KI_ARCHIVE"}){
    confess "KI_ARCHIVE environment variable is not set!";
}

my %file_types_to_install;

our $no_file_error = "File could not be found";

# subroutines

sub get_text{
    my ($file) = @_;
    my $prod = get_std_rcs_file($file);
    my $text = read_prod($prod);
    return $text;
}

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

# puts the file in the tmp directory
sub queue_archival{
    my ($file, $text) = @_;
    Logging::debug("Queuing <$file> for archival");
    configure_tmp();
    my $file_ext = $file;
    $file_ext =~ s/.*\.//;
    confess "Unexpected file type <$file_ext>" unless defined $filetype_lookup{$file_ext};
    $file_types_to_install{$file_ext} = 1;
    my $tmp_file = "$tmp_dir/$file";
    open my $fh, "> $tmp_file" or confess "Could not save copy of file (to archive) in <$tmp_file>";
    print $fh $text;
    close $fh;
}

# empties the tmp directory if nothing's been added yet
sub configure_tmp{
    if(scalar keys %file_types_to_install == 0){
        unlink(glob("$tmp_dir/*"));
    }
}

# installs all file types added to the tmp directory
sub install_all{
    foreach my $file_type (keys %file_types_to_install){
        Logging::event("Installing <$file_type> type files...");
        system("krm_mass_coci.pl '$tmp_dir' '$file_type' 'Automated Recipe Generator' -auto > /dev/null");
        delete $file_types_to_install{$file_type};
        unlink(glob("$tmp_dir/*.$file_type"));
    }
}

1;
