use warnings;
use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
use LOGGING;
require Test::Homebrew_Exception;

my $tempfile = "/tmp/.logging-test-file-asdfasdfasdfasdf";

open my $temp, ("> $tempfile") or die "Could not open tmp file for writing";
LOGGING::set_log($temp);
LOGGING::set_level("debug");

LOGGING::event("This should be here");
LOGGING::debug("This should be here");
LOGGING::diag("This should not be here");

open my $null, ("/dev/null") or die "Could not open /dev/null";
LOGGING::set_log($null);

open $temp, $tempfile or die "Could not open tmp file for reading";
my @text = <$temp>;
my $text = join "", @text;
close $temp;
ok($text =~ m/This should be here\nThis should be here\n$/, "basic logging");
