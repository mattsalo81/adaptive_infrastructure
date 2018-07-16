create table exceptions(
    device 		varchar2	(32)	not null,
    lpt			number		(4,0)	not null,
    opn			number		(4,0)	not null,
    exception_number    number          (4) not null,
    constraint exc_pk PRIMARY KEY (device, lpt, opn, exception_number)
)


