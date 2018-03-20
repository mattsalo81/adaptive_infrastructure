create table opt_and_lpt_assertions(
	technology		varchar2(16)	NOT NULL,
	rule			varchar2(256)	NOT NULL,
	constraint op_assert_pk PRIMARY KEY (technology, rule)
);
