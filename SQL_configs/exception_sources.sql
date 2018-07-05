create table exception_sources(
    exception_number            number (4) primary key,
    source                      varchar2(256),
    active                      varchar2(12) check (active in ('ACTIVE', 'INACTIVE')),
    notes                       varchar2(1024)
)


