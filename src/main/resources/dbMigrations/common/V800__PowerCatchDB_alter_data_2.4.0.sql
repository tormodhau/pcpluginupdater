SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

\connect powercatch


INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (88, 'mobileclient_autosync_on_complete', 'false', 'admin', NULL, 'powercatch', 0);

-- This value should always be the same as the last id we insert manually
SELECT pg_catalog.setval('konfigurasjon.config_server_values_id_seq', 88, true);


-- Insert new meter replacement issuetype 
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('4b252da2-5a38-4c15-940e-6fd7033d3d10','PC_ISSUETYPE_METER_REPLACEMENT', 'PPT', 0, 'summary', 'PowerCatch Update Script');

-- Insert new pages
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('77562310-d45c-4400-b71f-7d5d334c10a7', 'pc.page.customerdata', NULL, 'PowerCatch Update Script', 106);
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('3acc5fd5-602e-48f2-aedd-0440491fbcfb', 'pc.page.installation.data', NULL, 'PowerCatch Update Script', 107);
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('a998c50a-21f4-4c8d-895f-2b524f6d8e82', 'pc.page.measure.equipment', NULL, 'PowerCatch Update Script', 108);
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('fbc82b7f-159d-4da9-afbc-c0c96978283e', 'pc.page.order.info', NULL, 'PowerCatch Update Script', 109);

-- Insert new fields
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7b3483b4-d84f-42ec-bba8-4a06ee0869af', NULL, 'PC_INSTALLATION_STREET_NO', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('e4aad805-6426-46fa-841a-3579ad637109', NULL, 'PC_METER_NUMBER', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('7d8c04ab-dad6-43e2-affe-eb25478c5422', NULL, 'PC_OLD_METER_READING', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('d4437ec5-01d4-4f7a-a3e9-aef3f45cc631', NULL, 'PC_REGISTERED_VOLTAGE2', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('683e847a-4f12-4b8b-ab5a-31130fd8a8a6', NULL, 'PC_BOOKING_ORDER', NULL, 'PowerCatch Update Script');


-- Insert field property for new fields
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('93bc6821-7f29-4f5b-b987-26830d6a18f8', '', 0, NULL, NULL, '7b3483b4-d84f-42ec-bba8-4a06ee0869af', 'PowerCatch Update Script'); -- PC_INSTALLATION_STREET_NO-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('cb9e039e-a1f9-49aa-afe6-aba86fe968d9', '', 1, 1, NULL, 'e4aad805-6426-46fa-841a-3579ad637109', 'PowerCatch Update Script', 1,1,1); -- PC_METER_NUMBER-properties (Ny målers målernummer)
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, scannable, hide_values, cross_validation) VALUES ('9fb374c7-da6c-49f9-9147-c356625cb418', '', 1, 1, NULL, '7d8c04ab-dad6-43e2-affe-eb25478c5422', 'PowerCatch Update Script', 1,1,1); -- PC_OLD_METER_READING-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('a7fdcba9-f57f-45ef-8903-ee2229d35b7f', '', 1, 1, NULL, 'd4437ec5-01d4-4f7a-a3e9-aef3f45cc631', 'PowerCatch Update Script'); -- PC_REGISTERED_VOLTAGE2-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('d963c52b-3079-4ac5-a3ab-8ead9c472546', '', 0, 0, NULL, '683e847a-4f12-4b8b-ab5a-31130fd8a8a6', 'PowerCatch Update Script'); -- PC_BOOKING_ORDER-properties

