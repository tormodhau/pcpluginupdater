\connect powercatch

-- PC-3154 Layoutlist sqlscript creation
CREATE TABLE IF NOT EXISTS konfigurasjon.sqllog
(
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  sqlstatement character varying,
  created_date timestamp with time zone NOT NULL DEFAULT now(),
  comment character varying,
  CONSTRAINT pk_sqllog PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE konfigurasjon.sqllog
  OWNER TO powercatch;


CREATE OR REPLACE FUNCTION konfigurasjon.layoutlist_changes()
  RETURNS trigger AS
$BODY$DECLARE
 sql character varying;
 comment character varying;
BEGIN
 -- new rows
 IF (TG_OP = 'INSERT' AND NEW.gui = 1) THEN
  IF (TG_TABLE_NAME = 'issuetype') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, nbr, name, project_key, new_issue_enabled, summary_field, changed_by, changed_date, deleted, gui) values (''' 
		|| NEW.id || ''',' || quote_nullable(NEW.nbr) || ',' || quote_nullable(NEW.name) || ',' || quote_nullable(NEW.project_key) || ',' || NEW.new_issue_enabled || ',' || quote_nullable(NEW.summary_field) || ',' || quote_nullable(NEW.changed_by) 
		|| ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || 0 || ');';
  ELSEIF (TG_TABLE_NAME = 'page') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, nbr, name, signaturerequired, commentpresent, show_camera_on_page, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || replace(quote_nullable(NEW.nbr), '''', '') || ',' || quote_nullable(NEW.name) || ',' || NEW.signaturerequired || ',' || NEW.commentpresent || ',' || NEW.show_camera_on_page
		|| ',' || quote_nullable(NEW.changed_by) || ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || 0 || ');';
  ELSEIF (TG_TABLE_NAME = 'field') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, nbr, name, customfieldid, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || quote_nullable(NEW.nbr) || ',' || quote_nullable(NEW.name) || ',' || replace(quote_nullable(NEW.customfieldid), '''', '')
		|| ',' || quote_nullable(NEW.changed_by) || ',' || quote_nullable(NEW.changed_date) || ',' || NEW.deleted || ',' || 0 || ');';
  ELSEIF (TG_TABLE_NAME = 'fieldproperty') THEN
	sql := 'insert into ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' (id, label, editable, required, checkboxvalidationid, id_field, hidden, scannable, hide_values, cross_validation, dependency_field, changed_by, changed_date, deleted, gui) values ('''
		|| NEW.id || ''',' || quote_nullable(NEW.label) || ',' || NEW.editable || ',' || NEW.required || ',' || replace(quote_nullable(NEW.checkboxvalidationid), '''', '') || ',' 
		|| quote_nullable(NEW.id_field) || ',' || replace(quote_nullable(NEW.hidden), '''', '') || ',' || NEW.scannable || ',' || NEW.hide_values || ',' || NEW.cross_validation || ',' || quote_nullable(NEW.dependency_field)
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
		|| ', project_key = ' || quote_nullable(NEW.project_key) || ', new_issue_enabled = ' || NEW.new_issue_enabled || ', summary_field = ' || quote_nullable(NEW.summary_field) 
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
  ELSEIF (TG_TABLE_NAME = 'page') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set nbr = ' || NEW.nbr || ', name = ' || quote_nullable(NEW.name) 
		|| ', signaturerequired = ' || NEW.signaturerequired || ', commentpresent = ' || NEW.commentpresent || ', show_camera_on_page = ' || NEW.show_camera_on_page
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
  ELSEIF (TG_TABLE_NAME = 'field') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set nbr = ' || quote_nullable(NEW.nbr) || ', name = ' || quote_nullable(NEW.name) 
		|| ', customfieldid = ' || replace(quote_nullable(NEW.customfieldid), '''', '')
		|| ', changed_by = ' || quote_nullable(NEW.changed_by) || ', changed_date = ' || quote_nullable(NEW.changed_date) || ', deleted = ' || NEW.deleted || ', gui = 0 where id = ''' || NEW.id || ''';';
  ELSEIF (TG_TABLE_NAME = 'fieldproperty') THEN
	sql := 'update ' || TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME || ' set label = ' || quote_nullable(NEW.label) || ', editable = ' || NEW.editable || ', required = ' || replace(quote_nullable(NEW.required), '''', '')
		|| ', checkboxvalidationid = ' || replace(quote_nullable(NEW.checkboxvalidationid), '''', '') || ', id_field = ' || quote_nullable(NEW.id_field) || ', hidden = ' || replace(quote_nullable(NEW.hidden), '''', '')
		|| ', scannable = ' || NEW.scannable || ', hide_values = ' || NEW.hide_values || ', cross_validation = ' || NEW.cross_validation || ', dependency_field = ' || quote_nullable(NEW.dependency_field)
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

DROP TRIGGER IF EXISTS issuetype_changes ON konfigurasjon.issuetype;  
CREATE TRIGGER issuetype_changes
  AFTER INSERT OR UPDATE OR DELETE
  ON konfigurasjon.issuetype
  FOR EACH ROW
  EXECUTE PROCEDURE konfigurasjon.layoutlist_changes();
 
DROP TRIGGER IF EXISTS page_changes ON konfigurasjon.page; 
CREATE TRIGGER page_changes
  AFTER INSERT OR UPDATE OR DELETE
  ON konfigurasjon.page
  FOR EACH ROW
  EXECUTE PROCEDURE konfigurasjon.layoutlist_changes();
  
DROP TRIGGER IF EXISTS field_changes ON konfigurasjon.field;
CREATE TRIGGER field_changes
  AFTER INSERT OR UPDATE OR DELETE
  ON konfigurasjon.field
  FOR EACH ROW
  EXECUTE PROCEDURE konfigurasjon.layoutlist_changes();
  
DROP TRIGGER IF EXISTS fieldproperty_changes ON konfigurasjon.fieldproperty;
CREATE TRIGGER fieldproperty_changes
  AFTER INSERT OR UPDATE OR DELETE
  ON konfigurasjon.fieldproperty
  FOR EACH ROW
  EXECUTE PROCEDURE konfigurasjon.layoutlist_changes();

DROP TRIGGER IF EXISTS issuetype_page_changes ON konfigurasjon.issuetype_page;
CREATE TRIGGER issuetype_page_changes
  AFTER INSERT OR UPDATE OR DELETE
  ON konfigurasjon.issuetype_page
  FOR EACH ROW
  EXECUTE PROCEDURE konfigurasjon.layoutlist_changes();
  
DROP TRIGGER IF EXISTS page_fieldproperty_changes ON konfigurasjon.page_fieldproperty; 
CREATE TRIGGER page_fieldproperty_changes
  AFTER INSERT OR UPDATE OR DELETE
  ON konfigurasjon.page_fieldproperty
  FOR EACH ROW
  EXECUTE PROCEDURE konfigurasjon.layoutlist_changes();

DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_schema='konfigurasjon' and table_name='field' and column_name='gui') THEN
	ALTER TABLE konfigurasjon.field ADD COLUMN gui integer NOT NULL DEFAULT 0;
ELSE
	RAISE NOTICE 'Column "field.gui" already exist, skipping';
END IF;
END
$$;

DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_schema='konfigurasjon' and table_name='fieldproperty' and column_name='gui') THEN
	ALTER TABLE konfigurasjon.fieldproperty ADD COLUMN gui integer NOT NULL DEFAULT 0;
ELSE
	RAISE NOTICE 'Column "fieldproperty.gui" already exist, skipping';
END IF;
END
$$;

DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_schema='konfigurasjon' and table_name='issuetype' and column_name='gui') THEN
	ALTER TABLE konfigurasjon.issuetype ADD COLUMN gui integer NOT NULL DEFAULT 0;
ELSE
	RAISE NOTICE 'Column "issuetype.gui" already exist, skipping';
END IF;
END
$$;

DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_schema='konfigurasjon' and table_name='issuetype_page' and column_name='gui') THEN
	ALTER TABLE konfigurasjon.issuetype_page ADD COLUMN gui integer NOT NULL DEFAULT 0;
ELSE
	RAISE NOTICE 'Column "issuetype_page.gui" already exist, skipping';
END IF;
END
$$;

DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_schema='konfigurasjon' and table_name='page' and column_name='gui') THEN
	ALTER TABLE konfigurasjon.page ADD COLUMN gui integer NOT NULL DEFAULT 0;
