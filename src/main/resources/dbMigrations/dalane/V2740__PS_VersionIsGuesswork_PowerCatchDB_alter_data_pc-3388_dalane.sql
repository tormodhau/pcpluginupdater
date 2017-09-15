-- Create issuetype: Montasje gatelys
INSERT INTO prosjekt.jira_subissue(id_issuetype, pc_text, locale, sortorder, deleted, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'Montasje gatelys', 'no_NO', 28, 0, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.jira_subissue WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT');

INSERT INTO prosjekt.sa_issuetype(pc_key, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.sa_issuetype WHERE pc_key='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT');
	
-- SA
INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_GENERAL_SJA', 0, 7, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.sa_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT');
	
-- FC values
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_CONTINUITY_MEASURED', 'no_NO', 'Det er målt kontinuitet i beskyttelsesledere og utjevningsforbindelser', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_CONTINUITY_MEASURED');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_ISOLATION_MEASURED', 'no_NO', 'Det er utført isolasjonsmåling (måles mellom fase og jord)', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_ISOLATION_MEASURED');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_CONTACT_RESISTANCE', 'no_NO', 'Det er målt eller beregnet overgangsmotstand på jordelektrode (angi måleverdi som kommentar)', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_CONTACT_RESISTANCE');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_AUTOMATIC_DISCONNECT', 'no_NO', 'Det er kontrollert at kursene har automatisk utkobling', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_AUTOMATIC_DISCONNECT');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_VOLTAGE_DROP', 'no_NO', 'Det er kontrollert spenningsfall', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_VOLTAGE_DROP');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_POLARITY', 'no_NO', 'Det er foretatt polaritetskontroll', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_POLARITY');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_LUMINANCE', 'no_NO', 'Det er utført luminansmåling', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_LUMINANCE');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_LIGHT_STRENGTH', 'no_NO', 'Det er utført måling av belysningsstyrke', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_LIGHT_STRENGTH');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_MATERIAL_CE', 'no_NO', 'Utstyret er CE-merket og montert i hht monteringsanvisning', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_MATERIAL_CE');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_CONNECTIONS_CORRECT', 'no_NO', 'Alle tilkoblinger er utført riktig', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_CONNECTIONS_CORRECT');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_ACCESS', 'no_NO', 'Det er tilstrekkelig adgang for kontroll og vedlikehold', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_ACCESS');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_SELECTIVITY', 'no_NO', 'Selektiviteten i anlegget er kontrollert (dersom dette er et krav)', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_SELECTIVITY');	
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_ARMATURE_MOUNT', 'no_NO', 'Armaturen er korrekt montert etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_ARMATURE_MOUNT');		
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_GROUND_MOUNT', 'no_NO', 'Avleder samt jordleder til avleder er montert korrekt etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_GROUND_MOUNT');		
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_FOUNDATION_MOUNT', 'no_NO', 'Fundament er montert korrekt etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_FOUNDATION_MOUNT');	
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_POLE_MOUNT', 'no_NO', 'Stolpen samt bardun er montert korrekt etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_POLE_MOUNT');	
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_WIRE_MOUNT', 'no_NO', 'Ledning er montert korrekt (inkludert pilhøyde) etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_WIRE_MOUNT');	
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_WIRE_SUSPENSION_MOUNT', 'no_NO', 'Linjeoppheng er montert korrekt etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_WIRE_SUSPENSION_MOUNT');	
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_COMMON_ROUTING_MOUNT', 'no_NO', 'Fellesføring er montert korrekt etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_COMMON_ROUTING_MOUNT');	
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_FOUNDATION_POLE_MOUNT', 'no_NO', 'Fundament til mast er montert korrekt etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_FOUNDATION_POLE_MOUNT');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_CABLE_MOUNT', 'no_NO', 'Kabler er forlagt og montert korrekt etter angitte retningslinjer', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_CABLE_MOUNT');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_CABINET_MOUNT', 'no_NO', 'Kabelskap er montert korrekt', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_CABINET_MOUNT');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_IGNITION', 'no_NO', 'Tenningsfunksjonen fungerer tilfredsstillende', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_IGNITION');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_LIGHTREGULATION', 'no_NO', 'Lysregulering fungerer tilfredsstillende', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_LIGHTREGULATION');
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_EXTRA_WORK', 'no_NO', 'Mulig tilleggsarbeid er notert/registrert', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_EXTRA_WORK');
	
