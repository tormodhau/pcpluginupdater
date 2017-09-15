
--------- VOKKS oppsett -------



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


-- Insert new meter replacement issuetype for test
INSERT INTO konfigurasjon.issuetype (id, name, project_key, new_issue_enabled, summary_field, changed_by) VALUES ('42de41da-2012-441b-9cce-8c7e3126b8ed','PC_ISSUETYPE_METER_REPLACEMENT', 'TEST', 0, 'summary', 'PowerCatch Update Script');

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('683e847a-4f12-4b8b-ab5a-31130fd8a8a6', NULL, 'PC_BOOKING_ORDER', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('d963c52b-3079-4ac5-a3ab-8ead9c472546', '', 0, 0, NULL, '683e847a-4f12-4b8b-ab5a-31130fd8a8a6', 'PowerCatch Update Script'); -- PC_BOOKING_ORDER-properties

-- Generert
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', 'pc.page.order.info', 0, 'PowerCatch Update Script', 110);
-- Ordre info -- Generert
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b4812a8e-6d7d-4bf1-809a-56c0926d0597', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', '15aadd9c-611b-44da-9525-c01029a583ea', 1, 'PowerCatch Update Script'); -- summary-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('6e1b2a56-be22-4512-a54c-19ad8438c0a9', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', '4a019e67-69be-4a0a-82f3-5ac65780db35', 2, 'PowerCatch Update Script'); -- description-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('86bc0406-d1c0-4bad-aca0-6e6f2d84874b', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', '2c44e699-173c-4091-9a5c-873e459618a3', 3, 'PowerCatch Update Script'); -- PC_PLANNED_DATE-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('3a8cec31-678b-4f1c-b546-1511f1ad0b76', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', 'd11aa057-050d-4673-a5b3-43244be6a0a0', 4, 'PowerCatch Update Script'); -- timetrackin-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('c06372c1-fc77-45d2-b6ab-d15f0629cc86', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', 'd963c52b-3079-4ac5-a3ab-8ead9c472546', 5, 'PowerCatch Update Script'); -- PC_BOOKING_ORDER-properties on page





-- Generert
INSERT INTO konfigurasjon.page (id, name, signaturerequired, changed_by, nbr) VALUES ('dec6479c-8d22-4417-ad75-ea22bd4d5a30', 'pc.page.installation.data', 0, 'PowerCatch Update Script', 111);

