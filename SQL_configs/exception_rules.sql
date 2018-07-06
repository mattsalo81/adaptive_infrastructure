create table exception_rules(
             exception_number           number   (4,0) not null,
             rule_number                number   (4,0) default 0,
             active                     varchar2 (16)  default 'ACTIVE' check (active in ('ACTIVE', 'INACTIVE')),
             technology                 varchar2 (16),
             family                     varchar2 (128),
             dev_class                  varchar2 (128),
             prod_grp                   varchar2 (128),
             routing                    varchar2 (128),
             effective_routing          varchar2 (128),
             program                    varchar2 (128),
             device                     varchar2 (128),
             process_option             varchar2 (128),
             coordref                   varchar2 (128),
             test_lpt                   varchar2 (128),
             test_opn                   varchar2 (128),
             lpt                        varchar2 (128),
             functionality              varchar2 (128),
             pcd                        varchar2 (16),
             PCD_REV                    varchar2 (16),
             expiration_date            date,             
             constraint exc_rules_pk PRIMARY KEY (exception_number, rule_number),
             constraint exc_rules_fk FOREIGN KEY (exception_number) REFERENCES exception_sources (exception_number),
             constraint valid_rule check (
                        technology is not null or
                        family is not null or
                        routing is not null or
                        effective_routing is not null or
                        prod_grp is not null or
                        dev_class is not null or
                        program is not null or
                        device is not null or
                        process_option is not null or
                        coordref is not null or
                        coordref is not null or
                        coordref is not null or
                        test_lpt is not null or
                        test_opn is not null or
                        lpt is not null or
                        functionality is not null or
                        PCD_REV is not null),
            constraint pcd_rule check (PCD_REV is null or (pcd is not null));
);             
insert into exception_rules (exception_number, rule_number, active, technology) values 
(0, 0, 'ACTIVE', 'R_TEST');
insert into exception_rules (exception_number, rule_number, active, technology) values 
(0, 1, 'INACTIVE', 'R_TEST');





