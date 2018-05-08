create table limits_database  (
    technology			varchar2 (16)   not null,
        test_area                       varchar2 (16)   not null,
    item_type			varchar2 (16)   check (item_type in ('TECHNOLOGY', 'ROUTING', 'PROGRAM', 'DEVICE')),
    item				varchar2 (32)   not null,
    etest_name			varchar2 (32) 	not null,
    deactivate			varchar2 (1)    default 'N',
        sampling_rate                   varchar2 (3)    check (sampling_rate in ('MON', 'WAS', 'REL')),
    dispo				varchar2 (1),
    pass_criteria_percent		number   (2,2),
    reprobe_map			varchar2 (32),
    dispo_rule			varchar2 (16) default 'OPAP',
    spec_upper			number,
    spec_lower			number,
    reverse_spec_limit		varchar2 (1),
    reliability			varchar2 (1),
    reliability_upper		number,
    reliability_lower		number,
    reverse_reliability_limit	varchar2 (1),
        limit_comments                  varchar2 (1024),
    constraint ld_pk PRIMARY KEY (technology, test_area, item_type, item, etest_name),
        constraint ld_dispo check(
                                dispo is null or
                                        dispo in ('Y', 'N')
                                        and pass_criteria_percent <= 1
                                        and pass_criteria_percent >=0
                                        and dispo_rule in ('MRP', 'LRP', 'OPAP', 'OFAF')
                                        and spec_lower is not null
        ),
        constraint ld_dispo_lim check(
                                spec_lower is null or
                                        spec_lower is not null
                                        and spec_upper is not null
                                        and spec_upper >= spec_lower
                                        and reverse_spec_limit in ('Y', 'N')
        ),
        constraint ld_ink check(
                                reliability is null or
                                        reliability in ('Y', 'N')
                                        and reliability_lower is not null
        ),
        constraint ld_ink_lim check(
                                reliability_lower is null or
                                        reliability_lower is not null
                                        and reliability_upper is not null
                                        and reliability_upper >= reliability_lower
                                        and reverse_reliability_limit in ('Y', 'N')
        ),
    constraint ld_deac check (deactivate in ('Y', 'N')),
    constraint ld_funny check (item_type != 'TECHNOLOGY' or technology = item)

);
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'TECHNOLOGY', 'TEST_TECH', 'PARM1', 'Y');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'TECHNOLOGY', 'TEST_TECH', 'PARM2', 'N');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'ROUTING', 'TEST_ROUT', 'PARM2', 'Y');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'TECHNOLOGY', 'TEST_TECH', 'PARM3', 'N');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'ROUTING', 'TEST_ROUT', 'PARM3', 'N');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'PROGRAM', 'TEST_PROG', 'PARM3', 'Y');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'TECHNOLOGY', 'TEST_TECH', 'PARM4', 'N');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'ROUTING', 'TEST_ROUT', 'PARM4', 'N');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'PROGRAM', 'TEST_PROG', 'PARM4', 'N');
insert into limits_database (technology, test_area, item_type, item, etest_name, deactivate) values 
('TEST_TECH', 'TEST_AREA', 'DEVICE', 'TEST_DEV', 'PARM4', 'Y');

