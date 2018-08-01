package URL;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $stored_proxy = undef;
store_proxy();
restore_proxy();

sub store_proxy{
    if (exists $ENV{"http_proxy"}){
        $stored_proxy = $ENV{"http_proxy"};
    }else{
        $stored_proxy = undef;
    }
}

sub set_default_proxy{
    $ENV{"http_proxy"} = "wwwgate.ti.com:80";
}

sub delete_proxy{
    delete $ENV{"http_proxy"};
}

sub restore_proxy{
    if(defined $stored_proxy){
        $ENV{"http_proxy"} = $stored_proxy;
    }else{
        delete $ENV{"http_proxy"};
    }
}

sub check_if_url_exists{
    my ($url) = @_;
    my $exists;
    $exists = _check_if_url_exists($url);
    return $exists if $exists;
    store_proxy();
    set_default_proxy();
    $exists = _check_if_url_exists($url);
    if ($exists){
        restore_proxy();
        return $exists;
    }
    delete_proxy();
    $exists = _check_if_url_exists($url);
    if ($exists){
        restore_proxy();
        return $exists;
    }
    restore_proxy();
    return 0;
}

# returns timestamp if a URL returns a 200 or 300 code
# otherwise false
sub _check_if_url_exists{
        my ($url) = @_;
        my $response = `curl --silent -I "$url"`;
        my $code = $response;
        $code =~ s/\n.*//s;
        $code =~ s/^\S+\s+//s;
        if ($code =~ m/^[23]/s){
                my $timestamp = $response;
                $timestamp =~ s/.*Last-Modified:\s*//s;
                $timestamp =~ s/\n.*//s;
                return convert_curl_timestamp_to_str($timestamp);
        }else{
                return 0;
        }
        return undef;
}

sub download_url{
    my ($url) = @_;
    my $exists;
    $exists = _check_if_url_exists($url);
    return _download_url($url) if $exists;
    store_proxy();
    set_default_proxy();
    $exists = _check_if_url_exists($url);
    if ($exists){
        my $body = _download_url($url);
        restore_proxy();
        return $body;
    }
    delete_proxy();
    $exists = _check_if_url_exists($url);
    if ($exists){
        my $body = _download_url($url);
        restore_proxy();
        return $body;
    }
    restore_proxy();
    return undef;
}

sub _download_url{
    my ($url) = @_;
    my $curl = "curl --silent $url";
    my $text_body = `$curl`;
    return $text_body;
}


sub convert_curl_timestamp_to_str{
        my ($timestamp) = @_;
        # Wed, 27 Jul 2011 19:17:35 GMT
        my ($dow, $dom, $mon, $year, $hrminsec, $zone) = split /\s+/, $timestamp;
        return 0 unless defined $hrminsec;
        my ($hr, $min, $sec) = split(/:/, $hrminsec);
        my %mon2num = (
                Jan => 1,
                Feb => 2,
                Mar => 3,
                Apr => 4,
                May => 5,
                Jun => 6,
                Jul => 7,
                Aug => 8,
                Sep => 9,
                Oct => 10,
                Nov => 11,
                Dec => 12,
        );
        confess "No way to convert month <$mon> to string" unless defined $mon2num{$mon};
        return sprintf("%04d%02d%02d%02d%02d%02d", $year, $mon2num{$mon}, $dom, $hr, $min, $sec);
}

1;
