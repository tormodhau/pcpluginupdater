-- equipment_db_path
DO
$$
BEGIN
IF NOT EXISTS (SELECT 1
               FROM konfigurasjon.config_server_values
               WHERE key = 'equipment_db_path') THEN
	INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (99, 'equipment_db_path', 'c:\PowerCatch\equipmentdb\equipment.sqlite', 'PowerCatch Update Script 2.5.1', NULL, 'powercatch', 0);
ELSE
  RAISE NOTICE 'Configuration for key: "equipment_db_path" already exists, skipping';
END IF;
END
$$;

-- equipment_db_zip_limit
DO
$$
BEGIN
IF NOT EXISTS (SELECT 1
               FROM konfigurasjon.config_server_values
               WHERE key = 'equipment_db_zip_limit') THEN
	INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (100, 'equipment_db_zip_limit', '5000', 'PowerCatch Update Script 2.5.1', NULL, 'powercatch', 0);
ELSE
  RAISE NOTICE 'Configuration for key: "equipment_db_zip_limit" already exists, skipping';
END IF;
END
$$;

-- equipment_mapping
DO
$$
BEGIN
IF NOT EXISTS (SELECT 1
               FROM konfigurasjon.config_server_values
               WHERE key = 'equipment_mapping') THEN
	INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (101, 'equipment_mapping', '{"item": [{"itemid": "No", "name": "Description", "description": "Description",	"unit": "Base_Unit_of_Measure",	"attrs": "Product_Group_Code,Batch_Size,ETag"}],"stock": [{"stockid": "", "name": "", "address": ""}],"unit": [{"unitid": "Base_Unit_of_Measure", "name": "Base_Unit_of_Measure", "description": ""}]}', 'PowerCatch Update Script 2.5.1', NULL, 'powercatch', 0);
ELSE
  RAISE NOTICE 'Configuration for key: "equipment_mapping" already exists, skipping';
END IF;
END
$$;




DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM konfigurasjon.config_server_values WHERE key='equipment_config') THEN
		INSERT INTO konfigurasjon.config_server_values(id, key, value, changed_by, reference_element, company_key, deleted) SELECT 102, 'equipment_config', '{"DOKUMENTASJON":"Materiell-nummer som er listet opp i objekt under various_items , felt equipment_number vil bli behandlet som diverse-vare på mobil. Dette innebærer at flere linjer kan ha samme nummer og navn/enhet kan overstyres av bruker.","various_items":[{"equipment_number":"9999999"},{"equipment_number":"0000000"}]}', 'Flyway konfigurasjon V1', NULL, 'powercatch', 0;
		PERFORM pg_catalog.setval('konfigurasjon.config_server_values_id_seq', 102, true);
	ELSE
		RAISE NOTICE 'Config already has equipment_config - skip insert';
	END IF;
END
$$;



-- TEN-267
-- Opprette nFeed-felt for kundeordre
DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key WHERE pc_key = 'PC_TASK_METER_CHANGE') THEN

		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METER_CHANGE', 1, 1, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_TEMP_POWER_SUPPLY_ASSEMBLY', 2, 2, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_TEMP_POWER_SUPPLY_DISASSEMBLY', 3, 3, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METER_REMOVE', 4, 4, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_SYSTEM_DISCONNECTION_STOP', 5, 5, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_SYSTEM_DISCONNECTION_PAYMENT', 6, 6, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_SYSTEM_CONNECTION_NEW_CUSTOMER', 7, 7, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_SYSTEM_CONNECTION_PAYMENT', 8, 8, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METER_SETUP', 9, 9, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_TERMINAL_EXCHANGE', 10, 10, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_TERMINAL_CHANGE', 11, 11, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_TERMINAL_SETUP', 12, 12, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METERCONTROL_DEBUG', 13, 13, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METERCONTROL_SEAL', 14, 14, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METERCONTROL_COMPLAIN', 15, 15, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METERCONTROL_READ', 16, 16, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_METERCONTROL_CHANGE', 17, 17, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_REVISION_SYSTEM', 18, 18, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_REVISION_METER', 19, 19, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_REVISION_SAMPLE', 20, 20, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_ENERGYPULSE_SETUP', 21, 21, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_CONCENTRATOR_WORK', 22, 22, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KO', 'PC_CUSTOMER_WORKORDER', 'PC_TASK', 'PC_TASK_CONTROL_CLOSED_INSTALLATION', 67, 23, 'PowerCatch Update Script 3.0.0');

		RAISE NOTICE 'Added initial values (TEN-267) to table key';
	ELSE
		RAISE NOTICE 'Initial values (TEN-267) exists, dropping insert';
	END IF;
