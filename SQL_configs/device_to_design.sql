create table device_to_design_manual(
	device varchar2 (32) not null,
	design varchar2 (32) not null,
	notes  varchar2 (256),

	constraint dev2des_pk PRIMARY KEY (device, design)
);
insert into device_to_design_manual (device, design, notes) values
('TEST_DEVICE', 'TEST_CHIP', 'For database testing');
