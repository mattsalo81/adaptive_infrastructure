use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use LimitDatabase::GetLimit;
use Data::Dumper;

# resolve limits table
my $test_tech = "TEST_TECH";
my $test_area = "TEST_AREA";
my $test_rout = "TEST_ROUT";
my $test_prog = "TEST_PROG";
my $test_dev = "TEST_DEV";

# resolve all limits at the device level -> should resolve alphabetically, and all deactivated
my $limits = GetLimit::get_all_limits($test_tech, $test_area, $test_rout, $test_prog, $test_dev);
is(scalar @{$limits}, 4, "Found all four test limits");

is($limits->[0]->{"ETEST_NAME"}, "PARM1", "Parm1 resolved first");
is($limits->[1]->{"ETEST_NAME"}, "PARM2", "Parm2 resolved second");
is($limits->[2]->{"ETEST_NAME"}, "PARM3", "Parm3 resolved third");
is($limits->[3]->{"ETEST_NAME"}, "PARM4", "Parm4 resolved fourth");

is($limits->[0]->{"DEACTIVATE"}, "Y", "Parm1 resolved DEACTIVATED");
is($limits->[1]->{"DEACTIVATE"}, "Y", "Parm2 resolved DEACTIVATED");
is($limits->[2]->{"DEACTIVATE"}, "Y", "Parm3 resolved DEACTIVATED");
is($limits->[3]->{"DEACTIVATE"}, "Y", "Parm4 resolved DEACTIVATED");

# resolve all limits at the program level -> should resolve alphabetically, and PARM1/2/3 deactivated only
$limits = GetLimit::get_all_limits($test_tech, $test_area, $test_rout, $test_prog, undef);
is(scalar @{$limits}, 4, "Found all four test limits");

is($limits->[0]->{"ETEST_NAME"}, "PARM1", "Parm1 resolved first");
is($limits->[1]->{"ETEST_NAME"}, "PARM2", "Parm2 resolved second");
is($limits->[2]->{"ETEST_NAME"}, "PARM3", "Parm3 resolved third");
is($limits->[3]->{"ETEST_NAME"}, "PARM4", "Parm4 resolved fourth");

is($limits->[0]->{"DEACTIVATE"}, "Y", "Parm1 resolved DEACTIVATED");
is($limits->[1]->{"DEACTIVATE"}, "Y", "Parm2 resolved DEACTIVATED");
is($limits->[2]->{"DEACTIVATE"}, "Y", "Parm3 resolved DEACTIVATED");
is($limits->[3]->{"DEACTIVATE"}, "N", "Parm4 resolved ACTIVATED");

# resolve all limits at the effective_routing level -> should resolve alphabetically, and PARM1/2 deactivated only
$limits = GetLimit::get_all_limits($test_tech, $test_area, $test_rout, undef, undef);
is(scalar @{$limits}, 4, "Found all four test limits");

is($limits->[0]->{"ETEST_NAME"}, "PARM1", "Parm1 resolved first");
is($limits->[1]->{"ETEST_NAME"}, "PARM2", "Parm2 resolved second");
is($limits->[2]->{"ETEST_NAME"}, "PARM3", "Parm3 resolved third");
is($limits->[3]->{"ETEST_NAME"}, "PARM4", "Parm4 resolved fourth");

is($limits->[0]->{"DEACTIVATE"}, "Y", "Parm1 resolved DEACTIVATED");
is($limits->[1]->{"DEACTIVATE"}, "Y", "Parm2 resolved DEACTIVATED");
is($limits->[2]->{"DEACTIVATE"}, "N", "Parm3 resolved ACTIVATED");
is($limits->[3]->{"DEACTIVATE"}, "N", "Parm4 resolved ACTIVATED");

dies_ok(sub{GetLimit::get_all_limits($test_tech, $test_area, $test_rout, undef, $test_dev)}, "Resolving limits at the device level with an undefined program");

my $known_tech = "LBC5";
my $known_area = "PARAMETRIC";
my $known_rout = "PARAMETRIC__A72AE3A+-X";
my $known_prog = "M06BEC65310B0";
$limits = GetLimit::get_all_limits($known_tech, $known_area, $known_rout, $known_prog, undef);
ok(scalar @{$limits}, "Found some limits on a real technology");




