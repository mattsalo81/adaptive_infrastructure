create table raw_scribes(
        technology       varchar(32),
        coordref         varchar(32),
        source           varchar(258),
        source_type      varchar(32),
        location         varchar(32),
        test_mod         varchar(32),
        mod_rev          varchar(32),
        orientation      varchar (7) check (orientation in ('LEFT','DOWN','UP','RIGHT','UNKNOWN')),
        x                number (10,6),
        y                number (10,6),
        placement        number(2),
        constraint r_scribes_pk PRIMARY KEY (technology, coordref, source, location, test_mod, mod_rev, orientation, placement),
        constraint r_scribes_pad check (x is null and y is null or x is not null and y is not null)
);
