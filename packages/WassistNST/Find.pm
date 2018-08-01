package WassistNST::Find;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use WassistNST::Identify;
use WCR::WassistNST;
use PhotoDoc::WassistNST;

sub for_coordref{
    my ($coordref) = @_;
    my ($body, $source, $info);
    # WCR first
    ($body, $info) = WCR::WassistNST::get_body_for_coordref($coordref);
    $source = "WCR";
    if (defined $body && WassistNST::Identify::is_valid_format($body)){
        return ($body, $source, $info);
    }
    # check Photo sites
    my $bodies = PhotoDoc::WassistNST::get_wassist_bodies($coordref);
    foreach my $url (keys %{$bodies}){
        $body = $bodies->{$url};
        $source = "PhotoDoc";
        $info = $url;
        return ($body, $source, $info) if WassistNST::Identify::is_valid_format($body);
    }
    return (undef, undef, undef);
}


1;
