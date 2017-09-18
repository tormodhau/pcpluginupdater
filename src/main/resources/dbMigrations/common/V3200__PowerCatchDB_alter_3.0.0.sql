
-- delete old equipment schema, tables, functions etc. 
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template_issue') THEN
	DROP SCHEMA IF EXISTS equipment CASCADE;
	RAISE NOTICE 'Deleted schema equipment';
END IF;
END
$$;

-- recreate equipment schema
CREATE SCHEMA IF NOT EXISTS equipment AUTHORIZATION powercatch;

--SET search_path = equipment, pg_catalog;

-- new table template
CREATE TABLE IF NOT EXISTS equipment.template 
(
	id bigserial,
	templateid character varying(30),
	issuetype character varying(50),
	jobtype character varying(50),
	changed_date timestamp with time zone NOT NULL DEFAULT now(),
	changed_by character varying(50),
	deleted integer NOT NULL DEFAULT 0,
	CONSTRAINT pk_template PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.template OWNER TO powercatch;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template' and column_name='id') THEN
	COMMENT ON COLUMN equipment.template.id IS 'PowerCatch intern id for vare i materiellmal';
	RAISE NOTICE 'Added comment for column "template.id"';
ELSE
	RAISE NOTICE 'Column "template.id" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template' and column_name='templateid') THEN
	COMMENT ON COLUMN equipment.template.templateid IS 'Kundens id for materiellmal';
	RAISE NOTICE 'Added comment for column "template.templateid"';
ELSE
	RAISE NOTICE 'Column "template.templateid" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template' and column_name='issuetype') THEN
	COMMENT ON COLUMN equipment.template.issuetype IS 'PowerCatch sakstype som skal brukes for denne materiellmalen';
	RAISE NOTICE 'Added comment for column "template.issuetype"';
ELSE
	RAISE NOTICE 'Column "template.issuetype" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template' and column_name='jobtype') THEN
	COMMENT ON COLUMN equipment.template.jobtype IS 'Kundens jobbtype som skal brukes for denne materiellmalen';
	RAISE NOTICE 'Added comment for column "template.jobtype"';
ELSE
	RAISE NOTICE 'Column "template.jobtype" does not exist. Dropping comment';
END IF;
END
$$;

-- new table template_item
CREATE TABLE IF NOT EXISTS equipment.template_item 
(
	id bigserial,
	template_itemid character varying(30),
	id_item bigint,
	id_stock bigint,
	id_template bigint,
	defaultqty numeric(8,2),
	changed_date timestamp with time zone NOT NULL DEFAULT now(),
	changed_by character varying(50),
	deleted integer NOT NULL DEFAULT 0,
	CONSTRAINT pk_template_item PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.template_item OWNER TO powercatch;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template_item' and column_name='id') THEN
	COMMENT ON COLUMN equipment.template_item.id IS 'PowerCatch intern id for element i materiellmal';
	RAISE NOTICE 'Added comment for column "template_item.id"';
ELSE
	RAISE NOTICE 'Column "template_item.id" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template_item' and column_name='template_itemid') THEN
	COMMENT ON COLUMN equipment.template_item.template_itemid IS 'Kundens id for element i materiellmal';
	RAISE NOTICE 'Added comment for column "template_item.template_itemid"';
ELSE
	RAISE NOTICE 'Column "template_item.template_itemid" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template_item' and column_name='id_item') THEN
	COMMENT ON COLUMN equipment.template_item.id_item IS 'Referanse til PowerCatch intern id for vare';
	RAISE NOTICE 'Added comment for column "template_item.id_item"';
ELSE
	RAISE NOTICE 'Column "template_item.id_item" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template_item' and column_name='id_stock') THEN
	COMMENT ON COLUMN equipment.template_item.id_stock IS 'Referanse til PowerCatch intern id for lager';
	RAISE NOTICE 'Added comment for column "template_item.id_stock"';
ELSE
	RAISE NOTICE 'Column "template_item.id_stock" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template_item' and column_name='id_template') THEN
	COMMENT ON COLUMN equipment.template_item.id_template IS 'Referanse til PowerCatch intern id for materiellmal';
	RAISE NOTICE 'Added comment for column "template_item.id_template"';
ELSE
	RAISE NOTICE 'Column "template_item.id_template" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='template_item' and column_name='defaultqty') THEN
	COMMENT ON COLUMN equipment.template_item.defaultqty IS 'Standard antall for vare i materiellmal';
	RAISE NOTICE 'Added comment for column "template_item.defaultqty"';
