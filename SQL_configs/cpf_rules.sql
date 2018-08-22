create table cpf_rules(
        technology       varchar(32),
        priority         varchar(32),
        process_options  varchar(128),
        module_rule      varchar(128),
        cpf_base         varchar(32),
        constraint cpf_pk PRIMARY KEY (technology, priority)
);
insert into cpf_rules (technology, priority, process_options, module_rule, cpf_base) values 
('TEST', 0, NULL, NULL, 'base');
insert into cpf_rules (technology, priority, process_options, module_rule, cpf_base) values 
('TEST', 1, NULL, 'MOD1 || MOD2', 'cpf2');
insert into cpf_rules (technology, priority, process_options, module_rule, cpf_base) values 
('TEST', 2, 'OPTION1 && OPTION2', NULL, 'cpf1');
