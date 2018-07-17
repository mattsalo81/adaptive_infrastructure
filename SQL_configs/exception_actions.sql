create table exception_actions(
    exception_number    number  (4)  not null,
    action_number       number  (4)  not null,
    action_type         varchar2(32) check (action_type in ('LIMITS')),
    action              varchar2(32),
    object              varchar2(32),
    subject             varchar2(32),
    value               varchar2(256),
    constraint exc_a_pk PRIMARY KEY (exception_number, action_number),
    constraint exc_a_lim check (
        action_type != 'LIMITS' or
            action in ('RELAX', 'SET', 'TIGHTEN') and object in ('LSL', 'USL', 'LRL', 'URL', 'PASS_CRITERIA_PERCENT', 'SAMPLING_RATE')
            or action = 'SET' and object in ('DISPO_RULE', 'LIMIT_COMMENTS', 'REPROBE_MAP')
            or action in ('SET_REVERSED', 'SET_UNREVERSED', 'USE', 'NO_USE') and object in ('SPEC', 'REL')
            or action = 'DEACTIVATE' and object = 'PARAMETER'
    )
);
insert into exception_actions (exception_number, action_number, action_type, action, object, subject, value) values
(0, 0, 'LIMITS', 'SET', 'USL', 'TEST_PARM', -10);
insert into exception_actions (exception_number, action_number, action_type, action, object, subject, value) values
(1, 0, 'LIMITS', 'SET', 'LIMIT_COMMENTS', NULL, 'This comment was set in the database');
