/*	UN-COMMENT TO ADD FIELD 'Ax Prosjekt' TO NETT-ISSUES ON MOBILE
-- ----------------------------------------
-- Customized layout-list for Dalane Energi
--    Adding field Ax Prosjekt to PC_ISSUETYPE_WO_NET and PC_ISSUETYPE_SUB_TASK_NET
-- lage field 
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) SELECT '20696524-145b-8b3d-389a-b9b6846182cb', NULL, 'PC_PROJECT_EXTERNAL', 15500, 'PowerCatch Update Script 2.3.3'
	WHERE NOT EXISTS (SELECT 1 FROM konfigurasjon.field WHERE id = '20696524-145b-8b3d-389a-b9b6846182cb');

-- lage field-property
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) SELECT '23da7db8-49ea-aa15-1787-492127b338d4', 'Ax Prosjekt', 0, NULL, NULL, '20696524-145b-8b3d-389a-b9b6846182cb', 'PowerCatch Update Script' 
	WHERE NOT EXISTS (SELECT 1 FROM konfigurasjon.fieldproperty WHERE id = '23da7db8-49ea-aa15-1787-492127b338d4');
	
-- koble field-property og page order.info
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) SELECT 'db4e67a2-8097-7027-5ba0-157ab95ab1c5', '7dbb5114-e884-3645-daee-ee421bbf4a8b', '23da7db8-49ea-aa15-1787-492127b338d4', 3, 'PowerCatch Update Script' 
	WHERE NOT EXISTS (SELECT 1 FROM konfigurasjon.page_fieldproperty WHERE id = 'db4e67a2-8097-7027-5ba0-157ab95ab1c5');
	
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) SELECT '9a1797d6-cd8c-aa6c-785a-7acdf7719667', '335321c9-58d7-4aba-85fc-f208e963fee1', '23da7db8-49ea-aa15-1787-492127b338d4', 3, 'PowerCatch Update Script'
	WHERE NOT EXISTS (SELECT 1 FROM konfigurasjon.page_fieldproperty WHERE id = '9a1797d6-cd8c-aa6c-785a-7acdf7719667');
*/

-- PC-3310
update konfigurasjon.page_fieldproperty set id_page = '335321c9-58d7-4aba-85fc-f208e963fee1', id_fieldproperty = '250b1d86-34fd-47ff-a9b6-de5aec805e3e', sortorder = 5, changed_by = 'PowerCatch admin', changed_date = '2016-05-02 08:56:30.858+02', deleted = 0 where id = 'e84ff71d-d5e5-4ecc-a39d-0957b4883a9a';
update konfigurasjon.page_fieldproperty set id_page = '335321c9-58d7-4aba-85fc-f208e963fee1', id_fieldproperty = '549ab99d-d4a4-4454-a418-deb6d3423f8b', sortorder = 4, changed_by = 'PowerCatch admin', changed_date = '2016-05-02 08:56:30.847+02', deleted = 0 where id = 'afa120cf-a97d-45bd-a6b0-8e1522d40be3';
update konfigurasjon.page_fieldproperty set id_page = '335321c9-58d7-4aba-85fc-f208e963fee1', id_fieldproperty = '2c44e699-173c-4091-9a5c-873e459618a3', sortorder = 3, changed_by = 'PowerCatch admin', changed_date = '2016-05-02 08:56:30.736+02', deleted = 0 where id = '8ada6864-28e1-4444-b499-211ef3d682f7';
insert into konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by, changed_date, deleted) values ('bec259a5-d0be-44dc-903f-87483ec2391b','335321c9-58d7-4aba-85fc-f208e963fee1','4e8a31ff-3040-4e14-9d60-9eae17e1b7b3',6,'PowerCatch admin','2016-05-02 08:56:28.687+02',0);
