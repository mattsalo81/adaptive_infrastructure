use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Database::PrimaryKeys;

my $known_database = 'etest';
my $known_table = 'daily_sms_extract';
my $known_fake = 'I DO NOT EXIST';
my $known_keys = [qw(DEVICE LPT OPN)];

# PRIMARY KEYS
ok(lists_identical(PrimaryKeys::get_primary_key_attributes($known_database, $known_table), $known_keys), 'Correctly fetch ordered primary key attributes from known table');

# CHECK IF TABLE EXISTS


ok( PrimaryKeys::does_table_exist($known_database, $known_table), "Known table exists");
ok(!PrimaryKeys::does_table_exist($known_database, $known_fake), "Fake table does not exist");
dies_ok(sub{PrimaryKeys::does_table_exist($known_fake, $known_table)}, "known table in fake database does not exist");
dies_ok(sub{PrimaryKeys::does_table_exist($known_fake, $known_fake)}, "fake table in fake db");


