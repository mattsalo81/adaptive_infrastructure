create table etest_daily_sms_extract(
	device 			varchar2	(32)	not null,
	technology	 	varchar2	(32)	not null,
	family 			varchar2	(32)	not null,
	coordref		varchar2	(16)	not null,
	routing			varchar2	(32)	not null,
	effective_routing	varchar2	(32)	not null,
	test_lpt		number		(4,0)	not null,
	COT			varchar2	(1)	in ('Y', 'N'),
	program			varchar2	(32)	not null,
	prober_file		varchar2	(32)	not null,
	recipe			varchar2	(128)	not null,

	constraint sms_pk PRIMARY KEY (device, test_lpt)
);


