create table pcd_rev(
    PCD         varchar2 (16),
    ACTIVE      varchar2 (3) check (ACTIVE in ('CUR', 'OLD')),
    REV         varchar2 (16),
    DATE_ALIGNED DATE default sysdate,

    constraint pcd_rev_pk PRIMARY KEY (PCD, REV)
);
insert into pcd_rev (pcd, active, rev) values 
('EXCEPTION_TEST', 'CUR', '1.0');
