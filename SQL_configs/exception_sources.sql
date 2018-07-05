create table exception_sources(
    exception_number            number (4) primary key,
    source                      varchar2(256),
    active                      varchar2(12) check (active in ('ACTIVE', 'INACTIVE')),
    notes                       varchar2(1024)
);
insert into exception_sources (exception_number, source, active, notes) values
(0, 'Testing purposes', 'ACTIVE', 'Used to test exception system');
insert into exception_sources (exception_number, source, active, notes) values
(1, 'Testing purposes', 'INACTIVE', 'Used to test exception system');

