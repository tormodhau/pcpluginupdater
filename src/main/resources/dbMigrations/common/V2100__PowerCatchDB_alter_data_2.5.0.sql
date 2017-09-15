-- New config for vector-tile-CSS
INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (91, 'mapit_infrastructure_popup', '', 'PowerCatch Update Script 2.5.0', NULL, 'powercatch', 0);
INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (92, 'mobileclient_infrastructure_layout', '', 'PowerCatch Update Script 2.5.0', NULL, 'powercatch', 0);
INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (93, 'mobileclient_infrastructure_sync', '', 'PowerCatch Update Script 2.5.0', NULL, 'powercatch', 0);
INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (94, 'infrastructure_db_path', 'C:\PowerCatch\infrastructuredb\infrastructure.db', 'PowerCatch Update Script 2.5.0', NULL, 'powercatch', 0);
INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (95, 'infrastructure_db_zip_limit', '1000', 'PowerCatch Update Script 2.5.0', NULL, 'powercatch', 0);

-- Detected on new installation that owner was postgres - this resulted in sync-error on mobile
ALTER TABLE prosjekt.sa_risk OWNER TO powercatch;

-- SUP-701 - common available from 2.5.0
insert into konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by, changed_date, deleted, gui) values ('3228f3fe-9596-4661-ba9a-6911668fab66','f4b56786-39b2-4c96-baed-e30c297bca0a','b1de6368-e72b-4db6-8d7d-9a88b5dae3d0',3,'PowerCatch admin','2016-06-10 11:06:51.297+02',0,0);
insert into konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by, changed_date, deleted, gui) values ('3ad029ca-d4b3-4d3e-b5cf-5899e67b2f95','f4b56786-39b2-4c96-baed-e30c297bca0a','55254909-80a4-44a3-b5f5-4339413e6b27',4,'PowerCatch admin','2016-06-10 11:06:52.665+02',0,0);

INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (96, 'mobileservlet_netbas_xml_destination', 'INTERN', 'PowerCatch Update Script 2.5.0', NULL, 'powercatch', 0);

-- Delete fields added in PC-3329 in 2.4.4 (Markering av viktig informasjon på arbeidsordre)
delete from konfigurasjon.page_fieldproperty where id='0eb6c76c-04a3-0a89-53de-2815b71a0747' and id_fieldproperty = 'b1400988-c593-d93a-76e5-b4eec73bbcc7';
delete from konfigurasjon.fieldproperty where id = 'b1400988-c593-d93a-76e5-b4eec73bbcc7' and id_field = 'edc14f8d-ef20-9600-251c-2cd5e6ef18c5';
delete from konfigurasjon.field where id = 'edc14f8d-ef20-9600-251c-2cd5e6ef18c5' and name = 'PC_IMPORTANT_INFO';

-- Should powercatch use activeMq (used in listener)
INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (97, 'powercatch_uses_activemq', 'false', 'PowerCatch Update Script 2.5.0', NULL, 'powercatch', 0);
-- This value should always be the same as the last id we insert manually (90 will be set by 2.3.3-script)
SELECT pg_catalog.setval('konfigurasjon.config_server_values_id_seq', 97, true);


-- PC-3539 part 1
--	will set drop_signature on all issuetypes which don't have a page containing field PC_SIGNATURE_REQUIRED
update konfigurasjon.issuetype set drop_signature=1 where id in (select id_issuetype from konfigurasjon.issuetype_page where id_page in (select id from konfigurasjon.page where name = 'pc.page.order.info' and id not in 
(select distinct page.id from konfigurasjon.page, ((konfigurasjon.field 
inner join konfigurasjon.fieldproperty on field.id = fieldproperty.id_field) 
inner join konfigurasjon.page_fieldproperty on page_fieldproperty.id_fieldproperty = fieldproperty.id) 
where field.name = 'PC_SIGNATURE_REQUIRED' and page.id = page_fieldproperty.id_page and page.name = 'pc.page.order.info')));

-- PC-3539 part 2
--	will delete PC_SIGNATURE_REQUIRED from all pages since this is obsolete after drop_signature on issuetype-level was introduced
delete from konfigurasjon.page_fieldproperty where id_fieldproperty = (select id from konfigurasjon.fieldproperty where id_field = (select id from konfigurasjon.field where name = 'PC_SIGNATURE_REQUIRED'));
delete from konfigurasjon.fieldproperty where id_field = (select id from konfigurasjon.field where name = 'PC_SIGNATURE_REQUIRED');
delete from konfigurasjon.field where name = 'PC_SIGNATURE_REQUIRED';

-- PC-3402 Oppdatere layoutlist ao med og uten SJA til å bruke PC_PROJECT_NUBER isteden for PC_ORDER_NUMBER
update konfigurasjon.page_fieldproperty set id_fieldproperty = '45fca5ff-c819-4745-8ffe-668ea1cf852e' where id_page='53584e38-400d-4905-a563-08e56853f2ec' and id_fieldproperty ='71f25906-c204-432c-a38c-be73d09be9da';

