-- SUP-992/PC-3927
DO
$$
BEGIN
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_task WHERE pc_key = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_task(pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_NON_PROC', 'no_NO', 'AUS uten spesifiserte arbeidsprosedyrer', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.sa_task WHERE pc_key = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_task(pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'no_NO', 'AUS med spesifiserte arbeidsprosedyrer', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.sa_risk WHERE id_task = 'PC_SA_TASK_POWERED_WORK_PROCED' AND pc_key = 'PC_SA_RISK_MECHANICAL_POWER_TOOLS') THEN
		INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'PC_SA_RISK_MECHANICAL_POWER_TOOLS', 'no_NO', '1 Mekaniske krefter i verktøy', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED - PC_SA_RISK_MECHANICAL_POWER_TOOLS already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.sa_risk WHERE id_task = 'PC_SA_TASK_POWERED_WORK_PROCED' AND pc_key = 'PC_SA_RISK_PERSONELL_EARTHING') THEN
		INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'PC_SA_RISK_PERSONELL_EARTHING', 'no_NO', '2 Beskyttelsesjording for personell, også bakkepersonell', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED - PC_SA_RISK_PERSONELL_EARTHING already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.sa_risk WHERE id_task = 'PC_SA_TASK_POWERED_WORK_PROCED' AND pc_key = 'PC_SA_RISK_GIK') THEN
		INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'PC_SA_RISK_GIK', 'no_NO', '3 GIK', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED - PC_SA_RISK_GIK already exists.';
	END IF;
		
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_risk WHERE id_task = 'PC_SA_TASK_POWERED_WORK_PROCED' AND pc_key = 'PC_SA_RISK_WEATHERCONDITIONS') THEN
		INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'PC_SA_RISK_WEATHERCONDITIONS', 'no_NO', '4 Værforhold', 0, 4);	
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED - PC_SA_RISK_WEATHERCONDITIONS already exists.';
	END IF;
		
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_risk WHERE id_task = 'PC_SA_TASK_POWERED_WORK_PROCED' AND pc_key = 'PC_SA_RISK_SECURITYDISTANCE') THEN
		INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'PC_SA_RISK_SECURITYDISTANCE', 'no_NO', '5 Sikkerhetsavstand', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED - PC_SA_RISK_SECURITYDISTANCE already exists.';
	END IF;
		
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_risk WHERE id_task = 'PC_SA_TASK_POWERED_WORK_PROCED' AND pc_key = 'PC_SA_RISK_FAILURE_BY_MOVEMENT') THEN
		INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'PC_SA_RISK_FAILURE_BY_MOVEMENT', 'no_NO', '6 Fare for svikt ved bevegelser av faser, utstyr og verktøy', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED - PC_SA_RISK_FAILURE_BY_MOVEMENT already exists.';
	END IF;
		
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_risk WHERE id_task = 'PC_SA_TASK_POWERED_WORK_PROCED' AND pc_key = 'PC_SA_RISK_OTHER') THEN
		INSERT INTO prosjekt.sa_risk(id_task, pc_key, locale, pc_text, sortorder, updateid)
		VALUES ('PC_SA_TASK_POWERED_WORK_PROCED', 'PC_SA_RISK_OTHER', 'no_NO', '7 Annet', 0, 4);
	ELSE 
		RAISE NOTICE 'PC_SA_TASK_POWERED_WORK_PROCED - PC_SA_RISK_OTHER already exists.';
	END IF;
	
	
	-- "Montasje HS-bryteranlegg i nettstasjon"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje HS-bryter i mast"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje graving av grøft for kabel og rør"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje endeavsl./tilkobling kabel HS"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje endeavsl./tilkobling kabel LS"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje skift/monter trafo i mast"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje reising/bardunering mast HS/LS"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje jordplatemåling"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje ombygging av nettstasjon i mast"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje prefab. nettstasjon på bakke"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje prefab. nettstasjon i mast"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje skift kabelskap"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje strekking LS"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje transformator NS bakke"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje tilkobling kabel i mast"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
	
	-- "Montasje jordfeilsøk"
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE' AND id_task = 'PC_SA_TASK_POWERED_WORK_NON_PROC') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_POWERED_WORK_NON_PROC', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE and PC_SA_TASK_POWERED_WORK_NON_PROC already exists.';
	END IF;
	
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_connection WHERE id_issuetype = 'PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE' AND id_task = 'PC_SA_TASK_POWERED_WORK_PROCED') THEN
		INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, updateid)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE', 'PC_SA_TASK_POWERED_WORK_PROCED', 8);
	ELSE 
		RAISE NOTICE 'Connection for PC_ISSUETYPE_ASSEMBLY_GROUND_ERROR_TRACE and PC_SA_TASK_POWERED_WORK_PROCED already exists.';
	END IF;
