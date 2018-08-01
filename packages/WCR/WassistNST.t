use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use WCR::WassistNST;

my $known_coordref = "704038C0";
my $known_wcf = "DMOS5_1833LBC8.03ZEJ_704038C0_20161208212608_wfcfg.xml";

my $body1 = WCR::WassistNST::get_body_for_wcf($known_wcf);
my ($body2, $wcf) = WCR::WassistNST::get_body_for_coordref($known_coordref);

is($wcf, $known_wcf, "found the expected wcf through the given coordref");
ok(defined $body1, "found body for wcf");
ok(defined $body2, "found body for coordref");
is($$body1, $$body2, "Identical bodies found for corresponding coordref/wcf");
ok($$body1 ne "", "bodies were not empty");
