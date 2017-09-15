\connect powercatch


ALTER TABLE konfigurasjon.page ADD column show_camera_on_page integer DEFAULT 0;


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