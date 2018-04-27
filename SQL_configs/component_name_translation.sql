create table component_name_translation(
	raw_name 		varchar2 (32) not null,
	etest_name 		varchar2 (32) not null,
	notes			varchar2 (256),
	constraint compname_pk PRIMARY KEY (raw_name, etest_name)
);
insert into component_name_translation (raw_name, etest_name, notes) values
('MATT_TEST_1', 'MATT_TEST_1', 'For database testing');
insert into component_name_translation (raw_name, etest_name, notes) values
('MATT_TEST_2', 'MATT_TEST_2', 'For database testing');
insert into component_name_translation (raw_name, etest_name, notes) values
('MATT_TEST_3', 'MATT_TEST_3', 'For database testing');
insert into component_name_translation (raw_name, etest_name, notes) values
('MATT_TEST_3_RESPIN', 'MATT_TEST_3', 'For database testing');
insert into component_name_translation (raw_name, etest_name, notes) values
('MATT_TEST_3_RESPIN', 'MATT_TEST_4', 'For database testing');
