-- used by archiving feature in mobile servlet
CREATE TABLE sync.issue_backup_temp
(
  id uuid,
  key character varying(255),
  username character varying(255),
  sync_status integer,
  sync_date timestamp with time zone,
  content bytea,
  comment text,
  mobilesyncstatus integer,
  steps_executed integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sync.issue_backup_temp
  OWNER TO powercatch;
  
  
CREATE OR REPLACE FUNCTION sync.archivebackupprepare(daystokeep integer)
  RETURNS integer AS
$BODY$
DECLARE daystring character varying;
BEGIN
	daystring := $1 || ' day';

	-- load data ot archive to temp table
	insert into sync.issue_backup_temp select * from sync.issue_backup where sync_date < date_trunc('day', NOW()) - daystring::interval order by sync_date;

RETURN 0;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sync.archivebackupprepare(integer)
  OWNER TO powercatch;

  
CREATE OR REPLACE FUNCTION sync.archivebackupcleanup(daystokeep integer)
  RETURNS integer AS
$BODY$
DECLARE daystring character varying;
BEGIN
	daystring := $1 || ' day';

	-- delete archived data
	delete from sync.issue_backup where sync_date < date_trunc('day', NOW()) - daystring::interval;

	-- clean up temp table
	truncate table sync.issue_backup_temp;
RETURN 0;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sync.archivebackupcleanup(integer)
  OWNER TO powercatch;


-- SUPAMS-160
DO
$$
BEGIN
IF EXISTS (SELECT column_name 
               FROM information_schema.columns 
               WHERE table_catalog = 'powercatch' and table_schema='prosjekt' and table_name='errorlogs' and column_name='message') THEN
	ALTER TABLE prosjekt.errorlogs ALTER COLUMN message TYPE text;
	RAISE NOTICE 'Changed column "errorlogs.message" from character varying(1000) to text';
ELSE
	RAISE NOTICE 'Column "errorlogs.message" does not exist.';
END IF;
END
$$;