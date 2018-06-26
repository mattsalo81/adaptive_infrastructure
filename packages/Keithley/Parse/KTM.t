use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::Parse::KTM;
use Data::Dumper;

my $subsite = "hpa07_scm33_mod10";
my $parms = [qw(TFHK_NOM c4 CC_TFVIA TS_HS1 TS_HS2 TS_NSHW TS_NSHM TS_NSHA TS_NSHB TS_NSHL TS_NXDV corr1 TS_NXHV TS_NXRV corr2)];
my $ktm_text = q{
/*>> KITT MODULE GENERATION VERSION V4.2 Fri Nov 10 17:01:16 2017 */
/*
RevID,$Revision: 1.5 $
*/
/*>> KTM TEST MODULE DESCRIPTION FOR hpa07_scm33_mod10e_r00. */
/*
01-17-2007
created for ttr
*/

/*>> KTM WAFER & SUBSITE NAME

MY2004AS_TTR
hpa07_scm33_mod10

END KTM WAFER & SUBSITE NAME*/

/*>> KTM PROBE CARD FILE NAME

MPRZxx

END KTM PROBE CARD FILE NAME*/

/*>> KTM CONSTANT & GENERAL PURPOSE VARIABLES */

#define	N	'n'
#define	n	'n'
#define	P	'p'
#define	p	'p'

/*>> KTM TEST MODULE VARIABLES FOR hpa07_scm33_mod10e_r00 */

double TFHK_NOM[1];		/* for res4_offset */
double c4[1];		/* for res */
double CC_TFVIA[1];		/* for eXpReSSioN */
double TS_HS1[1];		/* for res */
double TS_HS2[1];		/* for res */
double TS_NSHW[1];		/* for res4 */
double TS_NSHM[1];		/* for res4 */
double TS_NSHA[1];		/* for res4 */
double TS_NSHB[1];		/* for res4 */
double TS_NSHL[1];		/* for res4 */
double TS_NXDV[1];		/* for resdeltw_noarray */
double corr1[1];		/* for resdeltw_noarray */
double TS_NXHV[1];		/* for reshr_noarray */
double TS_NXRV[1];		/* for reshr_noarray */
double corr2[1];		/* for reshr_noarray */
int   ki_loopcount;		/* for results */
/* Global Pre-Defined Identifiers */


/* Local Pre-Defined Identifiers */

/*>> KTM TEST MODULE CONSTANTS SETTINGS

END CONSTANTS SETTINGS*/

/*>> KTM TEST MODULE PLOT AND LOG ***DO NOT MODIFY***

TFHK_NOM,PLOT_OFF,LOG_ON,1,USER_OFF
c4,PLOT_OFF,LOG_OFF,1,USER_OFF
CC_TFVIA,PLOT_OFF,LOG_ON,1,USER_OFF
TS_HS1,PLOT_OFF,LOG_ON,1,USER_OFF
TS_HS2,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NSHW,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NSHM,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NSHA,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NSHB,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NSHL,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NXDV,PLOT_OFF,LOG_ON,1,USER_OFF
corr1,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NXHV,PLOT_OFF,LOG_ON,1,USER_OFF
TS_NXRV,PLOT_OFF,LOG_ON,1,USER_OFF
corr2,PLOT_OFF,LOG_ON,1,USER_OFF

END PLOT AND LOG SETTINGS*/

/*>> KTM TEST MODULE BEGIN USRLIB INFORMATION

ktest,

KTM TEST MODULE END USRLIB INFORMATION*/


/*>> KTM TEST MODULE TEST SEQUENCE FOR hpa07_scm33_mod10e_r00 */
/* Dut 7;  TFVIA Kelvin */
TFHK_NOM [0]= res4_offset(p12, p13, p15, p14, -1,500.0e-06);

/* Dut 8;  TFVIA Contact Chain */
c4 [0]= res(p16, p15, -1,500.0e-06);
CC_TFVIA [0]= *c4 / 50.0; /* ohms/via */
/* Dut 1;  Thin Film Resistor  Matching Horizontal   47/4.7 */
TS_HS1 [0]= res(p2, p1, -1,94.0e-06);
TS_HS2 [0]= res(p3, p1, -1,94.0e-06);
/* Dut 2; */
TS_NSHW [0]= res4(p5, p6, p8, p7, -1,490.0e-06); /* 25/24.5 */
/* Dut 3; */
TS_NSHM [0]= res4(p6, p7, p9, p8, -1,248.0e-06); /* 25/12.4 */
/* Dut 4; */
TS_NSHA [0]= res4(p7, p8, p10, p9, -1,94.0e-06); /* 7.0/4.7 */
/* Dut 5;  */
TS_NSHB [0]= res4(p8, p9, p11, p10, -1,94.0e-06); /* 9.0/4.7 */
/* Dut 6;  */
TS_NSHL [0]= res4(p9, p10, p12, p11, -1,94.0e-06); /* 25/4.7 */
TS_NXDV [0]= 0;
TS_NXDV [0]= resdeltw_noarray(*TS_NSHW,*TS_NSHM,*TS_NSHL, 24.5, 12.4 ,4.7 ,corr1);
TS_NXHV [0]= reshr_noarray(7.0, 9.0, 25.0,*TS_NSHA,*TS_NSHB,*TS_NSHL, 4.7,*TS_NXDV, TS_NXRV, corr2);
};


my $ktm = Parse::KTM->new($ktm_text);
is($ktm->get_subsite(), $subsite, "Successfully extracted subsite");
ok(lists_identical($ktm->get_parameters(), $parms), "Successfully extracted parameters");
