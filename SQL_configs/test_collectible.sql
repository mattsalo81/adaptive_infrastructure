create table test_collectible(
       technology varchar(32),
       test_mod varchar(32),
       test_group varchar(32),
       constraint tc_pk PRIMARY KEY (technology, test_mod, test_group)
);
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_CONFLICT', 'CONFLICT_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_DEFINED', 'UNDEFINED_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_GAP', 'GAP_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_INCOMPLETE', 'INCOMPLETE_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_LPT_DEP', 'LOGPOINT_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_MISSING', 'MISSING_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_MULTI_1', 'MULTI_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_MULTI_2', 'MULTI_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_PO_DEP', 'PROCESS_OPTION_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_PRECEDENCE', 'PRECEDENCE_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_PRIORITY', 'PRIORITY_RESOLVE');
insert into test_collectible (technology, test_mod, test_group) values
('WAV_TEST', 'WAV_TEST_SIMPLE', 'SIMPLE_RESOLVE');
