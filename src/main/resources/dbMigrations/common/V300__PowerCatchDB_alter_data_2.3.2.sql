-- SUP-566 Ny delsak "bestilling materiell" (HLK)
-- This UPSERT (if exist: UPDATE, if not exist: INSERT) is a combination of UPDATE and INSERT which can be run multiple times without adding extra, unwanted, records
--UPDATE prosjekt.jira_subissue SET pc_text='Bestilling materiell', sortorder=26 WHERE id_issuetype='PC_ISSUETYPE_ORDER_MATERIAL' AND locale='no_NO';
INSERT INTO prosjekt.jira_subissue(id_issuetype, pc_text, locale, sortorder, changed_by) SELECT 'PC_ISSUETYPE_ORDER_MATERIAL', 'Bestilling materiell', 'no_NO', 26, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.jira_subissue WHERE id_issuetype='PC_ISSUETYPE_ORDER_MATERIAL' AND locale='no_NO');


-- PC-3169 Ny delsak "Innmåling av anlegg" (Dalane)
--UPDATE prosjekt.jira_subissue SET pc_text='Innmåling av anlegg', sortorder=27 WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND locale='no_NO';
INSERT INTO prosjekt.jira_subissue(id_issuetype, pc_text, locale, sortorder, changed_by) SELECT 'PC_ISSUETYPE_MEASURE_INSTALLATION', 'Innmåling av anlegg', 'no_NO', 27, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.jira_subissue WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND locale='no_NO');
	   
-- Datafangst	   
--UPDATE prosjekt.task_objectdata SET pc_text='Innmålingsmetode:', sortorder=1 WHERE pc_task='PC_ISSUETYPE_MEASURE_INSTALLATION' AND pc_key='PC_MEASURE_METHOD' AND locale='no_NO'; 
INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_MEASURE_INSTALLATION', 'PC_MEASURE_METHOD', 'Innmålingsmetode:', 'no_NO', 1, 3, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.task_objectdata WHERE pc_task='PC_ISSUETYPE_MEASURE_INSTALLATION' AND pc_key='PC_MEASURE_METHOD' AND locale='no_NO');

-- Sluttkontroll
--UPDATE prosjekt.fc_value SET pc_text='Innmåling av anlegg utført og Netbas oppdatert', updateid=2 WHERE pc_key='PC_MEASURED_NETBAS_UPDATED' AND locale='no_NO';
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, updateid, changed_by) SELECT 'PC_MEASURED_NETBAS_UPDATED', 'no_NO', 'Innmåling av anlegg utført og Netbas oppdatert', 3, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_MEASURED_NETBAS_UPDATED' AND locale='no_NO');
--UPDATE prosjekt.fc_connection SET sortorder=1, updateid=2 WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND id_value='PC_MEASURED_NETBAS_UPDATED';	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_MEASURE_INSTALLATION', 'PC_MEASURED_NETBAS_UPDATED',1, 2, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND id_value='PC_MEASURED_NETBAS_UPDATED');

--UPDATE prosjekt.fc_value SET pc_text='Oppdatert driftssentral', updateid=2 WHERE pc_key='PC_UPDATED_CENTRAL' AND locale='no_NO';
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, updateid, changed_by) SELECT 'PC_UPDATED_CENTRAL', 'no_NO', 'Oppdatert driftssentral', 3, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_UPDATED_CENTRAL' AND locale='no_NO');
--UPDATE prosjekt.fc_connection SET sortorder=2, updateid=2 WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND id_value='PC_UPDATED_CENTRAL';	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_MEASURE_INSTALLATION', 'PC_UPDATED_CENTRAL',2, 2, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND id_value='PC_UPDATED_CENTRAL');
	
--UPDATE prosjekt.fc_value SET pc_text='Oppdatert tegninger/oversiktslister etc', updateid=2 WHERE pc_key='PC_UPDATED_DRAWINGS' AND locale='no_NO';
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, updateid, changed_by) SELECT 'PC_UPDATED_DRAWINGS', 'no_NO', 'Oppdatert tegninger/oversiktslister etc', 3, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_UPDATED_DRAWINGS' AND locale='no_NO');
--UPDATE prosjekt.fc_connection SET sortorder=3, updateid=2 WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND id_value='PC_UPDATED_DRAWINGS';	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) SELECT 'PC_ISSUETYPE_MEASURE_INSTALLATION', 'PC_UPDATED_DRAWINGS',3, 2, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_MEASURE_INSTALLATION' AND id_value='PC_UPDATED_DRAWINGS');
	
-- SJA
INSERT INTO prosjekt.sa_issuetype(pc_key, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_MEASURE_INSTALLATION', 0, 3, 'PowerCatch Update Script 2.3.2'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.sa_issuetype WHERE pc_key='PC_ISSUETYPE_MEASURE_INSTALLATION');
	
-- Cleanup
delete from prosjekt.sa_issuetype where pc_key = 'PC_ISSUETYPE_WO_NET' and deleted = 1;

	
-- New config for vector-tile-CSS
INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (90, 'vectortile_styles', '', 'PowerCatch Update Script 2.3.2', NULL, 'powercatch', 0);
-- This value should always be the same as the last id we insert manually (88 and 89 will be set by 2.4.0-script)
SELECT pg_catalog.setval('konfigurasjon.config_server_values_id_seq', 90, true);


-- PC-3168 Legge ved "Generell SJA" på alle delsaker, NETT
--- first delete all if they already exist to avoid duplicates if script runs several times
DELETE FROM prosjekt.sa_connection WHERE id_task='PC_GENERAL_SJA' AND updateid=6 AND changed_by='PowerCatch Update Script 2.3.2';
--- then insert the records
INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid, changed_by) SELECT id_issuetype, 'PC_GENERAL_SJA', 6, 'PowerCatch Update Script 2.3.2' from prosjekt.jira_subissue;