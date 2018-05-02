create table functional_parameters (
	technology			varchar2 (16) 	not null,
	effective_routing		varchar2 (32)   not null,
	etest_name			varchar2 (32) 	not null,
	svn				varchar2 (32),
	component			varchar2 (128),
	test_type			varchar2 (32), 
	description			varchar2 (300),
	constraint func_parm_pk PRIMARY KEY (technology, effective_routing, etest_name)
);
insert into functional_parameters (technology, effective_routing, etest_name) values
('TEST_TECH', 'TEST_ROUT', 'PARM1');
insert into functional_parameters (technology, effective_routing, etest_name) values
('TEST_TECH', 'TEST_ROUT', 'PARM2');
insert into functional_parameters (technology, effective_routing, etest_name) values
('TEST_TECH', 'TEST_ROUT', 'PARM3');
insert into functional_parameters (technology, effective_routing, etest_name) values
('TEST_TECH', 'TEST_ROUT', 'PARM4');
