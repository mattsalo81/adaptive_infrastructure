create table daily_sms_extract(
    device 			varchar2	(32)	not null,
    technology	 	varchar2	(32)	not null,
    family 			varchar2	(32)	not null,
    coordref		varchar2	(16)	not null,
    routing			varchar2	(32)	not null,
    effective_routing	varchar2	(32)	not null,
    lpt			number		(4,0)	not null,
    opn			number		(4,0)	not null,
    COT			varchar2	(1)     check (COT in ('Y', 'N')),
    card_family		varchar2	(16)	not null,
    program			varchar2	(32)	not null,
    prober_file		varchar2	(32)	not null,
    area			varchar2	(32)	not null,
    recipe			varchar2	(128)	not null,

    constraint sms_pk PRIMARY KEY (device, lpt, opn)
)


