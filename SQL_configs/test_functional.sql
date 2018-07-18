create table test_functional(
       technology varchar(32),
       test_mod varchar(32),
       mod_rev varchar(32),
       test_group varchar(32),
       priority number(2),
       process_option varchar(128),
       logpoints varchar(128),
       functionality varchar(32) check (REGEXP_LIKE(functionality, '^(SF|NF|NSF[0-9])$')),
       notes varchar(256),
       constraint tf_pk PRIMARY KEY (technology, test_mod, mod_rev, test_group, functionality),
       constraint tf_null_priority check ( 
                                    (REGEXP_LIKE(functionality, '^(SF|NF)$') and priority is null) or
                                    ((not REGEXP_LIKE(functionality, '^(SF|NF)$')) and priority is not null)
                                    ),
       constraint tf_take_notes check((REGEXP_LIKE(functionality, '^(SF|NF)$')) or notes is not null),
       constraint tf_no_regex check(
                        ((not REGEXP_LIKE(mod_rev, '[/\*]')) or (mod_rev = '*')) and -- Can't use regex here, only star for default
                        ((not REGEXP_LIKE(test_group, '[/\*]')) or (test_group = '*')) and -- Can't use regex here, only star for default
                        (not REGEXP_LIKE(test_mod, '[/\*]'))  -- Can't use regex here, only star for default
                        ),
       constraint tf_priority check( priority is null or priority > -1)
);
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_SIMPLE', '*', 'SIMPLE_RESOLVE', '', '', '', 'SF', '');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PRECEDENCE', '*', 'PRECEDENCE_RESOLVE', '', '', '', 'SF', '');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PRECEDENCE', 'A', 'PRECEDENCE_RESOLVE', '', '', '', 'NF', '');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PRECEDENCE', 'B', 'PRECEDENCE_RESOLVE', '5', '', '', 'NSF1', 'Test for precedence');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PRIORITY', 'A', 'PRIORITY_RESOLVE', '1', '', '', 'NSF1', 'Test for priority');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PRIORITY', 'B', 'PRIORITY_RESOLVE', '2', '', '', 'NSF2', 'Test for priority');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_DEFINED', '*', 'UNDEFINED_RESOLVE', '', '', '', 'SF', 'Resolves unless');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_MISSING', '*', '*', '', '', '', 'SF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_MULTI_1', '*', '*', '', '', '', 'SF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_MULTI_2', '*', '*', '', '', '', 'SF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PO_DEP', '*', '*', '', '', '', 'SF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PO_DEP', 'A', '*', '', 'opt1', '', 'NF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_PO_DEP', 'B', '*', '', 'opt2', '', 'NF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_LPT_DEP', '*', '*', '', '', '', 'SF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_LPT_DEP', 'A', '*', '', '', '!9300', 'NF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_LPT_DEP', 'B', '*', '', '', '9300', 'NF', 'all resolve if they exist');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_CONFLICT', 'A', '*', '', 'opt1', '', 'NF', 'Nonfunctional for opt1 (conflict if opt1.!opt2)');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_CONFLICT', 'A', '*', '', '!opt2', '', 'SF', 'functional for opt2 (conflict if opt1.!opt2)');
insert into test_functional (technology, test_mod, mod_rev, test_group, priority, process_option, logpoints, functionality, notes) values
('WAV_TEST', 'WAV_TEST_GAP', 'A', '*', '', 'opt1.opt2', '', 'SF', 'Only defined for one process option.  gaps for devices that have module but do not meet p.o req');
