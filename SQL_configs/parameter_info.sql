create table parameter_info (
        technology			varchar2 (16)   not null,
        etest_name			varchar2 (32)   not null,
        svn				varchar2 (32),
        component			varchar2 (128),
        parm_type_pcd                   varchar2 (3) check(parm_type_pcd in ('MON', 'WAS', 'REL')),
        test_type			varchar2 (32), 
        description			varchar2 (300),
        constraint para_info_pk PRIMARY KEY (technology, etest_name)
);
insert into parameter_info (technology, etest_name, parm_type_pcd) values
('TEST_TECH', 'PARM1', 'WAS');
insert into parameter_info (technology, etest_name, parm_type_pcd) values
('TEST_TECH', 'PARM2', 'WAS');
insert into parameter_info (technology, etest_name, parm_type_pcd) values
('TEST_TECH', 'PARM3', 'WAS');
insert into parameter_info (technology, etest_name, parm_type_pcd) values
('TEST_TECH', 'PARM4', 'WAS');
insert into parameter_info (technology, etest_name, parm_type_pcd) values
('TEST_TECH', 'PARM5', 'WAS');
