create table design_to_components_manual(
    design 		varchar2 (32) not null,
    component 	varchar2 (128) not null,
    notes		varchar2 (256),

    constraint des2comp_pk PRIMARY KEY (design, component)
);
insert into design_to_components_manual (design, component, notes) values
('TEST_CHIP', 'TEST_COMP', 'For Database Testing');

