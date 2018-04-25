create table component_name_translation(
	raw_name 		varchar2 (32) not null,
	etest_name 		varchar2 (32) not null,
	notes			varchar2 (256),
	constraint compname_pk PRIMARY KEY (raw_name, etest_name)
);
