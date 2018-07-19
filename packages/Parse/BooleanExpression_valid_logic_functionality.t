use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use Parse::BooleanExpression;
use SMS::SMSSpec;


my $sms_rec = SMSSpec->new({
    TECHNOLOGY  =>      "WAV_TEST",
    COORDREF    =>      "TCOORD1",
    ROUTING     =>      "DUMMY",
    EFFECTIVE_ROUTING   => "DUMMY",
    
});

my $t_expression = "SIMPLE_RESOLVE:SF";
ok(BooleanExpression::does_sms_record_satisfy_functionality($sms_rec, $t_expression), "Simple resolve");

$t_expression = "SIMPLE_RESOLVE:SF <=> SIMPLE_RESOLVE:TOP:SF";
ok(BooleanExpression::does_sms_record_satisfy_functionality($sms_rec, $t_expression), "Simple resolve with logic");

my $f_expression = "SIMPLE_RESOLVE:SF <=> ! SIMPLE_RESOLVE:TOP:SF";
ok(!BooleanExpression::does_sms_record_satisfy_functionality($sms_rec, $f_expression), "Simple resolve with logic (fail)");
