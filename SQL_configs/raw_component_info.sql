create table raw_component_info(
	technology	varchar2 (16) not null,
	device 		varchar2 (32) not null,
	component 	varchar2 (128) not null,
	manual		varchar2 (1) check (manual in ('Y', 'N')),
	constraint rawcomp_pk PRIMARY KEY (technology, device, component)
);
insert into raw_component_info (technology, device, component, manual) values
('TEST', 'TEST_DEVICE1', 'UNDEFINED_COMP', 'Y');
insert into raw_component_info (technology, device, component, manual) values
('TEST', 'TEST_DEVICE1', 'TEST_1', 'Y');
insert into raw_component_info (technology, device, component, manual) values
('TEST', 'TEST_DEVICE2', 'TEST_1', 'Y');
insert into raw_component_info (technology, device, component, manual) values
('TEST', 'TEST_DEVICE2', 'TEST_2', 'Y');
insert into raw_component_info (technology, device, component, manual) values
('TEST', 'TEST_DEVICE3', 'TEST_3', 'Y');
insert into raw_component_info (technology, device, component, manual) values
('TEST', 'TEST_DEVICE3', 'TEST_3_RESPIN', 'Y');