ELSE
	RAISE NOTICE 'Column "template_item.defaultqty" does not exist. Dropping comment';
END IF;
END
$$;

-- new table stock
CREATE TABLE IF NOT EXISTS equipment.stock
(
  id bigserial,
  stockid character varying(30) NOT NULL,
  name character varying(50) NOT NULL,
  address character varying(50),
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  changed_by character varying(50),
  deleted integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_stock PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.stock
  OWNER TO powercatch;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='stock' and column_name='id') THEN
	COMMENT ON COLUMN equipment.stock.id IS 'PowerCatch intern id for lager';
	RAISE NOTICE 'Added comment for column "stock.id"';
ELSE
	RAISE NOTICE 'Column "stock.id" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='stock' and column_name='stockid') THEN
	COMMENT ON COLUMN equipment.stock.stockid IS 'Kundens id for lager';
	RAISE NOTICE 'Added comment for column "stock.stockid"';
ELSE
	RAISE NOTICE 'Column "stock.stockid" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='stock' and column_name='name') THEN
	COMMENT ON COLUMN equipment.stock.name IS 'Kundens navn for lager';
	RAISE NOTICE 'Added comment for column "stock.name"';
ELSE
	RAISE NOTICE 'Column "stock.name" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='stock' and column_name='address') THEN
	COMMENT ON COLUMN equipment.stock.address IS 'Kundens adresse for lager';
	RAISE NOTICE 'Added comment for column "stock.address"';
ELSE
	RAISE NOTICE 'Column "stock.address" does not exist. Dropping comment';
END IF;
END
$$;

-- new table unit
CREATE TABLE IF NOT EXISTS equipment.unit
(
  id bigserial,
  unitid character varying(30) NOT NULL,
  name character varying(50) NOT NULL,
  description character varying(255),
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  changed_by character varying(50),
  deleted integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_unit PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.unit
  OWNER TO powercatch;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='unit' and column_name='id') THEN
	COMMENT ON COLUMN equipment.unit.id IS 'PowerCatch intern id for enhet';
	RAISE NOTICE 'Added comment for column "unit.id"';
ELSE
	RAISE NOTICE 'Column "unit.id" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='unit' and column_name='unitid') THEN
	COMMENT ON COLUMN equipment.unit.unitid IS 'Kundens id for enhet';
	RAISE NOTICE 'Added comment for column "unit.unitid"';
ELSE
	RAISE NOTICE 'Column "unit.unitid" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='unit' and column_name='name') THEN
	COMMENT ON COLUMN equipment.unit.name IS 'Kundens navn for enhet';
	RAISE NOTICE 'Added comment for column "unit.name"';
ELSE
	RAISE NOTICE 'Column "unit.name" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='unit' and column_name='description') THEN
	COMMENT ON COLUMN equipment.unit.description IS 'Kundens beskrivelse for enhet';
	RAISE NOTICE 'Added comment for column "unit.description"';
ELSE
	RAISE NOTICE 'Column "unit.description" does not exist. Dropping comment';
END IF;
END
$$;

-- new table item
CREATE TABLE IF NOT EXISTS equipment.item
(
  id bigserial,
  itemid character varying(30) NOT NULL,
  name character varying(50) NOT NULL,
  description character varying(255),
  id_unit bigint, 
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  changed_by character varying(50),
  deleted integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_item PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.item
  OWNER TO powercatch;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='item' and column_name='id') THEN
	COMMENT ON COLUMN equipment.item.id IS 'PowerCatch intern id for vare';
	RAISE NOTICE 'Added comment for column "item.id"';
ELSE
	RAISE NOTICE 'Column "item.id" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='item' and column_name='itemid') THEN
	COMMENT ON COLUMN equipment.item.itemid IS 'Kundens id for vare';
	RAISE NOTICE 'Added comment for column "item.itemid"';
ELSE
	RAISE NOTICE 'Column "item.itemid" does not exist. Dropping comment';
END IF;
END
$$;

-- new table item_attr
CREATE TABLE IF NOT EXISTS equipment.item_attr
(
  id bigserial,
  name character varying(50) NOT NULL,
  key character varying(50),
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  changed_by character varying(50),
  deleted integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_item_attr PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.item_attr
  OWNER TO powercatch;
COMMENT ON TABLE equipment.item_attr IS 'Inneholder attributter knyttet til en vare, f.eks. leverandør, produsent';
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='item_attr' and column_name='id') THEN
	COMMENT ON COLUMN equipment.item_attr.id IS 'PowerCatch intern id for vare attributt';
	RAISE NOTICE 'Added comment for column "item_attr.id"';
