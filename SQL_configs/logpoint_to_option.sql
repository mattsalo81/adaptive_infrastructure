create table logpoint_to_option(
	technology	varchar2(16)	NOT NULL,
	lpt_rule	varchar2(128)	NOT NULL,
	process_option	varchar2(32)	NOT NULL,
	constraint lgp2op_pk PRIMARY KEY (technology, lpt_rule, process_option)
);
insert into logpoint_to_option (technology, lpt_rule, process_option) values
('TEST', '9300', 'SHAZAM');
insert into logpoint_to_option (technology, lpt_rule, process_option) values
('TEST', '9455', 'WOW');
insert into logpoint_to_option (technology, lpt_rule, process_option) values
('TEST', '3355^3362', 'NICE');
insert into logpoint_to_option (technology, lpt_rule, process_option) values
('TEST', '(9300|9455)&0050', 'DANG');

