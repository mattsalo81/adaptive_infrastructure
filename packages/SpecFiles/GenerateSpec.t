use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use SpecFiles::GenerateSpec;
use SpecFiles::Spec;
use LimitDatabase::LimitRecord;


# predecessor specs
my $spec = Spec->new();
my %template = (
    ETEST_NAME                  =>      "PARM1",
    LIMIT_COMMENTS              =>      "This is the lowest priority limit",
    DEACTIVATE                  =>      "N",
    DISPO                       =>      "Y",
    RELIABILITY                 =>      "N",
    SAMPLING_RATE               =>      "9 SITE",
    PASS_CRITERIA_PERCENT       =>      .75,
    SPEC_LOWER                  =>      -10,
    SPEC_UPPER                  =>      10,
    REVERSE_SPEC_LIMIT          =>      "N",
);
my $limit1 = LimitRecord->new_from_hash(\%template);
my $expected = q{
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
};
GenerateSpec::add_predecessor_spec_for_limit($spec, $limit1);
is("\n" . $spec->get_text(), $expected, "Got expected spec result for predecessor limit");

$spec = Spec->new();
# add previous limit to a new limit (as predecessor) and lower the lsl
$template{"SPEC_LOWER"} = -100;
$template{"LIMIT_COMMENTS"} = "The lower spec limit was lowered";
$template{"PREDECESSOR"} = $limit1;
my $limit2 = LimitRecord->new_from_hash(\%template);

$expected = q{
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
# The lower spec limit was lowered                         #
# PARM1=================3===-100========10==========1==6== #
};
GenerateSpec::add_predecessor_spec_for_limit($spec, $limit2);
is("\n" . $spec->get_text(), $expected, "Got expected spec result for nested predecessor limit");

# add a reliability range
$template{"LIMIT_COMMENTS"} = "We added a reliability range";
$template{"RELIABILITY"} = "Y";
$template{"RELIABILITY_LOWER"} = "1";
$template{"RELIABILITY_UPPER"} = "10";
$template{"REVERSE_RELIABILITY_LIMIT"} = "N";
$template{"PREDECESSOR"} = $limit2;
my $limit3 = LimitRecord->new_from_hash(\%template);
$spec = Spec->new();

$expected = q{
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
# The lower spec limit was lowered                         #
# PARM1=================3===-100========10==========1==6== #
# We added a reliability range                             #
# PARM1=================3===-100========10==========1==6== #
# PARM1=================1===1===========10==========1==2== #
};
GenerateSpec::add_predecessor_spec_for_limit($spec, $limit3);
is("\n" . $spec->get_text(), $expected, "Got expected spec result for nested predecessor limit (reliability)");


# SPEC
$spec = Spec->new();
GenerateSpec::add_spec_for_limit($spec, $limit3);
$expected = q{
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
# The lower spec limit was lowered                         #
# PARM1=================3===-100========10==========1==6== #
# We added a reliability range                             #
PARM1                   3   -100        10          1  6
PARM1                   1   1           10          1  2
};
is("\n" . $spec->get_text(), $expected, "Got expected spec result for nested limit");

$template{"RELIABILITY"} = "N";
$template{"DISPO"} = "N";
$template{"LIMIT_COMMENTS"} = "No useful limits";

my $limit4 = LimitRecord->new_from_hash(\%template);
$spec = Spec->new();
GenerateSpec::add_spec_for_limit($spec, $limit4);
$expected = q{
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
# The lower spec limit was lowered                         #
# PARM1=================3===-100========10==========1==6== #
# No useful limits                                         #
};
is("\n" . $spec->get_text(), $expected, "Got expected spec result for nested limit without dispo/rel");