ELSE
	RAISE NOTICE 'Column "item_attr.id" does not exist. Dropping comment';
END IF;
END
$$;

-- new table item_attr_value
CREATE TABLE IF NOT EXISTS equipment.item_attr_value
(
  id bigserial,
  id_item bigint NOT NULL,
  id_item_attr bigint NOT NULL,
  value text,
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  changed_by character varying(50),
  deleted integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_item_attr_value PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.item_attr_value
  OWNER TO powercatch;
COMMENT ON TABLE equipment.item_attr_value IS 'Inneholder verdien som er satt for et attributt knyttet til en vare';
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='item_attr_value' and column_name='id') THEN
	COMMENT ON COLUMN equipment.item_attr_value.id IS 'PowerCatch intern id for attributt verdi for vare';
	RAISE NOTICE 'Added comment for column "item_attr_value.id"';
ELSE
	RAISE NOTICE 'Column "item_attr_value.id" does not exist. Dropping comment';
END IF;
END
$$;

-- new table consumption
CREATE TABLE IF NOT EXISTS equipment.consumption
(
  id bigserial,
  issueid character varying(20),
  userid character varying(50),
  date timestamp with time zone,
  id_template bigint,
  status integer,
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  changed_by character varying(50),
  deleted integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_consumption PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.consumption
  OWNER TO powercatch;
COMMENT ON TABLE equipment.consumption IS 'Metadata av forbrukt materiell for en sak (ordre)';
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='consumption' and column_name='id') THEN
	COMMENT ON COLUMN equipment.consumption.id IS 'PowerCatch intern id for metadata knyttet til forbrukt materiell';
	RAISE NOTICE 'Added comment for column "consumption.id"';
ELSE
	RAISE NOTICE 'Column "consumption.id" does not exist. Dropping comment';
END IF;
END
$$;
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='consumption' and column_name='status') THEN
	COMMENT ON COLUMN equipment.consumption.status IS 'Status som brukes ifbm synkronisering mellom server og mobil enhet';
	RAISE NOTICE 'Added comment for column "consumption.status"';
ELSE
	RAISE NOTICE 'Column "consumption.status" does not exist. Dropping comment';
END IF;
END
$$;

-- new table consumption_item
CREATE TABLE IF NOT EXISTS equipment.consumption_item
(
  id bigserial,
  id_item bigint NOT NULL,
  itemqty numeric(8,2),
  id_unit bigint,
  id_stock bigint,
  id_consumption bigint,
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  changed_by character varying(50),
  deleted integer NOT NULL DEFAULT 0,
  CONSTRAINT pk_consumption_item PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE equipment.consumption_item
  OWNER TO powercatch;
COMMENT ON TABLE equipment.consumption_item IS 'Forbrukt materiell for en sak (ordre)';
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='consumption_item' and column_name='id') THEN
	COMMENT ON COLUMN equipment.consumption_item.id IS 'PowerCatch intern id for forbrukt materiell';
	RAISE NOTICE 'Added comment for column "consumption_item.id"';
ELSE
	RAISE NOTICE 'Column "consumption_item.id" does not exist. Dropping comment';
END IF;
END
$$;


DO
$$
BEGIN
IF NOT EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='equipment' and table_name='consumption_item' and column_name='comment') THEN
	ALTER TABLE equipment.consumption_item ADD comment character varying(255);
	COMMENT ON COLUMN equipment.consumption_item.comment IS 'Will contain equipment name if this has been edited on mobile';
	RAISE NOTICE 'Added column "consumption_item.comment"';
ELSE
	RAISE NOTICE 'Column "consumption_item.comment" already exist.';
END IF;
END
$$;

-- TEN-267
-- Opprette nFeed-felt for kundeordretype
CREATE TABLE IF NOT EXISTS prosjekt.key
(
	id bigserial NOT NULL,
	project character varying(100),
	issuetype character varying(100),
	target character varying(100),
	pc_key character varying(100),
	translation_id bigint,
	sortorder integer NOT NULL DEFAULT 0,
	deleted integer NOT NULL DEFAULT 0,
	changed_by character varying(100) DEFAULT 'admin'::character varying,
	changed_date timestamp with time zone NOT NULL DEFAULT now()
);
ALTER TABLE prosjekt.key DROP CONSTRAINT IF EXISTS key_primary_key;
ALTER TABLE prosjekt.key ADD CONSTRAINT key_primary_key PRIMARY KEY (id);
ALTER TABLE prosjekt.key OWNER TO powercatch;

