create table functional_parameters (
        technology			varchar2 (16)   not null,
        effective_routing		varchar2 (32)   not null,
        etest_name			varchar2 (32)   not null,
        svn				varchar2 (32),
        component			varchar2 (128),
        parm_type_pcd                   varchar2 (3) check(parm_type_pcd in ('MON', 'WAS', 'REL')),
        test_type			varchar2 (32), 
        description			varchar2 (300),
        constraint func_parm_pk PRIMARY KEY (technology, effective_routing, etest_name)
);
insert into functional_parameters (technology, effective_routing, etest_name, parm_type_pcd) values
('TEST_TECH', 'TEST_ROUT', 'PARM1', 'WAS');
insert into functional_parameters (technology, effective_routing, etest_name, parm_type_pcd) values
('TEST_TECH', 'TEST_ROUT', 'PARM2', 'WAS');
insert into functional_parameters (technology, effective_routing, etest_name, parm_type_pcd) values
('TEST_TECH', 'TEST_ROUT', 'PARM3', 'WAS');
insert into functional_parameters (technology, effective_routing, etest_name, parm_type_pcd) values
('TEST_TECH', 'TEST_ROUT', 'PARM4', 'WAS');