END
$$;

DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key_translation WHERE pc_text = 'Målerbytte') THEN

		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (1, 'Målerbytte', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (2, 'Byggestrøm Oppsett', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (3, 'Byggestrøm Nedtak', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (4, 'Målernedtak', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (5, 'Anleggsutkobling Opphør', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (6, 'Anleggsutkobling Betalingsoppfølging', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (7, 'Anleggsinnkobling Overgang til ny kunde', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (8, 'Anleggsinnkobling Betalingsoppfølging', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (9, 'Måleroppsett/Nyanlegg', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (10, 'Terminal Bytte', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (11, 'Terminal Endring', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (12, 'Terminal Oppsett', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (13, 'Målerkontroll Feilsøk', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (14, 'Målerkontroll Plombering', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (15, 'Målerkontroll Klagesak (kundeklage)', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (16, 'Målerkontroll Avlesning', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (17, 'Målerkontroll Endring i målepunkt', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (18, 'Revisjon Anlegg', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (19, 'Revisjon Måler', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (20, 'Revisjon Stikkprøve', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (21, 'Oppsett energipuls', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (22, 'Arbeid med konsentrator', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (67, 'Kontroll stengte anlegg', 'PowerCatch Update Script 3.0.0');

		RAISE NOTICE 'Added initial values (TEN-267) to table key_translation';
	ELSE
		RAISE NOTICE 'Initial values (TEN-267) exists, dropping insert';
	END IF;
END
$$;


-- TEN-349
-- Opprette nFeed-felt for serviceordre
DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key WHERE pc_key = 'PC_TASK_MOVE') THEN

		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_MOVE', 23, 1, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_NET_EXPANSION', 24, 2, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_CONNECT_DISCONNECT', 25, 3, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_CORRECTIVE_ACTION', 26, 4, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_METER_WORK', 27, 5, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_LATERAL', 28, 6, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_SERVICE_TEMP_POWER_SUPPLY', 29, 7, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_INSPECTION', 30, 8, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_CUSTOMER_CARE', 31, 9, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_VOLTAGE_COMPLAINT', 32, 10, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_REINVESTMENT', 33, 11, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('SO', 'PC_ISSUETYPE_SERVICEORDER', 'PC_TASK', 'PC_TASK_INVESTMENT', 34, 12, 'PowerCatch Update Script 3.0.0');
		
		RAISE NOTICE 'Added initial values (TEN-349) to table key';
	ELSE
		RAISE NOTICE 'Initial values (TEN-349) exists, dropping insert';
	END IF;
END
$$;

DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key_translation WHERE pc_text = 'Service Flytting') THEN

		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (23, 'Service Flytting', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (24, 'Service Nettutvidelse', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (25, 'Service Ut- innkobling installatør', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (26, 'Service Korrektiv tiltak', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (27, 'Service Målerarbeid', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (28, 'Service Stikkledning', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (29, 'Service Byggstrøm', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (30, 'Service Befaring', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (31, 'Service Kundebehandling', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (32, 'Service Spenningsklage', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (33, 'Service Reinvestering', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (34, 'Service Investering', 'PowerCatch Update Script 3.0.0');
		
		RAISE NOTICE 'Added initial values (TEN-349) to table key_translation';
	ELSE
		RAISE NOTICE 'Initial values (TEN-349) exists, dropping insert';
	END IF;
END
$$;


-- TEN-415
-- Opprette listeverdier for TableGrid

-- READBYCODE
DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key WHERE pc_key = 'Montør') THEN

		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', 'Montør', 35, 1, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '2', 36, 2, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '3', 37, 3, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '4', 38, 4, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '5', 39, 5, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '6', 40, 6, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '7', 41, 7, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '8', 42, 8, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '9', 43, 9, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '11', 44, 10, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '20', 45, 11, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '23', 46, 12, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '24', 47, 13, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '26', 48, 14, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '27', 49, 15, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '28', 50, 16, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '29', 51, 17, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '50', 52, 18, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '55', 53, 19, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '60', 54, 20, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READBYCODE', '70', 55, 21, 'PowerCatch Update Script 3.0.0');
		
		RAISE NOTICE 'Added initial values (TEN-415) to table key: READBYCODE';
	ELSE
		RAISE NOTICE 'Initial values (TEN-415) exists, dropping insert: READBYCODE';
	END IF;
END
$$;

DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key_translation WHERE pc_text = 'Avlest av netteier') THEN

		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (35, 'Avlest av netteier', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (36, 'Avlest av kunden', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (37, 'Stipulert', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (38, 'Beregnet stand', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (39, 'Beregnet effekt for avregning', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (40, 'Effektavlesning avregnes ikke', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (41, 'Interpolert', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (42, 'Beregnet effekt (ikke stand)', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (43, 'Beregnet kvartalseffekt', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (44, 'Avlest av installatør', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (45, 'Manuelt tlf.avlest kunde', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (46, 'Innringt avlesn. av kunde (tlf.avlest)', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (47, 'Avlesning via internett (Touch)', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (48, 'Avlest av kunde via mail', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (49, 'Avlest via SMS', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (50, 'Scannet avlesn.kort', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (51, 'Stipulert avlesn. av Intelli', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (52, 'Elektronisk overførsel', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (53, 'Generert verdi', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (54, 'Generert startavlesning', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (55, 'Avlesning avregnes ikke', 'PowerCatch Update Script 3.0.0');
		
		RAISE NOTICE 'Added initial values (TEN-415) to table key_translation: READBYCODE';
	ELSE
		RAISE NOTICE 'Initial values (TEN-415) exists, dropping insert: READBYCODE';
	END IF;
END
$$;		

-- READINCONNECTIONWITHCODE
DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key WHERE pc_key = 'Mounting') THEN

		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'Mounting', 56, 1, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'Dismounting', 57, 2, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'Ordinary', 58, 3, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'Extra', 59, 4, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'DeliveryChange', 60, 5, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'MovingOut', 61, 6, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'Control', 62, 7, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'Temporary', 63, 8, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'Replacement', 64, 9, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'MovingIn', 65, 10, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'METER_READING', 'READINCONNECTIONWITHCODE', 'None', 66, 11, 'PowerCatch Update Script 3.0.0');
		
		RAISE NOTICE 'Added initial values (TEN-415) to table key: READINCONNECTIONWITHCODE';
	ELSE
		RAISE NOTICE 'Initial values (TEN-415) exists, dropping insert: READINCONNECTIONWITHCODE';
	END IF;
END
$$;

DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key_translation WHERE pc_text = 'Oppsett av måler') THEN

		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (56, 'Oppsett av måler', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (57, 'Nedtak av måler', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (58, 'Ordinær', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (59, 'Ekstraordinær', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (60, 'Leverandørbytte', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (61, 'Utflytting', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (62, 'Kontroll', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (63, 'Midlertidig', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (64, 'Bytte', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (65, 'Innflytting', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (66, '', 'PowerCatch Update Script 3.0.0');

		RAISE NOTICE 'Added initial values (TEN-415) to table key_translation: READINCONNECTIONWITHCODE';
	ELSE
		RAISE NOTICE 'Initial values (TEN-415) exists, dropping insert: READINCONNECTIONWITHCODE';
	END IF;
END
$$;		

-- TRANSFORMATOR, TYPE (TEN-576)
DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key WHERE pc_key = 'Power') THEN

		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'TRANSFORMATOR', 'TYPE', 'Power', 68, 1, 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key (project, issuetype, target, pc_key, translation_id, sortorder, changed_by) VALUES ('KIS', 'TRANSFORMATOR', 'TYPE', 'Voltage', 69, 2, 'PowerCatch Update Script 3.0.0');
		
		RAISE NOTICE 'Added initial values (TEN-576) to table key: TYPE';
	ELSE
		RAISE NOTICE 'Initial values (TEN-576) exists, dropping insert: TYPE';
	END IF;
END
$$;

DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.key_translation WHERE pc_text = 'Strømtrafo') THEN

		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (68, 'Strømtrafo', 'PowerCatch Update Script 3.0.0');
		INSERT INTO prosjekt.key_translation (id, pc_text, changed_by) VALUES (69, 'Spenningstrafo', 'PowerCatch Update Script 3.0.0');

		RAISE NOTICE 'Added initial values (TEN-576) to table key_translation: TYPE';
	ELSE
		RAISE NOTICE 'Initial values (TEN-576) exists, dropping insert: TYPE';
	END IF;
END
$$;	

-- Fix typo (PC-4051)
DO
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM prosjekt.sa_risk WHERE pc_text = 'Klemkader') THEN
		RAISE NOTICE 'No typo to fix (PC-4051)';
	ELSE
		UPDATE prosjekt.sa_risk SET pc_text='Klemskader', updateid=5 WHERE pc_text = 'Klemkader';
		RAISE NOTICE 'Typo Klemkader edited to Klemskader (PC-4051)';
	END IF;
END
$$;	
