
-- New table for risk-analysis (used by Table Grid Editor in project NETT)

CREATE TABLE IF NOT EXISTS netbas.task_group_info
(
  tid integer NOT NULL,
  xml character varying,
  last_changed timestamp without time zone,
  CONSTRAINT "taskId_pk" PRIMARY KEY (tid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE netbas.task_group_info
  OWNER TO powercatch;

  
DROP INDEX IF EXISTS netbas."kontrollpunkt_alle_ids.idx";

CREATE INDEX "kontrollpunkt_alle_ids.idx"
  ON netbas.kontrollpunkt
  USING btree
  (tid, oid, wid, did);
  
DROP INDEX IF EXISTS netbas."delkoponent_tid_wid_oid.idx";

CREATE INDEX "delkoponent_tid_wid_oid.idx"
  ON netbas.delkomponent
  USING btree
  (tid, wid, oid);
  

-- PC-3044 Make some more room for driftsmerking on infrastruktur.
ALTER TABLE infrastruktur.anlegg ALTER COLUMN driftsmerking TYPE character varying(255);
ALTER TABLE infrastruktur.bryter ALTER COLUMN driftsmerking TYPE character varying(255);
ALTER TABLE infrastruktur.bygning ALTER COLUMN driftsmerking TYPE character varying(255);
ALTER TABLE infrastruktur.kabelskap ALTER COLUMN driftsmerking1 TYPE character varying(255);
ALTER TABLE infrastruktur.kabelskap ALTER COLUMN driftsmerking2 TYPE character varying(255);
ALTER TABLE infrastruktur.linje ALTER COLUMN driftsmerking TYPE character varying(255);
ALTER TABLE infrastruktur.mastepunkt ALTER COLUMN driftsmerking TYPE character varying(255);
ALTER TABLE infrastruktur.nettstasjon ALTER COLUMN driftsmerking TYPE character varying(255);
ALTER TABLE infrastruktur.trafo ALTER COLUMN driftsmerking TYPE character varying(255);  