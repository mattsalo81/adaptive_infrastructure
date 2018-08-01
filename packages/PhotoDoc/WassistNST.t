use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use PhotoDoc::WassistNST;
use Data::Dumper;
use Logging;

my $known_coordref = "X2421R10";
my $known_text = "VIA6LM1CV1P12";
my $known_multiple_url_coordref = "X2421R10";
my $known_urls = [
    'http://home.dal.design.ti.com/~dt_user/pointers/dm4_wassist/X2421R10',
    'http://home.dal.design.ti.com/~dt_user/pointers/dm5_wassist/X2421R10'
];

my $urls = PhotoDoc::WassistNST::find_wassist_urls($known_multiple_url_coordref);
ok(lists_identical($urls, $known_urls), "Found known URLs, prioritized by date");
my $bodies = PhotoDoc::WassistNST::get_wassist_bodies($known_coordref);
ok(scalar keys %{$bodies}, "found bodies of $known_coordref");
my @keys = keys %{$bodies};
my $key = $keys[0];
ok(${$bodies->{$key}} =~ m/$known_text/, "Found some known text in the body");
