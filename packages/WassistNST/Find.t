use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use WassistNST::Find;

my ($body, $source, $info);



my $known_coordref_wcf = "T520A0";
my $known_wcf = "DMOS5_1850LBC8LVISO.07BBSS_T520A0_20150113162459_wfcfg.xml";
my $known_contents1 = "NCH_S5N_104";

my $known_coordref_photo = "B206AAAA";
my $known_url = "http://home.dal.design.ti.com/~dt_user/pointers/dm5_wassist/B206AAAA";
my $known_contents2 = "PISOGOIDNW1AV2";

($body, $source, $info) = WassistNST::Find::for_coordref($known_coordref_wcf);
ok(defined $body, "found a body for $known_coordref_wcf");
ok((defined $body) && $$body =~ m/$known_contents1/, "Contents contained expected regex");
is($source, "WCR", "Found body using wcr");
is($info, $known_wcf, "Found using expected wcf");


($body, $source, $info) = WassistNST::Find::for_coordref($known_coordref_photo);
ok(defined $body, "found a body for $known_coordref_photo");
ok((defined $body) && ($$body =~ m/$known_contents2/), "Contents contained expected regex");
is($source, "PhotoDoc", "Found body using photo docs");
is($info, $known_url, "Found using expected url");
