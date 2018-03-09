create table process_code_to_option(
	technology	varchar2(16)	NOT NULL,
	code_num	number(2,0)	NOT NULL,
	process_code	varchar2(16)	NOT NULL,
	process_option	varchar2(32)	default 'PLACEHOLDER',
	constraint pcto_pk PRIMARY KEY (technology, code_num, process_code, process_option)
);
insert into process_code_to_option (technology, code_num, process_code, process_option) values
('TEST', 0, 'MATT', 'SHAZAM');
insert into process_code_to_option (technology, code_num, process_code, process_option) values
('TEST', 0, 'MATT', 'WOW');
insert into process_code_to_option (technology, code_num, process_code, process_option) values
('TEST', 0, 'MAATT', 'NICE');
insert into process_code_to_option (technology, code_num, process_code, process_option) values
('TEST', 1, 'MATT', 'HEYO');
insert into process_code_to_option (technology, code_num, process_code, process_option) values
('TEST1', 0, 'MATT', 'DANG');
-- replace value below with whatever $ProcessDecoder::placeholder_option is
insert into process_code_to_option (technology, code_num, process_code, process_option) values
('TEST', 0, 'BLANK', 'PLACEHOLDER');
