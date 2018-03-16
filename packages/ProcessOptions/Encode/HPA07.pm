package Encode::HPA07;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::ProcessEncoder;
use ProcessOptions::Encode::Global;

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> main naming convention
# code 3 -> flavor of hpa07
# code 4 -> ISO-J

my $options;

sub get_codes{
	my $area = Encode::Global::get_area_codes();
	my $ml	= Encode::Global::get_num_ml_codes();
	my $main = Encode::Global::parse_old_txt_format($options);	
	my $flavor = Encode::Global::parse_old_txt_format(q{
		100	50HPA07
		102	33HPA07
		103	50HPA07
		107	50HPA07 
	});
	my $isoj = Encode::Global::parse_old_txt_format(q{
		J	ISOS
		NOTJ	
	});
	return [$area, $ml, $main, $flavor, $isoj];
}

$options = q{
/+	
/F	HighSpeed
/J	HighSpeed  TFR
/P	Cu_BOAC
/Q	OTP
/R	TFR
/M	METDCU
++	CAP
AF	HighSpeed  CAP  OTP
AG	HighSpeed  HDCAP  TFR  OTP
AH	HDCAP  OTP
AI	HighSpeed  HDCAP  OTP
AJ	HighSpeed  CAP  TFR  OTP
AL	HDCAP  TFR  OTP
AN	HighSpeed  HDCAP  TFR  Cap_M2TN  OTP
AP	TFR  Cu_BOAC
AR	CAP  TFR  OTP
AU	CAP  TFR  Cu_BOAC
AX	HighSpeed  CAP  TFR  Cap_M2TN  OTP
AZ	HighSpeed  LDCAP  TFR  Cap_M2TN  OTP
BH	HDCAP  StackedCap  OTP
BI	HighSpeed  HDCAP  StackedCap  OTP
BK	HighSpeed  HDCAP  StackedCap
BL	HDCAP  StackedCap  PI
BQ	CAP  StackedCap  OTP
CE	TFR  CAP_HV
CF	HighSpeed  CAP  TFR  Cu_BOAC
CG	CAP  TFR  CAP_HV  OTP
CH	TFR  CAP_HV  OTP
CJ	HDCAP  TFR  CAP_HV  OTP
CQ	LDCAP  TFR  CAP_HV
CS	LDCAP
CU	LDCAP  TFR  CAP_HV  OTP
CV	LDCAP  CAP_HV  OTP
CW	HighSpeed  HDCAP  TFR  CAP_HV
CX	HighSpeed  HDCAP  TFR  CAP_HV  PI
DB	PI
DC	TFR  PI
DD	TFR  CAP_HV  PI  OTP
DF	HDCAP  TFR  CAP_HV
DG	HDCAP  TFR  CAP_HV  PI
DH	HDCAP  TFR  PI  OTP
DI	HDCAP  TFR  PI
DJ	HDCAP  TFR  Cap_M2TN  PI
DK	CAP  TFR  PI
DL	CAP  PI
DM	HDCAP  PI
DN	HighSpeed  CAP  PI
DP	HighSpeed  HDCAP  TFR  PI  OTP
DQ	CAP  PI  OTP
DR	CAP  TFR  CAP_HV
DU	CAP  TFR  CAP_HV  Cu_BOAC
DV	CAP  TFR  PI  OTP
DW	CAP  TFR  CAP_HV  MetDCU
DX	HDCAP  PI  OTP
DY	HighSpeed  CAP  PI  OTP
DZ	HighSpeed  CAP  TFR  PI
EA	CAP_HV
EB	HighSpeed  HDCAP  TFR  Cu_BOAC
EC	HDCAP  Cap_M2TN
ED	HighSpeed  HDCAP  TFR  Cap_M2TN  PI  OTP
EE	HDCAP  TFR  Cu_BOAC
EF	HDCAP  TFR  Cu_BOAC  OTP
EG	HDCAP  TFR  CAP_HV  OTP  PI
EH	TFR  CAP_HV  PI
EI	CAP  CAP_HV
EJ	HighSpeed  HDCAP  TFR  Cap_M2TN
EK	TFR  PI  OTP
EL	HighSpeed  HDCAP  TFR  Cap_M2TN  PI
EM	HighSpeed  CAP  TFR  Cap_M2TN  PI  OTP
EN	HighSpeed  LDCAP  TFR  Cap_M2TN  PI  OTP
ER	HighSpeed  CAP  TFR  Cap_M2TN
ES	HDCAP  TFR  Cap_M2TN
ET	CAP  TFR  Cap_M2TN
EV	HDCAP  TFR  Cap_M2TN  OTP
EW	HDCAP  TFR  Cap_M2TN  PI  OTP
EY	HighSpeed  LDCAP  TFR  CAP_HV  OTP
F+	HighSpeed  CAP
FA 	HDCAP16  Cap_M2TN
FH 	HDCAP16
FJ 	HighSpeed  CTOP16  TFR
FS 	CTOP16  TFR
G+	HighSpeed  HDCAP  TFR
GA	HighSpeed  CAP  TFR  PI  OTP
GB	HighSpeed  HDCAP  PI
GC	HighSpeed  HDCAP  PI  OTP
GD	HighSpeed  HDCAP  TFR  PI
GE	CAP  TFR  CAP_HV  PI  OTP
H+	HDCAP
HA	HDCAP  TFR  IR_Sensor
HB	HDCAP  TFR  OTP  IR_Sensor
I+	HighSpeed  HDCAP
J+	HighSpeed  CAP  TFR
L+	HDCAP  TFR
MA	TFR  CAP_HV  MetDCU  OTP
MB	HDCAP  TFR  CAP_HV  MetDCU
MC	HighSpeed  HDCAP  TFR  CAP_HV  MetDCU
MD	HDCAP  TFR  MetDCU
ME	HDCAP  TFR  Cap_M2TN  FluxGate
MF	FluxGate
MG	HDCAP  TFR  FluxGate
MH	HighSpeed  HDCAP  TFR  Cap_M2TN  FluxGate
MI	HDCAP  TFR  CAP_HV  OTP  MetDCU
MJ	HDCAP  TFR  Viatop
MK	HDCAP  TFR  FluxGate  ALCAP
ML	HDCAP TFR CAP_M2TN OTP METDCU PI
MP	HDCAP TFR CAP_M2TN METDCU
MQ	HDCAP TFR NPBLK CAP_HV METDCU
MM	Cap_M2TN  TFR
MN	HDCAP TFR CAP_M2TN OTP METDCU
NA	HDCAP  TFR  NPBLK
NB	HDCAP  TFR  NPBLK  CAP_HV  PI
NC	HDCAP  TFR  NPBLK  CAP_HV
ND	TFR  NPBLK  CAP_HV  PI
P+	CAP  Cu_BOAC
Q+	CAP  OTP
R+	CAP  TFR
/O	PBO
/S	TFR  PBO
A+	HighSpeed  HDCAP  TFR  PBO
AA	HighSpeed  HDCAP  TFR  PBO  OTP
AB	HighSpeed  HDCAP  PBO  OTP
AC	HighSpeed  CAP  TFR  PBO  OTP
AD	HighSpeed  CAP  PBO  OTP
AE	HDCAP  TFR  PBO  OTP
AK	HDCAP  PBO  OTP
AM	HDCAP  TFR  PBO  OTP
AO	CAP  PBO  OTP
AQ	HighSpeed  HDCAP  TFR  Cap_M2TN  OTP
AS	CAP  TFR  PBO  OTP
AT	CAP  TFR  PBO  Cu_BOAC  
AV	CAP  TFR  PBO
AY	HDCAP  TFR  OTP
B+	HighSpeed  HDCAP  PBO
C+	HighSpeed  CAP  TFR  PBO
CA	HDCAP  TFR  PBO
CB	TFR
CC	CAP  TFR  CAP_HV
CD	TFR  CAP_HV
CI	TFR  CAP_HV  PBO  OTP
CL	HDCAP  TFR
CM	Cap  TFR
CN	HighSpeed  HDCAP  TFR  PBO
CO	CAP  TFR  CAP_HV  Cu_BOAC
CP	HDCAP  TFR  CAP_HV  PBO
CR	LDCAP  TFR  CAP_HV
D+	HighSpeed  CAP  PBO
DA	CAP  TFR  CAP_HV  OTP
DE	HDCAP  TFR  CAP_HV  PBO
E+	HDCAP  TFR  PBO
EU	HighSpeed  CAP  TFR  Cap_M2TN
FR 	CTOP16  TFR
K+	HDCAP  PBO
LA	HDCAP  TFR
LB	CAP  TFR  OTP
LC	CAP  TFR  CAP_HV
M+	OBS
O+	CAP  PBO
S+	CAP  TFR  PBO
T+	CAP  TFR
};
1;
