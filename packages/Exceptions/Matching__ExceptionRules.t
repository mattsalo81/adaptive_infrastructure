use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Exceptions::ExceptionRules;

ok( ExceptionRules::numeric_comparison(99, '<', '100'), '< Test');
ok(!ExceptionRules::numeric_comparison(99, '>', '100'), '> Test');
ok(!ExceptionRules::numeric_comparison(99, '>=', '100'), '>= Test');
ok( ExceptionRules::numeric_comparison(99, '<=', '100'), '<= Test');
ok(!ExceptionRules::numeric_comparison(99, '=>', '100'), '=> Test');
ok( ExceptionRules::numeric_comparison(99, '=<', '100'), '=< Test');
ok(!ExceptionRules::numeric_comparison(101, '<', '100'), '< Test');
ok( ExceptionRules::numeric_comparison(101, '>', '100'), '> Test');
ok(!ExceptionRules::numeric_comparison(101, '<=', '100'), '<= Test');
ok( ExceptionRules::numeric_comparison(101, '>=', '100'), '>= Test');
ok(!ExceptionRules::numeric_comparison(101, '=<', '100'), '=< Test');
ok( ExceptionRules::numeric_comparison(101, '=>', '100'), '=> Test');
ok( ExceptionRules::numeric_comparison(100, '=', '100'), '= Test');
ok(!ExceptionRules::numeric_comparison(99, '=', '100'), '= Test');
ok( ExceptionRules::numeric_comparison(100, '==', '100'), '== Test');
ok(!ExceptionRules::numeric_comparison(99, '==', '100'), '== Test');
ok(!ExceptionRules::numeric_comparison(100, '<>', '100'), '<> Test');
ok( ExceptionRules::numeric_comparison(99, '<>', '100'), '<> Test');
ok(!ExceptionRules::numeric_comparison(100, '><', '100'), '>< Test');
ok( ExceptionRules::numeric_comparison(99, '><', '100'), '>< Test');
ok( ExceptionRules::numeric_comparison(101, '>>', '100'), '>> Test');
ok(!ExceptionRules::numeric_comparison(99, '>>', '100'), '>> Test');
ok(!ExceptionRules::numeric_comparison(101, '<<', '100'), '<< Test');
ok( ExceptionRules::numeric_comparison(99, '<<', '100'), '<< Test');
ok(!ExceptionRules::numeric_comparison(100, '!=', '100'), '!= Test');
ok( ExceptionRules::numeric_comparison(99, '!=', '100'), '!= Test');

ok( ExceptionRules::anchored_regex_with_numeric_comparison('any',  ''), 'Comparing any to //');
ok( ExceptionRules::anchored_regex_with_numeric_comparison('any',  '.*'), 'Comparing any to /.*/');
ok( ExceptionRules::anchored_regex_with_numeric_comparison('SMN_IOFS',  'SM._IOFS'), 'Comparing SMN_IOFS to /SM._IOFS/');
ok( ExceptionRules::anchored_regex_with_numeric_comparison('SMP_IOFS',  'SM._IOFS'), 'Comparing SMP_IOFS to /SM._IOFS/');
ok(!ExceptionRules::anchored_regex_with_numeric_comparison('SMN_BVD',  'SM._IOFS'), 'Comparing SMN_BVD to /SM._IOFS/');
ok( ExceptionRules::anchored_regex_with_numeric_comparison('SMN_BVD',  'SMN.*'), 'Comparing SMN_BVD to /SMN.*/');
ok(!ExceptionRules::anchored_regex_with_numeric_comparison('SMN_IOFS',  'SMN*'), 'Comparing SMN_IOFS to /SMN*/');
ok( ExceptionRules::anchored_regex_with_numeric_comparison('SMN_IOFS',  'SM(N|P).*'), 'Comparing SMN_IOFS to /SM(N|P).*/');
ok( ExceptionRules::anchored_regex_with_numeric_comparison('42',  '[0-9]+'), 'Comparing 42 to /[0-9]+/');
ok( ExceptionRules::anchored_regex_with_numeric_comparison('string',  '^.*$'), 'Comparing string to /^.*$/');
ok(!ExceptionRules::anchored_regex_with_numeric_comparison('Str',  '>0'), 'Comparing Str to />0/');
ok(!ExceptionRules::anchored_regex_with_numeric_comparison('Str',  '//\\'), 'Comparing Str to ///\\/');
ok(!ExceptionRules::anchored_regex_with_numeric_comparison('\\',  '\/\/'), 'Comparing \\ to /\/\//');
ok(!ExceptionRules::anchored_regex_with_numeric_comparison('CaSe',  'CASE'), 'Comparing CaSe to /CASE/');
dies_ok(sub {ExceptionRules::anchored_regex_with_numeric_comparison(undef, 'any')}, 'Comparing undef to /any/');
dies_ok(sub {ExceptionRules::anchored_regex_with_numeric_comparison('any',  undef)}, 'Comparing any to //');

ok( ExceptionRules::anchored_regex_with_numeric_comparison('42.0',  '==42'), 'Comparing 42.0 to ==42');
ok(!ExceptionRules::anchored_regex_with_numeric_comparison('1234',  '>5000'), 'Comparing 1234 to >5000');


ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('42.0',  '==42'), 'Comparing 42.0 to ==42');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('1234',  '>5000'), 'Comparing 1234 to >5000');
ok( ExceptionRules::explicit_anchored_regex_with_numeric_comparison('42.0',  '/==42/'), 'Comparing 42.0 to ==42');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('1234',  '/>5000/'), 'Comparing 1234 to >5000');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_IOFS',  'SM._IOFS'), 'Comparing SMN_IOFS to /SM._IOFS/');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMP_IOFS',  'SM._IOFS'), 'Comparing SMP_IOFS to /SM._IOFS/');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_BVD',  'SM._IOFS'), 'Comparing SMN_BVD to /SM._IOFS/');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_BVD',  'SMN.*'), 'Comparing SMN_BVD to /SMN.*/');
ok( ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_IOFS',  '/SM._IOFS/'), 'Comparing SMN_IOFS to /SM._IOFS/');
ok( ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMP_IOFS',  '/SM._IOFS/'), 'Comparing SMP_IOFS to /SM._IOFS/');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_BVD',  '/SM._IOFS/'), 'Comparing SMN_BVD to /SM._IOFS/');
ok( ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_BVD',  '/SMN.*/'), 'Comparing SMN_BVD to /SMN.*/');
ok(!ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_BVD',  '/.*/.*'), 'Comparing SMN_BVD to /SMN.*/');
ok( ExceptionRules::explicit_anchored_regex_with_numeric_comparison('SMN_BVD',  ''), 'Comparing SMN_BVD to //');


