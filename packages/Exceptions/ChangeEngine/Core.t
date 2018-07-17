use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Exceptions::ChangeEngine::Core;

my $sth = Exceptions::ChangeEngine::Core::get_exception_source_sth();
ok(defined $sth, "get statement handle");

my $known_exception = 0;
my $known_source = "Testing purposes";
my $source = Exceptions::ChangeEngine::Core::get_exception_source($known_exception);
is($source, $known_source, "Get source for exception $known_exception");

