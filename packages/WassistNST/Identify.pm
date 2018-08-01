package WassistNST::Identify;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

sub is_valid_format{
        my ($body_ref) = @_;
        return (is_nst($body_ref) || is_wassist($body_ref));
}

sub identify{
    my ($body_ref) = @_;
    my $rev;
    $rev = is_nst($body_ref);
    if($rev){
        return ("NST", $rev);
    }
    $rev = is_wassist($body_ref);
    if($rev){
        return ("WASSIST", $rev);
    }
    if (is_html($body_ref)){
        return ("HTML", undef);
    }
    if (is_chipopt($body_ref)){
        return ("CHIPOPT", undef);
    }
    confess "Could not identify file type for : " . $$body_ref;
}

sub is_nst{
        my ($text_ref) = @_;
        my $type;
        if ($$text_ref =~ m/summary_file_version = '(\S+)'/){
                return "NST-$1";
        }else{
                return 0;
        }
        return undef;
}

sub is_wassist{
        my ($text_ref) = @_;
        my $type;
        if ($$text_ref    =~ m/>>>>>  WASSIST (\S*) v(\S+)  <<<<</){
                return "WASSIST-$1-v$2";
        }else{
                return 0;
        }
        return undef;
}

sub is_chipopt{
        my ($text_ref) = @_;
        if ($$text_ref =~ m/^[^\n]*chipopt/i){
                return "CHIPOPT";
        }
        return 0;
}

sub is_html{
        my ($text_ref) = @_;
        if ($$text_ref =~ m/^[^\n]*DOCTYPE HTML/){
                return "HTML";
        }
        return 0;
}


1;
