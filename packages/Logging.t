use warnings;
use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Logging;
require Test::Homebrew_Exception;

my $tempfile = "/tmp/.logging-test-file-asdfasdfasdfasdf";

open my $temp, ("> $tempfile") or die "Could not open tmp file for writing";
Logging::set_log($temp);
Logging::set_level("debug");

Logging::event("This should be here");
Logging::debug("This should be here");
Logging::diag("This should not be here");

Logging::set_err($temp);
Logging::error("ERROR");

open my $null, ("/dev/null") or die "Could not open /dev/null";
Logging::set_log($null);

open $temp, $tempfile or die "Could not open tmp file for reading";
my @text = <$temp>;
my $text = join "", @text;
close $temp;
ok($text =~ m/This should be here\nThis should be here\nERROR\n$/, "basic logging");
