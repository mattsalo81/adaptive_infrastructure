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
    COMPONENT                   =>      "TESTCOMP",
);
my $limit1 = LimitRecord->new_from_hash(\%template);
my $expected = q{
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
};
GenerateSpec::add_predecessor_spec_for_limit($spec, $limit1, 0);
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
GenerateSpec::add_predecessor_spec_for_limit($spec, $limit2, 0);
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
GenerateSpec::add_predecessor_spec_for_limit($spec, $limit3, 0);
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
$template{"COMPONENT"} = undef;

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

# LIMIT LISTS
$spec = Spec->new();
GenerateSpec::add_spec_for_limits($spec, [$limit1, $limit4, $limit4]);
$expected = q{


#     Starting TESTCOMP Parameters                         #
# This is the lowest priority limit                        #
PARM1                   3   -10         10          1  6


#     Starting NO COMPONENT Parameters                     #
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
# The lower spec limit was lowered                         #
# PARM1=================3===-100========10==========1==6== #
# No useful limits                                         #
# This is the lowest priority limit                        #
# PARM1=================3===-10=========10==========1==6== #
# The lower spec limit was lowered                         #
# PARM1=================3===-100========10==========1==6== #
# No useful limits                                         #
};

is("\n" . $spec->get_text(), $expected, "Got expected spec result for list of three limits with different components");

# check if it'll print something that doesn't have limits
$spec = Spec->new();
$template{"DISPO"} = "N";
$template{"RELIABILITY"} = "N";
my $limit5 = LimitRecord->new_from_hash(\%template);
GenerateSpec::add_spec_for_limit($spec, $limit5);
ok($spec->get_text() ne "", "Parameter has no real limits, but limits in predecessors, and we added something");

$spec = Spec->new();
$template{"PREDECESSOR"} = undef;
my $limit6 = LimitRecord->new_from_hash(\%template);
GenerateSpec::add_spec_for_limit($spec, $limit6);
is($spec->get_text(), "", "Limit (and all predecessors) have no dispo/rel limits. nothing added to spec");




