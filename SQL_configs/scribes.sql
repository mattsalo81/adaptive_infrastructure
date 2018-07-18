create table scribes(
        technology       varchar(32),
        coordref         varchar(32),
        test_mod         varchar(32),
        mod_rev          varchar(32),
        orientation      varchar (7) check (orientation in ('LEFT','DOWN','UP','RIGHT','UNKNOWN')),
        pad1_x           number (10,6),
        pad1_y           number (10,6),
        array_x          number (10,6),
        array_y          number (10,6),
        placement        number(2),
        constraint scribes_pk PRIMARY KEY (technology, coordref, test_mod, mod_rev, orientation, placement),
        constraint scribes_pad check (pad1_x is null and pad1_y is null or pad1_x is not null and pad1_y is not null),
        constraint scribes_arr check (array_x is null and array_y is null or array_x is not null and array_y is not null)
);
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_CONFLICT', 'A', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_DEFINED', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_GAP', 'A', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_INCOMPLETE', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_LPT_DEP', 'A', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_MISSING', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_MULTI_1', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_PO_DEP', 'A', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_PRECEDENCE', 'A', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_PRIORITY', 'B', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD1', 'WAV_TEST_SIMPLE', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_DEFINED', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_LPT_DEP', 'B', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_MULTI_2', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_PO_DEP', 'B', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_PRECEDENCE', 'A', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_PRECEDENCE', 'B', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_PRECEDENCE', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_PRIORITY', 'A', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD2', 'WAV_TEST_PRIORITY', 'B', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD3', 'WAV_TEST_DEFINED', 'whatever', 'DOWN', '0');
insert into scribes (technology, coordref, test_mod, mod_rev, orientation, placement) values
('WAV_TEST', 'TCOORD3', 'WAV_TEST_UNDEFINED', 'whatever', 'DOWN', '0');
