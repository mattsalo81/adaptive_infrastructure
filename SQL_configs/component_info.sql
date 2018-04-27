create table component_info(
	technology	varchar2 (16) not null,
	device 		varchar2 (32) not null,
	component 	varchar2 (128) not null,
	constraint comp_pk PRIMARY KEY (technology, device, component)
);
