create table device_to_design_manual(
	device varchar2 (32) not null,
	design varchar2 (32) not null,

	constraint dev2des_pk PRIMARY KEY (device, design)
)

