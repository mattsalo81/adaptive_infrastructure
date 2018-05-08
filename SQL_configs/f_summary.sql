create table f_summary (
    technology			varchar2 (16) 	not null,
    etest_name			varchar2 (32) 	not null,
    parm_type_pcd		varchar2 (3)	check (parm_type_pcd in ('MON', 'WAS', 'REL')),
    sampling_rate		varchar2 (3)	check (sampling_rate in ('MON', 'WAS', 'REL')),
    svn				varchar2 (32),
    process_options		varchar2 (128),
    component			varchar2 (128),
    test_type			varchar2 (32), 
    description			varchar2 (300),
    deactivate			varchar2 (1) default 'N',
    dispo			varchar2 (1),
    pass_criteria_percent	number   (2,2),
    reprobe_map			varchar2 (32),
    dispo_rule			varchar2 (16) default 'OPAP',
    spec_upper			number,
    spec_lower			number,
    reverse_spec_limit		varchar2 (1),
    reliability			varchar2 (1),
    reliability_upper		number,
    reliability_lower		number,
    reverse_reliability_limit	varchar2 (1),
    constraint fsum_pk PRIMARY KEY (technology, etest_name, process_options),
    constraint fsum_dispo check(
                dispo is null or 
                    dispo in ('Y', 'N') 
                    and pass_criteria_percent <= 1 
                    and pass_criteria_percent >=0
                    and dispo_rule in ('MRP', 'LRP', 'OPAP', 'OFAF')
                    and spec_lower is not null
    ),
    constraint fsum_dispo_lim check(
                spec_lower is null or 
                    spec_lower is not null
                    and spec_upper is not null
                    and spec_upper >= spec_lower
                    and reverse_spec_limit in ('Y', 'N')
    ),
    constraint fsum_ink check(
                reliability is null or 
                    reliability in ('Y', 'N')
                    and reliability_lower is not null
    ),
    constraint fsum_ink_lim check(
                reliability_lower is null or 
                    reliability_lower is not null
                    and reliability_upper is not null
                    and reliability_upper >= reliability_lower
                    and reverse_reliability_limit in ('Y', 'N')
    ),
    
    constraint fsum_deac check (deactivate in ('Y', 'N'))

);
-- Known parameter that exists
insert into f_summary (technology, etest_name, process_options) values 
('TEST_GOOD_TECH', 'EXISTS', 'BASELINE');
-- Testing if we can get muliple parameters
insert into f_summary (technology, etest_name, process_options) values 
('TEST_GOOD_TECH', 'DIFF_OPT', 'OPTION1');
insert into f_summary (technology, etest_name, process_options) values 
('TEST_GOOD_TECH', 'DIFF_OPT', 'OPTION2');
