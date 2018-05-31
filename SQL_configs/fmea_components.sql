create table fmea_components(
    technology	varchar2 (16) not null,
    component 	varchar2 (128) not null,
    constraint fmea_pk PRIMARY KEY (technology, component)
);
insert into fmea_components (technology, component) values
('TEST', 'FMEA_COMP1');
insert into fmea_components (technology, component) values
('TEST', 'FMEA_COMP2');
