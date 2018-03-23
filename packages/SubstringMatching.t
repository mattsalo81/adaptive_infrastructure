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

