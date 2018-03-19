create table option_to_option(
	technology		varchar2(16)	NOT NULL,
	priority		number(3,0)	NOT NULL,
	process_option_rule	varchar2(128)	NOT NULL,
	process_option		varchar2(32)	NOT NULL,
	constraint op2op_pk PRIMARY KEY (technology, priority)
);

insert into option_to_option (technology, priority, process_option_rule, process_option) values
('TEST', 0, 'WOW && WHOOPIE', 'NOT_POSSIBLE');
insert into option_to_option (technology, priority, process_option_rule, process_option) values
('TEST', 1, 'WOW2', 'BAD');
insert into option_to_option (technology, priority, process_option_rule, process_option) values
('TEST', 2, 'WOW', 'WOW2');
insert into option_to_option (technology, priority, process_option_rule, process_option) values
('TEST', 3, 'WOW2', 'WOW3');
insert into option_to_option (technology, priority, process_option_rule, process_option) values
('TEST', 4, 'NOT_REAL || DANG', 'FOUND_IT');
