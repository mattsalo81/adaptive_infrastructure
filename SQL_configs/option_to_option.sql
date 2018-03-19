create table option_to_option(
	technology		varchar2(16)	NOT NULL,
	process_option_rule	varchar2(128)	NOT NULL,
	process_option		varchar2(32)	NOT NULL,
	constraint op2op_pk PRIMARY KEY (technology, process_option_rule, process_option)
);
