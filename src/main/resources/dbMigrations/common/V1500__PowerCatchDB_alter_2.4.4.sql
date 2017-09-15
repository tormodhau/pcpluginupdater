-- Add signature required column to issuetype
ALTER TABLE konfigurasjon.issuetype ADD COLUMN drop_signature integer NOT NULL DEFAULT 0;

 -- DROP FUNCTION konfigurasjon."getAllLayouts"();
-- Added new field drop_signature to issuetype table
CREATE OR REPLACE FUNCTION konfigurasjon."getAllLayouts"()
  RETURNS refcursor AS
$BODY$DECLARE 
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select  -- issuetype values
		it."name" as issuetype_name, 
		it."project_key" as project_key, 
		it."new_issue_enabled" as new_issue_enabled, 
		it."summary_field" as summary_field, 
		it."drop_signature" as drop_signature,
		-- page values
		p."name" as page_name, 
		p."signaturerequired" as signaturerequired,
		p."commentpresent" as commentpresent,
		p."show_camera_on_page" as show_camera_on_page,
		-- field values 
		f."name" as field_name, 
		f."customfieldid" as customfieldid,
		-- fieldproperty values
		fp."label" as label, 
		fp."editable" as editable, 
		fp."required" as required, 
		fp."hidden" as hidden, 
		fp."checkboxvalidationid" as checkboxvalidationid,
		fp."scannable" as scannable, 
		fp."hide_values" as hide_values,
		fp."cross_validation" as cross_validation,
		fp."dependency_field" as dependency_field
	from 
		konfigurasjon."issuetype" it
	inner join 
		konfigurasjon."issuetype_page" ip on it."id" = ip."id_issuetype" and it."deleted" = 0
	inner join 
		konfigurasjon."page" p on p."id" = ip."id_page" and p."deleted" = 0
	left join
		konfigurasjon."page_fieldproperty" pfp on pfp."id_page" = p."id"
	left join
		konfigurasjon."fieldproperty" fp on fp."id" = pfp."id_fieldproperty" and fp."deleted" = 0
	left join 
		konfigurasjon."field" f on f."id" = fp."id_field" and f."deleted" = 0
	order by 
		it."name", it."project_key", ip."sortorder", pfp."sortorder";
RETURN mycurs;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon."getAllLayouts"()
  OWNER TO powercatch;
  
-- Function: konfigurasjon.layoutlist_changes()

-- DROP FUNCTION konfigurasjon.layoutlist_changes();
-- Added logging of new value drop_signature for issuetype SQL queries
CREATE OR REPLACE FUNCTION konfigurasjon.layoutlist_changes()
  RETURNS trigger AS
$BODY$DECLARE
 sql character varying;
 comment character varying;
