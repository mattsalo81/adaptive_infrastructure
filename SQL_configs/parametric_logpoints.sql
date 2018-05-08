create table etest_logpoints(
    logpoint	number(4,0)	not null,
    operation	number(4,0)	not null,
    test_area	varchar2(32)	not null,
    constraint logpoint_pk primary key (logpoint, operation)
)