END
$$;


DO
$$
BEGIN
	IF NOT EXISTS (SELECT * FROM prosjekt.sa_role WHERE id = 1) THEN
		INSERT INTO prosjekt.sa_role(id, pc_key, locale, pc_text, sortorder, updateid)
		VALUES (1, 'PC_WORKER', 'no_NO', 'Montør', 1, 1);
	ELSE
		RAISE NOTICE 'SA_ROLE with ID = 1 already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.sa_role WHERE id = 2) THEN
		INSERT INTO prosjekt.sa_role(id, pc_key, locale, pc_text, sortorder, updateid)
		VALUES (2, 'PC_AUS_PLANNER', 'no_NO', 'AUS-planlegger', 2, 1);
	ELSE
		RAISE NOTICE 'SA_ROLE with ID = 2 already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.sa_role WHERE id = 3) THEN
		INSERT INTO prosjekt.sa_role(id, pc_key, locale, pc_text, sortorder, updateid)
		VALUES (3, 'PC_SECURITY_LEAD', 'no_NO', 'Leder for sikkerhet', 3, 1);
	ELSE
		RAISE NOTICE 'SA_ROLE with ID = 3 already exists.';
	END IF;
END
$$;


-- SUP-1036
DO
$$
BEGIN
	IF NOT EXISTS (SELECT * FROM prosjekt.task_objectdata WHERE pc_task = 'PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER' AND pc_key = 'PC_METERPOINT_ID') THEN
		INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER', 'PC_METERPOINT_ID', 'Målepunkt-id:', 'no_NO', 6);
	ELSE
		RAISE NOTICE 'task_objectdata for PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER and PC_METERPOINT_ID already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.task_objectdata WHERE pc_task = 'PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER' AND pc_key = 'PC_FUSESIZE_MAINFUSE') THEN
		INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER', 'PC_FUSESIZE_MAINFUSE', 'Sikringsstørrelse hovedsikring:', 'no_NO', 7);
	ELSE
		RAISE NOTICE 'task_objectdata for PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER and PC_FUSESIZE_MAINFUSE already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.task_objectdata WHERE pc_task = 'PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER' AND pc_key = 'PC_METERPOINT_ID') THEN
		INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER', 'PC_METERPOINT_ID', 'Målepunkt-id:', 'no_NO', 14);
	ELSE
		RAISE NOTICE 'task_objectdata for PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER and PC_METERPOINT_ID already exists.';
	END IF;

	IF NOT EXISTS (SELECT * FROM prosjekt.task_objectdata WHERE pc_task = 'PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER' AND pc_key = 'PC_FUSESIZE_MAINFUSE') THEN
		INSERT INTO prosjekt.task_objectdata(pc_task, pc_key, pc_text, locale, sortorder)
		VALUES ('PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER', 'PC_FUSESIZE_MAINFUSE', 'Sikringsstørrelse hovedsikring:', 'no_NO', 15);
	ELSE
		RAISE NOTICE 'task_objectdata for PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER and PC_FUSESIZE_MAINFUSE already exists.';
	END IF;
END
$$;