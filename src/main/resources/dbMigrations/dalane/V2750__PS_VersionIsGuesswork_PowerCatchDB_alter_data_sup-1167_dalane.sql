-- Insert fc values
INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_WORK_CORRECTLY_EXECUTED', 'no_NO', 'Arbeidet er utført etter vedlagte retningslinjer og beskrivelser.', 0, 6, 'PowerCatch Update Script SUP-1167'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_WORK_CORRECTLY_EXECUTED');

INSERT INTO prosjekt.fc_value(pc_key, locale, pc_text, deleted, updateid, changed_by) SELECT 'PC_FC_IMAGES_ATTACHED', 'no_NO', 'Det er vedlagt bildedokumentasjon på arbeidet som er utført.', 0, 6, 'PowerCatch Update Script SUP-1167'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_value WHERE pc_key='PC_FC_IMAGES_ATTACHED');

-- Insert fc connections
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE', 'PC_FC_WORK_CORRECTLY_EXECUTED', 17, 0, 4, 'PowerCatch Update Script SUP-1167'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE' AND id_value='PC_FC_WORK_CORRECTLY_EXECUTED');
	
INSERT INTO prosjekt.fc_connection(id_issuetype, id_value, sortorder, deleted, updateid, changed_by) SELECT 'PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE', 'PC_FC_IMAGES_ATTACHED', 18, 0, 4, 'PowerCatch Update Script SUP-1167'
	WHERE NOT EXISTS (SELECT 1 FROM prosjekt.fc_connection WHERE id_issuetype='PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE' AND id_value='PC_FC_IMAGES_ATTACHED');