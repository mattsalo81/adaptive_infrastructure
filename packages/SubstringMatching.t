use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use SubstringMatching;


is(SubstringMatching::levenshtein("1234", "1234"), 0, "Identical strings have 0 edit distance");
is(SubstringMatching::levenshtein("", "1234"), 4, "empty string okay and edit distance is length of other string");
is(SubstringMatching::levenshtein("", ""), 0, "Two empty strings ok");
is(SubstringMatching::levenshtein("4321", "1234"), 4, "reversed strings");
dies_ok(sub{SubstringMatching::levenshtein(undef, "1234")}, "Undefined strings");



is(SubstringMatching::longest_common_substring("1234", "1234"), 4, "Identical strings have max common substring");
is(SubstringMatching::longest_common_substring("111111123444444", "1234"), 4, "total substring");
is(SubstringMatching::longest_common_substring("1a2a3a4", "1234"), 1, "Common sequence is 4 but substring is 1");
