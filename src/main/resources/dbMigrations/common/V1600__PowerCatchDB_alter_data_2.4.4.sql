SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


-- PC-3329 Markering av viktig informasjon p� arbeidsordre
--   Legger til skjult felt PC_IMPORTANT_INFO
-- Insert new fields
INSERT INTO konfigurasjon.field (id, nbr, name, customfieldid, changed_by) VALUES ('edc14f8d-ef20-9600-251c-2cd5e6ef18c5', NULL, 'PC_IMPORTANT_INFO', NULL, 'PowerCatch Update Script 2.4.4');

-- Insert field property for new fields
INSERT INTO konfigurasjon.fieldproperty (id, label, editable, hidden, required, checkboxvalidationid, id_field, changed_by) VALUES ('b1400988-c593-d93a-76e5-b4eec73bbcc7', '', 0, 1, NULL, NULL, 'edc14f8d-ef20-9600-251c-2cd5e6ef18c5', 'PowerCatch Update Script 2.4.4'); -- PC_IMPORTANT_INFO-properties

-- Insert field on attachments-page (field is hidden)
INSERT INTO konfigurasjon.page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by) VALUES ('0eb6c76c-04a3-0a89-53de-2815b71a0747', 'f3b63b5a-9b9f-473e-a165-6a3f537b0989', 'b1400988-c593-d93a-76e5-b4eec73bbcc7', 99, 'PowerCatch Update Script 2.4.4');
