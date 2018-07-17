create table exceptions(
    exception_number    number          (4)     not null,
    device 		varchar2	(32)	not null,
    lpt			number		(4,0)	not null,
    opn			number		(4,0)	not null,
    constraint exc_pk PRIMARY KEY (exception_number, device, lpt, opn)
);
insert into exceptions (exception_number, device, lpt, opn) values
(0, 'TEST_DEV', 0000, 0000);

