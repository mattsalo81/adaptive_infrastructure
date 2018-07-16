create table exception_actions(
    exception_number    number  (4)  not null,
    action_number       number  (4)  not null,
    action_type         varchar2(32) check (action_type in ('LIMITS')),
    action              varchar2(32),
    object              varchar2(32),
    subject             varchar2(32),
    value               varchar2(32),
    constraint exc_a_pk PRIMARY KEY (exception_number, action_number)
);
insert into exception_actions (exception_number, action_number, action_type, action, object, subject, value) values
(1, 0, 'LIMITS', 'SET', 'USL', 'TEST_PARM', -10);
