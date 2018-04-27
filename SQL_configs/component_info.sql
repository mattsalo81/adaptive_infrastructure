create table component_info(
	device 		varchar2 (32) not null,
	component 	varchar2 (128) not null,
	constraint comp_pk PRIMARY KEY (device, component)
);
