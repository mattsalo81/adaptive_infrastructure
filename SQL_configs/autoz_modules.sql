create table autoz_modules(
        technology       varchar(32),
        test_area        varchar(32),
        test_module      varchar(32),
        constraint autoz_pk PRIMARY KEY (technology, test_area, test_module)
);
insert into autoz_modules (technology, test_area, test_module) values 
('TEST', 'TEST', 'TEST');
