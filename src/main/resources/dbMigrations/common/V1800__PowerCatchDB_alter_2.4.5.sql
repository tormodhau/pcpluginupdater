
-- New table for errorlogging.
CREATE TABLE IF NOT EXISTS prosjekt.errorlogs
(
  user_id character varying(20) NOT NULL,
  dated timestamp without time zone NOT NULL,
  logger character varying(500) NOT NULL,
  level character varying(10) NOT NULL,
  message character varying(1000) NOT NULL
);

-- PC-3448 new function archiving data from sync.issue_backup
CREATE OR REPLACE FUNCTION sync.archivebackup(daystokeep integer, filepath character varying)
  RETURNS integer AS
$BODY$
DECLARE filename character varying;
DECLARE daystring character varying;
DECLARE timenow timestamp;
BEGIN
	timenow := current_timestamp;
	-- create absolute filename
	filename := $2 || current_date || '-' || date_part('hour', timenow) || '.' || date_part('minute', timenow) || '_issue_backup.copy';

	daystring := $1 || ' day';

	-- load data ot archive to temp table
	create temp table archive_table as select * from sync.issue_backup where sync_date < date_trunc('day', NOW()) - daystring::interval order by sync_date;

	-- do the copy to file
	EXECUTE format ('copy archive_table to %L', filename);

	-- delete archived data
	delete from sync.issue_backup where sync_date < date_trunc('day', NOW()) - daystring::interval;

	-- clean up temp table
	drop table archive_table;
RETURN 0;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sync.archivebackup(integer, character varying)
  OWNER TO powercatch;