CREATE TABLE IF NOT EXISTS prosjekt.sa_role
(
  id integer NOT NULL,
  pc_key character varying(255),
  locale character varying(5),
  pc_text character varying(255),
  sortorder integer NOT NULL DEFAULT 0,
  deleted integer NOT NULL DEFAULT 0,
  updateid double precision NOT NULL DEFAULT 0,
  changed_by character varying(100) DEFAULT 'admin'::character varying,
  changed_date timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "PK_ID" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE prosjekt.sa_action
  OWNER TO powercatch;
ALTER TABLE prosjekt.sa_role
  OWNER TO powercatch;