-- Generert
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('84d95327-d53c-4029-b9ee-acf82a1c78f5', NULL, 'PC_METERPOINT_ID', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('64076d6e-3912-4706-8c1d-7eda5d056089', NULL, 'PC_METERPOINT_INSTALLATIONID', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('545c393c-979a-4d22-b195-2e1a568b0a65', NULL, 'PC_CUSTOMER_ADDRESSCOMMENT', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('a412bce1-251c-4f0c-b2ab-fc9b5880939b', NULL, 'PC_INSTALLATION_ADDRESS_ZIPCODE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('b8466ce3-398a-40f4-ba4d-38d4a6f5746e', NULL, 'PC_INSTALLATION_ADDRESS_CITY_NAME', NULL, 'PowerCatch Update Script');
--Finnes 
--"2da613f2-5986-418a-a60f-eed5728389fe";"";"PC_INSTALLATION_ADDRESS"
--"c39018e5-b1d1-4713-9171-fcd7c6ac763f";"";"PC_CUSTOMER_MOBILE"
--"178ac866-4348-49bb-ada4-752c940ad12d";"";"PC_CUSTOMER_NAME"
--"d4034a39-fe17-40d8-9a43-95f74e4f1c08";"";"PC_INSTALLATION_DESCRIPTION"
--"446bddae-dd60-49ea-b33a-1b911243c30b";"";"PC_CUSTOMER_PHONE"

-- Generert
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('a73475cd-79fd-4ce9-b719-54e7cfce01e7', '', 0, NULL, NULL, '84d95327-d53c-4029-b9ee-acf82a1c78f5', 'PowerCatch Update Script'); -- PC_METERPOINT_ID-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('0adc60de-f902-45a4-9eeb-b49385fcd098', '', 0, NULL, NULL, '64076d6e-3912-4706-8c1d-7eda5d056089', 'PowerCatch Update Script'); -- PC_METERPOINT_INSTALLATIONID-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('0249aaaa-6d22-43b3-a2cf-ccb874ff2605', '', 0, NULL, NULL, '545c393c-979a-4d22-b195-2e1a568b0a65', 'PowerCatch Update Script'); -- PC_CUSTOMER_ADDRESSCOMMENT-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('1041f2fe-4e39-4714-aded-0159d5c8894c', '', 0, NULL, NULL, 'a412bce1-251c-4f0c-b2ab-fc9b5880939b', 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS_ZIPCODE-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('f809f048-b053-4ba0-a447-bd61862f03a6', '', 0, NULL, NULL, 'b8466ce3-398a-40f4-ba4d-38d4a6f5746e', 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS_CITY_NAME-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('d69f04e6-5236-4aef-b1b0-e7b8c3ae97f7', '', 0, NULL, NULL, '2da613f2-5986-418a-a60f-eed5728389fe', 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('4a76410f-670b-4b02-baeb-8bc1c6f33b9f', '', 0, NULL, NULL, 'c39018e5-b1d1-4713-9171-fcd7c6ac763f', 'PowerCatch Update Script'); -- PC_CUSTOMER_MOBILE-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('4cc810f4-0880-4c93-9161-56a38d0dcd37', '', 0, NULL, NULL, '178ac866-4348-49bb-ada4-752c940ad12d', 'PowerCatch Update Script'); -- PC_CUSTOMER_NAME-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('e1bcca27-2f61-4096-8515-07efab63bfc7', '', 0, NULL, NULL, 'd4034a39-fe17-40d8-9a43-95f74e4f1c08', 'PowerCatch Update Script'); -- PC_INSTALLATION_DESCRIPTION-properties
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('06585611-6810-4d51-9fa8-8835ae4da942', '', 0, NULL, NULL, '446bddae-dd60-49ea-b33a-1b911243c30b', 'PowerCatch Update Script'); -- PC_CUSTOMER_PHONE-properties


-- Generert
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b9ca49ae-d658-47cb-834a-bb13e17d0e26', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', 'a73475cd-79fd-4ce9-b719-54e7cfce01e7', 1, 'PowerCatch Update Script'); --PC_METERPOINT_ID
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('b2ea4397-2f15-4b19-b271-e150593de1cb', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', '0adc60de-f902-45a4-9eeb-b49385fcd098', 2, 'PowerCatch Update Script'); -- PC_METERPOINT_INSTALLATIONID
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('29e2dc17-80a0-4742-86f4-544ec59f69d5', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', '0249aaaa-6d22-43b3-a2cf-ccb874ff2605', 3, 'PowerCatch Update Script'); -- PC_CUSTOMER_ADDRESSCOMMENT
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('51c1159a-f4c8-4a62-84b9-b1c6500d6496', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', 'd69f04e6-5236-4aef-b1b0-e7b8c3ae97f7', 4, 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('12643ea7-6731-49bb-80cd-3c95fe2ed6d9', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', '1041f2fe-4e39-4714-aded-0159d5c8894c', 5, 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS_ZIPCODE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('04791866-d9bd-4abc-bf0d-f9c822eb2db4', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', 'f809f048-b053-4ba0-a447-bd61862f03a6', 6, 'PowerCatch Update Script'); -- PC_INSTALLATION_ADDRESS_CITY_NAME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('41467b0f-8e80-4f66-bb95-c151ae4616c8', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', 'e1bcca27-2f61-4096-8515-07efab63bfc7', 7, 'PowerCatch Update Script'); -- PC_INSTALLATION_DESCRIPTION
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('028c2a86-df8a-4a6d-a799-4de58056127f', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', '4cc810f4-0880-4c93-9161-56a38d0dcd37', 8, 'PowerCatch Update Script'); -- PC_CUSTOMER_NAME
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('5a5ce4c5-0a1c-4508-876c-dcc22033236c', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', '4a76410f-670b-4b02-baeb-8bc1c6f33b9f', 9, 'PowerCatch Update Script'); -- PC_CUSTOMER_MOBILE
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('5dc0dbc8-21a1-472c-8e57-90e6eeb19591', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', '06585611-6810-4d51-9fa8-8835ae4da942', 10, 'PowerCatch Update Script'); -- PC_CUSTOMER_PHONE

-- Connect issuetype and pages
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('16070acd-5e5d-4201-983e-2b0973f2557d', '42de41da-2012-441b-9cce-8c7e3126b8ed', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', 1, 'PowerCatch Update Script'); --ordreinfo data data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('7322d273-0974-4a24-abda-3f67420095e6', '42de41da-2012-441b-9cce-8c7e3126b8ed', 'dec6479c-8d22-4417-ad75-ea22bd4d5a30', 2, 'PowerCatch Update Script'); --anleggsdata data
INSERT INTO konfigurasjon.issuetype_page (id, id_issuetype, id_page, sortorder, changed_by) VALUES ('934a9351-a27a-4e11-8d0d-2a702a4c89cb', '42de41da-2012-441b-9cce-8c7e3126b8ed', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 3, 'PowerCatch Update Script'); --Attachments page data

--PC-2121
--Endret fra timetracking til timeoriginalestimate


--PC-3175 Nye felter ut på mobilen.
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('96882cb6-5fc8-46d2-a8ed-2ff5af97b455', NULL, 'PC_INBOUND_ANTENNA_STATE_ANTENNA_TYPE', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('628f533c-9769-4edf-82b3-c283a9640000', '', 0, 0, NULL, '96882cb6-5fc8-46d2-a8ed-2ff5af97b455', 'PowerCatch Update Script'); -- PC_INBOUND_ANTENNA_STATE_ANTENNA_TYPE (Antenne)

INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('44917630-1aa7-4e8b-bc58-ba2baee883d5', NULL, 'PC_METERPOINT_PHASES', NULL, 'PowerCatch Update Script');
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by) VALUES ('3878eaa9-8690-495c-843d-81be6955e709', '', 0, 0, NULL, '44917630-1aa7-4e8b-bc58-ba2baee883d5', 'PowerCatch Update Script'); -- PC_METERPOINT_PHASES (Antall faser)

INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('e82d1659-a985-43d8-9206-b8a8c9a10d20', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', '628f533c-9769-4edf-82b3-c283a9640000', 6, 'PowerCatch Update Script'); -- PC_INBOUND_ANTENNA_STATE_ANTENNA_TYPE-properties on page
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('8475fc52-63f6-42e6-8661-0a4eee28de73', 'e2a015a0-0422-41c7-ad66-2dfc7ab2b3dd', '3878eaa9-8690-495c-843d-81be6955e709', 7, 'PowerCatch Update Script'); -- PC_METERPOINT_PHASES-properties on page
