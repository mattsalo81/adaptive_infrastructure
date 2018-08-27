create table technology_5_site(
    technology	                varchar(16)	not null,
    five_site_preference        varchar(5) check (five_site_preference in ('INNER', 'OUTER')),
    constraint t5s_pk PRIMARY KEY (technology)
);
insert into technology_5_site (technology, five_site_preference) values
('TEST_INNER', 'INNER');
insert into technology_5_site (technology, five_site_preference) values
('TEST_OUTER', 'OUTER');
