package PhotoDoc::WassistNST;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use URL;

my $north_wassist_dir = "http://home.dal.design.ti.com/~dt_user/pointers/dm4_wassist";
my $south_wassist_dir = "http://home.dal.design.ti.com/~dt_user/pointers/dm5_wassist";

# confess "Could not connect to Photo team's website, is your network configured correctly?" unless URL::check_if_url_exists($south_wassist_dir);

# given a coordref, returns a list of pointers to the text of the wassist/nst
sub get_wassist_bodies{
    my ($coordref) = @_;
    my $urls = find_wassist_urls($coordref);
    my %bodies;
    foreach my $url (@{$urls}){
        my $body = URL::download_url($url);
        $bodies{$url} = \$body;
    }
    return \%bodies;
}

# given a coordref, returns the possible urls of the wassist/nst or undef
sub find_wassist_urls{
    my ($coordref) = @_;
    my %urls;
    confess "$coordref is not defined" unless defined $coordref;
    $coordref =~ s/[^-_a-zA-Z0-9]//g;
    if ($coordref ne ""){
        foreach my $dir ($south_wassist_dir, $north_wassist_dir){
            # check default case
            my $url = "$dir/$coordref";
            my $stamp = URL::check_if_url_exists($url);
            Logging::diag("URL <$url> " . ($stamp ? "exists" : "does not exist"));
            if ($stamp){
                    $urls{$url} = $stamp;
            }
            # check all lowercase
            if ($coordref =~ m/[a-z]/i){
                $url = $coordref;
                $url =~ tr/[A-Z]/[a-z]/;
                $url = "$dir/$url";
                # check lowercase
                my $stamp = URL::check_if_url_exists($url);
                if ($stamp){
                    $urls{$url} = $stamp;
                }
            }
        }
    }
    # sort list by most recent file
    Logging::diag("found " . (scalar keys %urls) . " url(s) for $coordref");
    my @prioritized = sort {$urls{$b} <=> $urls{$a}} keys %urls;
    return \@prioritized;
}


1;
