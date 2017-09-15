\connect powercatch


ALTER TABLE konfigurasjon.fieldproperty ADD column scannable  integer DEFAULT 0;
ALTER TABLE konfigurasjon.fieldproperty ADD column hide_values  integer DEFAULT 0;
ALTER TABLE konfigurasjon.fieldproperty ADD column cross_validation  integer DEFAULT 0;


-- Function: konfigurasjon."getAllLayouts"()

-- DROP FUNCTION konfigurasjon."getAllLayouts"();

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
		fp."cross_validation" as cross_validation
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

  
-- function for setting short_id on all linje-records. This is needed to make vector-tiles work
--  called using: select infrastruktur.setShortIdOnAllLinjeRecords();
CREATE OR REPLACE FUNCTION infrastruktur.setShortIdOnAllLinjeRecords()
  RETURNS character varying AS
$BODY$
declare
    arow record;
    shortId varchar(4);
  begin
    for arow in
	-- select all "linje" and split into "mastepunkt" (see description above)
        SELECT * FROM infrastruktur.linje
	--LIMIT 4 -- limit during dev
    loop

	-- get a shortId
	shortId := infrastruktur.getshortid('linje');

	-- update record
	UPDATE infrastruktur.linje SET short_id = shortId WHERE id = arow.id;
	
    end loop;
    
    RETURN 'OK';
  end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION infrastruktur.setShortIdOnAllLinjeRecords()
  OWNER TO postgres;
  

-- function for exporting all linje-records created from SOSI to a .csv-file. This is needed to create vector-tile-dbs (sqlite)
--  called using: select infrastruktur.exportlinevectortilessosi();
CREATE OR REPLACE FUNCTION infrastruktur.exportLineVectorTilesSOSI()
  RETURNS character varying AS
$BODY$
begin
	 COPY (
	select l.short_id,
	CASE
	WHEN m.variant='JordkabelHSP' OR m.variant='JordkabelLSP' OR m.variant='KABEL' THEN 'Jordkabel'
	ELSE 'Line'
	END
	AS variantLinje,
	m.pos_lat, m.pos_long,
	CASE
	WHEN l.spenning=132 THEN 'Regionalnett'
	WHEN m.variant='HENGEKABEL' OR m.variant='JordkabelLSP' OR m.variant='LuftledningLSP' OR m.variant='KABEL' THEN 'Lavspenningsnett'
	ELSE 'Høyspenningsnett'
	END
	AS variantSpenning
	from infrastruktur.mastepunkt m INNER JOIN infrastruktur.linje l ON m.id_linje = l.id ORDER BY short_id, posisjon
	) TO 'c:\tmp\vectordata.csv' (FORMAT CSV, DELIMITER '|', HEADER true);
	RETURN 'OK';
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION infrastruktur.exportLineVectorTilesSOSI()
  OWNER TO postgres;

  
-- function for exporting all linje-records created from ISYNIS to a .csv-file. This is needed to create vector-tile-dbs (sqlite)
--  called using: select infrastruktur.exportlinevectortilesisynis();
CREATE OR REPLACE FUNCTION infrastruktur.exportLineVectorTilesISYNIS()
  RETURNS character varying AS
$BODY$
begin
	COPY (
	select l.short_id, 
	l.variant AS variantLinje,
	m.pos_lat, 
	m.pos_long, 
	a.variant AS variantSpenning
	from infrastruktur.mastepunkt m 
	INNER JOIN infrastruktur.linje l ON m.id_linje = l.id
	inner join infrastruktur.anlegg a on a.id = l.id_anlegg
	ORDER BY short_id, posisjon
	) TO 'c:\tmp\vectordata.csv' (FORMAT CSV, DELIMITER '|', HEADER true);
	RETURN 'OK';
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION infrastruktur.exportLineVectorTilesISYNIS()
  OWNER TO postgres;
  

-- function for setting short_id on linje-records where this field is empty. This is needed to make vector-tiles work  
--  select infrastruktur.setshortidonemptyrecords();
CREATE OR REPLACE FUNCTION infrastruktur.setshortidonemptyrecords()
  RETURNS character varying AS
$BODY$

declare
    arow record;
    shortId varchar(4);
  begin
    for arow in
	-- select all "linje" and split into "mastepunkt" (see description above)
        SELECT * FROM infrastruktur.linje where short_id is null
	--LIMIT 4 -- limit during dev
    loop

	-- get a shortId
	shortId := infrastruktur.getshortid('linje');

	-- update record
	UPDATE infrastruktur.linje SET short_id = shortId WHERE id = arow.id;
	
    end loop;
    
    RETURN 'OK';
  end;
  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION infrastruktur.setshortidonemptyrecords()
  OWNER TO postgres;


-- PC-3142
DO
$$
BEGIN
IF NOT EXISTS (SELECT relname
				FROM pg_class INNER JOIN pg_catalog.pg_namespace n ON n.oid = pg_class.relnamespace
				WHERE n.nspname='prosjekt' AND relname='activemq_id_seq') THEN
	CREATE SEQUENCE prosjekt.activemq_id_seq
			INCREMENT 1
			MINVALUE 1
			MAXVALUE 9223372036854775807
			START 1
			CACHE 1;
	ALTER TABLE prosjekt.activemq_id_seq
		OWNER TO powercatch;
ELSE
	RAISE NOTICE 'Sequence "activemq_id_seq" already exists, skipping';
END IF;
END
$$;

DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='prosjekt' and table_name='activemq_failures' and column_name='message') THEN
	ALTER TABLE prosjekt.activemq_failures ALTER message TYPE text;
	RAISE NOTICE 'Column "activemq_failures.message" changed from varchar to text';
