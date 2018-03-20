create table effective_routing_to_options(
	technology		varchar2(16)	NOT NULL,
	effective_routing	varchar2(32)    NOT NULL,
	process_option		varchar2(32)	NOT NULL,
	constraint effrout2op_pk PRIMARY KEY (technology, effective_routing, process_option)
);
