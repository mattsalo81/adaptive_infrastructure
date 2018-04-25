create table raw_component_info(
	device 		varchar2 (32) not null,
	component 	varchar2 (128) not null,
	manual		varchar2 (1) check (manual in ('Y', 'N')),
	constraint rawcomp_pk PRIMARY KEY (device, component)
);