ELSE
	RAISE NOTICE 'Column "activemq_failures.message" does not exist, creating';
	ALTER TABLE prosjekt.activemq_failures ADD COLUMN message text;
END IF;
END
$$;


-- PC-3154
DROP FUNCTION konfigurasjon."updateField"(uuid, character varying, character varying, numeric, character varying, boolean);

CREATE OR REPLACE FUNCTION konfigurasjon."updateField"(id_field character varying, nbr character varying, name character varying, customfieldid numeric, changed_by character varying, deleted integer)
  RETURNS integer AS
$BODY$DECLARE
	id_field_var uuid;
BEGIN
  id_field_var := $1;
  
  -- if deleted, update all referenced fieldproperties as deleted too, and all references in table page_fieldproperty
  IF ($6 = 1) THEN
    -- update fieldproperty referencing current field
    update konfigurasjon."fieldproperty" set "deleted" = 1 where fieldproperty."id_field" = id_field_var;

    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon."page_fieldproperty" set "deleted" = 1 where page_fieldproperty."id_fieldproperty" in 
      (select "id" from konfigurasjon."fieldproperty" where fieldproperty."id_field" = id_field_var);
  ELSEIF ($6 = 0) THEN
    -- changed deleted for fieldproperty and page_fieldproperty if field.deleted is changed
    IF (select 1 from konfigurasjon."field" where "id" = id_field_var and field."deleted" = 1) THEN
      -- update fieldproperty referencing current field
      update konfigurasjon."fieldproperty" set "deleted" = 0 where fieldproperty."id_field" = id_field_var;

      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon."page_fieldproperty" set "deleted" = 0 where page_fieldproperty."id_fieldproperty" in 
        (select "id" from konfigurasjon."fieldproperty" where fieldproperty."id_field" = id_field_var);
    END IF;
  END IF;

  update konfigurasjon."field"
  set "nbr" = $2, "name" = $3, "customfieldid" = $4, "changed_date" = now(), "changed_by" = $5, "deleted" = $6
  where "id" = id_field_var; 
  
  return 1;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon."updateField"(character varying, character varying, character varying, numeric, character varying, integer)
  OWNER TO postgres;

DROP FUNCTION konfigurasjon."updateFieldproperty"(uuid, character varying, boolean, boolean, integer, character varying, boolean);
 
CREATE OR REPLACE FUNCTION konfigurasjon."updateFieldproperty"(id_fieldproperty character varying, label character varying, editable integer, required integer, checkboxvalidationid integer, hidden integer, scannable integer, hide_values integer, cross_validation integer, changed_by character varying, deleted integer)
  RETURNS integer AS
$BODY$DECLARE
	id_fieldproperty_var uuid;
BEGIN
  id_fieldproperty_var := $1;
  
  -- if deleted, update all references in table page_fieldproperty
  IF ($7 = 1) THEN
    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon."page_fieldproperty" set "deleted" = 1 where page_fieldproperty."id_fieldproperty" = id_fieldproperty_var;
  ELSEIF ($7 = 0) THEN
    -- change deleted for page_fieldproperty if fieldproperty.deleted is changed
    IF (select 1 from konfigurasjon."fieldproperty" where "id" = id_fieldproperty_var and fieldproperty."deleted" = 1) THEN
      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon."page_fieldproperty" set "deleted" = 0 where page_fieldproperty."id_fieldproperty" = id_fieldproperty_var;
    END IF;
  END IF;

  update konfigurasjon."fieldproperty"
  set "label" = $2, "editable" = $3, "required" = $4, "checkboxvalidationid" = $5, "hidden" = $6, "scannable" = $7, "hide_values" = $8, "cross_validation" = $9, "changed_date" = now(), "changed_by" = $10, "deleted" = $11
  where "id" = id_fieldproperty_var; 
  
  return 1;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon."updateFieldproperty"(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer)
  OWNER TO postgres;

DROP FUNCTION konfigurasjon."updateFieldproperty"(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer);

CREATE OR REPLACE FUNCTION konfigurasjon."updateFieldproperty"(id_fieldproperty character varying, label character varying, editable integer, checkboxvalidationid integer, required integer, hidden integer, scannable integer, hide_values integer, cross_validation integer, changed_by character varying, deleted integer)
  RETURNS integer AS
$BODY$DECLARE
	id_fieldproperty_var uuid;
BEGIN
  id_fieldproperty_var := $1;
  
  -- if deleted, update all references in table page_fieldproperty
  IF ($7 = 1) THEN
    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon."page_fieldproperty" set "deleted" = 1 where page_fieldproperty."id_fieldproperty" = id_fieldproperty_var;
  ELSEIF ($7 = 0) THEN
    -- change deleted for page_fieldproperty if fieldproperty.deleted is changed
    IF (select 1 from konfigurasjon."fieldproperty" where "id" = id_fieldproperty_var and fieldproperty."deleted" = 1) THEN
      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon."page_fieldproperty" set "deleted" = 0 where page_fieldproperty."id_fieldproperty" = id_fieldproperty_var;
    END IF;
  END IF;

  update konfigurasjon."fieldproperty"
  set "label" = $2, "editable" = $3, "required" = $5, "checkboxvalidationid" = $4, "hidden" = $6, "scannable" = $7, "hide_values" = $8, "cross_validation" = $9, "changed_date" = now(), "changed_by" = $10, "deleted" = $11
  where "id" = id_fieldproperty_var; 
  
  return 1;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon."updateFieldproperty"(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer)
  OWNER TO postgres;
