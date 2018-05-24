create table component_to_bit (
        technology			varchar2 (16)   not null,
        component			varchar2 (128)  not null,
        bit                             number   (3)    not null,
    constraint c2b_pk primary key (technology, component, bit)
);
insert into component_to_bit (technology, component, bit) values
('TEST', 'COMP1', '21');
insert into component_to_bit (technology, component, bit) values
('TEST', 'COMP2', '22');
insert into component_to_bit (technology, component, bit) values
('TEST', 'COMP3', '23');
insert into component_to_bit (technology, component, bit) values
('TEST', 'COMP4', '24');
insert into component_to_bit (technology, component, bit) values
('TEST', 'COMP5', '25');
insert into component_to_bit (technology, component, bit) values
('TEST', 'COMP6', '26');
insert into component_to_bit (technology, component, bit) values
('TEST', 'COMP100', '30');
