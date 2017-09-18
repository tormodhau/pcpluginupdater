--------- EMBRIQ oppsett -------



-- ################# Slette  - 2.4.0 kode som ikke skal være med på embriq

/*

-- Insert new meter replacement issuetype 
-- INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('4b252da2-5a38-4c15-940e-6fd7033d3d10','PC_ISSUETYPE_METER_REPLACEMENT', 'PPT', 0, 'summary', 'PowerCatch Update Script');
delete from konfigurasjon.issuetype where id = '4b252da2-5a38-4c15-940e-6fd7033d3d10';

-- Insert new pages
--INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('77562310-d45c-4400-b71f-7d5d334c10a7', 'pc.page.customerdata', NULL, 'PowerCatch Update Script', 106);
delete from konfigurasjon.page where id = '77562310-d45c-4400-b71f-7d5d334c10a7';
--INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('3acc5fd5-602e-48f2-aedd-0440491fbcfb', 'pc.page.installation.data', NULL, 'PowerCatch Update Script', 107);
delete from konfigurasjon.page where id = '3acc5fd5-602e-48f2-aedd-0440491fbcfb';
--INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('a998c50a-21f4-4c8d-895f-2b524f6d8e82', 'pc.page.measure.equipment', NULL, 'PowerCatch Update Script', 108);
delete from konfigurasjon.page where id = 'a998c50a-21f4-4c8d-895f-2b524f6d8e82';
--INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('fbc82b7f-159d-4da9-afbc-c0c96978283e', 'pc.page.order.info', NULL, 'PowerCatch Update Script', 109);
delete from konfigurasjon.page where id = 'fbc82b7f-159d-4da9-afbc-c0c96978283e';

-- Insert new fields
--INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7b3483b4-d84f-42ec-bba8-4a06ee0869af', NULL, 'PC_INSTALLATION_STREET_NO', NULL, 'PowerCatch Update Script');
delete from konfigurasjon.field where id = '7b3483b4-d84f-42ec-bba8-4a06ee0869af';
--INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('e4aad805-6426-46fa-841a-3579ad637109', NULL, 'PC_METER_NUMBER', NULL, 'PowerCatch Update Script');
delete from konfigurasjon.field where id = 'e4aad805-6426-46fa-841a-3579ad637109';
--INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7d8c04ab-dad6-43e2-affe-eb25478c5422', NULL, 'PC_OLD_METER_READING', NULL, 'PowerCatch Update Script');
delete from konfigurasjon.field where id = '7d8c04ab-dad6-43e2-affe-eb25478c5422';
--INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('d4437ec5-01d4-4f7a-a3e9-aef3f45cc631', NULL, 'PC_REGISTERED_VOLTAGE2', NULL, 'PowerCatch Update Script');
-- Brukes på vokks og embriq oppsett INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('683e847a-4f12-4b8b-ab5a-31130fd8a8a6', NULL, 'PC_BOOKING_ORDER', NULL, 'PowerCatch Update Script');


-- Insert field property for new fields
--INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('93bc6821-7f29-4f5b-b987-26830d6a18f8', '', 0, NULL, NULL, '7b3483b4-d84f-42ec-bba8-4a06ee0869af', 'PowerCatch Update Script'); -- PC_INSTALLATION_STREET_NO-properties
delete from konfigurasjon.fieldproperty  where id = '93bc6821-7f29-4f5b-b987-26830d6a18f8';
--INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('cb9e039e-a1f9-49aa-afe6-aba86fe968d9', '', 1, 1, NULL, 'e4aad805-6426-46fa-841a-3579ad637109', 'PowerCatch Update Script', 1,1,1); -- PC_METER_NUMBER-properties (Ny målers målernummer)
delete from konfigurasjon.fieldproperty  where id = 'cb9e039e-a1f9-49aa-afe6-aba86fe968d9';
--INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('9fb374c7-da6c-49f9-9147-c356625cb418', '', 1, 1, NULL, '7d8c04ab-dad6-43e2-affe-eb25478c5422', 'PowerCatch Update Script', 1,1,1); -- PC_OLD_METER_READING-properties
delete from konfigurasjon.fieldproperty  where id = '9fb374c7-da6c-49f9-9147-c356625cb418';
--INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('a7fdcba9-f57f-45ef-8903-ee2229d35b7f', '', 1, 1, NULL, 'd4437ec5-01d4-4f7a-a3e9-aef3f45cc631', 'PowerCatch Update Script'); -- PC_REGISTERED_VOLTAGE2-properties
delete from konfigurasjon.fieldproperty  where id = 'a7fdcba9-f57f-45ef-8903-ee2229d35b7f';

-- Brukes på vokks og embriq oppsett INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('d963c52b-3079-4ac5-a3ab-8ead9c472546', '', 0, 0, NULL, '683e847a-4f12-4b8b-ab5a-31130fd8a8a6', 'PowerCatch Update Script'); -- PC_BOOKING_ORDER-properties

-- Ordre info
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('0ae5c893-708c-4fc8-8e6b-ffea4abbd37c', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', '15aadd9c-611b-44da-9525-c01029a583ea', 1, 'PowerCatch Update Script'); -- summary-properties on page
delete from konfigurasjon.page_fieldproperty where id = '0ae5c893-708c-4fc8-8e6b-ffea4abbd37c';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b32b6376-891a-45b2-ac3d-dbc83a3eab91', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', '4a019e67-69be-4a0a-82f3-5ac65780db35', 2, 'PowerCatch Update Script'); -- description-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'b32b6376-891a-45b2-ac3d-dbc83a3eab91';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('00c54e8a-763a-49de-af51-9df72053793c', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', '2c44e699-173c-4091-9a5c-873e459618a3', 3, 'PowerCatch Update Script'); -- PC_PLANNED_DATE-properties on page
delete from konfigurasjon.page_fieldproperty where id = '00c54e8a-763a-49de-af51-9df72053793c';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('9c50928b-07f7-4e29-8d51-6cf722f8c605', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', 'd963c52b-3079-4ac5-a3ab-8ead9c472546', 4, 'PowerCatch Update Script'); -- PC_BOOKING_ORDER-properties on page
delete from konfigurasjon.page_fieldproperty where id = '9c50928b-07f7-4e29-8d51-6cf722f8c605';

-- field on page-- page customerdata
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('ae6f34fd-7ba2-4f54-aa99-f13d6589e924', '77562310-d45c-4400-b71f-7d5d334c10a7', 'b1de6368-e72b-4db6-8d7d-9a88b5dae3d0', 1, 'PowerCatch Update Script'); -- PC_CUSTOMER_NAME-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'ae6f34fd-7ba2-4f54-aa99-f13d6589e924';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('48eaa452-b238-4aed-97c6-fd129bc8e29b', '77562310-d45c-4400-b71f-7d5d334c10a7', '55254909-80a4-44a3-b5f5-4339413e6b27', 2, 'PowerCatch Update Script'); -- "PC_CUSTOMER_MOBILE"-properties on page
delete from konfigurasjon.page_fieldproperty where id = '48eaa452-b238-4aed-97c6-fd129bc8e29b';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('cbf06eff-bf03-4954-975d-cc07f7a9593d', '77562310-d45c-4400-b71f-7d5d334c10a7', 'abbcbe8c-d6f3-41da-bca4-810eee92b16f', 3, 'PowerCatch Update Script'); -- "PC_CUSTOMER_EMAIL"-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'cbf06eff-bf03-4954-975d-cc07f7a9593d';

-- field on page-- page anleggsdata
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d7e4cb80-d6b9-4221-94e1-96dbaccd3137', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', 'd6d21257-30f3-4e6c-9bf4-e2e503ab79f5', 1, 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'd7e4cb80-d6b9-4221-94e1-96dbaccd3137';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e7cd83d2-7877-44bf-8e13-982ed80356fc', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', '93bc6821-7f29-4f5b-b987-26830d6a18f8', 2, 'PowerCatch Update Script'); -- PC_INSTALLATION_STREET_NO-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'e7cd83d2-7877-44bf-8e13-982ed80356fc';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b425f53e-e1e8-449d-9784-d916b857fb52', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', '84e10dc1-9463-400d-8614-d947ca066e13', 3, 'PowerCatch Update Script'); -- PC_INSTALLATION_ZIPCODE-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'b425f53e-e1e8-449d-9784-d916b857fb52';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d82d1673-2ab4-4ae7-9e35-5012fdd776d1', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', '51d7ece3-cec1-4444-93c1-cd7d7ecfb5ef', 4, 'PowerCatch Update Script'); -- PC_INSTALLATION_CITY-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'd82d1673-2ab4-4ae7-9e35-5012fdd776d1';

-- FERDIG field on page-- page målerdata
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('f51f5db8-02e6-4710-b4a5-f9b148eab159', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', '97594e2d-e0ab-4338-ac33-a8bcacf2f26c', 1, 'PowerCatch Update Script'); -- PC_METER_ID-properties on page
delete from konfigurasjon.page_fieldproperty where id = 'f51f5db8-02e6-4710-b4a5-f9b148eab159';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('68b50e5c-2cf1-4165-9d2d-5c7faddf26f1', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', '9fb374c7-da6c-49f9-9147-c356625cb418', 2, 'PowerCatch Update Script'); -- PC_OLD_METER_READING-properties on page
delete from konfigurasjon.page_fieldproperty where id = '68b50e5c-2cf1-4165-9d2d-5c7faddf26f1';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('4d2d79b6-ba95-4c18-a72f-6a14500e5e7d', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', 'cac3b0be-b8a3-4713-ba46-d64381151ea7', 3, 'PowerCatch Update Script'); -- PC_NEW_METER_TYPE-properties on page
delete from konfigurasjon.page_fieldproperty where id = '4d2d79b6-ba95-4c18-a72f-6a14500e5e7d';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('55504c42-e1c6-4dbd-9128-93e9841cb691', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', 'cb9e039e-a1f9-49aa-afe6-aba86fe968d9', 4, 'PowerCatch Update Script'); -- PC_METER_NUMBER-properties on page
delete from konfigurasjon.page_fieldproperty where id = '55504c42-e1c6-4dbd-9128-93e9841cb691';
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('73942aa6-2768-41d1-be59-e181c77d0e2f', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', '60716744-b2ad-4327-9b71-1989e5815973', 5, 'PowerCatch Update Script'); -- PC_NEW_METER_READING-properties on page
delete from konfigurasjon.page_fieldproperty where id = '73942aa6-2768-41d1-be59-e181c77d0e2f';

-- Connect issuetype and pages
--INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('81d641bb-7609-4b3e-87e1-771889d6e65f', '4b252da2-5a38-4c15-940e-6fd7033d3d10', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', 1, 'PowerCatch Update Script'); --ordreinfo data data
delete from konfigurasjon.issuetype_page where id = '81d641bb-7609-4b3e-87e1-771889d6e65f';
--INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2f098b46-8fee-492c-9729-9c189c8e1918', '4b252da2-5a38-4c15-940e-6fd7033d3d10', '77562310-d45c-4400-b71f-7d5d334c10a7', 2, 'PowerCatch Update Script'); --customer data data
delete from konfigurasjon.issuetype_page where id = '2f098b46-8fee-492c-9729-9c189c8e1918';
--INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('50e32a27-0bb3-49c4-9665-175f1927d5ce', '4b252da2-5a38-4c15-940e-6fd7033d3d10', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', 3, 'PowerCatch Update Script'); --object data
delete from konfigurasjon.issuetype_page where id = '50e32a27-0bb3-49c4-9665-175f1927d5ce';
--INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0ef4fc07-c743-44da-a734-356819628185', '4b252da2-5a38-4c15-940e-6fd7033d3d10', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', 4, 'PowerCatch Update Script'); --meterdata data
delete from konfigurasjon.issuetype_page where id = '0ef4fc07-c743-44da-a734-356819628185';
--INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7ae85b73-e0d2-4977-a761-25cb48f41058', '4b252da2-5a38-4c15-940e-6fd7033d3d10', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 5, 'PowerCatch Update Script'); --Attachments page data
delete from konfigurasjon.issuetype_page where id = '7ae85b73-e0d2-4977-a761-25cb48f41058';
*/