-- PC-3593
--	added Final Control (sluttkontroll) for Montasje graving av grøft for stikkledning (PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE)
--	inserts can be run multiple times without duplicating data
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_NOT_RELEVANT',1, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_NOT_RELEVANT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_DITCH_URBAN',2, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_DITCH_URBAN');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_DITCH_WILD',3, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_DITCH_WILD');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_DITCH_CABLE_PIPE',4, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_DITCH_CABLE_PIPE');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_DITCH_AGRICULTURE',5, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_DITCH_AGRICULTURE');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_DITCH_SHALLOW',6, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_DITCH_SHALLOW');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_MASS_BACKFILL',7, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_MASS_BACKFILL');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_MASS_FILLING',8, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_MASS_FILLING');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_TOP_LEVELING',9, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_TOP_LEVELING');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_ASPHALT_AREA_MEASURE',10, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_ASPHALT_AREA_MEASURE');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_PRIVATE_AGREEMENT',11, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_PRIVATE_AGREEMENT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_CABLE_GROUND_REN4101',12, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_CABLE_GROUND_REN4101');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_CABLE_BEND',13, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_CABLE_BEND');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_CABLE_BAND_MOUNT',14, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_CABLE_BAND_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_DATA_SYSTEM_UPDATE_NOTES',15, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_DATA_SYSTEM_UPDATE_NOTES');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE', 'PC_FC_CLEANUP',16, 3, 'PowerCatch Update Script 2.5.0' 
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE' AND id_value='PC_FC_CLEANUP');

-- PC-3417 Erding i layout for Befaring på stedet	
insert into konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by, changed_date, deleted, gui) values ('4add62eb-4c44-47ef-ab3a-aab7cd1c7f10','664881ac-3245-403f-afd8-94ec6a8bf1ce','f4b56786-39b2-4c96-baed-e30c297bca0a',2,'PowerCatch admin','2016-09-15 13:27:13.262+02',0,0);
delete from konfigurasjon.issuetype_page where id = '57fb4b35-79f2-4e18-a187-1d92dafd85cb';
update konfigurasjon.issuetype_page set id_issuetype = '664881ac-3245-403f-afd8-94ec6a8bf1ce', id_page = 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', sortorder = 5, changed_by = 'PowerCatch admin', changed_date = '2016-09-15 13:27:13.257+02', deleted = 0, gui = 0 where id = 'ab438739-274f-4b9a-93da-84950dd6a955';
update konfigurasjon.issuetype_page set id_issuetype = '664881ac-3245-403f-afd8-94ec6a8bf1ce', id_page = '083bbac1-bafa-40a3-95eb-743b18faefaf', sortorder = 4, changed_by = 'PowerCatch admin', changed_date = '2016-09-15 13:27:13.255+02', deleted = 0, gui = 0 where id = '68f51438-5fc7-46b4-be0d-bbfd088ba9b3';
delete from konfigurasjon.issuetype_page where id = '78a65757-b531-416b-9579-bcf5e7b1cfd0';
update konfigurasjon.issuetype_page set id_issuetype = '664881ac-3245-403f-afd8-94ec6a8bf1ce', id_page = '4f0f380c-e58e-4222-a59b-5ac41c145793', sortorder = 3, changed_by = 'PowerCatch admin', changed_date = '2016-09-15 13:27:13.235+02', deleted = 0, gui = 0 where id = 'd5f7e9ea-1079-4160-a592-4f130354251e';
insert into konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by, changed_date, deleted, gui) values ('448a0b86-04bb-4f7b-bdf9-aa69a3664079','664881ac-3245-403f-afd8-94ec6a8bf1ce','335321c9-58d7-4aba-85fc-f208e963fee1',1,'PowerCatch admin','2016-09-15 13:27:13.087+02',0,0);


-- CHANGES AFTER RC CREATED ---

-- Change sortorder, PC-3036
UPDATE konfigurasjon.issuetype_page SET sortorder=8, changed_by='PowerCatch Update Script 2.5.0' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 7 AND id_page = 'ee363b7d-5f24-48e1-8fff-689c4f80d651';
UPDATE konfigurasjon.issuetype_page SET sortorder=7, changed_by='PowerCatch Update Script 2.5.0' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 6 AND id_page = '1905badf-c9f9-456c-82ca-4d9f9c6791d0';
UPDATE konfigurasjon.issuetype_page SET sortorder=6, changed_by='PowerCatch Update Script 2.5.0' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 5 AND id_page = '5b7e4a0d-2438-4090-9559-923e75659c53';
UPDATE konfigurasjon.issuetype_page SET sortorder=5, changed_by='PowerCatch Update Script 2.5.0' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 4 AND id_page = 'f3b63b5a-9b9f-473e-a165-6a3f537b0989';
UPDATE konfigurasjon.issuetype_page SET sortorder=4, changed_by='PowerCatch Update Script 2.5.0' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 3 AND id_page = '03edfc1f-7663-e593-0151-d7a512cab832';