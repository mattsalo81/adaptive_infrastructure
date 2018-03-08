create table process_code_to_option(
	technology	varchar2(16)	NOT NULL,
	code_num	number(2,0)	NOT NULL,
	process_code	varchar2(16)	NOT NULL,
	process_option	varchar2(32)	NOT NULL,
	constraint pcto_pk PRIMARY KEY (technology, code_num, process_code, process_option)
)
