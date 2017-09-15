-- PC-3503 PC_NEW_COMDEVICE_SERIAL_NUMBER Obligatorisk felt
-- Add new Fieldproperty with required field
insert into konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, hidden, scannable, hide_values, cross_validation, dependency_field, changed_by, changed_date, deleted, gui) values ('6446d857-3fbb-4b72-ae0e-b177aa27030f',NULL,1,1,NULL,'993af071-d4b9-457a-b233-2837d601e701',0,1,1,1,NULL,'PowerCatch admin','2016-04-18 13:40:18.855+02',0,0);
-- Update 128 to use new fieldproperty
update konfigurasjon.page_fieldproperty set id_fieldproperty='6446d857-3fbb-4b72-ae0e-b177aa27030f' where id_page='3ce54236-966e-4968-bc98-f74c5193977d' and id_fieldproperty = '154a67cb-b247-435a-9a5d-66b6cac1917c';
