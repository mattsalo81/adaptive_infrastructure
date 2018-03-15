create table daily_wip_extract(
	lot			number		(7,0)	PRIMARY KEY,
	device 			varchar2	(32)	not null,
	lpt			number		(4,0)	not null,
	wafers			number		(2,0)	not null
)


