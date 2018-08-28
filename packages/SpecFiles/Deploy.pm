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

init();

sub init{
    unlink glob "$tmp_dir/*";
    %prog2spec = ();
    mkdir $common_dir_from_q3030 unless -d $common_dir_from_q3030;
}

sub save{
    my ($program, $file_name, $text) = @_;
    my $tmp_file = "$tmp_dir/$file_name";
    open my $fh, "> $tmp_file" or confess "Could not open <$tmp_file> for reading";
    print $fh $text;
    close $fh;
    $prog2spec{$program} = $file_name;
}

sub commit{
    if(scalar keys %prog2spec > 0){
        create_migration_info();
    }
}

sub create_migration_info{
    my $stamp = get_timestamp();
    my $tar = tar_tmp_files($stamp);
    my $shell_file_name = "deploy_spec__$stamp.sh";
    my $cmp_dir = "/tmp/.adaptive_spec_deply_$stamp";
    my $script = qq{#!/bin/bash
        # execute me to deploy specfiles for '$stamp'
       
        # set up a comparison dir for later 
        if [ ! -d '$cmp_dir' ] ; then
            mkdir '$cmp_dir'
        fi
        cd '$cmp_dir'
        tar -xf '$common_dir_from_parm5tst/$tar'

        # extract our file into the specfile directory
        cd '$program_dir_from_parm5tst/specfiles'
        tar -xf '$common_dir_from_parm5tst/$tar'
        
    };
    foreach my $program (keys %prog2spec){
        my $spec = $prog2spec{$program};
        $script .= qq{
            # migrating '$program'
            ###############################################
            # manage program folder
            cd '$program_dir_from_parm5tst'
            if [ ! -d '$program' ] ; then
                mkdir '$program'
            fi

            # manage previous specfile
            cd '$program'
            if [ -f '$program.spec' ] ; then
                mv '$program.spec' '$program.spec-$stamp'
            fi
    
            # manage previous link
            if [ -L '$program.spec' ] ; then
                LINK_DEST="\$(readlink '$program.spec')"
                if [ "\$LINK_DEST" -ne '$program_dir_from_parm5tst/specfiles/$spec' ] ; then
                    mv '$program.spec' '$program.spec-$stamp'
                fi
            fi

            # create softlink
            if [ ! -e '$program.spec' ] ; then
                ln -s '$program_dir_from_parm5tst/specfiles/$spec' '$program.spec'
            fi


        };
    }
    $script .= qq{

        # Comparing checksums of program/spec to original file
        ######################################################
        cd '$program_dir_from_parm5tst'

    };
    foreach my $program (keys %prog2spec){
        my $spec = $prog2spec{$program};
        $script .= qq{
            CUR_CKSUM="\$(cksum '$program/$program.spec' | sed 's/[ \\t].*//')"
            COR_CKSUM="\$(cksum '$cmp_dir/$spec' | sed 's/[ \\t].*//')"
            if [ "\$CUR_CKSUM" != "\$COR_CKSUM" ] ; then
                echo "<$program> failed to deploy <$spec>.  Checksum is <\$CUR_CKSUM> but should be <\$COR_CKSUM>"
            fi
        };
    }
    my $q3030_shell = "$common_dir_from_q3030/$shell_file_name";
    my $parm5tst_shell = "$common_dir_from_parm5tst/$shell_file_name";
    open my $fh, "> $q3030_shell" or confess "Could not write to <$q3030_shell>";
    print $fh $script;
    close $fh;
    `chmod 777 $q3030_shell`;
    print "\nLog into TestWARE's server as 'parm5tst' and\n";
    print "run the following script <$parm5tst_shell> to deploy specfiles\n\n";
}


sub tar_tmp_files{
    my ($stamp) = @_;
    my $tar_name = "adaptive_spec__$stamp.tar";
    my $tar = "$common_dir_from_q3030/$tar_name";
    `tar -cf '$tar' -C '$tmp_dir' .`;
    return $tar_name;
}

sub get_timestamp{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $nice_timestamp = sprintf ( "%04d_%02d_%02d__%02d_%02d_%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;
}

1;
