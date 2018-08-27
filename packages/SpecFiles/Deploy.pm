package SpecFiles::Deploy;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $tmp_dir = '/tmp/.adaptive_infrastructre__SpecFiles__Deploy';
mkdir $tmp_dir unless -d $tmp_dir;
my %prog2spec;
my $common_dir_from_q3030 = "/dm5/ki/specfiles";
my $common_dir_from_parm5tst = "/dm5/ki/specfiles";
my $program_dir_from_q3030 = '/usr1/testware/scraptest';
my $program_dir_from_parm5tst = '/usr1/testware/scraptest';

#init();

sub init{
    unlink glob "$tmp_dir/*";
    %prog2spec = ();
    mkdir $common_dir_from_q3030 unless -d $common_dir_from_q3030;
}

sub save{
    my ($program, $file_name, $text) = @_;
    my $tmp_file = "$tmp_dir/$file_name";
    open my $fh, "> $tmp_file" or confess "Could not open <$tmp_file> for reading";
    print $fh, $text;
    close $fh;
    $prog2spec{$program} = $file_name;
}

sub create_migration_info{
    
}

sub tar_tmp_files{
    my $stamp = get_timestamp();
    my $tar = $common_dir_from_q3030 . "/adaptive_spec__$stamp.tar";
    `tar -cf '$tar' -C '$tmp_dir' .`;
}

sub get_timestamp{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $nice_timestamp = sprintf ( "%04d_%02d_%02d__%02d_%02d_%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;
}

1;