ELSE
	RAISE NOTICE 'Column "page.gui" already exist, skipping';
END IF;
END
$$;

DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_schema='konfigurasjon' and table_name='page_fieldproperty' and column_name='gui') THEN
	ALTER TABLE konfigurasjon.page_fieldproperty ADD COLUMN gui integer NOT NULL DEFAULT 0;
ELSE
	RAISE NOTICE 'Column "page_fieldproperty.gui" already exist, skipping';
END IF;
END
$$;

  
DROP FUNCTION IF EXISTS konfigurasjon."updateField"(character varying, character varying, character varying, numeric, character varying, integer);

CREATE OR REPLACE FUNCTION konfigurasjon.updatefield(id_field character varying, nbr character varying, name character varying, customfieldid numeric, changed_by character varying, deleted integer, gui integer)
  RETURNS integer AS
$BODY$DECLARE
	id_field_var uuid;
BEGIN
  id_field_var := $1;
  
  -- if deleted, update all referenced fieldproperties as deleted too, and all references in table page_fieldproperty
  IF ($6 = 1) THEN
    -- update fieldproperty referencing current field
    update konfigurasjon.fieldproperty set deleted = 1, gui = $7 where fieldproperty.id_field = id_field_var;

    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon.page_fieldproperty set deleted = 1, gui = $7 where page_fieldproperty.id_fieldproperty in 
      (select id from konfigurasjon.fieldproperty where fieldproperty.id_field = id_field_var);
  ELSEIF ($6 = 0) THEN
    -- changed deleted for fieldproperty and page_fieldproperty if field.deleted is changed
    IF (select 1 from konfigurasjon.field where id = id_field_var and field.deleted = 1) THEN
      -- update fieldproperty referencing current field
      update konfigurasjon.fieldproperty set deleted = 0, gui = $7 where fieldproperty.id_field = id_field_var;

      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon.page_fieldproperty set deleted = 0, gui = $7 where page_fieldproperty.id_fieldproperty in 
        (select id from konfigurasjon.fieldproperty where fieldproperty.id_field = id_field_var);
    END IF;
  END IF;

  update konfigurasjon.field
  set nbr = $2, name = $3, customfieldid = $4, changed_date = now(), changed_by = $5, deleted = $6, gui = $7
  where id = id_field_var; 
  
  return 1;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon.updatefield(character varying, character varying, character varying, numeric, character varying, integer, integer)
  OWNER TO postgres;

  
