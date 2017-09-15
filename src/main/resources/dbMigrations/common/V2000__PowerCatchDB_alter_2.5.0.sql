--
-- Create infrastruktur tables in the infrastruktur shema
--
SET search_path = infrastruktur, pg_catalog;

CREATE TABLE IF NOT EXISTS object_entity_type (
    id bigserial PRIMARY KEY,
    name character varying(100),
    key character varying(50),
    description character varying(255),
    locale_key character varying(100)
);
ALTER TABLE object_entity_type OWNER TO powercatch;



CREATE TABLE IF NOT EXISTS object_attr (
    id bigserial PRIMARY KEY,
    name character varying(100),
    key character varying(100),
    locale_key character varying(100),
    data_type_id bigint -- an enum stored in java no.resight.powercatch.ObjectAttrType
);
ALTER TABLE object_attr OWNER TO powercatch;



CREATE TABLE IF NOT EXISTS object_entity(
    id bigserial PRIMARY KEY,
    deleted integer NOT NULL, -- boolean with 0/1 because we want the same code to potentially work with Oracle
    parent_id bigint,
    pos_lat double precision,
    pos_long double precision,
    created_by character varying(100) NOT NULL,
    edited_by character varying(100) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    edited_at timestamp with time zone NOT NULL,
    geo_json character varying NOT NULL,
    search_string character varying NOT NULL,
    prop_json character varying NOT NULL,
    type_id bigint NOT NULL  REFERENCES object_entity_type(id)
);
ALTER TABLE object_entity OWNER TO powercatch;


--- CREATE INDEX IF NOT EXISTS parent_id_idx ON object_entity (parent_id);
-- For older versons than Postgres 9.5 we need to do IF NOT EXISTS the hard way
DO $$
BEGIN

IF NOT EXISTS (
    SELECT 1
    FROM   pg_class c
    JOIN   pg_namespace n ON n.oid = c.relnamespace
    WHERE  c.relname = 'parent_id_idx'
    AND    n.nspname = 'infrastruktur' -- 'public' by default
    ) THEN

    CREATE INDEX parent_id_idx ON object_entity (parent_id);
END IF;

END$$;

CREATE TABLE IF NOT EXISTS object_attr_value (
    id bigserial PRIMARY KEY,
    object_entity_id bigint NOT NULL REFERENCES object_entity(id),
    object_attr_id bigint NOT NULL REFERENCES object_attr(id)
);
ALTER TABLE object_attr_value OWNER TO powercatch;



CREATE TABLE IF NOT EXISTS object_attr_date (
    attr_value_id bigint PRIMARY KEY REFERENCES object_attr_value(id),
    value timestamp with time zone NOT NULL
);
ALTER TABLE object_attr_date OWNER TO powercatch;



CREATE TABLE IF NOT EXISTS object_attr_integer (
    attr_value_id bigint PRIMARY KEY REFERENCES object_attr_value(id),
    value bigint NOT NULL
);
ALTER TABLE object_attr_integer OWNER TO powercatch;



CREATE TABLE IF NOT EXISTS object_attr_double (
    attr_value_id bigint PRIMARY KEY REFERENCES object_attr_value(id),
    value double precision
);
ALTER TABLE object_attr_double OWNER TO powercatch;



CREATE TABLE IF NOT EXISTS object_attr_string (
    attr_value_id bigint PRIMARY KEY REFERENCES object_attr_value(id),
    value character varying
);
ALTER TABLE object_attr_string OWNER TO powercatch;



CREATE TABLE IF NOT EXISTS object_attr_text (
    attr_value_id bigint PRIMARY KEY REFERENCES object_attr_value(id),
    value text
);
ALTER TABLE object_attr_text OWNER TO powercatch;