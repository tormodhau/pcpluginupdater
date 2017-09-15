
-- SUP-908
-- Ny delsak, NETT: "PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE" Montasje jordfeilsøk

DO
$do$
	BEGIN
		IF NOT EXISTS (SELECT * FROM prosjekt.jira_subissue WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE') THEN
		
			RAISE NOTICE 'Inserting new issuetype: PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE';

			-- New issuetype
			INSERT INTO prosjekt.jira_subissue(id_issuetype, pc_text, locale, sortorder, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'Montasje jordfeilsøk', 'no_NO', 28, 'PowerCatch Update Script 2.6.0');

			-- Object data
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_CIRCUIT_NUMBER', 'Kretsnummer:', 'no_NO', 1, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_ZERO_ASSURANCE', 'Nullpunktsikring (O=Ok, D=Defekt, R=Reparert):', 'no_NO', 2, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_MEASURED_VOLTAGE_SUBSTATION', 'Målt spenning nettstasjon:', 'no_NO', 3, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_PHASE_VOLTAGE', 'Fasespenning:    V', 'no_NO', 4, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_VOLTAGE_L1', 'L1-J:    V', 'no_NO', 5, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_VOLTAGE_L2', 'L2-J:    V', 'no_NO', 6, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_VOLTAGE_L3', 'L3-J:    V', 'no_NO', 7, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SPACE', ' ', 'no_NO', 8, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_RESIDUAL_CURRENT', 'Jordfeilstrøm', 'no_NO', 9, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_RESIDUAL_CURRENT_CUSTOMER_1', 'Kunde 1:     Adresse:     Jordfeilstrøm:    mA', 'no_NO', 10, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_RESIDUAL_CURRENT_CUSTOMER_2', 'Kunde 2:     Adresse:     Jordfeilstrøm:    mA', 'no_NO', 11, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_RESIDUAL_CURRENT_CUSTOMER_3', 'Kunde 3:     Adresse:     Jordfeilstrøm:    mA', 'no_NO', 12, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_RESIDUAL_CURRENT_CUSTOMER_4', 'Kunde 4:     Adresse:     Jordfeilstrøm:    mA', 'no_NO', 13, 4, 'PowerCatch Update Script 2.6.0');

			-- Final check
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_NOT_RELEVANT',1, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_METER_FUSE_SIZE_INSTALLATION',2, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_METER_MARK_COLOR',3, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_METER_AVAILABILITY',4, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_VOLTAGE_MEASURE',5, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_METER_CONNECTION_TIGHTEN',6, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_DATA_SYSTEM_UPDATE_NOTES',7, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_METER_COMMUNICATION_TEST',8, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_INSTALLATION_VOLTAGE',9, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_TRANSFORMATOR_CONSUMPTION_VISIBLE',10, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_TRANSFORMATOR_DISTANCE',11, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_METER_TRANSFORMATOR_AVAILABILITY',12, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_SEAL',13, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_WATER_BEND',14, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_POLE_DISTANCE_NAIL',15, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_PROTECTION',16, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_GROUND_POLEBASE',17, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_EX_POLE',18, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_GROUND_REN4101',19, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_FOUNDATION_CABINET',20, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_CABINET_COVER',21, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CABLE_CONNECTION_MOMENT',22, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_METER_MOUNT_REN4100',23, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_FOUNDATION_CABINET_REN4100',24, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_DATA_SYSTEM_UPDATE_NOTES',25, 4, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_FC_CLEANUP',26, 4, 'PowerCatch Update Script 2.6.0');

			-- Safety assessment
			INSERT INTO prosjekt.sa_issuetype(pc_key, deleted, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 0, 4, 'PowerCatch Update Script 2.6.0');

			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_GENERAL_SJA', 7, 'PowerCatch Update Script 2.6.0');	
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_CABLE_TERMINATION', 7, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_LIVE_CABLE_MAST', 7, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_LINE_STRETCHING', 7, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_CRANE_BASKET', 7, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT', 7, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_POLES_BY_ROAD', 7, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_CONTROL_POLE', 7, 'PowerCatch Update Script 2.6.0');

			-- Add custom-field Nettstasjonsnummer to tab Anleggsdata on issuetype PC_ISSUETYPE_SUB_TASK_NET
			INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('283d5ef4-fb32-b295-9cb4-9f13d83006da', 'f4b56786-39b2-4c96-baed-e30c297bca0a', 'e3c29df2-b390-4e0c-82f0-3730c00f16c4', 5, 'PowerCatch Update Script 2.6.0');

		ELSE 
			RAISE NOTICE 'Issuetype PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE already exists.';
		END IF;
	END
$do$;

-- PC-3654-synkronisere-timesaldo: New config for turning display of hour balance on/off on mobile
INSERT INTO konfigurasjon.config_server_values(id, key, value, changed_by, reference_element, company_key, deleted) SELECT 98, 'mobileclient_show_hour_balance', 'false', 'PowerCatch Update Script 2.6.0', NULL, 'powercatch', 0 
	WHERE NOT EXISTS (SELECT 1 FROM konfigurasjon.config_server_values WHERE key='mobileclient_show_hour_balance');
