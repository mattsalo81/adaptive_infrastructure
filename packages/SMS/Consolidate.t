use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SMS::Consolidate;
use SMS::SMSSpec;
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


my @dev_lpt_opn_f = qw(DEVICE LPT OPN);
my @tests = (
    # DEVICE TEST
    [ # input values
        [ # selected device/lpt/opn
            # [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 9300 8820)], 
            [qw(DEVICE1 9300 8823)], 
        ], [ # desired consolidation fields
            qw(DEVICE),
        ]
    ], # =>
    [ # output values (expected)
        [ # unconsolidated dev/lpt/opn
        ],
        [ # matched consolidations
            # ["DEVICE1"]
            ["DEVICE1"]
        ],        
    ],
    # DEVICE OPN TEST
    [ # input values
        [ # selected device/lpt/opn
            # [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 9300 8820)], 
            [qw(DEVICE1 9300 8823)], 
        ], [ # desired consolidation fields
            qw(DEVICE LPT),
        ]
    ], # =>
    [ # output values (expected)
        [ # unconsolidated dev/lpt/opn
        ],
        [ # matched consolidations
            # ["DEVICE1"]
            ["DEVICE1", "6152"],
            ["DEVICE1", "9300"],
        ],        
    ],
    [ # input values
        [ # selected device/lpt/opn
            # [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 9300 8820)], 
            [qw(DEVICE1 9300 8823)], 
        ], [ # desired consolidation fields
            qw(PROGRAM),
        ]
    ], # =>
    [ # output values (expected)
        [ # unconsolidated dev/lpt/opn
            [qw(DEVICE1 6152 8820)],
            [qw(DEVICE1 9300 8820)],
        ],
        [ # matched consolidations
            # ["DEVICE1"]
            ["PROG1H"]
        ],        
    ],
    [ # input values
        [ # selected device/lpt/opn
            # [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 9300 8820)], 
            [qw(DEVICE1 9300 8823)], 
        ], [ # desired consolidation fields
        ]
    ], # =>
    [ # output values (expected)
        [ # unconsolidated dev/lpt/opn
            [qw(DEVICE1 6152 8820)], 
            [qw(DEVICE1 9300 8820)], 
            [qw(DEVICE1 9300 8823)], 
        ],
        [ # matched consolidations
            # ["DEVICE1"]
        ],        
    ],
    [ # input values
        [ # selected device/lpt/opn
            # [qw(DEVICE1 6152 8820)], 
        ], [ # desired consolidation fields
            qw(PROGRAM),
        ]
    ], # =>
    [ # output values (expected)
        [ # unconsolidated dev/lpt/opn
        ],
        [ # matched consolidations
            # ["DEVICE1"]
        ],        
    ],
);



# TEST HARNESS
for (my $test = 0; $test < scalar @tests; $test+=2){
    # get raw input/outputs
    my $inputs = $tests[$test];
    my $outputs = $tests[$test + 1];
    my ($input_dev_lpt_opn_arr, $consol) = @{$inputs};
    my ($unconsol_dev_lpt_opn_arr, $exp_matched) = @{$outputs};
    
    # massage dev/lpt/opn into NAME_uc hash
    my @input_dev_lpt_opn;
    foreach my $arr (@{$input_dev_lpt_opn_arr}){
        my %h;
        for(my $i = 0; $i< @dev_lpt_opn_f; $i++){
            $h{$dev_lpt_opn_f[$i]} = $arr->[$i];
        }
        push @input_dev_lpt_opn, \%h;
    }
    
    # run consolidator
    my ($unmatched, $matched) = SMS::Consolidate::consolidate($sms_records, \@input_dev_lpt_opn, $consol);

    # format outputs
    my @unmatched               = map {"['" . join("', '", @{$_}{@dev_lpt_opn_f}) . "'"} @{$unmatched};
    my @expected_unmatched      = map {"['" . join("', '", @{$_}) . "'"} @{$unconsol_dev_lpt_opn_arr};
    my @matched                 = map {"['" . join("', '", @{$_}) . "'"} @{$matched};
    my @expected_matched        = map {"['" . join("', '", @{$_}) . "'"} @{$exp_matched};
    ok(have_same_elements(\@unmatched, \@expected_unmatched), "Test " . $test/2 . " Expected unmatched") 
        or diag(print Dumper({INPUTS=>$inputs,EXPECTED_OUT=>[$unconsol_dev_lpt_opn_arr, $exp_matched],OUTPUTS=>[$unmatched, $matched]}));
    ok(have_same_elements(\@matched,   \@expected_matched),   "Test " . $test/2 . " Expected matched")
        or diag(print Dumper({INPUTS=>$inputs,EXPECTED_OUT=>[$unconsol_dev_lpt_opn_arr, $exp_matched],OUTPUTS=>[$unmatched, $matched]}));
}

