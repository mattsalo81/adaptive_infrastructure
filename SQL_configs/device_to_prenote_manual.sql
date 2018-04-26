create table device_to_prenote_manual(
	device		varchar2 (32) PRIMARY KEY,
	prenote		varchar2 (32) NOT NULL,
	notes		varchar2 (256)
);
insert into device_to_prenote_manual (device, prenote, notes) values
('TEST_DEVICE', 'TEST_PRENOTE', 'For Database testing');
