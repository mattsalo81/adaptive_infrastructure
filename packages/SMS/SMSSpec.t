use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SMS::SMSSpec;

my $raw_rec = {TECHNOLOGY => "thing", PROGRAM=> "prog", DEVICE=>"dev", LPT=>9300, OPN=>8820};
my $rec = SMSSpec->new($raw_rec);
foreach my $key (keys %{$raw_rec}){
    ok(defined $rec->{$key}, "object has $key");
    is($rec->{$key}, $raw_rec->{$key}, "object has same value of $key");
}

is($rec->get("TECHNOLOGY"), "thing", "getter method works fine");
dies_ok(sub{$rec->get("doesn't exist")}, "Getter method on nonexistant member");

is($rec->unique_id(), "dev 9300 8820", "Generated unique key");