BEGIN
 -- new rows
 IF (TG_OP = 'INSERT' AND NEW.gui = 1) THEN
  IF (TG_TABLE_NAME = 'issuetype') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, nbr, name, project_key, new_issue_enabled, summary_field, changed_by, changed_date, deleted, drop_signature, gui) values (''' 
		|| NEW.id || ''',' || quote_nullable(NEW.nbr) || ',' || quote_nullable(NEW.name) || ',' || quote_nullable(NEW.project_key) || ',' 
		|| replace(quote_nullable(NEW.new_issue_enabled), '''', '') || ',' || quote_nullable(NEW.summary_field) || ',' || quote_nullable(NEW.changed_by) 
		|| ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || replace(quote_nullable(NEW.drop_signature), '''', '') || ',' || 0 || ');';
  ELSEIF (TG_TABLE_NAME = 'page') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, nbr, name, signaturerequired, commentpresent, show_camera_on_page, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || replace(quote_nullable(NEW.nbr), '''', '') || ',' || quote_nullable(NEW.name) || ',' || replace(quote_nullable(NEW.signaturerequired), '''', '') || ',' 
		|| replace(quote_nullable(NEW.commentpresent), '''', '') || ',' || replace(quote_nullable(NEW.show_camera_on_page), '''', '')
		|| ',' || quote_nullable(NEW.changed_by) || ',' || quote_nullable(NEW.changed_date) || ',' || replace(quote_nullable(NEW.deleted), '''', '') || ',' || 0 || ');';
  ELSEIF (TG_TABLE_NAME = 'field') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, nbr, name, customfieldid, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || quote_nullable(NEW.nbr) || ',' || quote_nullable(NEW.name) || ',' || replace(quote_nullable(NEW.customfieldid), '''', '')
		|| ',' || quote_nullable(NEW.changed_by) || ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || 0 || ');';
  ELSEIF (TG_TABLE_NAME = 'fieldproperty') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, label, editable, required, checkboxvalidationid, id_field, hidden, scannable, hide_values, cross_validation, dependency_field, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || quote_nullable(NEW.label) || ',' || NEW.editable || ',' || NEW.required || ',' || replace(quote_nullable(NEW.checkboxvalidationid), '''', '') || ',' 
		|| quote_nullable(NEW.id_field) || ',' || replace(quote_nullable(NEW.hidden), '''', '') || ',' || replace(quote_nullable(NEW.scannable), '''', '') || ',' 
		|| replace(quote_nullable(NEW.hide_values), '''', '') || ',' || replace(quote_nullable(NEW.cross_validation), '''', '') || ',' || quote_nullable(NEW.dependency_field)
		|| ',' || quote_nullable(NEW.changed_by) || ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || 0 || ');';
	comment := 'FIELD = ' || (select name from konfigurasjon.field where id = NEW.id_field);
  ELSEIF (TG_TABLE_NAME = 'issuetype_page') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, id_issuetype, id_page, sortorder, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || quote_nullable(NEW.id_issuetype) || ',' || quote_nullable(NEW.id_page) || ',' || replace(quote_nullable(NEW.sortorder), '''', '')
		|| ',' || quote_nullable(NEW.changed_by) || ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || 0 || ');';
	comment := 'ISSUETYPE = ' || (select name from konfigurasjon.issuetype where id = NEW.id_issuetype) || ', PAGE = ' || (select concat_ws(', ', nbr, name) from konfigurasjon.page where id = NEW.id_page);
  ELSEIF (TG_TABLE_NAME = 'page_fieldproperty') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, id_page, id_fieldproperty, sortorder, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || quote_nullable(NEW.id_page) || ',' || quote_nullable(NEW.id_fieldproperty) || ',' || replace(quote_nullable(NEW.sortorder), '''', '')
		|| ',' || quote_nullable(NEW.changed_by) || ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || 0 || ');';
	comment := 'PAGE = ' || (select concat_ws(', ', nbr, name) from konfigurasjon.page where id = NEW.id_page) || ', FIELD = ' || (select name from konfigurasjon.field where id = (select id_field from konfigurasjon.fieldproperty where id = NEW.id_fieldproperty));
  END IF;
 -- updated rows
 ELSEIF (TG_OP = 'UPDATE' AND NEW.gui = 1) THEN
  IF (TG_TABLE_NAME = 'issuetype') THEN
	  sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set nbr = ' || quote_nullable(NEW.nbr) || ', name = ' || quote_nullable(NEW.name) 
		|| ', project_key = ' || quote_nullable(NEW.project_key) || ', new_issue_enabled = ' || replace(quote_nullable(NEW.new_issue_enabled), '''', '') || ', summary_field = ' 
		|| quote_nullable(NEW.summary_field) || ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) 
		|| ', deleted = ' || NEW.deleted || ', drop_signature = ' || replace(quote_nullable(NEW.drop_signature), '''', '') || ', gui = 0 where id = ''' || NEW.id || ''';';
  ELSEIF (TG_TABLE_NAME = 'page') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set nbr = ' || replace(quote_nullable(NEW.nbr), '''', '') || ', name = ' || quote_nullable(NEW.name) 
		|| ', signaturerequired = ' || replace(quote_nullable(NEW.signaturerequired), '''', '') || ', commentpresent = ' || replace(quote_nullable(NEW.commentpresent), '''', '') 
		|| ', show_camera_on_page = ' || replace(quote_nullable(NEW.show_camera_on_page), '''', '')
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
  ELSEIF (TG_TABLE_NAME = 'field') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set nbr = ' || quote_nullable(NEW.nbr) || ', name = ' || quote_nullable(NEW.name) 
		|| ', customfieldid = ' || replace(quote_nullable(NEW.customfieldid), '''', '')
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
  ELSEIF (TG_TABLE_NAME = 'fieldproperty') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set label = ' || quote_nullable(NEW.label) || ', editable = ' || replace(quote_nullable(NEW.editable), '''', '') 
		|| ', required = ' || replace(quote_nullable(NEW.required), '''', '')
		|| ', checkboxvalidationid = ' || replace(quote_nullable(NEW.checkboxvalidationid), '''', '') || ', id_field = ' || quote_nullable(NEW.id_field) || ', hidden = ' || replace(quote_nullable(NEW.hidden), '''', '')
		|| ', scannable = ' || replace(quote_nullable(NEW.scannable), '''', '') || ', hide_values = ' || replace(quote_nullable(NEW.hide_values), '''', '') 
		|| ', cross_validation = ' || replace(quote_nullable(NEW.cross_validation), '''', '') || ', dependency_field = ' || quote_nullable(NEW.dependency_field)
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
	comment := 'FIELD = ' || (select name from konfigurasjon.field where id = NEW.id_field);
  ELSEIF (TG_TABLE_NAME = 'issuetype_page') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set id_issuetype = ' || quote_nullable(NEW.id_issuetype) || ', id_page = ' || quote_nullable(NEW.id_page) || ', sortorder = ' || replace(quote_nullable(NEW.sortorder), '''', '')
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
	comment := 'ISSUETYPE = ' || (select name from konfigurasjon.issuetype where id = NEW.id_issuetype) || ', PAGE = ' || (select concat_ws(', ', nbr, name) from konfigurasjon.page where id = NEW.id_page);
  ELSEIF (TG_TABLE_NAME = 'page_fieldproperty') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set id_page = ' || quote_nullable(NEW.id_page) || ', id_fieldproperty = ' || quote_nullable(NEW.id_fieldproperty) || ', sortorder = ' || replace(quote_nullable(NEW.sortorder), '''', '')
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
	comment := 'PAGE = ' || (select concat_ws(', ', nbr, name) from konfigurasjon.page where id = NEW.id_page) || ', FIELD = ' || (select name from konfigurasjon.field where id = (select id_field from konfigurasjon.fieldproperty where id = NEW.id_fieldproperty));
  END IF;
 -- deleted rows
 ELSEIF (TG_OP = 'DELETE') THEN
  sql := 'delete from ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' where id = ''' || OLD.id || ''';';
  IF (TG_TABLE_NAME = 'issuetype_page') THEN
	comment := 'ISSUETYPE = ' || (select name from konfigurasjon.issuetype where id = OLD.id_issuetype) || ', PAGE = ' || (select concat_ws(', ', nbr, name) from konfigurasjon.page where id = OLD.id_page);
  ELSEIF (TG_TABLE_NAME = 'page_fieldproperty') THEN
	comment := 'PAGE = ' || (select concat_ws(', ', nbr, name) from konfigurasjon.page where id = OLD.id_page) || ', FIELD = ' || (select name from konfigurasjon.field where id = (select id_field from konfigurasjon.fieldproperty where id = OLD.id_fieldproperty));
  END IF;
 END IF;
 IF (sql IS NOT NULL AND sql <> '') THEN
   INSERT INTO konfigurasjon.sqllog (sqlstatement, comment) VALUES (sql, comment); 
 END IF;
 
 RETURN NEW;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon.layoutlist_changes()
  OWNER TO powercatch;

  
-- added fieldproperty.id
-- Added new field drop_signature to issuetype table
CREATE OR REPLACE FUNCTION konfigurasjon."getAllLayouts"()
  RETURNS refcursor AS
$BODY$DECLARE 
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select  -- issuetype values
		it."name" as issuetype_name, 
		it."project_key" as project_key, 
		it."new_issue_enabled" as new_issue_enabled, 
		it."summary_field" as summary_field, 
		it."drop_signature" as drop_signature,
		-- page values
		p."name" as page_name, 
		p."signaturerequired" as signaturerequired,
		p."commentpresent" as commentpresent,
		p."show_camera_on_page" as show_camera_on_page,
		-- field values 
		f."name" as field_name, 
		f."customfieldid" as customfieldid,
		-- fieldproperty values
		fp."label" as label, 
		fp."editable" as editable, 
		fp."required" as required, 
		fp."hidden" as hidden, 
		fp."checkboxvalidationid" as checkboxvalidationid,
		fp."scannable" as scannable, 
		fp."hide_values" as hide_values,
		fp."cross_validation" as cross_validation,
		fp."dependency_field" as dependency_field,
		fp."id" as fieldproperty_id
	from 
		konfigurasjon."issuetype" it
	inner join 
		konfigurasjon."issuetype_page" ip on it."id" = ip."id_issuetype" and it."deleted" = 0
	inner join 
		konfigurasjon."page" p on p."id" = ip."id_page" and p."deleted" = 0
	left join
		konfigurasjon."page_fieldproperty" pfp on pfp."id_page" = p."id"
	left join
		konfigurasjon."fieldproperty" fp on fp."id" = pfp."id_fieldproperty" and fp."deleted" = 0
	left join 
		konfigurasjon."field" f on f."id" = fp."id_field" and f."deleted" = 0
	order by 
		it."name", it."project_key", ip."sortorder", pfp."sortorder";
RETURN mycurs;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon."getAllLayouts"()
  OWNER TO powercatch;