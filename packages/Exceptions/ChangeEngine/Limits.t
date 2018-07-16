use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Exceptions::ChangeEngine::Limits;
use SMS::SMSDigest;
use Data::Dumper;

my @test_format  = qw(DEVICE LPT OPN TECHNOLOGY AREA PROGRAM EFFECTIVE_ROUTING);
my @test_records = (
    [qw(DEVICE1 6152 8820 TECH1 METAL2     PROG1M ROUT1)],
    [qw(DEVICE1 9300 8820 TECH1 PARAMETRIC PROG1P ROUT1)],
    [qw(DEVICE1 9300 8823 TECH1 PARAMETRIC PROG1H ROUT1)],
    [qw(DEVICE2 6152 8820 TECH1 METAL2     PROG1M ROUT1)],
    [qw(DEVICE2 9300 8820 TECH1 PARAMETRIC PROG1P ROUT1)],
    [qw(DEVICE3 6152 8820 TECH1 METAL2     PROG2M ROUT2)],
    [qw(DEVICE3 9300 8820 TECH1 PARAMETRIC PROG2P ROUT2)],
    [qw(DEVICE4 6652 8820 TECH2 METAL2     PROG3M ROUT3)],
    [qw(DEVICE4 9455 8820 TECH2 PARAMETRIC PROG3P ROUT3)],
    [qw(DEVICE5 6652 8820 TECH2 METAL2     PROG4M ROUT4)],
    [qw(DEVICE6 9455 8820 TECH2 PARAMETRIC PROG4P ROUT4)],
);

my $sms_records = [];
foreach my $test_record (@test_records){
    my %rec;
    @rec{@test_format} = @{$test_record};
    push @{$sms_records}, SMSSpec->new(\%rec);;
}
# DONE MAKING SMS RECORDS

my @dlo_f = qw(DEVICE LPT OPN);
my $dev_lpt_opn_arr = [
    [qw(DEVICE1 9300 8820)],
    [qw(DEVICE3 6152 8820)],
];
my $dev_lpt_opn = [map {my %h; @h{@dlo_f} = @{$_}; \%h} @{$dev_lpt_opn_arr}];

my $items = Exceptions::ChangeEngine::Limits::promote_dev_lpt_opn_list_to_program_list($sms_records, $dev_lpt_opn);
ok(scalar @{$items} == 1, "found 1 resolved program");
ok(lists_identical($items->[0], [qw(TECH1 METAL2 ROUT2 PROG2M), undef]), "Found correct info for querying limits database");
$items = Exceptions::ChangeEngine::Limits::promote_dev_lpt_opn_list_to_device_list($sms_records, $dev_lpt_opn);

ok(scalar @{$items} == 2, "found 2 resolved devices");
if((defined $items->[0]) && $items->[0]->[4] eq "DEVICE1"){
    ok(lists_identical($items->[0], [qw(TECH1 PARAMETRIC ROUT1 PROG1P DEVICE1)]), "Found correct info for querying limits database");
    ok(lists_identical($items->[1], [qw(TECH1 METAL2     ROUT2 PROG2M DEVICE3)]), "Found correct info for querying limits database");
}else{
    ok(lists_identical($items->[1], [qw(TECH1 PARAMETRIC ROUT1 PROG1P DEVICE1)]), "Found correct info for querying limits database");
    ok(lists_identical($items->[0], [qw(TECH1 METAL2     ROUT2 PROG2M DEVICE3)]), "Found correct info for querying limits database");
}