-- Ordre info
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('0ae5c893-708c-4fc8-8e6b-ffea4abbd37c', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', '15aadd9c-611b-44da-9525-c01029a583ea', 1, 'PowerCatch Update Script'); -- summary-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b32b6376-891a-45b2-ac3d-dbc83a3eab91', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', '4a019e67-69be-4a0a-82f3-5ac65780db35', 2, 'PowerCatch Update Script'); -- description-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('00c54e8a-763a-49de-af51-9df72053793c', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', '2c44e699-173c-4091-9a5c-873e459618a3', 3, 'PowerCatch Update Script'); -- PC_PLANNED_DATE-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('9c50928b-07f7-4e29-8d51-6cf722f8c605', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', 'd963c52b-3079-4ac5-a3ab-8ead9c472546', 4, 'PowerCatch Update Script'); -- PC_BOOKING_ORDER-properties on page


-- field on page-- page customerdata
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('ae6f34fd-7ba2-4f54-aa99-f13d6589e924', '77562310-d45c-4400-b71f-7d5d334c10a7', 'b1de6368-e72b-4db6-8d7d-9a88b5dae3d0', 1, 'PowerCatch Update Script'); -- PC_CUSTOMER_NAME-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('48eaa452-b238-4aed-97c6-fd129bc8e29b', '77562310-d45c-4400-b71f-7d5d334c10a7', '55254909-80a4-44a3-b5f5-4339413e6b27', 2, 'PowerCatch Update Script'); -- "PC_CUSTOMER_MOBILE"-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('cbf06eff-bf03-4954-975d-cc07f7a9593d', '77562310-d45c-4400-b71f-7d5d334c10a7', 'abbcbe8c-d6f3-41da-bca4-810eee92b16f', 3, 'PowerCatch Update Script'); -- "PC_CUSTOMER_EMAIL"-properties on page

-- field on page-- page anleggsdata
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d7e4cb80-d6b9-4221-94e1-96dbaccd3137', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', 'd6d21257-30f3-4e6c-9bf4-e2e503ab79f5', 1, 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e7cd83d2-7877-44bf-8e13-982ed80356fc', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', '93bc6821-7f29-4f5b-b987-26830d6a18f8', 2, 'PowerCatch Update Script'); -- PC_INSTALLATION_STREET_NO-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b425f53e-e1e8-449d-9784-d916b857fb52', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', '84e10dc1-9463-400d-8614-d947ca066e13', 3, 'PowerCatch Update Script'); -- PC_INSTALLATION_ZIPCODE-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('d82d1673-2ab4-4ae7-9e35-5012fdd776d1', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', '51d7ece3-cec1-4444-93c1-cd7d7ecfb5ef', 4, 'PowerCatch Update Script'); -- PC_INSTALLATION_CITY-properties on page

-- FERDIG field on page-- page målerdata
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('f51f5db8-02e6-4710-b4a5-f9b148eab159', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', '97594e2d-e0ab-4338-ac33-a8bcacf2f26c', 1, 'PowerCatch Update Script'); -- PC_METER_ID-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('68b50e5c-2cf1-4165-9d2d-5c7faddf26f1', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', '9fb374c7-da6c-49f9-9147-c356625cb418', 2, 'PowerCatch Update Script'); -- PC_OLD_METER_READING-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('4d2d79b6-ba95-4c18-a72f-6a14500e5e7d', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', 'cac3b0be-b8a3-4713-ba46-d64381151ea7', 3, 'PowerCatch Update Script'); -- PC_NEW_METER_TYPE-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('55504c42-e1c6-4dbd-9128-93e9841cb691', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', 'cb9e039e-a1f9-49aa-afe6-aba86fe968d9', 4, 'PowerCatch Update Script'); -- PC_METER_NUMBER-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('73942aa6-2768-41d1-be59-e181c77d0e2f', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', '60716744-b2ad-4327-9b71-1989e5815973', 5, 'PowerCatch Update Script'); -- PC_NEW_METER_READING-properties on page

-- Connect issuetype and pages
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('81d641bb-7609-4b3e-87e1-771889d6e65f', '4b252da2-5a38-4c15-940e-6fd7033d3d10', 'fbc82b7f-159d-4da9-afbc-c0c96978283e', 1, 'PowerCatch Update Script'); --ordreinfo data data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('2f098b46-8fee-492c-9729-9c189c8e1918', '4b252da2-5a38-4c15-940e-6fd7033d3d10', '77562310-d45c-4400-b71f-7d5d334c10a7', 2, 'PowerCatch Update Script'); --customer data data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('50e32a27-0bb3-49c4-9665-175f1927d5ce', '4b252da2-5a38-4c15-940e-6fd7033d3d10', '3acc5fd5-602e-48f2-aedd-0440491fbcfb', 3, 'PowerCatch Update Script'); --object data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('0ef4fc07-c743-44da-a734-356819628185', '4b252da2-5a38-4c15-940e-6fd7033d3d10', 'a998c50a-21f4-4c8d-895f-2b524f6d8e82', 4, 'PowerCatch Update Script'); --meterdata data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7ae85b73-e0d2-4977-a761-25cb48f41058', '4b252da2-5a38-4c15-940e-6fd7033d3d10', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 5, 'PowerCatch Update Script'); --Attachments page data


INSERT INTO konfigurasjon.config_server_values (id, key, value, changed_by, reference_element, company_key, deleted) VALUES (89, 'mobileclient_default_sorting_on_device', 'SORTER_DEFAULT_KEY', 'admin', NULL, 'powercatch', 0);
-- This value should always be the same as the last id we insert manually
SELECT pg_catalog.setval('konfigurasjon.config_server_values_id_seq', 89, true);


-- Change sortorder, PC-3036
UPDATE konfigurasjon.issuetype_page SET sortorder=8, changed_by='PowerCatch Update Script 2.4' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 7;
UPDATE konfigurasjon.issuetype_page SET sortorder=7, changed_by='PowerCatch Update Script 2.4' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 6;
UPDATE konfigurasjon.issuetype_page SET sortorder=6, changed_by='PowerCatch Update Script 2.4' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 5;
UPDATE konfigurasjon.issuetype_page SET sortorder=5, changed_by='PowerCatch Update Script 2.4' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 4;
UPDATE konfigurasjon.issuetype_page SET sortorder=4, changed_by='PowerCatch Update Script 2.4' WHERE id_issuetype = '78a83cf4-e305-422a-9cf9-8eb752333691' AND sortorder = 3 AND id_page = '03edfc1f-7663-e593-0151-d7a512cab832';