-- FC connections
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_CONTINUITY_MEASURED', 1, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_CONTINUITY_MEASURED');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_ISOLATION_MEASURED', 2, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_ISOLATION_MEASURED');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_CONTACT_RESISTANCE', 3, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_CONTACT_RESISTANCE');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_AUTOMATIC_DISCONNECT', 4, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_AUTOMATIC_DISCONNECT');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_VOLTAGE_DROP', 5, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_VOLTAGE_DROP');		
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_SS_FUNCTIONAL_TEST', 6, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_SS_FUNCTIONAL_TEST');		
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_POLARITY', 7, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_POLARITY');		
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_LUMINANCE', 8, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_LUMINANCE');		
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_LIGHT_STRENGTH', 9, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_LIGHT_STRENGTH');		
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_MATERIAL_AMOUNT_TYPE', 10, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_MATERIAL_AMOUNT_TYPE');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_MATERIAL_CE', 11, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_MATERIAL_CE');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_CONNECTIONS_CORRECT', 12, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_CONNECTIONS_CORRECT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_ACCESS', 13, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_ACCESS');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_SELECTIVITY', 14, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_SELECTIVITY');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_ARMATURE_MOUNT', 15, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_ARMATURE_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_GROUND_MOUNT', 16, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_GROUND_MOUNT');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_FOUNDATION_MOUNT', 17, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_FOUNDATION_MOUNT');		
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_POLE_MOUNT', 18, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_POLE_MOUNT');	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_WIRE_MOUNT', 19, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_WIRE_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_WIRE_SUSPENSION_MOUNT', 20, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_WIRE_SUSPENSION_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_COMMON_ROUTING_MOUNT', 21, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_COMMON_ROUTING_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_FOUNDATION_POLE_MOUNT', 22, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_FOUNDATION_POLE_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_CABLE_MOUNT', 23, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_CABLE_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_CABINET_MOUNT', 24, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_CABINET_MOUNT');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_IGNITION', 25, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_IGNITION');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_LIGHTREGULATION', 26, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_LIGHTREGULATION');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_OPERATION_LABEL_ROUTINES', 27, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_OPERATION_LABEL_ROUTINES');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_AREA_CLEANUP', 28, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_AREA_CLEANUP');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT', 'PC_FC_EXTRA_WORK', 29, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_STREET_LIGHT' AND id_value='PC_FC_EXTRA_WORK');
	
-- Create issuetype: Montasje diverse
INSERT INTO prosjekt.jira_subissue(id_issuetype, pc_text, locale, sortorder, deleted, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_VARIOUS', 'Montasje diverse', 'no_NO', 28, 0, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.jira_subissue WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_VARIOUS');
	
INSERT INTO prosjekt.sa_issuetype(pc_key, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_VARIOUS', 0, 4, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.sa_issuetype WHERE pc_key='PC_ISSUETYPE_ASSEMBLY_VARIOUS');

-- SA
INSERT INTO prosjekt.sa_connection(id_issuetype, id_task, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_VARIOUS', 'PC_GENERAL_SJA', 0, 7, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.sa_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_VARIOUS');	
	
-- FC connections
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_VARIOUS', 'PC_FC_WORK_AS_INSTRUCTED', 1, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_VARIOUS' AND id_value='PC_FC_WORK_AS_INSTRUCTED');
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_VARIOUS', 'PC_FC_AREA_CLEANUP', 2, 0, 3, 'PowerCatch Update Script PC-3388'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_VARIOUS' AND id_value='PC_FC_AREA_CLEANUP');

-- bugfix, missing values
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, changed_by, updateid) VALUES ('PC_FC_WORK_AS_INSTRUCTED', 'no_NO', 'Arbeidet er utført etter gjeldende retningslinjer', 'PowerCatch Update Script PC-3388', 5);
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, changed_by, updateid) VALUES ('PC_FC_CONTRACT_NOT_NEEDED', 'no_NO', 'Arbeidet krever ikke samsvarserklæring', 'PowerCatch Update Script PC-3388', 5);
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, changed_by, updateid) VALUES ('PC_FC_CONTRACT_ATTACHED', 'no_NO', 'Samsvarserklæring ligger vedlagt', 'PowerCatch Update Script PC-3388', 5);