SELECT pg_catalog.setval('konfigurasjon.config_server_values_id_seq', 98, true);


-- SUP-900
-- Ny delsak, NETT: "PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE" Montasje jordfeilsøk

DO
$do$
	BEGIN
		IF NOT EXISTS (SELECT * FROM prosjekt.sa_task WHERE pc_key = 'PC_SA_TASK_HEAT_WORK') THEN
		
			RAISE NOTICE 'Inserting new task PC_SA_TASK_HEAT_WORK for all issuetypes';

		-- New tasks. Only one common task for PC_ISSUETYPE_WO_NET
			INSERT INTO prosjekt.sa_task(pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_TASK_HEAT_WORK', 'no_NO', 'Varme arbeid', 0, 0, 3, 'PowerCatch Update Script 2.6.0');


		-- Connect risks and tasks
			INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_TASK_HEAT_WORK', 'PC_SA_RISK_FIRE', 'no_NO', 'Brann', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_TASK_HEAT_WORK', 'PC_SA_RISK_EXPLOSION', 'no_NO', 'Eksplosjonsfarlige rom og områder', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
				

		-- New actions for each risk
			-- PC_SA_RISK_FIRE
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_FLAMMABLE_ISOLATION', 'no_NO', 'Risiko ved brennbar isolasjon i konstruksjoner er vurdert', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_OPENINGS_CLOSED', 'no_NO', 'Åpninger i gulv, vegger og himlinger er tettet', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_HIDDEN_ROOMS', 'no_NO', 'Skjulte rom er kontrollert', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_FLAMMABLE_LIQUIDS', 'no_NO', 'Brennbare materialer/væsker er fjernet.', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_FLAMMABLE_MATERIALS', 'no_NO', 'Brennbart materiale som ikke kan flyttes og brennbare bygningsdeler er beskyttet eller fuktet', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_APPROVED_EXTINGUISHERS', 'no_NO', 'Godkjent slokkeutstyr, minimum 2 stk. 6kg pulverapparat', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_FIRE_DETECTORS', 'no_NO', 'Brannalarmdetektorer eller sløyfer er utkoblet', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_FIRE_GUARD', 'no_NO', 'Brannvakt er tilstede under arbeidet, i pauser og minst en time etter at arbeidet er avsluttet', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_EQUIPMENT', 'no_NO', 'Arbeidsutstyret er kontrollert og i orden', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_INCREASED_READINESS', 'no_NO', 'Behovet for økt beredskap for å kunne takle branntilløp er vurdert', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_ESCAPE_ROUTES', 'no_NO', 'Det finnes minst to rømningsveier fra risikoområdet. ', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_FIRE_PROCEDURES', 'no_NO', 'Nødnummer og prosedyrer for varsling av brann og ulykker er kjent', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_ADDRESS_KNOWN', 'no_NO', 'Arbeidsplassens adresse er kjent', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_FIRE', 'PC_SA_ACTION_TWO_PERSONS', 'no_NO', 'To på arbeidsstedet', 0, 0, 3, 'PowerCatch Update Script 2.6.0');

				
			-- PC_SA_RISK_EXPLOSION
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_EXPLOSION', 'PC_SA_ACTION_PERMISSION', 'no_NO', 'Skriftlig tillatelse fra eier evt. Oppdragsgiver', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_EXPLOSION', 'PC_SA_ACTION_RISK_AND_GAS', 'no_NO', 'Risikovurdering og gassmåling er foretatt', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_EXPLOSION', 'PC_SA_ACTION_EXPLOSIVE_GAS', 'no_NO', 'Acetylen/oksygenbeholdere er ikke tatt inn i lokalet', 0, 0, 3, 'PowerCatch Update Script 2.6.0');
			INSERT INTO prosjekt.sa_action(id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by) VALUES 
				('PC_SA_RISK_EXPLOSION', 'PC_SA_ACTION_VENTILATION', 'no_NO', 'Det er sørget for god ventilasjon', 0, 0, 3, 'PowerCatch Update Script 2.6.0');

				
		-- Connect all issuetypes with the new task
			INSERT INTO prosjekt.sa_connection (id_issuetype, id_task, updateid, changed_by) SELECT 
				pc_key, 'PC_SA_TASK_HEAT_WORK', 8, 'PowerCatch Update Script 2.6.0' FROM prosjekt.sa_issuetype;	
				
		ELSE 
			RAISE NOTICE 'New task PC_SA_TASK_HEAT_WORK already exists.';
		END IF;
	END
$do$;



DO
$$
BEGIN
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_role WHERE pc_key = 'PC_APPRENTICE') THEN
		INSERT INTO prosjekt.sa_role(id, pc_key, locale, pc_text, sortorder, updateid)
		VALUES (4, 'PC_APPRENTICE', 'no_NO', 'Lærling', 4, 2);
	ELSE
		RAISE NOTICE 'SA_ROLE with pc_key = PC_APPRENTICE already exists.';
	END IF;
END
$$;
