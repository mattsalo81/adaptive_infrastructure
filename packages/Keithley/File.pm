package Keithley::File;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::Project;
use Keithley::Archive;

# package handles getting/saving files.  Can do archive/project directories

# takes a file and an optional archive flag. 
# find file, reads content into scalar, and returns text.
# defaults to current project, but archive flag can be used for PROD version of archived file 
sub get_text{
    my ($file, $arch) = @_;
    my $text;
    if((defined $arch) && $arch){
        $text = Archive::get_text($file);
    }else{
        $text = Project::get_text($file);
    }
    return $text;
}

# takes a file, some text, and an optional archive flag
# saves the text to the given file.  Defaults to the local project, but
# if ARCHIVE flag is set and true, then file will be queued for archival
# (install all queued files with 'commit')
sub save_text{
    my ($file, $text, $arch) = @_;
    if((defined $arch) && $arch){
        Archive::queue_archival($file, $text);
    }else{
        Project::save_text($file, $text);
    }
}

# commits all files queued for archival.  Does not do anything for the local project
sub commit{
    my ($arch) = @_;
    if ((defined $arch) && $arch){
        Archive::install_all();
    }else{
        # project files are already committed
    }
}

1;
