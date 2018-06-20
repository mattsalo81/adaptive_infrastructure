create table effective_component_info(
    technology	varchar2 (16) not null,
    program 	varchar2 (32) not null,
    component 	varchar2 (128) not null,
    constraint eff_comp_pk PRIMARY KEY (technology, program, component)
);
insert into effective_component_info (technology, program, component) values
('TEST', 'PROG1', 'COMP1');
insert into effective_component_info (technology, program, component) values
('TEST', 'PROG2', 'COMP2');
insert into effective_component_info (technology, program, component) values
('TEST', 'PROG2', 'COMP3');
insert into effective_component_info (technology, program, component) values
('TEST', 'PROG3', 'COMP4');
insert into effective_component_info (technology, program, component) values
('TEST', 'PROG3', 'COMP5');
insert into effective_component_info (technology, program, component) values
('TEST', 'PROG3', 'COMP6');
insert into effective_component_info (technology, program, component) values
('TEST', 'PROG3', 'NOT REAL COMP');
