create table alignment_modules(
        technology       varchar(32),
        test_area        varchar(32),
        test_module      varchar(32),
        autoz            varchar(2) check(autoz in ('Y', 'N')),
        constraint al_mod_pk PRIMARY KEY (technology, test_area, test_module)
);
insert into alignment_modules (technology, test_area, test_module, autoz) values 
('TEST', 'TEST', 'AUTO', 'Y');
insert into alignment_modules (technology, test_area, test_module, autoz) values 
('TEST', 'TEST', 'NO_AUTO', 'N');