DROP FUNCTION IF EXISTS konfigurasjon."updateFieldproperty"(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer);

CREATE OR REPLACE FUNCTION konfigurasjon.updatefieldproperty(id_fieldproperty character varying, label character varying, editable integer, checkboxvalidationid integer, required integer, hidden integer, scannable integer, hide_values integer, cross_validation integer, changed_by character varying, deleted integer, gui integer)
  RETURNS integer AS
$BODY$DECLARE
	id_fieldproperty_var uuid;
BEGIN
  id_fieldproperty_var := $1;
  
  -- if deleted, update all references in table page_fieldproperty
  IF ($11 = 1) THEN
    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon.page_fieldproperty set deleted = 1, gui = $12 where page_fieldproperty.id_fieldproperty = id_fieldproperty_var;
  ELSEIF ($11 = 0) THEN
    -- change deleted for page_fieldproperty if fieldproperty.deleted is changed
    IF (select 1 from konfigurasjon.fieldproperty where id = id_fieldproperty_var and fieldproperty.deleted = 1) THEN
      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon.page_fieldproperty set deleted = 0, gui = $12 where page_fieldproperty.id_fieldproperty = id_fieldproperty_var;
    END IF;
  END IF;

  update konfigurasjon.fieldproperty
  set label = $2, editable = $3, required = $5, checkboxvalidationid = $4, hidden = $6, scannable = $7, hide_values = $8, cross_validation = $9, changed_date = now(), changed_by = $10, deleted = $11, gui = $12
  where id = id_fieldproperty_var; 
  
  return 1;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon.updatefieldproperty(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer, integer)
  OWNER TO postgres;

  
  
 -- DROP FUNCTION konfigurasjon."getAllLayouts"();
-- Added dependency_field to fieldproperty table
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
  
  
DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_schema='konfigurasjon' and table_name='fieldproperty' and column_name='dependency_field') THEN
	ALTER TABLE konfigurasjon.fieldproperty ADD column dependency_field character varying(255);
ELSE
	RAISE NOTICE 'Column "fieldproperty.dependency_field" already exist, skipping';
END IF;
END
$$;


DROP FUNCTION konfigurasjon.updatefieldproperty(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer, integer);

CREATE OR REPLACE FUNCTION konfigurasjon.updatefieldproperty(id_fieldproperty character varying, label character varying, editable integer, checkboxvalidationid integer, required integer, hidden integer, scannable integer, hide_values integer, cross_validation integer, changed_by character varying, deleted integer, gui integer, dependency_field character varying)
  RETURNS integer AS
$BODY$DECLARE
	id_fieldproperty_var uuid;
BEGIN
  id_fieldproperty_var := $1;
  
  -- if deleted, update all references in table page_fieldproperty
  IF ($11 = 1) THEN
    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon.page_fieldproperty set deleted = 1, gui = $12 where page_fieldproperty.id_fieldproperty = id_fieldproperty_var;
  ELSEIF ($11 = 0) THEN
    -- change deleted for page_fieldproperty if fieldproperty.deleted is changed
    IF (select 1 from konfigurasjon.fieldproperty where id = id_fieldproperty_var and fieldproperty.deleted = 1) THEN
      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon.page_fieldproperty set deleted = 0, gui = $12 where page_fieldproperty.id_fieldproperty = id_fieldproperty_var;
    END IF;
  END IF;

  update konfigurasjon.fieldproperty
  set label = $2, editable = $3, required = $5, checkboxvalidationid = $4, hidden = $6, scannable = $7, hide_values = $8, cross_validation = $9, changed_date = now(), changed_by = $10, deleted = $11, gui = $12, dependency_field = $13
  where id = id_fieldproperty_var; 
  
  return 1;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon.updatefieldproperty(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer, integer, character varying)
  OWNER TO postgres;

 
-- PC_NEW_METER_STATE_ENERGY_CONSUMPTION_ACTIVE_REGISTRATION_DATE_TIME