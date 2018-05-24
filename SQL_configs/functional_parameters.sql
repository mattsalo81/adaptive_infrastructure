create table functional_parameters (
        technology			varchar2 (16)   not null,
        test_area                       varchar2 (16)   not null,
        effective_routing		varchar2 (32)   not null,
        etest_name			varchar2 (32)   not null,
        constraint func_parm_pk PRIMARY KEY (technology, test_area, effective_routing, etest_name)
);
insert into functional_parameters (technology, test_area, effective_routing, etest_name) values
('TEST_TECH', 'TEST_AREA', 'TEST_ROUT', 'PARM1');
insert into functional_parameters (technology, test_area, effective_routing, etest_name) values
('TEST_TECH', 'TEST_AREA', 'TEST_ROUT', 'PARM2');
insert into functional_parameters (technology, test_area, effective_routing, etest_name) values
('TEST_TECH', 'TEST_AREA', 'TEST_ROUT', 'PARM3');
insert into functional_parameters (technology, test_area, effective_routing, etest_name) values
('TEST_TECH', 'TEST_AREA', 'TEST_ROUT', 'PARM4');
