create table component_info(
    technology	varchar2 (16) not null,
    device 		varchar2 (32) not null,
    component 	varchar2 (128) not null,
    constraint comp_pk PRIMARY KEY (technology, device, component)
);
insert into component_info (technology, device, component) values
('TEST', 'DEV1', 'COMP1');
insert into component_info (technology, device, component) values
('TEST', 'DEV2', 'COMP2');
insert into component_info (technology, device, component) values
('TEST', 'DEV2', 'COMP3');
insert into component_info (technology, device, component) values
('TEST', 'DEV3', 'COMP4');
insert into component_info (technology, device, component) values
('TEST', 'DEV3', 'COMP5');
insert into component_info (technology, device, component) values
('TEST', 'DEV3', 'COMP6');
insert into component_info (technology, device, component) values
('TEST', 'DEV3', 'NOT REAL COMP');
