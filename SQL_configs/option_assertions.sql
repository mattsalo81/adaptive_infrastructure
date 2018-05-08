create table opt_and_lpt_assertions(
    technology		varchar2(16)	NOT NULL,
    rule			varchar2(256)	NOT NULL,
    constraint op_assert_pk PRIMARY KEY (technology, rule)
);
insert into opt_and_lpt_assertions (technology, rule) values
('TEST', 'DANG && WOW');
insert into opt_and_lpt_assertions (technology, rule) values
('TEST', 'DUMMY -> DANG');
insert into opt_and_lpt_assertions (technology, rule) values
('TESTFAIL', 'DUMMY');
