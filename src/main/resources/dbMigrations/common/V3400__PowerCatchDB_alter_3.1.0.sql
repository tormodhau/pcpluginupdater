\connect powercatch

-- Changed return value of fieldproperty.id
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
		fp."id"::"varchar" as fieldproperty_id
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
  
  
-- TEN-591
DO
$$
BEGIN
	IF EXISTS (SELECT column_name FROM information_schema.columns WHERE table_catalog = 'powercatch' and table_schema='prosjekt' and table_name='key' and column_name='mobile') THEN
		RAISE NOTICE 'Columns already exists. Dropping add operation';
	ELSE
		ALTER TABLE prosjekt.key ADD COLUMN mobile integer DEFAULT 1;
		COMMENT ON COLUMN prosjekt.key.mobile IS 'Value of 1 displays record on mobile';
		RAISE NOTICE 'Added new column mobile in table key';
	END IF;
END
$$;
  
-- TEN-591
-- Added trigger to automatically edit timestamp in column changed_date
CREATE OR REPLACE FUNCTION prosjekt.update_modified_column()	
RETURNS TRIGGER AS $$
BEGIN
    NEW.changed_date = now();
    RETURN NEW;	
END;
$$ language 'plpgsql';

DO
$$
BEGIN
IF EXISTS (select tgname from pg_trigger where tgname = 'key_update_changed_date') THEN
	RAISE NOTICE 'Trigger update_changed_date already exists';
ELSE
	CREATE TRIGGER key_update_changed_date BEFORE UPDATE ON prosjekt.key FOR EACH ROW EXECUTE PROCEDURE prosjekt.update_modified_column();
	RAISE NOTICE 'Created trigger key_update_changed_date';
END IF;
END
$$;

DO
$$
BEGIN
IF EXISTS (select tgname from pg_trigger where tgname = 'key_translation_update_changed_date') THEN
	RAISE NOTICE 'Trigger update_changed_date already exists';
ELSE
	CREATE TRIGGER key_translation_update_changed_date BEFORE UPDATE ON prosjekt.key_translation FOR EACH ROW EXECUTE PROCEDURE prosjekt.update_modified_column();
	RAISE NOTICE 'Created trigger key_translation_update_changed_date';
END IF;
END
$$;