DO
$$
BEGIN
	IF EXISTS (SELECT column_name FROM information_schema.columns WHERE table_catalog = 'powercatch' and table_schema='prosjekt' and table_name='key' and column_name='id') THEN
		COMMENT ON TABLE prosjekt.key IS 'Table used for mapping PC-names with readable text. Entries can be filtered with project, issuetype and target to limit result on query. This table will be used for SA (SJA), FC (Sluttkontroll), tasks, subissues, etc... ';
		COMMENT ON COLUMN prosjekt.key.id IS 'Auto-increment primary key to allow edits';
		COMMENT ON COLUMN prosjekt.key.project IS 'Optional key for project (NETT)';
		COMMENT ON COLUMN prosjekt.key.issuetype IS 'Optional key for issuetype (PC_ISSUETYPE_NETT_WO)';
		COMMENT ON COLUMN prosjekt.key.target IS 'Optional key for where entry will be used (PC_TASK)';
		COMMENT ON COLUMN prosjekt.key.pc_key IS 'PC-name for value value like subissue (PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE) or task ()... These are stored';
		RAISE NOTICE 'Added comments for columns in table key';
	ELSE
		RAISE NOTICE 'Columns does not exist. Dropping comments';
	END IF;
END
$$;

CREATE TABLE IF NOT EXISTS prosjekt.key_translation
(
	id bigserial NOT NULL,
	pc_text character varying(100),
	locale character varying(5) DEFAULT 'no_NO',
	deleted integer NOT NULL DEFAULT 0,
	changed_by character varying(100) DEFAULT 'admin'::character varying,
	changed_date timestamp with time zone NOT NULL DEFAULT now()
);
ALTER TABLE prosjekt.key_translation DROP CONSTRAINT IF EXISTS translation_primary_key;
ALTER TABLE prosjekt.key_translation ADD CONSTRAINT translation_primary_key PRIMARY KEY (id);
ALTER TABLE prosjekt.key_translation OWNER TO powercatch;

DO
$$
BEGIN
	IF EXISTS (SELECT column_name FROM information_schema.columns WHERE table_catalog = 'powercatch' and table_schema='prosjekt' and table_name='key_translation' and column_name='id') THEN
		COMMENT ON COLUMN prosjekt.key_translation.locale IS 'Default value no_NO';
		COMMENT ON COLUMN prosjekt.key_translation.pc_text IS 'Readable text like "Montasje prefab. nettstasjon i mast" to display in front-end for user. These are displayed';
		RAISE NOTICE 'Added comments for columns in table key_translation';
	ELSE
		RAISE NOTICE 'Columns does not exist. Dropping comments';
	END IF;
END
$$;


-- Start PC-3726
CREATE OR REPLACE FUNCTION konfigurasjon.updatefield(id_field character varying, nbr character varying, name character varying, customfieldid numeric, changed_by character varying, deleted integer, gui integer)
  RETURNS integer AS
$BODY$DECLARE
	id_field_var uuid;
	changed timestamp(3);
BEGIN
  id_field_var := $1;
  changed := now();
  
  -- if deleted, update all referenced fieldproperties as deleted too, and all references in table page_fieldproperty
  IF ($6 = 1) THEN
    -- update fieldproperty referencing current field
    update konfigurasjon.fieldproperty set deleted = 1, gui = $7, changed_date = changed, changed_by = $5 where fieldproperty.id_field = id_field_var;
  ELSEIF ($6 = 0) THEN
    -- changed deleted for fieldproperty and page_fieldproperty if field.deleted is changed
    IF (select 1 from konfigurasjon.field where id = id_field_var and field.deleted = 1) THEN
      -- update fieldproperty referencing current field
      update konfigurasjon.fieldproperty set deleted = 0, gui = $7, changed_date = changed, changed_by = $5 where fieldproperty.id_field = id_field_var;
    END IF;
  END IF;

  update konfigurasjon.field
  set nbr = $2, name = $3, customfieldid = $4, changed_date = changed, changed_by = $5, deleted = $6, gui = $7
  where id = id_field_var; 
  
  return 1;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION konfigurasjon.updatefield(character varying, character varying, character varying, numeric, character varying, integer, integer)
  OWNER TO postgres;

  
DROP FUNCTION konfigurasjon.updatefieldproperty(character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying, integer, integer, character varying);
-- End PC-3726