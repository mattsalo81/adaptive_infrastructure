create table logpoint_option_assertions(
	technology	varchar2(16)	NOT NULL,
	assertion	varchar2(256)	NOT NULL,
	constraint lptoptass_pk PRIMARY KEY (technology, assertion)
);