-- Sakstyper-- prosjekter som skal støttes PPEN, PPTO, PPTRE, PPFIRE
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('e028f89b-ef46-4c25-9929-d504b6fbbadb','PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT', 'PPEN', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('53fd5fb9-c750-490c-aafa-619d2d68e923','PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER', 'PPEN', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('65f9942c-5a39-4668-93e7-3de4c87da209','PC_ISSUETYPE_ROLLOUT_METER_CHANGE', 'PPEN', 0, 'summary', 'PowerCatch Update Script');


INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('d963c52b-3079-4ac5-a3ab-8ead9c472546', '', 0, 0, NULL, '683e847a-4f12-4b8b-ab5a-31130fd8a8a6', 'PowerCatch Update Script'); -- PC_BOOKING_ORDER-properties


--PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT 
-- Tabber / pages

-- ####################################################################
-- ############## Ordreinfo
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 'pc.page.order.info', 0, 'PowerCatch Update Script', 110); -- Ordreinfo
/*
	-- finnes summary																				- "0c859911-5b69-4b72-b4bc-65ed0ec74c4f" -> fieldproperty - "15aadd9c-611b-44da-9525-c01029a583ea"
	-- finnes description																			- "192c7bc4-b454-4262-9e27-213c14305469" -> fieldproperty - "4a019e67-69be-4a0a-82f3-5ac65780db35"
	-- finnes PC_BOOKING_ORDER																		- "683e847a-4f12-4b8b-ab5a-31130fd8a8a6" -> fieldproperty - "d963c52b-3079-4ac5-a3ab-8ead9c472546"
	PC_NO_OF_FAILED_ATTEMPTS
	PC_EXPECTED_END_TEMP_ON_HOLD
	PC_CUSTOMER_SMS
	-- finnes PC_PLANNED_DATE																		- "596b4d00-2c5d-426c-bf3b-da14f6d2e362" -> fieldproperty - "2c44e699-173c-4091-9a5c-873e459618a3"
*/




INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('de6354da-634a-4289-90e9-41e47331e695', NULL, 'PC_NO_OF_FAILED_ATTEMPTS', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('0a72954a-556c-4eb7-93e7-88d03eed8760', NULL, 'PC_EXPECTED_END_TEMP_ON_HOLD', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('50bf42f0-8ee6-481a-b73d-22b0a68b4d57', NULL, 'PC_CUSTOMER_SMS', NULL, 'PowerCatch Update Script');
--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('5c7fd27f-ed2a-4566-af2a-6f54a491cf1e', '', 0, 0, NULL, 'de6354da-634a-4289-90e9-41e47331e695', 'PowerCatch Update Script', 0,0,0); -- PC_NO_OF_FAILED_ATTEMPTS
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('75643d35-c945-4014-8c83-34401f1f154f', '', 0, 0, NULL, '0a72954a-556c-4eb7-93e7-88d03eed8760', 'PowerCatch Update Script', 0,0,0); -- PC_EXPECTED_END_TEMP_ON_HOLD
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('49f6d503-62d0-4b6c-a1bf-38b869a62583', '', 0, 0, NULL, '50bf42f0-8ee6-481a-b73d-22b0a68b4d57', 'PowerCatch Update Script', 0,0,0); -- PC_CUSTOMER_SMS
--																											ID															Page				fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('dfcc701a-a4e9-4de8-b3fb-31134c2e31e9', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', '15aadd9c-611b-44da-9525-c01029a583ea', 1, 'PowerCatch Update Script'); --summary
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('6169eb6c-14ef-4165-9439-fc96f7709e03', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', '4a019e67-69be-4a0a-82f3-5ac65780db35', 2, 'PowerCatch Update Script'); --description
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('81512c00-403a-4e98-be16-d2da119ffcd8', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 'd963c52b-3079-4ac5-a3ab-8ead9c472546', 3, 'PowerCatch Update Script'); --PC_BOOKING_ORDER
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('ffedf23f-9037-4806-a7eb-11e4521f3a85', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', '5c7fd27f-ed2a-4566-af2a-6f54a491cf1e', 4, 'PowerCatch Update Script'); --PC_NO_OF_FAILED_ATTEMPTS
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('9a1c5f4d-c9bf-4e5c-8f80-69108a544a5b', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', '75643d35-c945-4014-8c83-34401f1f154f', 5, 'PowerCatch Update Script'); --PC_EXPECTED_END_TEMP_ON_HOLD
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('cf6d6ba6-fd75-41ab-b780-496ee9e0f563', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', '49f6d503-62d0-4b6c-a1bf-38b869a62583', 6, 'PowerCatch Update Script'); --PC_CUSTOMER_SMS
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('2ef4402a-6169-4487-9a9a-16bee1c85c44', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', '2c44e699-173c-4091-9a5c-873e459618a3', 7, 'PowerCatch Update Script'); --PC_PLANNED_DATE


-- ####################################################################
-- ############## Anleggsdata
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('4f041f44-b539-4eae-8af0-350d1f882dc3', 'pc.page.installation.data', 0, 'PowerCatch Update Script', 111); -- Anleggsdata
/*	-- finnes PC_CUSTOMER_NAME																		- "178ac866-4348-49bb-ada4-752c940ad12d"
	-- finnes PC_CUSTOMER_PHONE																		- "446bddae-dd60-49ea-b33a-1b911243c30b"
	-- finnes PC_CUSTOMER_MOBILE																	- "c39018e5-b1d1-4713-9171-fcd7c6ac763f"
	PC_CUSTOMER_ADDRESSCOMMENT
	PC_INSTALLATION_ADDRESS_STREETNAME
	PC_INSTALLATION_ADDRESS_BUILDING_NUMBER
	PC_INSTALLATION_ADDRESS_BUILDING_LETTER
	PC_INSTALLATION_ADDRESS_FLOOR_IDENTIFICATION
	PC_INSTALLATION_ADDRESS_ROOM_IDENTIFICATION
	PC_INSTALLATION_ADDRESS_ZIPCODE
	PC_INSTALLATION_ADDRESS_CITY_NAME
	-- finnes PC_LONGITUDE *E* (editerbar ved at knapp for hent posisjon alltid er tilgjengelig) 	- "fa847e28-f2e1-43d9-9f81-0215426635e6"
	-- finnes PC_LATITUDE *E* (editerbar ved at knapp for hent posisjon alltid er tilgjengelig)		- "3b5e008d-0a8e-4328-badd-05c9b933d25c"
*/
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('0797d78c-dfd7-4349-9417-f020e638463b', NULL, 'PC_CUSTOMER_ADDRESSCOMMENT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('111ca050-ef05-4384-af60-c2fe3ca647a0', NULL, 'PC_INSTALLATION_ADDRESS_STREETNAME', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('1f628e71-9e38-44ee-9d04-9b4760e52d84', NULL, 'PC_INSTALLATION_ADDRESS_BUILDING_NUMBER', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('c73ff2d5-51ed-48cc-b174-7bf86e04ad03', NULL, 'PC_INSTALLATION_ADDRESS_BUILDING_LETTER', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('d2b3bb2c-30e3-468f-bdfb-89f0feca6463', NULL, 'PC_INSTALLATION_ADDRESS_FLOOR_IDENTIFICATION', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('ede5491d-1546-4892-9f23-99a2de736afd', NULL, 'PC_INSTALLATION_ADDRESS_ROOM_IDENTIFICATION', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('cb658eaa-8e91-4df1-8333-b74f29c53bdf', NULL, 'PC_INSTALLATION_ADDRESS_ZIPCODE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('c06e1e3a-7c0c-4bdd-a390-152aba63a2c4', NULL, 'PC_INSTALLATION_ADDRESS_CITY_NAME', NULL, 'PowerCatch Update Script');

--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('de2bb369-9847-4309-ac34-e89e47895c22', '', 0, 0, NULL, '0797d78c-dfd7-4349-9417-f020e638463b', 'PowerCatch Update Script', 0,0,0); -- PC_CUSTOMER_ADDRESSCOMMENT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('a8f633de-1136-4873-9f5f-fda22871585b', '', 0, 0, NULL, '111ca050-ef05-4384-af60-c2fe3ca647a0', 'PowerCatch Update Script', 0,0,0); -- PC_INSTALLATION_ADDRESS_STREETNAME
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('cf0e65d9-1fbc-491a-bf5f-7caa9c10339c', '', 0, 0, NULL, '1f628e71-9e38-44ee-9d04-9b4760e52d84', 'PowerCatch Update Script', 0,0,0); -- PC_INSTALLATION_ADDRESS_BUILDING_NUMBER
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('c9e93a1c-974f-46f8-8d62-9a03c3cec609', '', 0, 0, NULL, 'c73ff2d5-51ed-48cc-b174-7bf86e04ad03', 'PowerCatch Update Script', 0,0,0); -- PC_INSTALLATION_ADDRESS_BUILDING_LETTER
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('b57499bb-3b60-49a0-b8db-9d66f2ad1c2f', '', 0, 0, NULL, 'd2b3bb2c-30e3-468f-bdfb-89f0feca6463', 'PowerCatch Update Script', 0,0,0); -- PC_INSTALLATION_ADDRESS_FLOOR_IDENTIFICATION
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('23861b45-c21c-489c-810f-4e7fbb757b86', '', 0, 0, NULL, 'ede5491d-1546-4892-9f23-99a2de736afd', 'PowerCatch Update Script', 0,0,0); -- PC_INSTALLATION_ADDRESS_ROOM_IDENTIFICATION
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('cf5dde98-82ac-4bbb-99c9-3739e62705bf', '', 0, 0, NULL, 'cb658eaa-8e91-4df1-8333-b74f29c53bdf', 'PowerCatch Update Script', 0,0,0); -- PC_INSTALLATION_ADDRESS_ZIPCODE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('f5730100-2e15-4f72-b155-491af56fd0e5', '', 0, 0, NULL, 'c06e1e3a-7c0c-4bdd-a390-152aba63a2c4', 'PowerCatch Update Script', 0,0,0); -- PC_INSTALLATION_ADDRESS_CITY_NAME

--																											ID																	Page					fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('22b33222-891d-4250-8cba-2939b5d47733', '4f041f44-b539-4eae-8af0-350d1f882dc3', '178ac866-4348-49bb-ada4-752c940ad12d', 1, 'PowerCatch Update Script'); --PC_CUSTOMER_NAME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e9a11a9c-990b-49de-abe3-473a5df145f6', '4f041f44-b539-4eae-8af0-350d1f882dc3', '446bddae-dd60-49ea-b33a-1b911243c30b', 2, 'PowerCatch Update Script'); --PC_CUSTOMER_PHONE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('367c77ae-86db-42d5-b5cf-ed6ee7741c5e', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'c39018e5-b1d1-4713-9171-fcd7c6ac763f', 3, 'PowerCatch Update Script'); --PC_CUSTOMER_MOBILE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('3f0b5f6a-12cd-4cca-9ef8-62c1e566f9d5', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'de2bb369-9847-4309-ac34-e89e47895c22', 4, 'PowerCatch Update Script'); --PC_CUSTOMER_ADDRESSCOMMENT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('ae3b3292-2751-4648-8012-30dc053c4323', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'a8f633de-1136-4873-9f5f-fda22871585b', 5, 'PowerCatch Update Script'); --PC_INSTALLATION_ADDRESS_STREETNAME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('c16a7b99-b96f-4240-ba93-0405161240e4', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'cf0e65d9-1fbc-491a-bf5f-7caa9c10339c', 6, 'PowerCatch Update Script'); --PC_INSTALLATION_ADDRESS_BUILDING_NUMBER
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('c8bac729-8389-482c-9e27-0bc6c9d14777', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'c9e93a1c-974f-46f8-8d62-9a03c3cec609', 7, 'PowerCatch Update Script'); --PC_INSTALLATION_ADDRESS_BUILDING_LETTER
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('f091c318-d1a4-4261-b5b8-6650ebb9b665', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'b57499bb-3b60-49a0-b8db-9d66f2ad1c2f', 8, 'PowerCatch Update Script'); --PC_INSTALLATION_ADDRESS_FLOOR_IDENTIFICATION
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e7b4e5d5-c423-49a5-b419-42277c4b8b0b', '4f041f44-b539-4eae-8af0-350d1f882dc3', '23861b45-c21c-489c-810f-4e7fbb757b86', 9, 'PowerCatch Update Script'); --PC_INSTALLATION_ADDRESS_ROOM_IDENTIFICATION
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('1b093c1d-058c-47b5-bded-58bfaae1b0ac', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'cf5dde98-82ac-4bbb-99c9-3739e62705bf', 10, 'PowerCatch Update Script'); --PC_INSTALLATION_ADDRESS_ZIPCODE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('2bda0066-8ab7-4dd9-ab33-73662d54919b', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'f5730100-2e15-4f72-b155-491af56fd0e5', 11, 'PowerCatch Update Script'); --PC_INSTALLATION_ADDRESS_CITY_NAME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('f5b3b3ca-7a6b-4045-989e-41cc562c9404', '4f041f44-b539-4eae-8af0-350d1f882dc3', 'fa847e28-f2e1-43d9-9f81-0215426635e6', 12, 'PowerCatch Update Script'); --PC_LONGITUDE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('ac2cd725-4f0f-498e-865c-092607b7a0f8', '4f041f44-b539-4eae-8af0-350d1f882dc3', '3b5e008d-0a8e-4328-badd-05c9b933d25c', 13, 'PowerCatch Update Script'); --PC_LATITUDE



	
-- ####################################################################
-- ############## SJA - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 'pc.page.sja', 0, 'PowerCatch Update Script', 112); -- SJA - Opprettet nytt i languagepack
/*	PC_SJA_CONFIRMATION
	PC_METERPOINT_EXCEPTIONS
*/

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('0f6d7aff-c97e-4e4c-9185-c3c8cfdd48ac', NULL, 'PC_SJA_CONFIRMATION', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('3a85dfdd-09bc-4f24-8ceb-17d0374db1e3', NULL, 'PC_METERPOINT_EXCEPTIONS', NULL, 'PowerCatch Update Script');
--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('cc19264a-71b3-4087-8ced-84fd4f8f863f', '', 1, 0, NULL, '0f6d7aff-c97e-4e4c-9185-c3c8cfdd48ac', 'PowerCatch Update Script', 0,0,0); -- PC_SJA_CONFIRMATION
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('897f1508-4513-43a3-a5b2-57637ed6cd70', '', 1, 0, NULL, '3a85dfdd-09bc-4f24-8ceb-17d0374db1e3', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_EXCEPTIONS

--																											ID													Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d73e9b48-a4bf-48f1-9bfa-033b66f00947', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 'cc19264a-71b3-4087-8ced-84fd4f8f863f', 1, 'PowerCatch Update Script'); --PC_SJA_CONFIRMATION
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('71ca0c4f-f669-44c2-b960-cfe96035f1c6', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', '897f1508-4513-43a3-a5b2-57637ed6cd70', 2, 'PowerCatch Update Script'); --PC_METERPOINT_EXCEPTIONS



-- ####################################################################
-- ############## Målepunkt - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('afea42b5-feb2-46f9-a94a-ae5e897eeffe', 'pc.page.meterpoint', 0, 'PowerCatch Update Script', 113); -- Målepunkt - Opprettet nytt i languagepack
/*	PC_METERPOINT_ID
	PC_SUBSTATION_ID
	PC_METERPOINT_PHASES *E*
	-- finnes PC_VOLTAGE_LEVEL *E* 															- "0f7a16b8-2a71-4325-9aa4-eaa50e2eeb61" -> fieldproperty - finnes kun i ikke redigerbar  versjon"9b1854a1-25c2-4716-a8ee-9ebbcd3c4b9f"
	PC_METERPOINT_FUSE_SIZE *E*
	PC_METERPOINT_METER_LOCATION_INFO
	PC_METERPOINT_INSTALLATION_TYPE
	PC_METERPOINT_TRANSFORMERREDUCTION *E*
	PC_METERPOINT_TRANSFORMER_CLASS *E*
	PC_METERPOINT_TRANSFORMER_ID *E*
*/

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('cfbb75cd-f84e-42c7-83f2-40862d3eafa0', NULL, 'PC_METERPOINT_ID', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('80422fcc-3489-4531-ac08-98123a467bd0', NULL, 'PC_SUBSTATION_ID', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('b9eae8a2-3d4e-4fec-b19f-07d1e4d4b05e', NULL, 'PC_METERPOINT_PHASES', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('4333342a-7b93-406e-8cf2-acfa6cb8dcf1', NULL, 'PC_METERPOINT_FUSE_SIZE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('2f37d340-75ba-48f7-9e95-fc7eec9f0212', NULL, 'PC_METERPOINT_METER_LOCATION_INFO', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('6d4f4a2a-ee20-40e5-b820-02eea1aff980', NULL, 'PC_METERPOINT_INSTALLATION_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('b0b560c4-2de1-42ca-aeb3-e64f05b413bd', NULL, 'PC_METERPOINT_TRANSFORMERREDUCTION', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('f359c7d3-8a24-47da-8ac1-7cc72e12b407', NULL, 'PC_METERPOINT_TRANSFORMER_CLASS', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('61b1269d-53f5-4dcc-af6a-8af5e3012cc5', NULL, 'PC_METERPOINT_TRANSFORMER_ID', NULL, 'PowerCatch Update Script');


--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('8d1660bb-34c2-4384-ad36-61fe985238b8', '', 0, 0, NULL, 'cfbb75cd-f84e-42c7-83f2-40862d3eafa0', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_ID
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('25246340-1f86-49c8-869e-0f024eee5535', '', 0, 0, NULL, '80422fcc-3489-4531-ac08-98123a467bd0', 'PowerCatch Update Script', 0,0,0); -- PC_SUBSTATION_ID
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('697e348f-0fe1-482e-8fb4-3a09d9903b8d', '', 1, 0, NULL, 'b9eae8a2-3d4e-4fec-b19f-07d1e4d4b05e', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_PHASES
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('b365edc6-dbcd-403b-b62e-e7b25e883ea1', '', 1, 0, NULL, '0f7a16b8-2a71-4325-9aa4-eaa50e2eeb61', 'PowerCatch Update Script', 0,0,0); -- PC_VOLTAGE_LEVEL
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('27c46100-8538-4423-9aa7-79c8d51743b2', '', 1, 0, NULL, '4333342a-7b93-406e-8cf2-acfa6cb8dcf1', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_FUSE_SIZE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('acf6693d-2877-49d4-883c-edc9545a5048', '', 0, 0, NULL, '2f37d340-75ba-48f7-9e95-fc7eec9f0212', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_METER_LOCATION_INFO
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('bb179e34-eca9-4951-8f55-ad7eb0570a41', '', 0, 0, NULL, '6d4f4a2a-ee20-40e5-b820-02eea1aff980', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_INSTALLATION_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('c84244dc-137c-484e-ac9b-36b227ae91b7', '', 1, 0, NULL, 'b0b560c4-2de1-42ca-aeb3-e64f05b413bd', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_TRANSFORMERREDUCTION
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('61772899-631c-4411-be3f-1538e8957326', '', 1, 0, NULL, 'f359c7d3-8a24-47da-8ac1-7cc72e12b407', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_TRANSFORMER_CLASS
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('5cc01641-fae9-4ad4-a3bf-632f541b1661', '', 1, 0, NULL, '61b1269d-53f5-4dcc-af6a-8af5e3012cc5', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_TRANSFORMER_ID

--																											ID														Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('8e4b030f-102f-493f-b7f8-8d3457666ea1', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', '8d1660bb-34c2-4384-ad36-61fe985238b8', 1, 'PowerCatch Update Script'); --PC_METERPOINT_ID
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('4c95833b-8775-48e8-b67f-e071940a96ca', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', '25246340-1f86-49c8-869e-0f024eee5535', 2, 'PowerCatch Update Script'); --PC_SUBSTATION_ID
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('7a24b31e-5907-47c9-8cf0-8a0dd537f9bd', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', '697e348f-0fe1-482e-8fb4-3a09d9903b8d', 3, 'PowerCatch Update Script'); --PC_METERPOINT_PHASES
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('76a57798-5449-47f2-85d4-6a710d0b8bfa', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 'b365edc6-dbcd-403b-b62e-e7b25e883ea1', 4, 'PowerCatch Update Script'); --PC_VOLTAGE_LEVEL
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('aa9845af-00d3-4131-af87-2b4bb20ae604', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', '27c46100-8538-4423-9aa7-79c8d51743b2', 5, 'PowerCatch Update Script'); --PC_METERPOINT_FUSE_SIZE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('eb67638b-3577-423e-b0ec-6552e19d4a1a', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 'acf6693d-2877-49d4-883c-edc9545a5048', 6, 'PowerCatch Update Script'); --PC_METERPOINT_METER_LOCATION_INFO
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('be35d9eb-a839-4367-b1a5-be0d4aa10ff5', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 'bb179e34-eca9-4951-8f55-ad7eb0570a41', 7, 'PowerCatch Update Script'); --PC_METERPOINT_INSTALLATION_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d92956a7-56fb-44b2-9635-fb72e00234b2', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 'c84244dc-137c-484e-ac9b-36b227ae91b7', 8, 'PowerCatch Update Script'); --PC_METERPOINT_TRANSFORMERREDUCTION
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d268e4e6-3840-4e28-88ee-92f9adac11a4', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', '61772899-631c-4411-be3f-1538e8957326', 9, 'PowerCatch Update Script'); --PC_METERPOINT_TRANSFORMER_CLASS
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('f43d0956-7692-4c84-be8c-96ed6e0ab944', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', '5cc01641-fae9-4ad4-a3bf-632f541b1661', 10, 'PowerCatch Update Script'); --PC_METERPOINT_TRANSFORMER_ID



-- ####################################################################
-- ############# Eksisterende måler - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'pc.page.existing.meter', 0, 'PowerCatch Update Script', 114); --Eksisterende måler - Opprettet nytt i languagepack
/*
	PC_EXISTING_METER_STATE_METER_SERIAL_NUMBER *E*
	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT *E*
	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE *E* scann/valider
	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT *E*
	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE *E* scann/valider
	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT *E*
	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE *E* scann/valider
	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT *E*
	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE *E* scann/valider
*/

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('a0bef07f-250a-433b-bfed-9104dde14386', NULL, 'PC_EXISTING_METER_STATE_METER_SERIAL_NUMBER', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('76bce31b-e8dc-4af5-ab1b-1cb3fbc0938e', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('c5e1da58-bbdc-4ba3-a464-9d84fb581146', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('60216aa1-b370-4e30-97df-c4d401d40837', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('9b674d51-3149-40da-8a83-219ae2cbc7e9', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('d340bf52-075d-4cbc-a4cb-2e8f35d7f716', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('21e0a822-082c-4612-a1a7-3d7f2d4af3ba', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('5144bb88-3d38-4125-a70d-a12f9f0066a5', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('324dfc8c-db25-4575-84cb-bad0c349d4c1', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('2aa0ae8f-2e48-4b62-a0ec-e3e03fbc2396', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('63ac32cf-6e72-4ff7-be36-d4ee39b3a7b7', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('f73613da-a85b-49ad-acde-f5706db90c97', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('9da2b5a6-7600-4119-863a-cb2bbf7f075c', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE', NULL, 'PowerCatch Update Script');


--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('d7516a80-1965-4d08-b899-50977c63c5e1', '', 1, 0, NULL, 'a0bef07f-250a-433b-bfed-9104dde14386', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_METER_SERIAL_NUMBER
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('4b9e25e6-3a7f-4581-8f78-52b6f1de783a', '', 0, 0, NULL, '76bce31b-e8dc-4af5-ab1b-1cb3fbc0938e', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('5e1788a0-89ce-47ca-8e19-7d90c256aaa9', '', 1, 0, NULL, 'c5e1da58-bbdc-4ba3-a464-9d84fb581146', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('efaf1e64-86f7-428a-a127-94e9e801df0a', '', 1, 1, NULL, '60216aa1-b370-4e30-97df-c4d401d40837', 'PowerCatch Update Script', 1,1,1); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('a9cf4904-628e-42ee-a807-a243f918bddc', '', 0, 0, NULL, '9b674d51-3149-40da-8a83-219ae2cbc7e9', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('b27d0c98-ce1f-4c9e-80af-0c9a89fd1eb3', '', 1, 0, NULL, 'd340bf52-075d-4cbc-a4cb-2e8f35d7f716', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('905b0962-9b00-4d3e-bd75-062d8d4dfc5a', '', 1, 0, NULL, '21e0a822-082c-4612-a1a7-3d7f2d4af3ba', 'PowerCatch Update Script', 1,1,1); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('88db7b88-0dfe-4b30-8921-92d983046c8a', '', 0, 0, NULL, '5144bb88-3d38-4125-a70d-a12f9f0066a5', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('05be989f-9e78-4455-bd8f-19efa9ae158a', '', 1, 0, NULL, '324dfc8c-db25-4575-84cb-bad0c349d4c1', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('a7e237aa-32f8-4830-9ce9-fedb7cce46fb', '', 1, 0, NULL, '2aa0ae8f-2e48-4b62-a0ec-e3e03fbc2396', 'PowerCatch Update Script', 1,1,1); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('5c00dbea-0d9c-4ca4-8df3-1b720774c0cf', '', 0, 0, NULL, '63ac32cf-6e72-4ff7-be36-d4ee39b3a7b7', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('ab2ff314-745a-40e5-959d-908844484e58', '', 1, 0, NULL, 'f73613da-a85b-49ad-acde-f5706db90c97', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('7e516fa9-6720-41ce-a0ef-5b5b4d374603', '', 1, 0, NULL, '9da2b5a6-7600-4119-863a-cb2bbf7f075c', 'PowerCatch Update Script', 1,1,1); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE


--																											ID														Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('0fafecd9-f0fd-4f91-843f-e6010f9104d2', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'd7516a80-1965-4d08-b899-50977c63c5e1', 1, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_METER_SERIAL_NUMBER
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d01974db-2f23-4066-a246-6030d014c839', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '4b9e25e6-3a7f-4581-8f78-52b6f1de783a', 2, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('c7462cef-eca4-41cd-88ed-4d2ec4027077', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '5e1788a0-89ce-47ca-8e19-7d90c256aaa9', 3, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b6a128fd-e2bd-4b2e-babd-f036df440f13', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'efaf1e64-86f7-428a-a127-94e9e801df0a', 4, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('1d04f99d-50df-4681-8b71-7e982fe495b5', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'a9cf4904-628e-42ee-a807-a243f918bddc', 5, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('37c789b3-f51c-472f-8743-b1d576401b10', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'b27d0c98-ce1f-4c9e-80af-0c9a89fd1eb3', 6, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('5b044cb6-9b3e-4a82-bcfd-7f29fff7d1c0', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '905b0962-9b00-4d3e-bd75-062d8d4dfc5a', 7, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('27727741-4d77-4fd2-aeb0-aa864eca2971', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '88db7b88-0dfe-4b30-8921-92d983046c8a', 8, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('50acb064-0438-452b-8c32-040eac94c4a0', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '05be989f-9e78-4455-bd8f-19efa9ae158a', 9, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('730d2971-1969-454c-a77d-2470a5de9bae', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'a7e237aa-32f8-4830-9ce9-fedb7cce46fb', 10, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('95b4d602-6d27-4c5d-b131-937e6b544cfe', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '5c00dbea-0d9c-4ca4-8df3-1b720774c0cf', 11, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('28146cc2-2013-4137-9e83-3713c0d3befd', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'ab2ff314-745a-40e5-959d-908844484e58', 12, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('2626d5b7-b3a6-474f-9402-2c45f3144c31', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '7e516fa9-6720-41ce-a0ef-5b5b4d374603', 13, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE


-- ####################################################################
-- #############  Montasje ny måler - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('07967eac-bbb3-48a7-963a-4131beeeffed', 'pc.page.mounting.new.meter', 0, 'PowerCatch Update Script', 115); -- Montasje ny måler - Opprettet nytt i languagepack
/*	PC_DIRECT_CONNECTION *E*
	PC_RADIO_IS_ENABLED
	PC_RADIO_ESD_PRODUCT_TYPE
	PC_RADIO_MCD_PRODUCT_TYPE
	PC_RADIO_RF_ANTENNA_PRODUCT
	PC_RADIO_GSM_ANTENNA_PRODUCT
*/
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('68b831cf-fbf0-48db-a56f-c14b26ccdd8b', NULL, 'PC_DIRECT_CONNECTION', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('47c91479-7630-472d-9a64-6a919212b386', NULL, 'PC_RADIO_IS_ENABLED', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('b5ce43f2-8fba-4bbb-9765-9b5e90c8dd2b', NULL, 'PC_RADIO_ESD_PRODUCT_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('0b4ae0ba-4abe-4d93-89e6-342c64056b6c', NULL, 'PC_RADIO_MCD_PRODUCT_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('134cc2e1-509d-4350-b910-c125babab2cc', NULL, 'PC_RADIO_RF_ANTENNA_PRODUCT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('42c25f61-f934-4936-a8e3-1ceb810ee86e', NULL, 'PC_RADIO_GSM_ANTENNA_PRODUCT', NULL, 'PowerCatch Update Script');

--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('025f33da-3d1a-44b2-a0e4-4b75455f5a88', '', 1, 0, NULL, '68b831cf-fbf0-48db-a56f-c14b26ccdd8b', 'PowerCatch Update Script', 0,0,0); -- PC_DIRECT_CONNECTION
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('5036b6cd-7f43-4d9c-9c3d-29e199ab4f66', '', 0, 0, NULL, '47c91479-7630-472d-9a64-6a919212b386', 'PowerCatch Update Script', 0,0,0); -- PC_RADIO_IS_ENABLED
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('2951cacd-2039-4936-9763-7d8870687084', '', 0, 0, NULL, 'b5ce43f2-8fba-4bbb-9765-9b5e90c8dd2b', 'PowerCatch Update Script', 0,0,0); -- PC_RADIO_ESD_PRODUCT_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('a1ea1d33-0512-4c15-a4e7-9604b8e7928f', '', 0, 0, NULL, '0b4ae0ba-4abe-4d93-89e6-342c64056b6c', 'PowerCatch Update Script', 0,0,0); -- PC_RADIO_MCD_PRODUCT_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('b1727a30-f9bf-4004-9eda-18cc47532914', '', 0, 0, NULL, '134cc2e1-509d-4350-b910-c125babab2cc', 'PowerCatch Update Script', 0,0,0); -- PC_RADIO_RF_ANTENNA_PRODUCT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('0b8e555b-7dbc-41d6-a3f1-8d72b26aa9d0', '', 0, 0, NULL, '42c25f61-f934-4936-a8e3-1ceb810ee86e', 'PowerCatch Update Script', 0,0,0); -- PC_RADIO_GSM_ANTENNA_PRODUCT

--																											ID													Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('02ed9177-1217-4993-9630-4a618d33b5d7', '07967eac-bbb3-48a7-963a-4131beeeffed', '025f33da-3d1a-44b2-a0e4-4b75455f5a88', 1, 'PowerCatch Update Script'); --PC_DIRECT_CONNECTION
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('8ef3b636-2ca5-4d0d-901c-093582cd49f7', '07967eac-bbb3-48a7-963a-4131beeeffed', '5036b6cd-7f43-4d9c-9c3d-29e199ab4f66', 2, 'PowerCatch Update Script'); --PC_RADIO_IS_ENABLED
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('2bfcf507-c167-460e-b1d2-0e15e39bf034', '07967eac-bbb3-48a7-963a-4131beeeffed', '2951cacd-2039-4936-9763-7d8870687084', 3, 'PowerCatch Update Script'); --PC_RADIO_ESD_PRODUCT_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('11ab759a-a6ea-427b-8569-f97ff2797063', '07967eac-bbb3-48a7-963a-4131beeeffed', 'a1ea1d33-0512-4c15-a4e7-9604b8e7928f', 4, 'PowerCatch Update Script'); --PC_RADIO_MCD_PRODUCT_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('c500d079-4019-45c1-b0fc-deb5e7fc35fc', '07967eac-bbb3-48a7-963a-4131beeeffed', 'b1727a30-f9bf-4004-9eda-18cc47532914', 5, 'PowerCatch Update Script'); --PC_RADIO_RF_ANTENNA_PRODUCT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('a454ad26-fe5f-4b80-bb49-68f8d0542325', '07967eac-bbb3-48a7-963a-4131beeeffed', '0b8e555b-7dbc-41d6-a3f1-8d72b26aa9d0', 6, 'PowerCatch Update Script'); --PC_RADIO_GSM_ANTENNA_PRODUCT



-- ####################################################################
-- ############# Målerdata ny måler  - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('b93d7d31-767a-4500-b7a9-cec49d018739', 'pc.page.meterdata.new.meter', 0, 'PowerCatch Update Script', 116); -- Målerdata ny måler - Opprettet nytt i languagepack
/*	PC_NEW_METER_STATE_METER_SERIAL_NUMBER *E* scann/valider -Obligatorisk
	PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE *E*
	PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE *E*
	PC_NEW_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE *E*
	PC_NEW_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE *E*
	PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE *E*
	PC_NEW_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE *E*
	PC_NEW_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE *E*
	PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE *E*
*/
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('5dd4e65b-3525-40e6-9c15-f1a8f342dbe0', NULL, 'PC_NEW_METER_STATE_METER_SERIAL_NUMBER', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('6bb92a3c-8e12-4cd7-9162-3833f22be408', NULL, 'PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('5d8b7891-4b66-41fd-b2c1-dd3ee0053032', NULL, 'PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('95ba5125-153e-4596-89e1-4784eabf48c7', NULL, 'PC_NEW_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('39c313ea-ef5e-4742-ab8c-1f9ccd8a9c68', NULL, 'PC_NEW_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('196112f7-0af0-4a76-8830-79802e7d55bd', NULL, 'PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('5b6575be-2094-4d3e-8cc3-7f95c547a684', NULL, 'PC_NEW_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7f618892-5834-40f8-8114-69ab6b085729', NULL, 'PC_NEW_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7c9b77fd-0859-4cec-9f25-3e707dc909ff', NULL, 'PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE', NULL, 'PowerCatch Update Script');

--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('6fe6314a-3564-43fd-a46e-6550f1cc82ef', '', 1, 1, NULL, '5dd4e65b-3525-40e6-9c15-f1a8f342dbe0', 'PowerCatch Update Script', 1,1,1); -- PC_NEW_METER_STATE_METER_SERIAL_NUMBER
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('743ec458-879f-45fb-9e1e-250c3c564ea1', '', 1, 0, NULL, '6bb92a3c-8e12-4cd7-9162-3833f22be408', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('bb7966a9-361f-4f9e-9ae8-713ceef26fba', '', 1, 0, NULL, '5d8b7891-4b66-41fd-b2c1-dd3ee0053032', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('81ca1545-c5f1-447a-b2fa-d4d74eeaead3', '', 1, 0, NULL, '95ba5125-153e-4596-89e1-4784eabf48c7', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('c8db967b-c3f8-4ecf-baab-dfbe21135576', '', 1, 0, NULL, '39c313ea-ef5e-4742-ab8c-1f9ccd8a9c68', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('cd656a9b-9c5d-43ab-9413-3013066352b9', '', 1, 0, NULL, '196112f7-0af0-4a76-8830-79802e7d55bd', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('6996069d-b176-4714-8f33-63d34a1763e5', '', 1, 0, NULL, '5b6575be-2094-4d3e-8cc3-7f95c547a684', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('3d4bbeb9-aee4-4a81-80af-463b190a32a9', '', 1, 0, NULL, '7f618892-5834-40f8-8114-69ab6b085729', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('5b022a24-79c0-42e0-9f60-15522c2073e9', '', 1, 0, NULL, '7c9b77fd-0859-4cec-9f25-3e707dc909ff', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE

--																											ID														Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('ab6e8cc3-b3c5-4873-941b-be3e9f1997a9', 'b93d7d31-767a-4500-b7a9-cec49d018739', '6fe6314a-3564-43fd-a46e-6550f1cc82ef', 1, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_METER_SERIAL_NUMBER
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('69a6e585-7817-4e20-886f-5c36fca179cb', 'b93d7d31-767a-4500-b7a9-cec49d018739', '743ec458-879f-45fb-9e1e-250c3c564ea1', 2, 'PowerCatch Update Script'); --PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('7d0cb7bf-0855-4b84-b8ca-e75866e41ede', 'b93d7d31-767a-4500-b7a9-cec49d018739', 'bb7966a9-361f-4f9e-9ae8-713ceef26fba', 3, 'PowerCatch Update Script'); --PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e76865ef-1fd1-47ab-81a5-deebc57d3ebe', 'b93d7d31-767a-4500-b7a9-cec49d018739', '81ca1545-c5f1-447a-b2fa-d4d74eeaead3', 4, 'PowerCatch Update Script'); --PC_NEW_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('236f8f9b-5ee1-48bd-8226-446d46046181', 'b93d7d31-767a-4500-b7a9-cec49d018739', 'c8db967b-c3f8-4ecf-baab-dfbe21135576', 5, 'PowerCatch Update Script'); --PC_NEW_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('7ab9adf8-6719-4ac8-9e37-2bd4fe3cb053', 'b93d7d31-767a-4500-b7a9-cec49d018739', 'cd656a9b-9c5d-43ab-9413-3013066352b9', 6, 'PowerCatch Update Script'); --PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e19151e9-8c4e-4f7e-939a-0d87d9afa4f3', 'b93d7d31-767a-4500-b7a9-cec49d018739', '6996069d-b176-4714-8f33-63d34a1763e5', 7, 'PowerCatch Update Script'); --PC_NEW_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('aab0a492-fe68-4ad9-a728-94914de09c5f', 'b93d7d31-767a-4500-b7a9-cec49d018739', '3d4bbeb9-aee4-4a81-80af-463b190a32a9', 8, 'PowerCatch Update Script'); --PC_NEW_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('3f4d10c3-539c-4197-81f7-bb64bc0452cb', 'b93d7d31-767a-4500-b7a9-cec49d018739', '5b022a24-79c0-42e0-9f60-15522c2073e9', 9, 'PowerCatch Update Script'); --PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE


-- ####################################################################
-- ############# Registrering ny måler - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'pc.page.register.new.meter', 0, 'PowerCatch Update Script', 117); -- Registrering ny måler - Opprettet nytt i languagepack
/*	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT *E*
	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE *E* scann/valider
	PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
	PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT *E*
	PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE *E* scann/valider
	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT *E*
	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE *E* scann/valider
	PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
	PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT *E*
	PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE *E* scann/valider
*/

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('e98d0f56-7498-44d9-bb39-36404706554a', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('70db3007-51b0-41cb-856e-7cbe36e2765a', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7dd287cf-953c-45d4-aa9d-935dfb499808', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('8225962a-5ec4-4cb3-92b0-4bdfe3ae5f8d', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('a5be8ce0-ac0d-4f59-8485-db868a4c7a93', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('369d4ad5-e1c1-4079-8b00-597ecdfee3b2', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('b0c77735-ae90-4986-aea0-47c769b88470', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7062cbdd-f289-4dfc-a93d-65370a65b198', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('60b6bce0-26b1-44ec-b28f-675a19cd73cf', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('fc0b059e-8371-4a88-8d8e-c13540f6451a', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('d11be228-e767-4ae4-bfdb-3f2a92dc0819', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('5b1add31-5ae5-418f-98a5-1acdf4397c75', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE', NULL, 'PowerCatch Update Script');

--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('04e0b3db-4679-42c3-878e-83adde7685ac', '', 0, 0, NULL, 'e98d0f56-7498-44d9-bb39-36404706554a', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('a5183a73-d791-4909-9de8-188819cb37fe', '', 1, 0, NULL, '70db3007-51b0-41cb-856e-7cbe36e2765a', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('17bf0852-a794-4b39-9b12-07e5332d3a9b', '', 1, 0, NULL, '7dd287cf-953c-45d4-aa9d-935dfb499808', 'PowerCatch Update Script', 1,1,1); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('857f9f13-edc2-4162-a9a7-a74c0992e5ff', '', 0, 0, NULL, '8225962a-5ec4-4cb3-92b0-4bdfe3ae5f8d', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('b97ad7bf-8b3f-4386-a9f7-019ea28a4f10', '', 1, 0, NULL, 'a5be8ce0-ac0d-4f59-8485-db868a4c7a93', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('ca8330e3-cc98-4bc6-bf54-6f637e2320b5', '', 1, 0, NULL, '369d4ad5-e1c1-4079-8b00-597ecdfee3b2', 'PowerCatch Update Script', 1,1,1); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('a185e8d9-4e2d-480c-887e-dcfec72e03fa', '', 0, 0, NULL, 'b0c77735-ae90-4986-aea0-47c769b88470', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('088b7421-cc6f-4572-a4e0-3013fb57dca1', '', 1, 0, NULL, '7062cbdd-f289-4dfc-a93d-65370a65b198', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('fd91ea18-9126-4079-a170-4cb380c88d49', '', 1, 0, NULL, '60b6bce0-26b1-44ec-b28f-675a19cd73cf', 'PowerCatch Update Script', 1,1,1); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('ad020d5d-e578-4624-aab4-b5f167335194', '', 0, 0, NULL, 'fc0b059e-8371-4a88-8d8e-c13540f6451a', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('479cd743-35ca-4a2c-92ae-ea3fbcc1e726', '', 1, 0, NULL, 'd11be228-e767-4ae4-bfdb-3f2a92dc0819', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('8dba3475-42de-4979-9643-2b577b35e51c', '', 1, 0, NULL, '5b1add31-5ae5-418f-98a5-1acdf4397c75', 'PowerCatch Update Script', 1,1,1); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE

--																											ID														Page						fieldproperty
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('07d3ff01-d798-4f49-8a15-bb4fcfadccc9', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '04e0b3db-4679-42c3-878e-83adde7685ac', 1, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('5da68ed8-fdaa-48c9-a486-2d11885a2c61', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'a5183a73-d791-4909-9de8-188819cb37fe', 2, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('85e922f1-31d3-4822-8a60-d9a34309e411', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '17bf0852-a794-4b39-9b12-07e5332d3a9b', 3, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('37737534-51d8-4212-9269-b940d27e50ee', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '857f9f13-edc2-4162-a9a7-a74c0992e5ff', 4, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('3bec7e51-9896-4c52-b81c-bbb370344b0e', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'b97ad7bf-8b3f-4386-a9f7-019ea28a4f10', 5, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('5f38ce7a-6318-452d-aee4-f8649bef8813', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'ca8330e3-cc98-4bc6-bf54-6f637e2320b5', 6, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE
-- INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('605ea5a6-2a4d-4c18-9479-ee3045be9782', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'a185e8d9-4e2d-480c-887e-dcfec72e03fa', 7, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('5d08f624-f4ed-4065-93b8-b53e31d185b0', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '088b7421-cc6f-4572-a4e0-3013fb57dca1', 8, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('0d67fd82-468d-4372-93fa-a14553490834', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'fd91ea18-9126-4079-a170-4cb380c88d49', 9, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE
--INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('4953c7b5-4072-4bcf-a502-74d3c72ccdb0', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'ad020d5d-e578-4624-aab4-b5f167335194', 10, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e3eea61d-dc7f-481e-bea2-71560c80e59d', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '479cd743-35ca-4a2c-92ae-ea3fbcc1e726', 11, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('f368005e-818b-49e8-8cf9-ecd4117acaac', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '8dba3475-42de-4979-9643-2b577b35e51c', 12, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE


-- ####################################################################
-- ############# Ekstra - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('08631c23-a2f7-4d75-9f18-d00937da4683', 'pc.page.ekstra', 0, 'PowerCatch Update Script', 118); -- Ekstra - Opprettet nytt i languagepack
/*	PC_CHANGED_SLEEVE
	PC_CHANGED_CABLE_LOOP
	PC_EXTRA_ASSEMBLY_WORK
*/

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('71b313c3-faf4-4e4a-8e3f-3550e1e39c98', NULL, 'PC_CHANGED_SLEEVE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('f5c0ab5e-fd01-434e-89aa-03ad11089c0d', NULL, 'PC_CHANGED_CABLE_LOOP', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('2e552852-1a2a-417f-95ac-ff8d8e630146', NULL, 'PC_EXTRA_ASSEMBLY_WORK', NULL, 'PowerCatch Update Script');

--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('ad9eec7c-1de4-48fd-a026-632fd845d1f1', '', 1, 0, NULL, '71b313c3-faf4-4e4a-8e3f-3550e1e39c98', 'PowerCatch Update Script', 0,0,0); -- PC_CHANGED_SLEEVE
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('ec910eef-bcbd-4486-84e1-12ad5fb74af1', '', 1, 0, NULL, 'f5c0ab5e-fd01-434e-89aa-03ad11089c0d', 'PowerCatch Update Script', 0,0,0); -- PC_CHANGED_CABLE_LOOP
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('4579022f-aca5-463e-866b-13d6d724c943', '', 1, 0, NULL, '2e552852-1a2a-417f-95ac-ff8d8e630146', 'PowerCatch Update Script', 0,0,0); -- PC_EXTRA_ASSEMBLY_WORK

--																											ID														Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('dc139349-32e2-4619-a6b6-6092ef6bd4e3', '08631c23-a2f7-4d75-9f18-d00937da4683', 'ad9eec7c-1de4-48fd-a026-632fd845d1f1', 1, 'PowerCatch Update Script'); --PC_CHANGED_SLEEVE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('650c182f-bb0a-4825-82c5-f045edc75d46', '08631c23-a2f7-4d75-9f18-d00937da4683', 'ec910eef-bcbd-4486-84e1-12ad5fb74af1', 2, 'PowerCatch Update Script'); --PC_CHANGED_CABLE_LOOP
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('2166733b-1142-4f83-adb7-1c2d029f53e5', '08631c23-a2f7-4d75-9f18-d00937da4683', '4579022f-aca5-463e-866b-13d6d724c943', 3, 'PowerCatch Update Script'); --PC_EXTRA_ASSEMBLY_WORK



-- ####################################################################
-- ############# Sluttkontroll - Opprettet nytt i languagepack
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('10b1aa61-e654-4afe-b57e-d751f19b2f5c', 'pc.page.final.check', 0, 'PowerCatch Update Script', 119); -- Sluttkontroll
/*	PC_METERPOINT_FINAL_CHECK */

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('90805cec-c01e-4fd7-a1fe-add2b94a1ffc', NULL, 'PC_METERPOINT_FINAL_CHECK', NULL, 'PowerCatch Update Script');
--																																									  ID															field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('16c295fe-940d-46fe-b305-635381f0e3e4', '', 1, 0, NULL, '90805cec-c01e-4fd7-a1fe-add2b94a1ffc', 'PowerCatch Update Script', 0,0,0); -- PC_METERPOINT_FINAL_CHECK

--																											ID														Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('dca0c0b1-8556-4619-8011-1d4a4a1212f6', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', '16c295fe-940d-46fe-b305-635381f0e3e4', 1, 'PowerCatch Update Script'); --PC_METERPOINT_FINAL_CHECK



-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT PPEN)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('330bb2ae-9928-47dc-a397-ca30e5341849', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('5e7217e5-ec63-442b-91e3-a43e7c49c8f3', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfig urasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('53940cf6-ccd3-472b-a254-7adc2948000f', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('6081f3f5-ed7b-4217-8e3a-4ea90529e455', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('5dfad9f3-2d25-4c2f-8cc9-7af1f5c17939', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2336bdbf-8dcb-435a-9adf-fce26711daca', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('42780c63-f78d-416f-aca9-60f6b9ac50ce', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('d9c023ab-5484-4806-b3f4-88a9cce61da8', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('3d33707f-ae13-4e29-80d5-dfcef114b421', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('e88e6ac7-252b-4133-8f88-d3d6eaf75cd0', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('d081ac06-d2c9-4bd0-b9c3-5d1e9b253435', 'e028f89b-ef46-4c25-9929-d504b6fbbadb', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data


-- ####################################################################
-- ############## Målepunkt page for - PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER and PC_ISSUETYPE_ROLLOUT_METER_CHANGE
-- ####################################################################
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('57ac4954-9d67-4546-95f8-e9925465594f', 'pc.page.meterpoint', 0, 'PowerCatch Update Script', 120); -- Målepunkt - Opprettet nytt i languagepack
/*	PC_METERPOINT_ID
	PC_SUBSTATION_ID
	PC_METERPOINT_PHASES *E*
	-- finnes PC_VOLTAGE_LEVEL *E* 															- "0f7a16b8-2a71-4325-9aa4-eaa50e2eeb61" -> fieldproperty - finnes kun i ikke redigerbar  versjon"9b1854a1-25c2-4716-a8ee-9ebbcd3c4b9f"
	PC_METERPOINT_FUSE_SIZE *E*
	PC_METERPOINT_METER_LOCATION_INFO
	PC_METERPOINT_INSTALLATION_TYPE
		
	
*/

--																											ID														Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('2b00cbbf-1d0d-47d6-a9ef-2f74b808e05d', '57ac4954-9d67-4546-95f8-e9925465594f', '8d1660bb-34c2-4384-ad36-61fe985238b8', 1, 'PowerCatch Update Script'); --PC_METERPOINT_ID
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('3ef5390b-85d1-4900-9e6c-e9550ebcc1a3', '57ac4954-9d67-4546-95f8-e9925465594f', '25246340-1f86-49c8-869e-0f024eee5535', 2, 'PowerCatch Update Script'); --PC_SUBSTATION_ID
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('fc1d1c26-c602-4e1d-b323-59cebc3ae2f9', '57ac4954-9d67-4546-95f8-e9925465594f', '697e348f-0fe1-482e-8fb4-3a09d9903b8d', 3, 'PowerCatch Update Script'); --PC_METERPOINT_PHASES
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('aa102e7e-fbd7-472f-8970-4120d563f1bd', '57ac4954-9d67-4546-95f8-e9925465594f', 'b365edc6-dbcd-403b-b62e-e7b25e883ea1', 4, 'PowerCatch Update Script'); --PC_VOLTAGE_LEVEL
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('8d273797-c228-491f-936a-f40e195f5283', '57ac4954-9d67-4546-95f8-e9925465594f', '27c46100-8538-4423-9aa7-79c8d51743b2', 5, 'PowerCatch Update Script'); --PC_METERPOINT_FUSE_SIZE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('507e337e-3d4e-40b0-b768-6e71f4fe7f14', '57ac4954-9d67-4546-95f8-e9925465594f', 'acf6693d-2877-49d4-883c-edc9545a5048', 6, 'PowerCatch Update Script'); --PC_METERPOINT_METER_LOCATION_INFO
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('43f4a597-6e21-46f1-8e91-57eeb7b0f593', '57ac4954-9d67-4546-95f8-e9925465594f', 'bb179e34-eca9-4951-8f55-ad7eb0570a41', 7, 'PowerCatch Update Script'); --PC_METERPOINT_INSTALLATION_TYPE



-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER PPEN)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('800b0325-f356-48ab-84ee-d161c1ac7d8b', '53fd5fb9-c750-490c-aafa-619d2d68e923', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('a2065589-7b3c-4f21-8fab-6c112c73c2cd', '53fd5fb9-c750-490c-aafa-619d2d68e923', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('815f6c03-2e21-480a-839a-f6aa8d834924', '53fd5fb9-c750-490c-aafa-619d2d68e923', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('4a5ffccf-e12d-4154-95f2-b8a84e25ebec', '53fd5fb9-c750-490c-aafa-619d2d68e923', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('113d9225-35b2-4316-9620-bfa9245de563', '53fd5fb9-c750-490c-aafa-619d2d68e923', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bb383672-55cd-4437-97d7-df0d1db2f7aa', '53fd5fb9-c750-490c-aafa-619d2d68e923', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('49fa0e87-1965-49f6-8a96-28deddb4a74e', '53fd5fb9-c750-490c-aafa-619d2d68e923', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('30643987-ce08-43d6-a639-6cef7bc7b0c4', '53fd5fb9-c750-490c-aafa-619d2d68e923', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0aa217b7-736a-4beb-9610-fca3c40b4417', '53fd5fb9-c750-490c-aafa-619d2d68e923', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('abd28b4f-3727-4b1e-aff9-b8a278781de3', '53fd5fb9-c750-490c-aafa-619d2d68e923', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0fd32fa4-e8c8-4518-820d-796201571b9f', '53fd5fb9-c750-490c-aafa-619d2d68e923', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data



-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE PPEN)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('ffc40ccf-fc14-4f3a-881e-060d50c768ea', '65f9942c-5a39-4668-93e7-3de4c87da209', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bfbcd628-5e16-4e8d-9b96-413249dc98fb', '65f9942c-5a39-4668-93e7-3de4c87da209', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('721d6ee0-c787-4a93-a502-70ebf930b4d7', '65f9942c-5a39-4668-93e7-3de4c87da209', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('8a9b530f-97b2-41b8-832f-d8dd39d7b093', '65f9942c-5a39-4668-93e7-3de4c87da209', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bebc5a9d-3a6e-4c5b-ae37-c63685b85a26', '65f9942c-5a39-4668-93e7-3de4c87da209', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('fc7c21e1-dc7e-4892-b3fc-4ff0522ae428', '65f9942c-5a39-4668-93e7-3de4c87da209', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('aa649348-78b8-4c93-8db6-bd388831f1d1', '65f9942c-5a39-4668-93e7-3de4c87da209', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2891a701-5047-4768-b88f-5a039dc75516', '65f9942c-5a39-4668-93e7-3de4c87da209', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2f78f19a-1bcc-41d7-abf6-810dc5a61a16', '65f9942c-5a39-4668-93e7-3de4c87da209', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0677f535-591d-4baa-a52e-43413c977fd3', '65f9942c-5a39-4668-93e7-3de4c87da209', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7f44a3c8-378d-4a6f-b9fc-bfd89174ea2b', '65f9942c-5a39-4668-93e7-3de4c87da209', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data

/*
-- ######### OBS -> DISSE kan skippes nå når vi støtter flere prosjekter på en sakstype
-- New issuetypes
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('91e1e21f-42f8-4a5f-b471-737eb0e3cff8','PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT', 'PPTO', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('53f3d793-a70d-4645-9bcd-fa5a5b4cf96d','PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT', 'PPTRE', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('6998d375-20ba-4b17-b90b-751d97fbfd62','PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT', 'PPFIRE', 0, 'summary', 'PowerCatch Update Script');


-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT PPTO)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7917060a-d07d-4802-bbe6-85b3daeee137', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('58ca4715-9487-4257-b915-2ed5081bc538', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('e21cb5ab-0d24-48be-90ba-d58e7c1329b8', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('254942c0-f7a7-4ae4-a90d-fb20523eca26', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('479c9cc8-875b-4c6a-b4a8-3283f280d148', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('00187b5d-204e-4ee6-a98f-4c7878e00ac6', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7de64575-3fba-472d-8120-53649e4fc2d2', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('d1bc28b8-9f31-4a58-909a-3c21adc82d7d', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('ae0d1966-e0e8-4a0a-889f-6c3b43fecca9', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('60f3978b-4665-47ef-b919-b1e63c81d8d1', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7ce127ea-46d5-4257-bab8-8f05f98e8755', '91e1e21f-42f8-4a5f-b471-737eb0e3cff8', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data




-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT PPTRE)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('da292718-36dc-4170-8e9f-e263765ca748', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('996dc6e0-8741-4903-8c47-ce98c59938df', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('1b0f17c6-08e7-498b-b42a-875c521fcac0', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('c71e6720-9e9c-4a46-8048-9226d7ba0333', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('61de8d2f-bada-4d7e-bc78-1e6c60e2c5af', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('be9209eb-ff02-4638-84d2-28631c783ff8', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('6a813f73-83d0-4994-99ac-67a4b9a8d24c', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bc19fa1b-b8c2-4738-9dd0-274213447533', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('b0cbeb1a-4851-42db-8aa3-5057bf19cd7f', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('28d5aff2-8fe8-4595-b62f-88fe45a78af5', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('3cfe42a7-8178-4ba3-871b-c6f6788c8e9e', '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data


-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT PPFIRE)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bca94bf9-80a1-46b5-95bb-725b39fdd6a2', '6998d375-20ba-4b17-b90b-751d97fbfd62', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('5adf32cc-8223-4e25-baa9-e659110adb44', '6998d375-20ba-4b17-b90b-751d97fbfd62', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('c3cfb554-be6d-45ab-af1b-f6e14d81bfcb', '6998d375-20ba-4b17-b90b-751d97fbfd62', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('f4222e03-307f-48ee-a692-93198fdbb882', '6998d375-20ba-4b17-b90b-751d97fbfd62', 'afea42b5-feb2-46f9-a94a-ae5e897eeffe', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('c0410645-f8cb-4933-939f-cd34823c79c5', '6998d375-20ba-4b17-b90b-751d97fbfd62', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('dca63910-6d61-4554-b8dc-546ef20a9926', '6998d375-20ba-4b17-b90b-751d97fbfd62', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('1d1a3a6f-0702-46bf-991c-302bf53a847b', '6998d375-20ba-4b17-b90b-751d97fbfd62', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0e7f0d61-2d04-441a-b395-52029e1c6fcf', '6998d375-20ba-4b17-b90b-751d97fbfd62', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('415cbfa0-7d53-471b-87f7-f9c38134861f', '6998d375-20ba-4b17-b90b-751d97fbfd62', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('f81caf30-b870-49be-8e88-15b250a7e75a', '6998d375-20ba-4b17-b90b-751d97fbfd62', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('1cc9b648-bdb6-432a-95f7-acbe0104a386', '6998d375-20ba-4b17-b90b-751d97fbfd62', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data



-- Issuetypes to new projects
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('8626ac2d-9c80-45f3-9a12-216cc76d3457','PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER', 'PPTO', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4','PC_ISSUETYPE_ROLLOUT_METER_CHANGE', 'PPTO', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('03f413ef-79e8-46d0-a27f-ec7c036d0f86','PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER', 'PPTRE', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('7af94dec-1c27-4a3f-a774-baab65de703a','PC_ISSUETYPE_ROLLOUT_METER_CHANGE', 'PPTRE', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('44f949f2-b623-4e17-940c-99809806f64b','PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER', 'PPFIRE', 0, 'summary', 'PowerCatch Update Script');
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('e75e6b9e-1150-454e-836a-83b30a077b95','PC_ISSUETYPE_ROLLOUT_METER_CHANGE', 'PPFIRE', 0, 'summary', 'PowerCatch Update Script');


-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER PPTO)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('12e77d76-5fb4-482a-a244-06be284983c8', '8626ac2d-9c80-45f3-9a12-216cc76d3457', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('c6dafd87-1892-4281-b3f4-9754cbd7a7de', '8626ac2d-9c80-45f3-9a12-216cc76d3457', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('18f3cfa8-c6bb-4aa3-aa29-0231b022766a', '8626ac2d-9c80-45f3-9a12-216cc76d3457', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2cd64e72-ea90-4b90-95fa-d22c24fbc3f0', '8626ac2d-9c80-45f3-9a12-216cc76d3457', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('14d259e0-aefe-4c4b-8b3f-9bef661208b2', '8626ac2d-9c80-45f3-9a12-216cc76d3457', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('004e057f-c92f-41a1-bfb7-f032fc73f171', '8626ac2d-9c80-45f3-9a12-216cc76d3457', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('49585b6f-7e05-435f-9907-34f8ae164a05', '8626ac2d-9c80-45f3-9a12-216cc76d3457', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('99783aa5-d833-4a12-9ae4-97b9ca01cc36', '8626ac2d-9c80-45f3-9a12-216cc76d3457', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('ba3bd22d-9c2c-407a-8fbd-f1886a5e7994', '8626ac2d-9c80-45f3-9a12-216cc76d3457', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('cc54c4e7-879d-4ff9-baf8-edca2c9be241', '8626ac2d-9c80-45f3-9a12-216cc76d3457', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('b0b20b7a-b517-4603-a726-e2f93d06c609', '8626ac2d-9c80-45f3-9a12-216cc76d3457', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data


-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE PPTO)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2bdd4a41-c1bc-4b50-9676-22bb1137d12b', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('9683fe13-96af-4934-83d7-74d94f8c7b28', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('9200bd49-d88e-48a5-bbb5-7bc6bb1edf83', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bc389f2a-b298-42bf-a7c0-962c1cea8b42', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('3a74afaa-9506-44d6-a976-f8d6c3447984', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2457c429-abec-45fa-8ab0-85fc25fa626c', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('56bedb28-9d6b-4427-814b-76577e658df8', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('26a20f58-dfd6-48c9-b896-04d2c44bf358', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bf06b26b-88fe-419c-9ffc-6e47f4623ab8', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('ed62e816-bd1f-43eb-832d-4fdd12a53fa0', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0b95fcb0-bebc-43d3-b679-ec1d4bb7e8b4', 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data


-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER PPTRE)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('89501124-5a5b-49b7-a9d7-6b13c42a7a5d', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('ede47c30-4bd5-4436-b842-9945b2466cab', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2a2cba12-ad0e-4cf1-b480-d7fd3a05e8cb', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('a1f9cb4a-c7f3-4d95-9f75-6757098fb451', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('05df7fad-bd3a-4a21-a30c-518f39eafe13', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('328c939d-21c0-4022-b6de-1f678fb2c4ef', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('f610fd74-4220-4bd8-af2e-a936756cc736', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2c242d17-eb5d-4937-b1ed-517db0413446', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0e430ba6-a405-4b9f-bc22-df599654c95c', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('66a1d6e1-e108-4fa3-9c76-e0878950b291', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('624f7315-30a8-433d-bf69-fa7829554ad4', '03f413ef-79e8-46d0-a27f-ec7c036d0f86', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data



-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE PPTRE)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('94c20d5b-4c6a-476b-83fc-a4391f79d6cb', '7af94dec-1c27-4a3f-a774-baab65de703a', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('73237df4-4de4-498a-8008-d055b3bfd912', '7af94dec-1c27-4a3f-a774-baab65de703a', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('50a478e0-b04e-4706-b411-487a25d90539', '7af94dec-1c27-4a3f-a774-baab65de703a', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('50f6abcd-7ed2-4bfd-ad83-c8f00989ff56', '7af94dec-1c27-4a3f-a774-baab65de703a', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('1c1f31c2-eeda-4c76-b459-368f36b5ac98', '7af94dec-1c27-4a3f-a774-baab65de703a', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('c012be4f-1874-421e-9dee-20f0a0537831', '7af94dec-1c27-4a3f-a774-baab65de703a', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('20e4097a-058c-46ea-9a6b-a1a535584d34', '7af94dec-1c27-4a3f-a774-baab65de703a', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('3e93071c-cd48-43e4-accb-b3e8ca472d47', '7af94dec-1c27-4a3f-a774-baab65de703a', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('f1afe52c-6da3-499c-99bf-ed9525cec757', '7af94dec-1c27-4a3f-a774-baab65de703a', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('be7fe953-1377-475e-af57-047bbc7b5a99', '7af94dec-1c27-4a3f-a774-baab65de703a', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('54d145f8-d751-4e92-8c78-e628e86fef79', '7af94dec-1c27-4a3f-a774-baab65de703a', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data


-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER PPFIRE)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('e5fe1dcf-7db0-431a-be10-ca3794cd81ce', '44f949f2-b623-4e17-940c-99809806f64b', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('cdedfe1a-28de-4eeb-bd15-5f359ed80128', '44f949f2-b623-4e17-940c-99809806f64b', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('d48b734b-438d-4028-afec-776764bfcd98', '44f949f2-b623-4e17-940c-99809806f64b', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('881d5c53-2bf7-485a-844d-d66c29fd4f8e', '44f949f2-b623-4e17-940c-99809806f64b', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('d812f236-943c-4cad-83d4-1afbad1b03e6', '44f949f2-b623-4e17-940c-99809806f64b', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('e192ccb6-c17b-4982-ae92-84abb134c6e5', '44f949f2-b623-4e17-940c-99809806f64b', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('30658241-64ea-4fb0-9290-c1dd5e8af5b0', '44f949f2-b623-4e17-940c-99809806f64b', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0d899fd8-6d6f-4f80-b175-e9212725019b', '44f949f2-b623-4e17-940c-99809806f64b', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('afddfbbd-b9b9-4891-895b-e615c860137b', '44f949f2-b623-4e17-940c-99809806f64b', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('e5443799-cbc9-42ca-a703-63be9ea0d2dc', '44f949f2-b623-4e17-940c-99809806f64b', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('77279019-b4d6-4415-a2e8-da239f43f1b4', '44f949f2-b623-4e17-940c-99809806f64b', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data


-- ####################################################################
-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE PPFIRE)
-- ####################################################################
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('3bc252a6-394f-489e-afe5-48f552e9ef96', 'e75e6b9e-1150-454e-836a-83b30a077b95', 'bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30', 1, 'PowerCatch Update Script'); -- Ordreinfo page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2d47dce7-0036-4f7e-90ef-6aebc2b62e6c', 'e75e6b9e-1150-454e-836a-83b30a077b95', '4f041f44-b539-4eae-8af0-350d1f882dc3', 2, 'PowerCatch Update Script'); -- Anleggsdata page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('bb6a7171-cf3f-40dd-b0f3-f3c9c577de44', 'e75e6b9e-1150-454e-836a-83b30a077b95', '7cf691b0-d8b7-4a0c-a855-ec1610afcb38', 3, 'PowerCatch Update Script'); -- SJA page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('c2741267-8b98-4f93-995a-6887e674b707', 'e75e6b9e-1150-454e-836a-83b30a077b95', '57ac4954-9d67-4546-95f8-e9925465594f', 4, 'PowerCatch Update Script'); -- Målepunkt page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2bbb5d21-a848-45b1-837f-18a695462247', 'e75e6b9e-1150-454e-836a-83b30a077b95', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 5, 'PowerCatch Update Script'); -- Eksisterende måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7b5affa2-a78e-43a5-bd95-218389937204', 'e75e6b9e-1150-454e-836a-83b30a077b95', '07967eac-bbb3-48a7-963a-4131beeeffed', 6, 'PowerCatch Update Script'); -- Montasje ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('d8048bdd-2cc0-456c-80fe-f83b41527fee', 'e75e6b9e-1150-454e-836a-83b30a077b95', 'b93d7d31-767a-4500-b7a9-cec49d018739', 7, 'PowerCatch Update Script'); -- Målerdata ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7c7eeb33-c5f5-4038-9047-072146e64229', 'e75e6b9e-1150-454e-836a-83b30a077b95', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 8, 'PowerCatch Update Script'); -- Registrering ny måler page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('c7e94653-580e-43ec-8619-22eab7321d14', 'e75e6b9e-1150-454e-836a-83b30a077b95', '08631c23-a2f7-4d75-9f18-d00937da4683', 9, 'PowerCatch Update Script'); -- Ekstra page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('30e39ccf-bb6c-4189-b3dc-ff637c658610', 'e75e6b9e-1150-454e-836a-83b30a077b95', '10b1aa61-e654-4afe-b57e-d751f19b2f5c', 10, 'PowerCatch Update Script'); -- Sluttkontroll page data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('9d7b5f10-0398-42e8-905b-3c985b7155a8', 'e75e6b9e-1150-454e-836a-83b30a077b95', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 11, 'PowerCatch Update Script'); --Attachments page data




-- Delete mapping for projects, now one mapping has many projects

delete from konfigurasjon.issuetype where id = '91e1e21f-42f8-4a5f-b471-737eb0e3cff8';
delete from konfigurasjon.issuetype where id = '53f3d793-a70d-4645-9bcd-fa5a5b4cf96d';
delete from konfigurasjon.issuetype where id = '6998d375-20ba-4b17-b90b-751d97fbfd62';

-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT PPTO)
delete from konfigurasjon.issuetype_page where id = '7917060a-d07d-4802-bbe6-85b3daeee137';
delete from konfigurasjon.issuetype_page where id = '58ca4715-9487-4257-b915-2ed5081bc538';
delete from konfigurasjon.issuetype_page where id = 'e21cb5ab-0d24-48be-90ba-d58e7c1329b8';
delete from konfigurasjon.issuetype_page where id = '254942c0-f7a7-4ae4-a90d-fb20523eca26';
delete from konfigurasjon.issuetype_page where id = '479c9cc8-875b-4c6a-b4a8-3283f280d148';
delete from konfigurasjon.issuetype_page where id = '00187b5d-204e-4ee6-a98f-4c7878e00ac6';
delete from konfigurasjon.issuetype_page where id = '7de64575-3fba-472d-8120-53649e4fc2d2';
delete from konfigurasjon.issuetype_page where id = 'd1bc28b8-9f31-4a58-909a-3c21adc82d7d';
delete from konfigurasjon.issuetype_page where id = 'ae0d1966-e0e8-4a0a-889f-6c3b43fecca9';
delete from konfigurasjon.issuetype_page where id = '60f3978b-4665-47ef-b919-b1e63c81d8d1';
delete from konfigurasjon.issuetype_page where id = '7ce127ea-46d5-4257-bab8-8f05f98e8755';

-- ############# Delete Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT PPTRE)
delete from konfigurasjon.issuetype_page where id = 'da292718-36dc-4170-8e9f-e263765ca748';
delete from konfigurasjon.issuetype_page where id = '996dc6e0-8741-4903-8c47-ce98c59938df';
delete from konfigurasjon.issuetype_page where id = '1b0f17c6-08e7-498b-b42a-875c521fcac0';
delete from konfigurasjon.issuetype_page where id = 'c71e6720-9e9c-4a46-8048-9226d7ba0333';
delete from konfigurasjon.issuetype_page where id = '61de8d2f-bada-4d7e-bc78-1e6c60e2c5af';
delete from konfigurasjon.issuetype_page where id = 'be9209eb-ff02-4638-84d2-28631c783ff8';
delete from konfigurasjon.issuetype_page where id = '6a813f73-83d0-4994-99ac-67a4b9a8d24c';
delete from konfigurasjon.issuetype_page where id = 'bc19fa1b-b8c2-4738-9dd0-274213447533';
delete from konfigurasjon.issuetype_page where id = 'b0cbeb1a-4851-42db-8aa3-5057bf19cd7f';
delete from konfigurasjon.issuetype_page where id = '28d5aff2-8fe8-4595-b62f-88fe45a78af5';
delete from konfigurasjon.issuetype_page where id = '3cfe42a7-8178-4ba3-871b-c6f6788c8e9e';

-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE_CT PPFIRE)
delete from konfigurasjon.issuetype_page where id = 'bca94bf9-80a1-46b5-95bb-725b39fdd6a2';
delete from konfigurasjon.issuetype_page where id = '5adf32cc-8223-4e25-baa9-e659110adb44';
delete from konfigurasjon.issuetype_page where id = 'c3cfb554-be6d-45ab-af1b-f6e14d81bfcb';
delete from konfigurasjon.issuetype_page where id = 'f4222e03-307f-48ee-a692-93198fdbb882';
delete from konfigurasjon.issuetype_page where id = 'c0410645-f8cb-4933-939f-cd34823c79c5';
delete from konfigurasjon.issuetype_page where id = 'dca63910-6d61-4554-b8dc-546ef20a9926';
delete from konfigurasjon.issuetype_page where id = '1d1a3a6f-0702-46bf-991c-302bf53a847b';
delete from konfigurasjon.issuetype_page where id = '0e7f0d61-2d04-441a-b395-52029e1c6fcf';
delete from konfigurasjon.issuetype_page where id = '415cbfa0-7d53-471b-87f7-f9c38134861f';
delete from konfigurasjon.issuetype_page where id = 'f81caf30-b870-49be-8e88-15b250a7e75a';
delete from konfigurasjon.issuetype_page where id = '1cc9b648-bdb6-432a-95f7-acbe0104a386';

-- Delete Issuetypes to new projects
delete from konfigurasjon.issuetype where id = '8626ac2d-9c80-45f3-9a12-216cc76d3457';
delete from konfigurasjon.issuetype where id = 'a8ea672c-8c01-4a5a-835e-3bc3b7cb8ee4';
delete from konfigurasjon.issuetype where id = '03f413ef-79e8-46d0-a27f-ec7c036d0f86';
delete from konfigurasjon.issuetype where id = '7af94dec-1c27-4a3f-a774-baab65de703a';
delete from konfigurasjon.issuetype where id = '44f949f2-b623-4e17-940c-99809806f64b';
delete from konfigurasjon.issuetype where id = 'e75e6b9e-1150-454e-836a-83b30a077b95';

-- Delete ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER PPTO)
delete from konfigurasjon.issuetype_page where id = '12e77d76-5fb4-482a-a244-06be284983c8';
delete from konfigurasjon.issuetype_page where id = 'c6dafd87-1892-4281-b3f4-9754cbd7a7de';
delete from konfigurasjon.issuetype_page where id = '18f3cfa8-c6bb-4aa3-aa29-0231b022766a';
delete from konfigurasjon.issuetype_page where id = '2cd64e72-ea90-4b90-95fa-d22c24fbc3f0';
delete from konfigurasjon.issuetype_page where id = '14d259e0-aefe-4c4b-8b3f-9bef661208b2';
delete from konfigurasjon.issuetype_page where id = '004e057f-c92f-41a1-bfb7-f032fc73f171';
delete from konfigurasjon.issuetype_page where id = '49585b6f-7e05-435f-9907-34f8ae164a05';
delete from konfigurasjon.issuetype_page where id = '99783aa5-d833-4a12-9ae4-97b9ca01cc36';
delete from konfigurasjon.issuetype_page where id = 'ba3bd22d-9c2c-407a-8fbd-f1886a5e7994';
delete from konfigurasjon.issuetype_page where id = 'cc54c4e7-879d-4ff9-baf8-edca2c9be241';
delete from konfigurasjon.issuetype_page where id = 'b0b20b7a-b517-4603-a726-e2f93d06c609';

-- Delete ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE PPTO)
delete from konfigurasjon.issuetype_page where id = '2bdd4a41-c1bc-4b50-9676-22bb1137d12b';
delete from konfigurasjon.issuetype_page where id = '9683fe13-96af-4934-83d7-74d94f8c7b28';
delete from konfigurasjon.issuetype_page where id = '9200bd49-d88e-48a5-bbb5-7bc6bb1edf83';
delete from konfigurasjon.issuetype_page where id = 'bc389f2a-b298-42bf-a7c0-962c1cea8b42';
delete from konfigurasjon.issuetype_page where id = '3a74afaa-9506-44d6-a976-f8d6c3447984';
delete from konfigurasjon.issuetype_page where id = '2457c429-abec-45fa-8ab0-85fc25fa626c';
delete from konfigurasjon.issuetype_page where id = '56bedb28-9d6b-4427-814b-76577e658df8';
delete from konfigurasjon.issuetype_page where id = '26a20f58-dfd6-48c9-b896-04d2c44bf358';
delete from konfigurasjon.issuetype_page where id = 'bf06b26b-88fe-419c-9ffc-6e47f4623ab8';
delete from konfigurasjon.issuetype_page where id = 'ed62e816-bd1f-43eb-832d-4fdd12a53fa0';
delete from konfigurasjon.issuetype_page where id = '0b95fcb0-bebc-43d3-b679-ec1d4bb7e8b4';

-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER PPTRE)
delete from konfigurasjon.issuetype_page where id = '89501124-5a5b-49b7-a9d7-6b13c42a7a5d';
delete from konfigurasjon.issuetype_page where id = 'ede47c30-4bd5-4436-b842-9945b2466cab';
delete from konfigurasjon.issuetype_page where id = '2a2cba12-ad0e-4cf1-b480-d7fd3a05e8cb';
delete from konfigurasjon.issuetype_page where id = 'a1f9cb4a-c7f3-4d95-9f75-6757098fb451';
delete from konfigurasjon.issuetype_page where id = '05df7fad-bd3a-4a21-a30c-518f39eafe13';
delete from konfigurasjon.issuetype_page where id = '328c939d-21c0-4022-b6de-1f678fb2c4ef';
delete from konfigurasjon.issuetype_page where id = 'f610fd74-4220-4bd8-af2e-a936756cc736';
delete from konfigurasjon.issuetype_page where id = '2c242d17-eb5d-4937-b1ed-517db0413446';
delete from konfigurasjon.issuetype_page where id = '0e430ba6-a405-4b9f-bc22-df599654c95c';
delete from konfigurasjon.issuetype_page where id = '66a1d6e1-e108-4fa3-9c76-e0878950b291';
delete from konfigurasjon.issuetype_page where id = '624f7315-30a8-433d-bf69-fa7829554ad4';

-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE PPTRE)
delete from konfigurasjon.issuetype_page where id = '94c20d5b-4c6a-476b-83fc-a4391f79d6cb';
delete from konfigurasjon.issuetype_page where id = '73237df4-4de4-498a-8008-d055b3bfd912';
delete from konfigurasjon.issuetype_page where id = '50a478e0-b04e-4706-b411-487a25d90539';
delete from konfigurasjon.issuetype_page where id = '50f6abcd-7ed2-4bfd-ad83-c8f00989ff56';
delete from konfigurasjon.issuetype_page where id = '1c1f31c2-eeda-4c76-b459-368f36b5ac98';
delete from konfigurasjon.issuetype_page where id = 'c012be4f-1874-421e-9dee-20f0a0537831';
delete from konfigurasjon.issuetype_page where id = '20e4097a-058c-46ea-9a6b-a1a535584d34';
delete from konfigurasjon.issuetype_page where id = '3e93071c-cd48-43e4-accb-b3e8ca472d47';
delete from konfigurasjon.issuetype_page where id = 'f1afe52c-6da3-499c-99bf-ed9525cec757';
delete from konfigurasjon.issuetype_page where id = 'be7fe953-1377-475e-af57-047bbc7b5a99';
delete from konfigurasjon.issuetype_page where id = '54d145f8-d751-4e92-8c78-e628e86fef79';

-- ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_SUBSTATION_NEW_MASTER PPFIRE)
delete from konfigurasjon.issuetype_page where id = 'e5fe1dcf-7db0-431a-be10-ca3794cd81ce';
delete from konfigurasjon.issuetype_page where id = 'cdedfe1a-28de-4eeb-bd15-5f359ed80128';
delete from konfigurasjon.issuetype_page where id = 'd48b734b-438d-4028-afec-776764bfcd98';
delete from konfigurasjon.issuetype_page where id = '881d5c53-2bf7-485a-844d-d66c29fd4f8e';
delete from konfigurasjon.issuetype_page where id = 'd812f236-943c-4cad-83d4-1afbad1b03e6';
delete from konfigurasjon.issuetype_page where id = 'e192ccb6-c17b-4982-ae92-84abb134c6e5';
delete from konfigurasjon.issuetype_page where id = '30658241-64ea-4fb0-9290-c1dd5e8af5b0';
delete from konfigurasjon.issuetype_page where id = '0d899fd8-6d6f-4f80-b175-e9212725019b';
delete from konfigurasjon.issuetype_page where id = 'afddfbbd-b9b9-4891-895b-e615c860137b';
delete from konfigurasjon.issuetype_page where id = 'e5443799-cbc9-42ca-a703-63be9ea0d2dc';
delete from konfigurasjon.issuetype_page where id = '77279019-b4d6-4415-a2e8-da239f43f1b4';

-- Delete ############# Koble issuetype/pages (PC_ISSUETYPE_ROLLOUT_METER_CHANGE PPFIRE)
delete from konfigurasjon.issuetype_page where id = '3bc252a6-394f-489e-afe5-48f552e9ef96';
delete from konfigurasjon.issuetype_page where id = '2d47dce7-0036-4f7e-90ef-6aebc2b62e6c';
delete from konfigurasjon.issuetype_page where id = 'bb6a7171-cf3f-40dd-b0f3-f3c9c577de44';
delete from konfigurasjon.issuetype_page where id = 'c2741267-8b98-4f93-995a-6887e674b707';
delete from konfigurasjon.issuetype_page where id = '2bbb5d21-a848-45b1-837f-18a695462247';
delete from konfigurasjon.issuetype_page where id = '7b5affa2-a78e-43a5-bd95-218389937204';
delete from konfigurasjon.issuetype_page where id = 'd8048bdd-2cc0-456c-80fe-f83b41527fee';
delete from konfigurasjon.issuetype_page where id = '7c7eeb33-c5f5-4038-9047-072146e64229';
delete from konfigurasjon.issuetype_page where id = 'c7e94653-580e-43ec-8619-22eab7321d14';
delete from konfigurasjon.issuetype_page where id = '30e39ccf-bb6c-4189-b3dc-ff637c658610';
delete from konfigurasjon.issuetype_page where id = '9d7b5f10-0398-42e8-905b-3c985b7155a8';


*/

-- PC-3125
--Update missing values on Anleggsdata page
update konfigurasjon.page_fieldproperty set id_fieldproperty = 'b1de6368-e72b-4db6-8d7d-9a88b5dae3d0' where id = '22b33222-891d-4250-8cba-2939b5d47733'; --PC_CUSTOMER_NAME
update konfigurasjon.page_fieldproperty set id_fieldproperty = '90fca990-9c3c-40fc-9b9f-b091cc60220b' where id = 'e9a11a9c-990b-49de-abe3-473a5df145f6'; --PC_CUSTOMER_PHONE
update konfigurasjon.page_fieldproperty set id_fieldproperty = '55254909-80a4-44a3-b5f5-4339413e6b27' where id = '367c77ae-86db-42d5-b5cf-ed6ee7741c5e'; --PC_CUSTOMER_MOBILE

-- ######### Endringer ihht PC-3116 

-- Legge til felt på siden Målerdata ny måler
--PC_WORK_COMPLETED_DATE_TIME
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('ae41fe48-adb0-4307-bd3d-920873b6963c', NULL, 'PC_WORK_COMPLETED_DATE_TIME', NULL, 'PowerCatch Update Script');
--																																									  ID														field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('c8c7e78b-2947-4a00-a55e-e56832de3164', '', 1, 1, NULL, 'ae41fe48-adb0-4307-bd3d-920873b6963c', 'PowerCatch Update Script', 0,0,0); -- PC_WORK_COMPLETED_DATE_TIME
--																												ID													Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e84b9e73-4a99-4daf-845c-647d9688a853', 'b93d7d31-767a-4500-b7a9-cec49d018739', 'c8c7e78b-2947-4a00-a55e-e56832de3164', 10, 'PowerCatch Update Script'); --PC_WORK_COMPLETED_DATE_TIME


-- Fjerne disse feltene
-- finnes ikke PC_METERPOINT_SETTLEMENT_METHOD
--PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
	-- make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d01974db-2f23-4066-a246-6030d014c839', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '4b9e25e6-3a7f-4581-8f78-52b6f1de783a', 2, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
	delete from konfigurasjon.page_fieldproperty where id ='d01974db-2f23-4066-a246-6030d014c839';
--PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
	--make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('27727741-4d77-4fd2-aeb0-aa864eca2971', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '88db7b88-0dfe-4b30-8921-92d983046c8a', 8, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
	delete from konfigurasjon.page_fieldproperty where id ='27727741-4d77-4fd2-aeb0-aa864eca2971';
--PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
	--make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('1d04f99d-50df-4681-8b71-7e982fe495b5', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'a9cf4904-628e-42ee-a807-a243f918bddc', 5, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
	delete from konfigurasjon.page_fieldproperty where id ='1d04f99d-50df-4681-8b71-7e982fe495b5';
--PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
	--make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('95b4d602-6d27-4c5d-b131-937e6b544cfe', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '5c00dbea-0d9c-4ca4-8df3-1b720774c0cf', 11, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
	delete from konfigurasjon.page_fieldproperty where id ='95b4d602-6d27-4c5d-b131-937e6b544cfe';

--PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
	-- make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('07d3ff01-d798-4f49-8a15-bb4fcfadccc9', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '04e0b3db-4679-42c3-878e-83adde7685ac', 1, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_TYPE
	delete from konfigurasjon.page_fieldproperty where id ='07d3ff01-d798-4f49-8a15-bb4fcfadccc9';
--PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
	--make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('605ea5a6-2a4d-4c18-9479-ee3045be9782', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'a185e8d9-4e2d-480c-887e-dcfec72e03fa', 7, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_TYPE
	delete from konfigurasjon.page_fieldproperty where id ='605ea5a6-2a4d-4c18-9479-ee3045be9782';
--PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
	--make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('37737534-51d8-4212-9269-b940d27e50ee', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '857f9f13-edc2-4162-a9a7-a74c0992e5ff', 4, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_TYPE
	delete from konfigurasjon.page_fieldproperty where id ='37737534-51d8-4212-9269-b940d27e50ee';
--PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE
	--make delete INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('4953c7b5-4072-4bcf-a502-74d3c72ccdb0', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'ad020d5d-e578-4624-aab4-b5f167335194', 10, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_TYPE	
	delete from konfigurasjon.page_fieldproperty where id ='4953c7b5-4072-4bcf-a502-74d3c72ccdb0';

	
-- ######### Endringer ihht PC-3125 - Ikke lagt inn hos embriq,

--	** Utført -> Tab pc.page.installation.data:
--	** Utført -> Følgende felter har falt ut, og skal ligge først på den pagen:
--	** Utført -> PC_CUSTOMER_NAME
--	** Utført -> PC_CUSTOMER_PHONE
--	** Utført -> PC_CUSTOMER_MOBILE
--	** Utført -> 	--Update missing values on Anleggsdata page
--	** Utført -> 		update konfigurasjon.page_fieldproperty set id_fieldproperty = 'b1de6368-e72b-4db6-8d7d-9a88b5dae3d0' where id = '22b33222-891d-4250-8cba-2939b5d47733'; --PC_CUSTOMER_NAME
--	** Utført -> 		update konfigurasjon.page_fieldproperty set id_fieldproperty = '90fca990-9c3c-40fc-9b9f-b091cc60220b' where id = 'e9a11a9c-990b-49de-abe3-473a5df145f6'; --PC_CUSTOMER_PHONE
--	** Utført -> 		update konfigurasjon.page_fieldproperty set id_fieldproperty = '55254909-80a4-44a3-b5f5-4339413e6b27' where id = '367c77ae-86db-42d5-b5cf-ed6ee7741c5e'; --PC_CUSTOMER_MOBILE
	
	
	
--Tab pc.page.existing.meter: (aa29b9c9-8c57-42c3-a1ba-26d56309fe74)
--	Legg til datofelter
--	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
--	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
--	PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
--	PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME
--	Disse legges på sortorder 4, 7, 10, 13


INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('967f3122-df66-44b6-ad13-7f2a1fbf4afb', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('139a7d0d-1af3-4035-935c-566f87bc626b', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('421ff470-c236-488d-9081-0004a990f7df', NULL, 'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7af5a2d3-0659-427e-9bf3-a0ce7318e8e9', NULL, 'PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME

--																																									  ID											field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('f6ea90be-890e-493f-b94c-f99883d561a7', '', 1, 0, NULL, '967f3122-df66-44b6-ad13-7f2a1fbf4afb', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('c2abf9a0-e21f-4081-bab3-aa78de93a996', '', 1, 0, NULL, '139a7d0d-1af3-4035-935c-566f87bc626b', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('64957542-a720-4837-9273-f67a273104b5', '', 1, 0, NULL, '421ff470-c236-488d-9081-0004a990f7df', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('a869ff5d-4235-44da-8817-4a719e6c0e51', '', 1, 0, NULL, '7af5a2d3-0659-427e-9bf3-a0ce7318e8e9', 'PowerCatch Update Script', 0,0,0); -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME

--																											ID									Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('c5ad45d1-694d-421f-a91e-0038a9cece35', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'f6ea90be-890e-493f-b94c-f99883d561a7', 4, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('7a7f99c8-1c1c-4b71-ad9b-aba68d037ee4', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'c2abf9a0-e21f-4081-bab3-aa78de93a996', 7, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('35ee88f2-a1d8-4ae3-a6a5-927796ced291', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', '64957542-a720-4837-9273-f67a273104b5', 10, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('2981edc2-a780-4d00-9f6e-1123f33dfaf4', 'aa29b9c9-8c57-42c3-a1ba-26d56309fe74', 'a869ff5d-4235-44da-8817-4a719e6c0e51', 13, 'PowerCatch Update Script'); --PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME

update konfigurasjon.page_fieldproperty set sortorder = 1 where id = '0fafecd9-f0fd-4f91-843f-e6010f9104d2'; -- PC_EXISTING_METER_STATE_METER_SERIAL_NUMBER
update konfigurasjon.page_fieldproperty set sortorder = 2 where id = 'c7462cef-eca4-41cd-88ed-4d2ec4027077'; -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT
update konfigurasjon.page_fieldproperty set sortorder = 3 where id = 'b6a128fd-e2bd-4b2e-babd-f036df440f13'; -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE
update konfigurasjon.page_fieldproperty set sortorder = 5 where id = '37c789b3-f51c-472f-8743-b1d576401b10'; -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT
update konfigurasjon.page_fieldproperty set sortorder = 6 where id = '5b044cb6-9b3e-4a82-bcfd-7f29fff7d1c0'; -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE
update konfigurasjon.page_fieldproperty set sortorder = 8 where id = '50acb064-0438-452b-8c32-040eac94c4a0'; -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT
update konfigurasjon.page_fieldproperty set sortorder = 9 where id = '730d2971-1969-454c-a77d-2470a5de9bae'; -- PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE
update konfigurasjon.page_fieldproperty set sortorder = 11 where id = '28146cc2-2013-4137-9e83-3713c0d3befd'; -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT
update konfigurasjon.page_fieldproperty set sortorder = 12 where id = '2626d5b7-b3a6-474f-9402-2c45f3144c31'; -- PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE
	
	

--Tab pc.page.meterdata.new.meter
--	Flytt PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE til posisjonen etter PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE, dvs den får sortorder 6 etter flytting

update konfigurasjon.page_fieldproperty set sortorder = 6 where id = '7d0cb7bf-0855-4b84-b8ca-e75866e41ede';--PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE
update konfigurasjon.page_fieldproperty set sortorder = 3 where id = 'e76865ef-1fd1-47ab-81a5-deebc57d3ebe'; --PC_NEW_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE
update konfigurasjon.page_fieldproperty set sortorder = 4 where id = '236f8f9b-5ee1-48bd-8226-446d46046181'; --PC_NEW_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE
update konfigurasjon.page_fieldproperty set sortorder = 5 where id = '7ab9adf8-6719-4ac8-9e37-2bd4fe3cb053'; --PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE
	


--Tab pc.page.register.new.meter: (cfac8400-9aa0-42a9-ac4d-6d6685ae723c)
--	Legg til datofelter
--	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
--	PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
--	PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
--	PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME
--	Disse legges på sortorder 3, 6, 9, 12
	
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('5efb07c6-0abf-4826-b3be-84c81ca346aa', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('19842486-c549-4cde-bc39-52f1aa587951', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('8703f4a6-7412-460e-a9de-06988fe87d60', NULL, 'PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('3a32df75-1951-41fd-9a8b-bd92ad938158', NULL, 'PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME', NULL, 'PowerCatch Update Script'); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME

--																																										  ID													field id
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('32f2d6c2-c4d3-4bf8-84bc-9fad0976b349', '', 1, 0, NULL, '5efb07c6-0abf-4826-b3be-84c81ca346aa', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('f8c8bded-37f4-4f9f-b29f-33f4636ff1d7', '', 1, 0, NULL, '19842486-c549-4cde-bc39-52f1aa587951', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('4ec286c4-a587-43e9-96ca-aafbbd4f103b', '', 1, 0, NULL, '8703f4a6-7412-460e-a9de-06988fe87d60', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('cb764a62-31d5-46a4-b3ee-e3e0668d7dc7', '', 1, 0, NULL, '3a32df75-1951-41fd-9a8b-bd92ad938158', 'PowerCatch Update Script', 0,0,0); -- PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME
--																											ID															Page						fieldproperty
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('1c1ed79a-b17f-4d9d-b5e3-a7f2384f8157', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '32f2d6c2-c4d3-4bf8-84bc-9fad0976b349', 3, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('813568c3-83a0-4f24-96ed-67b9c0e051b9', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'f8c8bded-37f4-4f9f-b29f-33f4636ff1d7', 6, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('72b68ace-b767-4f61-84d4-409860c897b2', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', '4ec286c4-a587-43e9-96ca-aafbbd4f103b', 9, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('ed9ff70e-97e1-4a0e-bf67-ce7fa2092935', 'cfac8400-9aa0-42a9-ac4d-6d6685ae723c', 'cb764a62-31d5-46a4-b3ee-e3e0668d7dc7', 12, 'PowerCatch Update Script'); --PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME

update konfigurasjon.page_fieldproperty set sortorder = 1 where id = '5da68ed8-fdaa-48c9-a486-2d11885a2c61';
update konfigurasjon.page_fieldproperty set sortorder = 2 where id = '85e922f1-31d3-4822-8a60-d9a34309e411';
update konfigurasjon.page_fieldproperty set sortorder = 4 where id = '3bec7e51-9896-4c52-b81c-bbb370344b0e';
update konfigurasjon.page_fieldproperty set sortorder = 5 where id = '5f38ce7a-6318-452d-aee4-f8649bef8813';
update konfigurasjon.page_fieldproperty set sortorder = 7 where id = '5d08f624-f4ed-4065-93b8-b53e31d185b0';
update konfigurasjon.page_fieldproperty set sortorder = 8 where id = '0d67fd82-468d-4372-93fa-a14553490834';
update konfigurasjon.page_fieldproperty set sortorder = 10 where id = 'e3eea61d-dc7f-481e-bea2-71560c80e59d';
update konfigurasjon.page_fieldproperty set sortorder = 11 where id = 'f368005e-818b-49e8-8cf9-ecd4117acaac';


-- Oppsett driftsordre + ingen sakstyper skal kunne opprettes på mobil
-- issuetype
insert into konfigurasjon.issuetype values ('9d784c0b-073b-4df7-bf38-70d787e2e885','','PC_ISSUETYPE_SERVICE_CT','BIK,HAE,MTE',0,'','PowerCatch admin','2016-03-11 12:56:44.732+01',0);
insert into konfigurasjon.issuetype values ('afdd12af-ade2-4444-a88f-7a22a53c37cc','','PC_ISSUETYPE_SERVICE_SUBSTATION','BIK,HAE,MTE',0,'','PowerCatch admin','2016-03-11 12:55:39.686+01',0);
insert into konfigurasjon.issuetype values ('7006313c-675f-4c29-9705-0c6dec6bac9f','','PC_ISSUETYPE_SERVICE','BIK,HAE,MTE',0,'','PowerCatch admin','2016-03-11 12:54:48.227+01',0);
update konfigurasjon.issuetype set new_issue_enabled = 0 where id = '57e0ba97-1f40-494f-9ce3-efadf52d8b20';
update konfigurasjon.issuetype set new_issue_enabled = 0 where id = '664881ac-3245-403f-afd8-94ec6a8bf1ce';
update konfigurasjon.issuetype set new_issue_enabled = 0 where id = 'b5c2c02c-e88f-4013-9799-f970978ba8b2';

-- page
insert into konfigurasjon.page values ('d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b',127,'pc.page.new.meter.mounting',0,'PowerCatch admin','2016-03-11 15:48:03.903+01',0,0);
insert into konfigurasjon.page values ('c743e870-d80d-46fb-be38-127ba5da3d6a',126,'pc.page.existing.meter.unmounting',0,'PowerCatch admin','2016-03-11 15:47:02.143+01',0,0);
insert into konfigurasjon.page values ('6bf62319-624f-4816-9226-4962feb982f9',125,'pc.page.completed.work',0,'PowerCatch admin','2016-03-11 15:06:14.467+01',0,0);
insert into konfigurasjon.page values ('2b69c427-2618-48c4-8f4c-93da02ce9558',124,'pc.page.mounting.antenna',0,'PowerCatch admin','2016-03-11 14:04:51.131+01',0,0);
insert into konfigurasjon.page values ('1a270ff3-ec42-4f91-b2d9-8e056b96e790',123,'pc.page.unmounting.antenna',0,'PowerCatch admin','2016-03-11 14:04:20.604+01',0,0);

-- field
insert into konfigurasjon.field values ('2e15d2b5-c096-45ae-aa2e-4e1a11611aa5','','PC_WORKTASK_TYPE',NULL,'PowerCatch admin','2016-03-13 21:47:48.184+01',0);
insert into konfigurasjon.field values ('af3ac938-d390-446d-8ae1-2b72728f5721','','PC_NEW_METER_STATE_SIM_CARD_SERIAL_NUMBER',NULL,'PowerCatch admin','2016-03-11 15:54:00.71+01',0);
insert into konfigurasjon.field values ('2e5a8e96-ac2a-4245-9ca2-3aa41d187dd2','','PC_EXISTING_METER_STATE_SIM_CARD_SERIAL_NUMBER',NULL,'PowerCatch admin','2016-03-11 15:49:34.309+01',0);
insert into konfigurasjon.field values ('617443b1-8eec-45a1-9769-8edb95186f93','','PC_WORKTASK_DESCRIPTION',NULL,'PowerCatch admin','2016-03-11 15:07:09.656+01',0);
insert into konfigurasjon.field values ('045d0977-a061-4bba-9068-f27ff2515c57','','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE',NULL,'PowerCatch admin','2016-03-11 15:04:51.744+01',0);
insert into konfigurasjon.field values ('a3b94e9e-bfa5-4a7c-bf55-eb99126a76f9','','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE',NULL,'PowerCatch admin','2016-03-11 15:04:17.473+01',0);
insert into konfigurasjon.field values ('78310a18-dcc8-4f87-ae1b-4e0d441267a8','','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE',NULL,'PowerCatch admin','2016-03-11 15:03:32.738+01',0);
insert into konfigurasjon.field values ('87f59ead-5d77-4ff3-90c5-56d10a68a3b7','','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE',NULL,'PowerCatch admin','2016-03-11 15:02:54.293+01',0);
insert into konfigurasjon.field values ('e5f51cf9-e6ce-42bc-812b-6fd8747cd886','','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE',NULL,'PowerCatch admin','2016-03-11 15:02:13.715+01',0);
insert into konfigurasjon.field values ('66e68293-df69-42d7-9763-315bca1a3830','','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE',NULL,'PowerCatch admin','2016-03-11 15:01:31.915+01',0);
insert into konfigurasjon.field values ('b1095dd3-be70-42cc-a253-4ee004ffe4d2','','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE',NULL,'PowerCatch admin','2016-03-11 15:00:03.554+01',0);
insert into konfigurasjon.field values ('aeeb719d-2ee8-488e-8b0b-d24b91b82472','','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE',NULL,'PowerCatch admin','2016-03-11 14:58:30.281+01',0);

--  fieldproperty
insert into konfigurasjon.fieldproperty values ('d54bd9e4-78f8-4b1d-829b-e7ebf7428f70','',1,0,NULL,'60216aa1-b370-4e30-97df-c4d401d40837','PowerCatch admin','2016-03-13 22:19:28.185+01',0,0,1,1,1); --'PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE'
insert into konfigurasjon.fieldproperty values ('fdf514f0-0e5f-461d-8cd0-45591fb0b69e','',1,0,NULL,'5dd4e65b-3525-40e6-9c15-f1a8f342dbe0','PowerCatch admin','2016-03-13 22:13:42.311+01',0,0,1,1,1); --'PC_NEW_METER_STATE_METER_SERIAL_NUMBER'
insert into konfigurasjon.fieldproperty values ('62d11a06-72f8-4bab-8a93-a7f8951464e9','',1,0,NULL,'2e15d2b5-c096-45ae-aa2e-4e1a11611aa5','PowerCatch admin','2016-03-13 21:48:10.149+01',0,0,0,0,0); --'PC_WORKTASK_TYPE'
--insert into konfigurasjon.fieldproperty values ('cc19264a-71b3-4087-8ced-84fd4f8f863f','',1,0,NULL,'0f6d7aff-c97e-4e4c-9185-c3c8cfdd48ac','PowerCatch admin','2016-03-13 21:40:16.513+01',0,0,0,0,0); --'PC_SJA_CONFIRMATION'
insert into konfigurasjon.fieldproperty values ('764abfff-2380-4acf-bf97-75fef1ca2952','',1,0,NULL,'af3ac938-d390-446d-8ae1-2b72728f5721','PowerCatch admin','2016-03-11 15:54:11.078+01',0,0,0,0,0); --'PC_NEW_METER_STATE_SIM_CARD_SERIAL_NUMBER'
insert into konfigurasjon.fieldproperty values ('f25b8f1f-25aa-4f34-848c-d29ecdadfb56','',1,0,NULL,'2e5a8e96-ac2a-4245-9ca2-3aa41d187dd2','PowerCatch admin','2016-03-11 15:49:45.368+01',0,0,0,0,0); --'PC_EXISTING_METER_STATE_SIM_CARD_SERIAL_NUMBER'
insert into konfigurasjon.fieldproperty values ('4cce9941-47b5-4beb-a34d-f0149af05b0b','',1,0,NULL,'617443b1-8eec-45a1-9769-8edb95186f93','PowerCatch admin','2016-03-11 15:07:27.291+01',0,0,0,0,0); --'PC_WORKTASK_DESCRIPTION'
insert into konfigurasjon.fieldproperty values ('95eacf43-193a-46f5-b0c5-a6045ac6a651','',1,0,NULL,'045d0977-a061-4bba-9068-f27ff2515c57','PowerCatch admin','2016-03-11 15:05:01.391+01',0,0,0,0,0); --'PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE'
insert into konfigurasjon.fieldproperty values ('c015f676-e072-41f6-9f26-d4b7774d69ac','',1,0,NULL,'a3b94e9e-bfa5-4a7c-bf55-eb99126a76f9','PowerCatch admin','2016-03-11 15:04:26.734+01',0,0,0,0,0); --'PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE'
insert into konfigurasjon.fieldproperty values ('6411227e-d9e2-43d4-a01d-c4867552e2f0','',1,0,NULL,'78310a18-dcc8-4f87-ae1b-4e0d441267a8','PowerCatch admin','2016-03-11 15:03:44.326+01',0,0,0,0,0); --'PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE'
insert into konfigurasjon.fieldproperty values ('57627a00-44c4-4671-afa8-265ee0cbde77','',1,0,NULL,'87f59ead-5d77-4ff3-90c5-56d10a68a3b7','PowerCatch admin','2016-03-11 15:03:05.465+01',0,0,0,0,0); --'PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE'
insert into konfigurasjon.fieldproperty values ('f76d0fed-a736-4437-9424-7601a110a7e8','',1,0,NULL,'e5f51cf9-e6ce-42bc-812b-6fd8747cd886','PowerCatch admin','2016-03-11 15:02:27.193+01',0,0,0,0,0); --'PC_EXISTING_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE'
insert into konfigurasjon.fieldproperty values ('cd554e4f-7b68-4ce1-8f36-3f04cf6be945','',1,0,NULL,'66e68293-df69-42d7-9763-315bca1a3830','PowerCatch admin','2016-03-11 15:01:43.099+01',0,0,0,0,0); --'PC_EXISTING_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE'
insert into konfigurasjon.fieldproperty values ('5f12fb2a-0c30-451b-98e3-50f018664924','',1,0,NULL,'b1095dd3-be70-42cc-a253-4ee004ffe4d2','PowerCatch admin','2016-03-11 15:00:16.088+01',0,0,0,0,0); --'PC_EXISTING_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE'
insert into konfigurasjon.fieldproperty values ('d2a58204-1358-4a07-8c56-05b53d3321b7','',1,0,NULL,'aeeb719d-2ee8-488e-8b0b-d24b91b82472','PowerCatch admin','2016-03-11 14:58:55.904+01',0,0,0,0,0); --'PC_EXISTING_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE'

-- issuetype_page
insert into konfigurasjon.issuetype_page values ('47256b29-401d-4ded-867b-39cb68680f2c','9d784c0b-073b-4df7-bf38-70d787e2e885','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b',8,'PowerCatch admin','2016-03-11 15:58:26.949+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.new.meter.mounting'
insert into konfigurasjon.issuetype_page values ('1162d84a-5cb9-470f-a6ed-27efcc360748','9d784c0b-073b-4df7-bf38-70d787e2e885','f3b63b5a-9b9f-473e-a165-6a3f537b0989',11,'PowerCatch admin','2016-03-11 15:58:26.949+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.attachments'
insert into konfigurasjon.issuetype_page values ('6e331e35-dc11-46d5-aeef-51f439582849','9d784c0b-073b-4df7-bf38-70d787e2e885','10b1aa61-e654-4afe-b57e-d751f19b2f5c',10,'PowerCatch admin','2016-03-11 15:58:26.948+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.final.check'
insert into konfigurasjon.issuetype_page values ('80cb54c0-a9f0-4cdd-a241-1ea5877fcb2c','9d784c0b-073b-4df7-bf38-70d787e2e885','6bf62319-624f-4816-9226-4962feb982f9',9,'PowerCatch admin','2016-03-11 15:58:26.946+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.completed.work'
insert into konfigurasjon.issuetype_page values ('c0e924bd-70ae-43b5-a3e6-85ae0adfe1cd','9d784c0b-073b-4df7-bf38-70d787e2e885','c743e870-d80d-46fb-be38-127ba5da3d6a',7,'PowerCatch admin','2016-03-11 15:58:26.944+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.existing.meter.unmounting'
insert into konfigurasjon.issuetype_page values ('f1f5a4ae-779d-4e32-9f5b-247429f50760','afdd12af-ade2-4444-a88f-7a22a53c37cc','f3b63b5a-9b9f-473e-a165-6a3f537b0989',11,'PowerCatch admin','2016-03-11 15:57:58.264+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.attachments'
insert into konfigurasjon.issuetype_page values ('9e0b17e1-118f-4000-901a-9b354f2af774','afdd12af-ade2-4444-a88f-7a22a53c37cc','10b1aa61-e654-4afe-b57e-d751f19b2f5c',10,'PowerCatch admin','2016-03-11 15:57:58.262+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.final.check'
insert into konfigurasjon.issuetype_page values ('d6b2b43e-725b-4134-b704-f85d2b001c8c','afdd12af-ade2-4444-a88f-7a22a53c37cc','6bf62319-624f-4816-9226-4962feb982f9',9,'PowerCatch admin','2016-03-11 15:57:58.259+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.completed.work'
insert into konfigurasjon.issuetype_page values ('5e9d844c-5a64-42e1-be17-f0e606befc8b','afdd12af-ade2-4444-a88f-7a22a53c37cc','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b',8,'PowerCatch admin','2016-03-11 15:57:58.253+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.new.meter.mounting'
insert into konfigurasjon.issuetype_page values ('b66fe0c1-5828-448e-8e92-cc0d1e07ac2b','afdd12af-ade2-4444-a88f-7a22a53c37cc','c743e870-d80d-46fb-be38-127ba5da3d6a',7,'PowerCatch admin','2016-03-11 15:57:58.247+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.existing.meter.unmounting'
insert into konfigurasjon.issuetype_page values ('80b84f4b-a15e-492c-aff6-9dee725588ee','7006313c-675f-4c29-9705-0c6dec6bac9f','f3b63b5a-9b9f-473e-a165-6a3f537b0989',11,'PowerCatch admin','2016-03-11 15:57:04.402+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.attachments'
insert into konfigurasjon.issuetype_page values ('951f16a3-3df4-446b-966c-0e65fef522b5','7006313c-675f-4c29-9705-0c6dec6bac9f','10b1aa61-e654-4afe-b57e-d751f19b2f5c',10,'PowerCatch admin','2016-03-11 15:57:04.391+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.final.check'
insert into konfigurasjon.issuetype_page values ('60bf9d4e-d2af-4bc1-b964-89834cd2fbb8','7006313c-675f-4c29-9705-0c6dec6bac9f','6bf62319-624f-4816-9226-4962feb982f9',9,'PowerCatch admin','2016-03-11 15:57:04.389+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.completed.work'
insert into konfigurasjon.issuetype_page values ('a680bf00-638b-45d6-8c70-d03cce6a204d','7006313c-675f-4c29-9705-0c6dec6bac9f','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b',8,'PowerCatch admin','2016-03-11 15:57:04.379+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.new.meter.mounting'
insert into konfigurasjon.issuetype_page values ('0e3dc1c5-4ec6-4756-b510-5c51a73313bb','7006313c-675f-4c29-9705-0c6dec6bac9f','c743e870-d80d-46fb-be38-127ba5da3d6a',7,'PowerCatch admin','2016-03-11 15:57:04.375+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.existing.meter.unmounting'
insert into konfigurasjon.issuetype_page values ('9a737a0c-fc38-49e8-9a87-9da67683699c','9d784c0b-073b-4df7-bf38-70d787e2e885','2b69c427-2618-48c4-8f4c-93da02ce9558',6,'PowerCatch admin','2016-03-11 15:30:29.653+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.mounting.antenna'
insert into konfigurasjon.issuetype_page values ('a0bdc1e3-ed0b-4361-8264-b7f29fd137b0','9d784c0b-073b-4df7-bf38-70d787e2e885','1a270ff3-ec42-4f91-b2d9-8e056b96e790',5,'PowerCatch admin','2016-03-11 15:30:29.651+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.unmounting.antenna'
insert into konfigurasjon.issuetype_page values ('fd36962d-d0bb-4e52-a5ad-d7cc5fa3f4bd','9d784c0b-073b-4df7-bf38-70d787e2e885','afea42b5-feb2-46f9-a94a-ae5e897eeffe',4,'PowerCatch admin','2016-03-11 15:30:29.648+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.meterpoint'
insert into konfigurasjon.issuetype_page values ('2f8649bb-4ceb-47de-b5d4-60dbca81b709','9d784c0b-073b-4df7-bf38-70d787e2e885','7cf691b0-d8b7-4a0c-a855-ec1610afcb38',3,'PowerCatch admin','2016-03-11 15:27:39.439+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.sja'
insert into konfigurasjon.issuetype_page values ('b3709ecc-cee9-4b94-ad9a-fce7c26f125e','9d784c0b-073b-4df7-bf38-70d787e2e885','4f041f44-b539-4eae-8af0-350d1f882dc3',2,'PowerCatch admin','2016-03-11 15:27:39.438+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.installation.data'
insert into konfigurasjon.issuetype_page values ('418bf3b8-b4e4-4fc8-8256-46384618c8c1','9d784c0b-073b-4df7-bf38-70d787e2e885','bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30',1,'PowerCatch admin','2016-03-11 15:27:39.436+01',0); --'PC_ISSUETYPE_SERVICE_CT','pc.page.order.info'
insert into konfigurasjon.issuetype_page values ('5bb16370-1c06-48c0-9e5e-ebf5afd38bd7','afdd12af-ade2-4444-a88f-7a22a53c37cc','2b69c427-2618-48c4-8f4c-93da02ce9558',6,'PowerCatch admin','2016-03-11 15:17:51.628+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.mounting.antenna'
insert into konfigurasjon.issuetype_page values ('42709260-8f6a-4ad6-83cf-05db34ad3429','afdd12af-ade2-4444-a88f-7a22a53c37cc','1a270ff3-ec42-4f91-b2d9-8e056b96e790',5,'PowerCatch admin','2016-03-11 15:17:51.623+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.unmounting.antenna'
insert into konfigurasjon.issuetype_page values ('5e292577-a9e5-4073-a1fc-a3296ecd0dca','7006313c-675f-4c29-9705-0c6dec6bac9f','2b69c427-2618-48c4-8f4c-93da02ce9558',6,'PowerCatch admin','2016-03-11 15:16:46.291+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.mounting.antenna'
insert into konfigurasjon.issuetype_page values ('12b31c63-5189-4df3-92bb-41ca6335ed4c','7006313c-675f-4c29-9705-0c6dec6bac9f','1a270ff3-ec42-4f91-b2d9-8e056b96e790',5,'PowerCatch admin','2016-03-11 15:16:46.287+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.unmounting.antenna'
insert into konfigurasjon.issuetype_page values ('d07164c0-6633-4114-b707-80ee1f0c9d57','afdd12af-ade2-4444-a88f-7a22a53c37cc','57ac4954-9d67-4546-95f8-e9925465594f',4,'PowerCatch admin','2016-03-11 13:52:44.594+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.meterpoint'
insert into konfigurasjon.issuetype_page values ('88370109-9b55-44c8-9fdb-852fd5173063','afdd12af-ade2-4444-a88f-7a22a53c37cc','7cf691b0-d8b7-4a0c-a855-ec1610afcb38',3,'PowerCatch admin','2016-03-11 13:52:44.591+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.sja'
insert into konfigurasjon.issuetype_page values ('8cf59024-d4aa-4440-a694-4ffc764d62bf','afdd12af-ade2-4444-a88f-7a22a53c37cc','4f041f44-b539-4eae-8af0-350d1f882dc3',2,'PowerCatch admin','2016-03-11 13:52:44.588+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.installation.data'
insert into konfigurasjon.issuetype_page values ('834600e7-dcb7-4db1-a42a-81ec8ef29955','afdd12af-ade2-4444-a88f-7a22a53c37cc','bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30',1,'PowerCatch admin','2016-03-11 13:52:44.562+01',0); --'PC_ISSUETYPE_SERVICE_SUBSTATION','pc.page.order.info'
insert into konfigurasjon.issuetype_page values ('30f8e3f6-b334-4528-adb1-4291bbe55dd8','7006313c-675f-4c29-9705-0c6dec6bac9f','57ac4954-9d67-4546-95f8-e9925465594f',4,'PowerCatch admin','2016-03-11 13:46:24.741+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.meterpoint'
insert into konfigurasjon.issuetype_page values ('652c2eff-563d-4f2c-8502-b309ae8a5449','7006313c-675f-4c29-9705-0c6dec6bac9f','7cf691b0-d8b7-4a0c-a855-ec1610afcb38',3,'PowerCatch admin','2016-03-11 13:45:32.985+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.sja'
insert into konfigurasjon.issuetype_page values ('180f6e29-b7c7-41eb-bd0f-20d14e7443e3','7006313c-675f-4c29-9705-0c6dec6bac9f','4f041f44-b539-4eae-8af0-350d1f882dc3',2,'PowerCatch admin','2016-03-11 13:42:39.481+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.installation.data'
insert into konfigurasjon.issuetype_page values ('4f628a53-c9db-4ac5-a3e1-15ddf890e413','7006313c-675f-4c29-9705-0c6dec6bac9f','bddfd19e-be03-4a4e-8b87-7d7fcdb5dd30',1,'PowerCatch admin','2016-03-11 13:41:47.317+01',0); --'PC_ISSUETYPE_SERVICE','pc.page.order.info'

-- page_fieldproperty
insert into konfigurasjon.page_fieldproperty values ('0fa6553f-7825-45b8-9c0b-11c70c770c9d','c743e870-d80d-46fb-be38-127ba5da3d6a','d54bd9e4-78f8-4b1d-829b-e7ebf7428f70',4,'PowerCatch admin','2016-03-13 22:20:21.09+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('a973529b-4aaf-4702-aee0-0d3eb9b078fe','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','fdf514f0-0e5f-461d-8cd0-45591fb0b69e',1,'PowerCatch admin','2016-03-13 22:14:49.558+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_METER_SERIAL_NUMBER'
insert into konfigurasjon.page_fieldproperty values ('801d3a9d-8661-464f-a5d5-e8649ad99bbf','6bf62319-624f-4816-9226-4962feb982f9','4cce9941-47b5-4beb-a34d-f0149af05b0b',2,'PowerCatch admin','2016-03-13 22:01:06.144+01',0); --'pc.page.completed.work','PC_WORKTASK_DESCRIPTION'
insert into konfigurasjon.page_fieldproperty values ('be2b970d-efb4-4575-948a-c05aedf05e02','6bf62319-624f-4816-9226-4962feb982f9','62d11a06-72f8-4bab-8a93-a7f8951464e9',1,'PowerCatch admin','2016-03-13 22:01:06.142+01',0); --'pc.page.completed.work','PC_WORKTASK_TYPE'
insert into konfigurasjon.page_fieldproperty values ('a9b6e901-c592-4c91-a686-f596e718e12d','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','cb764a62-31d5-46a4-b3ee-e3e0668d7dc7',14,'PowerCatch admin','2016-03-11 15:56:18.793+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('292a9bd9-f9a9-42d3-ac00-41ec83ca418e','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','8dba3475-42de-4979-9643-2b577b35e51c',13,'PowerCatch admin','2016-03-11 15:56:18.791+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('adc241d3-05c8-4576-8db1-8a3ffb1bf950','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','479cd743-35ca-4a2c-92ae-ea3fbcc1e726',12,'PowerCatch admin','2016-03-11 15:56:18.789+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('6fb03a6b-8ae3-41da-9e86-661549338867','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','4ec286c4-a587-43e9-96ca-aafbbd4f103b',11,'PowerCatch admin','2016-03-11 15:56:18.786+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('216033ca-9220-4f34-97d8-96d86b6adaad','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','fd91ea18-9126-4079-a170-4cb380c88d49',10,'PowerCatch admin','2016-03-11 15:56:18.783+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('2ac0173e-04f1-424c-a938-d23c8eb8729f','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','088b7421-cc6f-4572-a4e0-3013fb57dca1',9,'PowerCatch admin','2016-03-11 15:56:18.781+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('8fb3fef7-ea26-40e1-8760-bafab8820963','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','f8c8bded-37f4-4f9f-b29f-33f4636ff1d7',8,'PowerCatch admin','2016-03-11 15:56:18.779+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('931c66c5-03cd-45ef-9c91-c7d884d0fcf0','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','ca8330e3-cc98-4bc6-bf54-6f637e2320b5',7,'PowerCatch admin','2016-03-11 15:56:18.776+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('136ebc0d-61e0-4320-a520-8dd00a44ed26','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','b97ad7bf-8b3f-4386-a9f7-019ea28a4f10',6,'PowerCatch admin','2016-03-11 15:56:18.774+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('dbbf6e9a-a155-405c-90bd-2c3b7e922088','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','32f2d6c2-c4d3-4bf8-84bc-9fad0976b349',5,'PowerCatch admin','2016-03-11 15:56:18.772+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('b02b9b06-b057-45a4-96fc-d7a831e83f70','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','17bf0852-a794-4b39-9b12-07e5332d3a9b',4,'PowerCatch admin','2016-03-11 15:56:18.769+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('0fbbfcfc-1259-48b8-91ce-73c5d71d0d6b','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','a5183a73-d791-4909-9de8-188819cb37fe',3,'PowerCatch admin','2016-03-11 15:56:18.764+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('7f35aae7-09ca-45b4-bf6a-50f68a4332d2','d60b4ce8-b763-4fc3-a025-5bbfd5d93d4b','764abfff-2380-4acf-bf97-75fef1ca2952',2,'PowerCatch admin','2016-03-11 15:56:18.75+01',0); --'pc.page.new.meter.mounting','PC_NEW_METER_STATE_SIM_CARD_SERIAL_NUMBER'
insert into konfigurasjon.page_fieldproperty values ('cf058669-cc2f-44d5-9c2b-ae973587ae6e','c743e870-d80d-46fb-be38-127ba5da3d6a','a869ff5d-4235-44da-8817-4a719e6c0e51',14,'PowerCatch admin','2016-03-11 15:52:50.774+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('e5ecb0de-d915-4d0c-a4be-f2bdbf6b32a9','c743e870-d80d-46fb-be38-127ba5da3d6a','7e516fa9-6720-41ce-a0ef-5b5b4d374603',13,'PowerCatch admin','2016-03-11 15:52:50.772+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('1878813b-9006-4548-aaf1-fa6f8bb36ca6','c743e870-d80d-46fb-be38-127ba5da3d6a','ab2ff314-745a-40e5-959d-908844484e58',12,'PowerCatch admin','2016-03-11 15:52:50.77+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_REACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('0553893f-908e-49a3-981c-1770f7d95871','c743e870-d80d-46fb-be38-127ba5da3d6a','64957542-a720-4837-9273-f67a273104b5',11,'PowerCatch admin','2016-03-11 15:52:50.768+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('b950975d-0e14-4f99-b478-4e3017252091','c743e870-d80d-46fb-be38-127ba5da3d6a','a7e237aa-32f8-4830-9ce9-fedb7cce46fb',10,'PowerCatch admin','2016-03-11 15:52:50.756+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('48b5c7af-7dd8-480f-9e24-cc5e8764093d','c743e870-d80d-46fb-be38-127ba5da3d6a','05be989f-9e78-4455-bd8f-19efa9ae158a',9,'PowerCatch admin','2016-03-11 15:52:50.751+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_REACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('5ca1913d-4086-4ed5-a2ed-5f51a0051bd9','c743e870-d80d-46fb-be38-127ba5da3d6a','c2abf9a0-e21f-4081-bab3-aa78de93a996',8,'PowerCatch admin','2016-03-11 15:52:50.749+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('9cbe69c5-5d6e-4da9-a916-95d1536e5afa','c743e870-d80d-46fb-be38-127ba5da3d6a','905b0962-9b00-4d3e-bd75-062d8d4dfc5a',7,'PowerCatch admin','2016-03-11 15:52:50.748+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_VALUE'
insert into konfigurasjon.page_fieldproperty values ('f7f152a0-76c3-436b-a2aa-e95cf0c03953','c743e870-d80d-46fb-be38-127ba5da3d6a','b27d0c98-ce1f-4c9e-80af-0c9a89fd1eb3',6,'PowerCatch admin','2016-03-11 15:52:50.745+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_PRODUCTION_ACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('7d7e0151-a896-4282-9a74-56560b083c3f','c743e870-d80d-46fb-be38-127ba5da3d6a','f6ea90be-890e-493f-b94c-f99883d561a7',5,'PowerCatch admin','2016-03-11 15:52:50.743+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME'
insert into konfigurasjon.page_fieldproperty values ('0b43baf1-45cc-4538-a60a-06340d3ab087','c743e870-d80d-46fb-be38-127ba5da3d6a','5e1788a0-89ce-47ca-8e19-7d90c256aaa9',3,'PowerCatch admin','2016-03-11 15:52:50.739+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_UNIT'
insert into konfigurasjon.page_fieldproperty values ('fb315ae4-32af-415f-b566-2bb815bc227d','c743e870-d80d-46fb-be38-127ba5da3d6a','d7516a80-1965-4d08-b899-50977c63c5e1',1,'PowerCatch admin','2016-03-11 15:52:50.737+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_METER_SERIAL_NUMBER'
insert into konfigurasjon.page_fieldproperty values ('f54a106c-4983-4fcd-83bb-a1270c83b9eb','c743e870-d80d-46fb-be38-127ba5da3d6a','f25b8f1f-25aa-4f34-848c-d29ecdadfb56',2,'PowerCatch admin','2016-03-11 15:52:50.734+01',0); --'pc.page.existing.meter.unmounting','PC_EXISTING_METER_STATE_SIM_CARD_SERIAL_NUMBER'
insert into konfigurasjon.page_fieldproperty values ('ff2b2c95-9388-4979-a80c-ffc739113d9d','1a270ff3-ec42-4f91-b2d9-8e056b96e790','95eacf43-193a-46f5-b0c5-a6045ac6a651',8,'PowerCatch admin','2016-03-11 15:05:13.314+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE'
insert into konfigurasjon.page_fieldproperty values ('727aeafb-79c7-43bc-9569-32ab6e9fb18e','1a270ff3-ec42-4f91-b2d9-8e056b96e790','c015f676-e072-41f6-9f26-d4b7774d69ac',7,'PowerCatch admin','2016-03-11 15:04:36.985+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE'
insert into konfigurasjon.page_fieldproperty values ('145d8cf9-4318-4599-82dd-a10d9bc9d0e1','1a270ff3-ec42-4f91-b2d9-8e056b96e790','6411227e-d9e2-43d4-a01d-c4867552e2f0',6,'PowerCatch admin','2016-03-11 15:03:55.803+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE'
insert into konfigurasjon.page_fieldproperty values ('19c5d66d-cf67-426c-8003-c6ad029422be','1a270ff3-ec42-4f91-b2d9-8e056b96e790','57627a00-44c4-4671-afa8-265ee0cbde77',5,'PowerCatch admin','2016-03-11 15:03:18.777+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE'
insert into konfigurasjon.page_fieldproperty values ('7034727c-f073-4fd6-9371-891a23c69e2f','1a270ff3-ec42-4f91-b2d9-8e056b96e790','f76d0fed-a736-4437-9424-7601a110a7e8',4,'PowerCatch admin','2016-03-11 15:02:38.964+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE'
insert into konfigurasjon.page_fieldproperty values ('a74841b4-4f78-42d7-a2a1-5c053ca24604','1a270ff3-ec42-4f91-b2d9-8e056b96e790','cd554e4f-7b68-4ce1-8f36-3f04cf6be945',3,'PowerCatch admin','2016-03-11 15:01:56.49+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE'
insert into konfigurasjon.page_fieldproperty values ('2b833a4c-0fa3-4638-9ddb-6ff0d04dae3c','1a270ff3-ec42-4f91-b2d9-8e056b96e790','5f12fb2a-0c30-451b-98e3-50f018664924',2,'PowerCatch admin','2016-03-11 15:00:31.865+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE'
insert into konfigurasjon.page_fieldproperty values ('2204644d-b6ac-4bbd-bf1f-28d4601315e8','1a270ff3-ec42-4f91-b2d9-8e056b96e790','d2a58204-1358-4a07-8c56-05b53d3321b7',1,'PowerCatch admin','2016-03-11 14:59:36.347+01',0); --'pc.page.unmounting.antenna','PC_EXISTING_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE'
insert into konfigurasjon.page_fieldproperty values ('d21f4ccc-aa02-419c-a63c-ccc22c344ae9','2b69c427-2618-48c4-8f4c-93da02ce9558','5b022a24-79c0-42e0-9f60-15522c2073e9',8,'PowerCatch admin','2016-03-11 14:52:07.848+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE'
insert into konfigurasjon.page_fieldproperty values ('0213022b-a7c0-4e4e-ae50-6c4028a1d2c4','2b69c427-2618-48c4-8f4c-93da02ce9558','3d4bbeb9-aee4-4a81-80af-463b190a32a9',7,'PowerCatch admin','2016-03-11 14:52:07.845+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_OUTBOUND_ANTENNA_STATE_REDUCER_TYPE'
insert into konfigurasjon.page_fieldproperty values ('07dfc98d-30fd-49ab-8ae5-b2d6991a599b','2b69c427-2618-48c4-8f4c-93da02ce9558','6996069d-b176-4714-8f33-63d34a1763e5',6,'PowerCatch admin','2016-03-11 14:52:07.836+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_OUTBOUND_ANTENNA_STATE_CABEL_TYPE'
insert into konfigurasjon.page_fieldproperty values ('7e2a3a4f-2603-435f-bacf-652f8f3b5ec0','2b69c427-2618-48c4-8f4c-93da02ce9558','cd656a9b-9c5d-43ab-9413-3013066352b9',5,'PowerCatch admin','2016-03-11 14:52:07.834+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_PLACEMENT_CODE'
insert into konfigurasjon.page_fieldproperty values ('ecc3968f-904a-4e58-9a2b-d73bf2fa7eb2','2b69c427-2618-48c4-8f4c-93da02ce9558','c8db967b-c3f8-4ecf-baab-dfbe21135576',4,'PowerCatch admin','2016-03-11 14:52:07.831+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_INBOUND_ANTENNA_STATE_REDUCER_TYPE'
insert into konfigurasjon.page_fieldproperty values ('78297d25-7051-45fc-a30a-4a901b884ef7','2b69c427-2618-48c4-8f4c-93da02ce9558','81ca1545-c5f1-447a-b2fa-d4d74eeaead3',3,'PowerCatch admin','2016-03-11 14:52:07.829+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_INBOUND_ANTENNA_STATE_CABEL_TYPE'
insert into konfigurasjon.page_fieldproperty values ('433f7d4e-c65c-40cd-b750-05fba5c5cd1f','2b69c427-2618-48c4-8f4c-93da02ce9558','bb7966a9-361f-4f9e-9ae8-713ceef26fba',2,'PowerCatch admin','2016-03-11 14:52:07.827+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_OUTBOUND_ANTENNA_STATE_ANTENNA_TYPE'
insert into konfigurasjon.page_fieldproperty values ('fc43b63c-fa4c-4fc1-84e7-6ae26a464cf9','2b69c427-2618-48c4-8f4c-93da02ce9558','743ec458-879f-45fb-9e1e-250c3c564ea1',1,'PowerCatch admin','2016-03-11 14:52:07.817+01',0); --'pc.page.mounting.antenna','PC_NEW_METER_INBOUND_ANTENNA_STATE_ANTENNA_TYPE'
