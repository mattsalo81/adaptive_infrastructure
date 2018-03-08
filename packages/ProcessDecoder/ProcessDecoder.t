use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessDecoder::ProcessDecoder;
use DBI;


my $sth1 = ProcessDecoder::get_options_for_code_sth();
my $sth2 = ProcessDecoder::get_options_for_code_sth();

is($sth1, $sth2, "multiple calls do not create unique sth");

# test cases, rely on DB vals
my @options = @{ProcessDecoder::get_options_for_code("TEST", 0, "MATT")};

is(@options, 2, "Correct number of results");
is(join(",", @options), "SHAZAM,WOW", "Correct results");

@options = @{ProcessDecoder::get_options_for_code("TEST", 1, "MATT")};
is(join(",", @options), "HEYO", "Correct results");


