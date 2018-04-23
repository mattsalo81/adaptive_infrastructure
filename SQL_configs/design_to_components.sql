create table design_to_components_manual(
	design 		varchar2 (32) not null,
	component 	varchar2 (128) not null,

	constraint des2comp_pk PRIMARY KEY (design, component)
)

