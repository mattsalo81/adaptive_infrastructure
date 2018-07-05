use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SMS::FastTable;
use Data::Dumper;
use Carp;

my $test_rec = [
    {
        DEVICE  =>      "DEV1",
        ROUTING =>      "ROUT1",
        PROGRAM =>      "PROG1",
    },
    {
        DEVICE  =>      "DEV2",
        ROUTING =>      "ROUT1",
        PROGRAM =>      "PROG2",
    },
    {
        DEVICE  =>      "DEV3",
        ROUTING =>      "ROUT2",
        PROGRAM =>      "PROG2",
    },
    {
        DEVICE  =>      "DEV4",
        ROUTING =>      "ROUT2",
        PROGRAM =>      "PROG3",
    },
    {
        DEVICE  =>      "DEV5",
        ROUTING =>      "ROUT3",
        PROGRAM =>      "PROG3",
    },
];

my $t;

# basic constructor tests

$t = FastTable->new([]);
ok(defined $t, "Empty table");

$t = FastTable->new([]);
is($t->{"INDEX"}, "DEVICE", "Defaults to indexing by device");

$t = FastTable->new("ROUTING", []);
is($t->{"INDEX"}, "ROUTING", "New indexed table by routing");

# extract constructor tests
$t = FastTable->new_extract();
ok(scalar keys %{$t->{"RECORDS"}} > 10, "found 10+ indexes in extract");
is($t->{"INDEX"}, "DEVICE", "Defaults to indexing by device");

$t = FastTable->new_extract("ROUTING");
ok(scalar keys %{$t->{"RECORDS"}} > 10, "found 10+ indexes in extract");
is($t->{"INDEX"}, "ROUTING", "Can specify INDEX");


# dumping/erasing records

$t = FastTable->new($test_rec);
my $ext_rec = $t->get_all_records();
ok(have_same_elements($ext_rec, $test_rec), "Extracting records in table");
$t->clear_all_records();
$ext_rec = $t->get_all_records();
ok(lists_identical($ext_rec, []), "Extracting records from empty table");

# indexing tests

$t = FastTable->new("ROUTING", $test_rec);
ok(defined ($t->{"RECORDS"}->{"ROUT1"}), "Routings used as key in table");

$t = FastTable->new("DEVICE", $test_rec);
ok(defined ($t->{"RECORDS"}->{"DEV1"}), "DEVICE used as key in table");

$t = FastTable->new($test_rec);
ok(defined ($t->{"RECORDS"}->{"DEV1"}), "DEVICE used as key in table - default");

dies_ok(sub {$t->index_by("I DO NOT EXIST")}, "Indexing on unexpected field");

$t = FastTable->new($test_rec);
$t->index_by("PROGRAM");
my $indexes = $t->get_all_indexes();
ok(have_same_elements($indexes, [qw(PROG1 PROG2 PROG3)]), "Retreiving indexes");

# index filtering

my $lambda = sub {
    my ($index) = @_;
    return $index =~ m/PROG[12]/;
};

$t->filter_indexes($lambda);
$indexes = $t->get_all_indexes();
ok(have_same_elements($indexes, [qw(PROG1 PROG2)]), "Successfully filtered by index");

# record filtering
$lambda = sub{
    my ($record) = @_;
    my $prog = $record->{"PROGRAM"};
    my $rout = $record->{"ROUTING"};
    unless($prog =~ m/PROG([0-9])/){
        confess "your lambda's wack yo - prog";
    }
    my $prog_num = $1;
    unless($rout =~ m/ROUT([0-9])/){
        confess "your lambda's wack yo - rout";
    }
    my $rout_num = $1;
    return $rout_num eq $prog_num;
};

$t = FastTable->new($test_rec);
my $exp_rec = [$test_rec->[0], $test_rec->[2], $test_rec->[4]];
$t->filter_records($lambda);
my $filtered = $t->get_all_records();
ok(have_same_elements($filtered, $exp_rec), "Successfully filtered records by lambda function");


