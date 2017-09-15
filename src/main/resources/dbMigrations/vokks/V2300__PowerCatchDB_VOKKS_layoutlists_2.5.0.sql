-- SUPAMS-106, changed customfield names for PC_METERPOINT_ID and PC_METERPOINT_INSTALLATIONID
update konfigurasjon.field set nbr = NULL, name = 'PC_COMPOINT_INSTALLATIONID', customfieldid = NULL, changed_by = 'PowerCatch admin', changed_date = '2016-11-09 10:31:12.272+01', deleted = 0, gui = 0 where id = '64076d6e-3912-4706-8c1d-7eda5d056089';
update konfigurasjon.field set nbr = NULL, name = 'PC_COMPOINT_ID', customfieldid = NULL, changed_by = 'PowerCatch admin', changed_date = '2016-11-09 10:30:18.135+01', deleted = 0, gui = 0 where id = '84d95327-d53c-4029-b9ee-acf82a1c78f5';
