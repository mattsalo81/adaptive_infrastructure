use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::ProcessDecoder;
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

throws_ok(sub{ProcessDecoder::get_options_for_code("I DO NOT EXIST", 0, "ASKJfaso")}, 'No options found', "dies if cannot find any options");
throws_ok(sub{ProcessDecoder::get_options_for_code("TEST", undef, undef)}, 'No options found', "dies if cannot find any options");


@options = @{ProcessDecoder::get_options_for_code("TEST", 0, "BLANK")};
is(scalar @options, 0, "Successfully returns 0 options if \$ProcessDecoder::placeholder_option is the only option found.");
