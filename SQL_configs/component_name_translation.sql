create table component_name_translation(
    technology		varchar2 (16) not null,
    raw_name 		varchar2 (32) not null,
    etest_name 		varchar2 (32) not null,
    notes			varchar2 (256),
    constraint compname_pk PRIMARY KEY (technology, raw_name, etest_name)
);
insert into component_name_translation (technology, raw_name, etest_name, notes) values
('OTHER_TEST', 'UNDEFINED_COMP', 'UNDEFINED_COMP', 'For database testing');
insert into component_name_translation (technology, raw_name, etest_name, notes) values
('TEST', 'TEST_1', 'TEST_1', 'For database testing');
insert into component_name_translation (technology, raw_name, etest_name, notes) values
('TEST', 'TEST_2', 'TEST_2', 'For database testing');
insert into component_name_translation (technology, raw_name, etest_name, notes) values
('TEST', 'TEST_3', 'TEST_3', 'For database testing');
insert into component_name_translation (technology, raw_name, etest_name, notes) values
('TEST', 'TEST_3_RESPIN', 'TEST_3', 'For database testing');
insert into component_name_translation (technology, raw_name, etest_name, notes) values
('TEST', 'TEST_3_RESPIN', 'TEST_4', 'For database testing');
