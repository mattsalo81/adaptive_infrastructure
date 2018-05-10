use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use ProcessOptions::OptionLookup;
use Data::Dumper;

my $known_tech  = 'TEST';
my $eff_1       = 'EFF_ROUT_1';
my $eff_2       = 'EFF_ROUT_2';
my $missing_eff = 'THIS DOES NOT EXIST';
my $opt1        = 'OPTION1';
my $opt2        = 'OPTION2';
my $opt2_case   = 'optION2';

#query test
my $sth = OptionLookup::get_options_for_effective_routing_sth();
ok(defined $sth, "Query defined");

# get options test
my $opt = OptionLookup::get_options_for_effective_routing($known_tech, $eff_1);
my @options = sort keys %{$opt};
ok(lists_identical(\@options, [$opt1, $opt2]), "Correctly got known process options from test cases in database");

$opt = OptionLookup::get_options_for_effective_routing($known_tech, $eff_1);
@options = sort keys %{$opt};
ok(lists_identical(\@options, [$opt1, $opt2]), "Correctly got known process options from test cases in database - second time");

dies_ok(sub{OptionLookup::get_options_for_effective_routing($known_tech, $missing_eff)}, "Dies on missing effective_routing");

# option check test

ok(OptionLookup::does_effective_routing_have_option($known_tech, $eff_1, $opt1), "Returns true when option there");
ok(OptionLookup::does_effective_routing_have_option($known_tech, $eff_1, $opt2_case), "Case insensitive");
ok(!OptionLookup::does_effective_routing_have_option($known_tech, $eff_2, $opt1), "Returns false when option not there");
dies_ok(sub{OptionLookup::does_effective_routing_have_option($known_tech, $missing_eff, $opt1)}, "Dies okay when routing/tech not defined");
