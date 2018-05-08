use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use DBI;
use ProcessOptions::ProcessEncoder;
use ProcessOptions::ProcessDecoder;

my @random_words = (
    'THANG',
    'THING',
    'THINK',
    'THANK',
    'HUNK',
    'HONK',
    'HANK',
    'HAND',
    'HANG',
);

my $word1 = $random_words[int(rand(scalar @random_words - 1))] . "1";
my $word2 = $random_words[int(rand(scalar @random_words - 1))] . "2";
my $word3 = $random_words[int(rand(scalar @random_words - 1))] . "3";

my $array1 = [$word1];
my $array2 = [$word2];

if (rand(1) > .5){
    push @{$array1}, $word3;
}else{
    push @{$array2}, $word3;
}

my $lookup = {
    CODE1	=>	$array1,
    CODE2	=>	$array2,
};

ProcessEncoder::update_code("TEST2", 0, $lookup);
ok(1, "didn't die when updating!");

my @match1 = sort @{ProcessDecoder::get_options_for_code("TEST2", 0, "CODE1")};
is(scalar @match1, scalar @{$array1} , "Found correct number of entries");
my $str1 = join(", ", sort @{$array1});
is(join(", ", sort @match1), $str1, "Found correct matches");

my @match2 = sort @{ProcessDecoder::get_options_for_code("TEST2", 0, "CODE2")};
is(scalar @match2, scalar @{$array2}, "Found correct number of entries");
my $str2 = join(", ", sort @{$array2});
is(join(", ", sort @match2), $str2, "Found correct matches");

dies_ok(sub{ProcessEncoder::update_code("TEST3", 0, {'!@#$%^&*()\'' => "TEST"})}, "Will not upload weird characters to DB");
dies_ok(sub{ProcessEncoder::update_code("TEST3", 0, {'TEST' => '!@#$%^&*()\''})}, "Will not upload weird characters to DB");

