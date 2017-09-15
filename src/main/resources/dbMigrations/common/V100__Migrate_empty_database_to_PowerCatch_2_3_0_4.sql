--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.14
-- Dumped by pg_dump version 9.3.14
-- Started on 2016-11-01 13:02:48

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 8 (class 2615 OID 27117)
-- Name: equipment; Type: SCHEMA; Schema: -; Owner: powercatch
--

CREATE SCHEMA equipment;


ALTER SCHEMA equipment OWNER TO powercatch;

--
-- TOC entry 9 (class 2615 OID 27118)
-- Name: infrastruktur; Type: SCHEMA; Schema: -; Owner: powercatch
--

CREATE SCHEMA infrastruktur;


ALTER SCHEMA infrastruktur OWNER TO powercatch;

--
-- TOC entry 10 (class 2615 OID 27119)
-- Name: konfigurasjon; Type: SCHEMA; Schema: -; Owner: powercatch
--

CREATE SCHEMA konfigurasjon;


ALTER SCHEMA konfigurasjon OWNER TO powercatch;

--
-- TOC entry 11 (class 2615 OID 27120)
-- Name: netbas; Type: SCHEMA; Schema: -; Owner: powercatch
--

CREATE SCHEMA netbas;


ALTER SCHEMA netbas OWNER TO powercatch;

--
-- TOC entry 12 (class 2615 OID 27121)
-- Name: prosjekt; Type: SCHEMA; Schema: -; Owner: powercatch
--

CREATE SCHEMA prosjekt;


ALTER SCHEMA prosjekt OWNER TO powercatch;

--
-- TOC entry 14 (class 2615 OID 27765)
-- Name: sync; Type: SCHEMA; Schema: -; Owner: powercatch
--

CREATE SCHEMA sync;


ALTER SCHEMA sync OWNER TO powercatch;

--
-- TOC entry 15 (class 2615 OID 27122)
-- Name: tekla; Type: SCHEMA; Schema: -; Owner: powercatch
--

CREATE SCHEMA tekla;


ALTER SCHEMA tekla OWNER TO powercatch;

--
-- TOC entry 1 (class 3079 OID 11750)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 27123)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = infrastruktur, pg_catalog;

--
-- TOC entry 292 (class 1255 OID 27134)
-- Name: getpowercatchid(character varying, character varying); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION getpowercatchid(OUT id uuid, no character varying, tablename character varying) RETURNS uuid
    LANGUAGE plpgsql
    AS $_$DECLARE

BEGIN
	EXECUTE 'select id from infrastruktur.' || quote_ident(tablename) || ' WHERE nr = ' || quote_literal($2) INTO id;
END;$_$;


ALTER FUNCTION infrastruktur.getpowercatchid(OUT id uuid, no character varying, tablename character varying) OWNER TO powercatch;

--
-- TOC entry 290 (class 1255 OID 27804)
-- Name: getshortid(character varying); Type: FUNCTION; Schema: infrastruktur; Owner: postgres
--

CREATE FUNCTION getshortid(OUT id character varying, tablename character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
  duplicateId boolean;
  lookupId character varying;
BEGIN
  duplicateId := true;
  WHILE (duplicateId)
  loop

    EXECUTE 'SELECT array_to_string(array((
      SELECT SUBSTRING(''abcdefghjklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'' FROM mod((random()*61)::int, 61)+1 FOR 1)
        FROM generate_series(1,4))),'''')' INTO id;

    EXECUTE 'SELECT short_id FROM infrastruktur.' || quote_ident(tablename) || ' WHERE short_id = ''' || id || '''' INTO lookupId;

    IF (lookupId IS NOT NULL) THEN
	  duplicateId := true;
    ELSE
	  duplicateId := false;
    END IF;

  end loop;
END;
$$;


ALTER FUNCTION infrastruktur.getshortid(OUT id character varying, tablename character varying) OWNER TO postgres;

--
-- TOC entry 321 (class 1255 OID 27805)
-- Name: importsosi(); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION importsosi() RETURNS character varying
    LANGUAGE plpgsql
    AS $$

-- ----------------------------------------------------------------------------------------------------
-- function creating linje and mastepunkt in powercatch-db, schema infrastruktur
-- Source is SOSI-data imported to PostGIS, table object_linestring, using Sosicon
--
--  called using:
--    delete from infrastruktur.mastepunkt;  --optional
--    delete from infrastruktur.linje;       --optional
--    select infrastruktur.importSosi();
--
-- How the select works:
--	- ST_AsText transform the geom-object to readable format:
--		"LINESTRING(10.594639615659 60.3658617640018,10.5941105685325 60.3657478538781)"
--	- 'string_to_array' creates an array containing lat, long and som ekstra text
--	- 'unnest' is used to split coordinate-sets into separate rows
--	- 'trim' is used to remove extra text
--	- Result:
--		1;"10.594639615659";"60.3658617640018";"20065 SKJERVUM K";"HENGEKABEL";"0.230000";"EX 3X95"
--		...for each posistion (mastepunkt) where same value in first column indicates same line (linje )
-- -----------------------------------------------------------------------------------------------------

  declare
    arow record;
    tmpId int;
    counter int;
    counterLines int;
    linjeId uuid;
    mastId uuid;
    shortId varchar(4);
  begin
    counterLines := 0;
    for arow in
	-- select all "linje" and split into "mastepunkt" (see description above)
        SELECT 	id_object_linestring AS id,
		trim('LINESTRING(' from split_part(s.token, ' ', 1))::numeric AS lon,
		trim(')' from split_part(s.token, ' ', 2))::numeric AS lat,
		plassering,
		objtype,
		trim(' kV' from spenning)::numeric As spenningTrimmed,
		typebetegnelse
	FROM	sosicon.object_linestring t, unnest(string_to_array(ST_AsText(t.object_geom), ',')) s(token)
	-- LIMIT 4 -- limit during dev
    loop
	if tmpId = arow.id then
		-- RAISE NOTICE 'Same object(%)', tmpId;
		-- increase counter
		counter := counter + 1;

		-- add mastepunkt
		INSERT INTO infrastruktur.mastepunkt(
				variant, id_linje, pos_lat, pos_long, posisjon, updateid
			) VALUES (
				arow.objtype, linjeId, arow.lat, arow.lon, counter, 1
			) RETURNING id INTO mastId;

		-- RAISE NOTICE 'New object inserted (%), nbr(%)', mastId, counter;

	else
		-- RAISE NOTICE 'New object(%)', tmpId;
		-- reset counter
		counter := 1;
		counterLines := counterLines + 1;

		-- store id to see if next mastepunkt belongs to same object
		tmpId := arow.id;

		-- get a shortId
		shortId := infrastruktur.getshortid('linje');

		-- add linje/kabel  returning new uuid for linje
		INSERT INTO infrastruktur.linje(
				nr, navn, spenning, variant, katalogvalg, pos_lat, pos_long, updateid, short_id
			) VALUES (
				arow.id, arow.plassering, arow.spenningTrimmed, arow.objtype, arow.typebetegnelse, arow.lat, arow.lon, 1, shortId
			) RETURNING id INTO linjeId;

		RAISE NOTICE 'New (%) inserted (%). Total lines: (%)', arow.objtype, linjeId, counterLines;


		-- add mastepunkt
		INSERT INTO infrastruktur.mastepunkt(
				variant, id_linje, pos_lat, pos_long, posisjon, updateid
			) VALUES (
				arow.objtype, linjeId, arow.lat, arow.lon, counter, 1
			) RETURNING id INTO mastId;


		-- RAISE NOTICE 'New object inserted (%), nbr(%)', mastId, counter;
	end if;
    end loop;
    RETURN 'OK - ' || counterLines || ' lines imported';
  end;
$$;


ALTER FUNCTION infrastruktur.importsosi() OWNER TO powercatch;

--
-- TOC entry 293 (class 1255 OID 27135)
-- Name: insertcabinet(character varying, character varying, double precision, double precision, character varying, character varying, double precision, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION insertcabinet(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, fabrikat character varying, voltage double precision, address character varying, description character varying, municipalityno character varying, municipalityname character varying, label2 character varying, barcode character varying, id_disttransformer character varying, id_plant character varying, changed_by character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE
   uidl integer;
   existingrow RECORD;
   id_disttransformer_var uuid;
   id_plant_var uuid;
BEGIN
   SELECT MAX(updateid) + 1 INTO uidl FROM infrastruktur.kabelskap;
   IF uidl IS NULL THEN
      uidl := 1;
   END IF;

   id_disttransformer_var := $15;
   id_plant_var := $16;

   retval = 0;

   SELECT * INTO existingrow FROM infrastruktur.kabelskap WHERE nr = $2;
   IF FOUND THEN
    IF (((existingrow.driftsmerking1 IS NULL AND $3 IS NOT NULL) OR existingrow.driftsmerking1 IS NOT NULL AND $3 IS NULL) OR existingrow.driftsmerking1 <> $3) OR
       (((existingrow.pos_lat IS NULL AND $4 IS NOT NULL) OR existingrow.pos_lat IS NOT NULL AND $4 IS NULL) OR existingrow.pos_lat <> $4) OR
       (((existingrow.pos_long IS NULL AND $5 IS NOT NULL) OR existingrow.pos_long IS NOT NULL AND $5 IS NULL) OR existingrow.pos_long <> $5) OR
       (((existingrow.variant IS NULL AND $6 IS NOT NULL) OR existingrow.variant IS NOT NULL AND $6 IS NULL) OR existingrow.variant <> $6) OR
       (((existingrow.fabrikat IS NULL AND $7 IS NOT NULL) OR existingrow.fabrikat IS NOT NULL AND $7 IS NULL) OR existingrow.fabrikat <> $7) OR
       (((existingrow.spenning IS NULL AND $8 IS NOT NULL) OR existingrow.spenning IS NOT NULL AND $8 IS NULL) OR existingrow.spenning <> $8) OR
       (((existingrow.adresse IS NULL AND $9 IS NOT NULL) OR existingrow.adresse IS NOT NULL AND $9 IS NULL) OR existingrow.adresse <> $9) OR
       (((existingrow.katalogvalg IS NULL AND $10 IS NOT NULL) OR existingrow.katalogvalg IS NOT NULL AND $10 IS NULL) OR existingrow.katalogvalg <> $10) OR
       (((existingrow.kommunenr IS NULL AND $11 IS NOT NULL) OR existingrow.kommunenr IS NOT NULL AND $11 IS NULL) OR existingrow.kommunenr <> $11) OR
       (((existingrow.kommunenavn IS NULL AND $12 IS NOT NULL) OR existingrow.kommunenavn IS NOT NULL AND $12 IS NULL) OR existingrow.kommunenavn <> $12) OR
       (((existingrow.driftsmerking2 IS NULL AND $13 IS NOT NULL) OR existingrow.driftsmerking2 IS NOT NULL AND $13 IS NULL) OR existingrow.driftsmerking2 <> $13) OR
       (((existingrow.strekkode IS NULL AND $14 IS NOT NULL) OR existingrow.strekkode IS NOT NULL AND $14 IS NULL) OR existingrow.strekkode <> $14) OR
       (((existingrow.id_nettstasjon IS NULL AND $15 IS NOT NULL) OR existingrow.id_nettstasjon IS NOT NULL AND $14 IS NULL) OR existingrow.id_nettstasjon <> id_disttransformer_var) OR
       (((existingrow.id_anlegg IS NULL AND $16 IS NOT NULL) OR existingrow.id_anlegg IS NOT NULL AND $14 IS NULL) OR existingrow.id_anlegg <> id_plant_var) OR
       (((existingrow.endret_av IS NULL AND $17 IS NOT NULL) OR existingrow.endret_av IS NOT NULL AND $15 IS NULL) OR existingrow.endret_av <> $17) THEN
      UPDATE infrastruktur.kabelskap
      SET driftsmerking1 = $3, pos_lat = $4, pos_long = $5, variant = $6, fabrikat = $7, spenning = $8, adresse = $9, katalogvalg = $10, kommunenr = $11, kommunenavn = $12, driftsmerking2 = $13,
		strekkode = $14, id_nettstasjon = id_disttransformer_var, id_anlegg = id_plant_var, endret_av = $17, endret_dato = now(), updateid = uidl
      WHERE nr = $2;
      retval = 2;
    END IF;
   ELSE
      INSERT INTO infrastruktur.kabelskap (updateid, nr, driftsmerking1, pos_lat, pos_long, variant, fabrikat, spenning, adresse, katalogvalg, kommunenr, kommunenavn, driftsmerking2, strekkode, id_nettstasjon, id_anlegg, endret_av, endret_dato)
      VALUES (uidl, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, id_disttransformer_var, id_plant_var, $17, now());
      retval = 1;
   END IF;
END;$_$;


ALTER FUNCTION infrastruktur.insertcabinet(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, fabrikat character varying, voltage double precision, address character varying, description character varying, municipalityno character varying, municipalityname character varying, label2 character varying, barcode character varying, id_disttransformer character varying, id_plant character varying, changed_by character varying) OWNER TO powercatch;

--
-- TOC entry 294 (class 1255 OID 27136)
-- Name: insertdistributiontransformer(character varying, character varying, double precision, double precision, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION insertdistributiontransformer(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, variant character varying, barcode character varying, municipalityno character varying, municipalityname character varying, address character varying, name character varying, balancemeetering integer, fingerprotected integer, maxusagelastyear character varying, id_area character varying, changed_by character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE
   uidl integer;
   existingrow RECORD;
   id_area_var uuid;
BEGIN
   SELECT MAX(updateid) + 1 INTO uidl FROM infrastruktur.nettstasjon;
   IF uidl IS NULL THEN
      uidl := 1;
   END IF;

   id_area_var := $15;

   SELECT * INTO existingrow FROM infrastruktur.nettstasjon WHERE nr = $2;
   IF FOUND THEN
    IF (((existingrow.driftsmerking IS NULL AND $3 IS NOT NULL) OR existingrow.driftsmerking IS NOT NULL AND $3 IS NULL) OR existingrow.driftsmerking <> $3) OR
       (((existingrow.pos_lat IS NULL AND $4 IS NOT NULL) OR existingrow.pos_lat IS NOT NULL AND $4 IS NULL) OR existingrow.pos_lat <> $4) OR
       (((existingrow.pos_long IS NULL AND $5 IS NOT NULL) OR existingrow.pos_long IS NOT NULL AND $5 IS NULL) OR existingrow.pos_long <> $5) OR
       (((existingrow.variant IS NULL AND $6 IS NOT NULL) OR existingrow.variant IS NOT NULL AND $6 IS NULL) OR existingrow.variant <> $6) OR
       (((existingrow.strekkode IS NULL AND $7 IS NOT NULL) OR existingrow.strekkode IS NOT NULL AND $7 IS NULL) OR existingrow.strekkode <> $7) OR
       (((existingrow.kommunenr IS NULL AND $8 IS NOT NULL) OR existingrow.kommunenr IS NOT NULL AND $8 IS NULL) OR existingrow.kommunenr <> $8) OR
       (((existingrow.kommunenavn IS NULL AND $9 IS NOT NULL) OR existingrow.kommunenavn IS NOT NULL AND $9 IS NULL) OR existingrow.kommunenavn <> $9) OR
       (((existingrow.adresse IS NULL AND $10 IS NOT NULL) OR existingrow.adresse IS NOT NULL AND $10 IS NULL) OR existingrow.adresse <> $10) OR
       (((existingrow.navn IS NULL AND $11 IS NOT NULL) OR existingrow.navn IS NOT NULL AND $11 IS NULL) OR existingrow.navn <> $11) OR
       (((existingrow.balansemaaling IS NULL AND $12 IS NOT NULL) OR existingrow.balansemaaling IS NOT NULL AND $12 IS NULL) OR existingrow.balansemaaling <> $12) OR
       (((existingrow.beroeringsikker IS NULL AND $13 IS NOT NULL) OR existingrow.beroeringsikker IS NOT NULL AND $13 IS NULL) OR existingrow.beroeringsikker <> $13) OR
       (((existingrow.max_uttak_siste_aar IS NULL AND $14 IS NOT NULL) OR existingrow.max_uttak_siste_aar IS NOT NULL AND $14 IS NULL) OR existingrow.max_uttak_siste_aar <> $14) OR
       (((existingrow.id_omraade IS NULL AND $15 IS NOT NULL) OR existingrow.id_omraade IS NOT NULL AND $15 IS NULL) OR existingrow.id_omraade <> id_area_var) THEN
      UPDATE infrastruktur.nettstasjon
      SET driftsmerking = $3, pos_lat = $4, pos_long = $5, variant = $6, strekkode = $7, kommunenr = $8, kommunenavn = $9, adresse = $10, navn = $11, balansemaaling = $12, beroeringsikker = $13, max_uttak_siste_aar = $14, id_omraade = id_area_var, endret_av = $16, endret_dato = now(), updateid = uidl
      WHERE nr = $2;
    END IF;
   ELSE
      INSERT INTO infrastruktur.nettstasjon (updateid, nr, driftsmerking, pos_lat, pos_long, variant, strekkode, kommunenr, kommunenavn, adresse, navn, balansemaaling, beroeringsikker, max_uttak_siste_aar, id_omraade, endret_av, endret_dato)
      VALUES (uidl, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, id_area_var, $16, now());
   END IF;

   retval = 0;

END;$_$;


ALTER FUNCTION infrastruktur.insertdistributiontransformer(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, variant character varying, barcode character varying, municipalityno character varying, municipalityname character varying, address character varying, name character varying, balancemeetering integer, fingerprotected integer, maxusagelastyear character varying, id_area character varying, changed_by character varying) OWNER TO powercatch;

--
-- TOC entry 295 (class 1255 OID 27137)
-- Name: insertline(character varying, character varying, double precision, double precision, character varying, character varying, double precision, double precision, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION insertline(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, name character varying, voltage double precision, measure double precision, description character varying, pos_list character varying, id_plant character varying, id_area character varying, id_line character varying, changed_by character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE
   uidl integer;
   existingrow RECORD;
   id_line_var uuid;
   id_plant_var uuid;
   id_area_var uuid;
BEGIN
   SELECT MAX(updateid) + 1 INTO uidl FROM infrastruktur.linje;
   IF uidl IS NULL THEN
      uidl := 1;
   END IF;

   id_line_var := $14;
   id_plant_var := $12;
   id_area_var := $13;

   SELECT * INTO existingrow FROM infrastruktur.linje WHERE nr = $2;
   IF FOUND THEN
    IF (((existingrow.driftsmerking IS NULL AND $3 IS NOT NULL) OR existingrow.driftsmerking IS NOT NULL AND $3 IS NULL) OR existingrow.driftsmerking <> $3) OR
       (((existingrow.pos_lat IS NULL AND $4 IS NOT NULL) OR existingrow.pos_lat IS NOT NULL AND $4 IS NULL) OR existingrow.pos_lat <> $4) OR
       (((existingrow.pos_long IS NULL AND $5 IS NOT NULL) OR existingrow.pos_long IS NOT NULL AND $5 IS NULL) OR existingrow.pos_long <> $5) OR
       (((existingrow.variant IS NULL AND $6 IS NOT NULL) OR existingrow.variant IS NOT NULL AND $6 IS NULL) OR existingrow.variant <> $6) OR
       (((existingrow.navn IS NULL AND $7 IS NOT NULL) OR existingrow.navn IS NOT NULL AND $7 IS NULL) OR existingrow.navn <> $7) OR
       (((existingrow.spenning IS NULL AND $8 IS NOT NULL) OR existingrow.spenning IS NOT NULL AND $8 IS NULL) OR existingrow.spenning <> $8) OR
       (((existingrow.antall IS NULL AND $9 IS NOT NULL) OR existingrow.antall IS NOT NULL AND $9 IS NULL) OR existingrow.antall <> $9) OR
       (((existingrow.katalogvalg IS NULL AND $10 IS NOT NULL) OR existingrow.katalogvalg IS NOT NULL AND $10 IS NULL) OR existingrow.katalogvalg <> $10) OR
       (((existingrow.pos_liste IS NULL AND $11 IS NOT NULL) OR existingrow.pos_liste IS NOT NULL AND $11 IS NULL) OR existingrow.pos_liste <> $11) OR
       (((existingrow.id_anlegg IS NULL AND $12 IS NOT NULL) OR existingrow.id_anlegg IS NOT NULL AND $12 IS NULL) OR existingrow.id_anlegg <> id_plant_var) OR
       (((existingrow.id_omraade IS NULL AND $13 IS NOT NULL) OR existingrow.id_omraade IS NOT NULL AND $13 IS NULL) OR existingrow.id_omraade <> id_area_var) OR
       (((existingrow.id_linje IS NULL AND $14 IS NOT NULL) OR existingrow.id_linje IS NOT NULL AND $14 IS NULL) OR existingrow.id_linje <> id_line_var) OR
       (((existingrow.endret_av IS NULL AND $15 IS NOT NULL) OR existingrow.endret_av IS NOT NULL AND $15 IS NULL) OR existingrow.endret_av <> $15) THEN
      UPDATE infrastruktur.linje
      SET driftsmerking = $3, pos_lat = $4, pos_long = $5, variant = $6, navn = $7, spenning = $8, antall = $9, katalogvalg = $10, pos_liste = $11, id_anlegg = id_plant_var, id_omraade = id_area_var,
		id_linje = id_line_var, endret_av = $15, endret_dato = now(), updateid = uidl
      WHERE nr = $2;
    END IF;
   ELSE
      INSERT INTO infrastruktur.linje (updateid, nr, driftsmerking, pos_lat, pos_long, variant, navn, spenning, antall, katalogvalg, pos_liste, id_anlegg, id_omraade, id_linje, endret_av, endret_dato)
      VALUES (uidl, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, id_plant_var, id_area_var, id_line_var, $15, now());
   END IF;

   retval = 0;

END;$_$;


ALTER FUNCTION infrastruktur.insertline(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, name character varying, voltage double precision, measure double precision, description character varying, pos_list character varying, id_plant character varying, id_area character varying, id_line character varying, changed_by character varying) OWNER TO powercatch;

--
-- TOC entry 297 (class 1255 OID 27138)
-- Name: insertpole(character varying, character varying, double precision, double precision, character varying, character varying, integer, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION insertpole(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, barcode character varying, sequence integer, measure integer, description character varying, id_line character varying, id_plant character varying, changed_by character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE
   uidl integer;
   existingrow RECORD;
   id_line_var uuid;
   id_plant_var uuid;
BEGIN
   SELECT MAX(updateid) + 1 INTO uidl FROM infrastruktur.mastepunkt;
   IF uidl IS NULL THEN
      uidl := 1;
   END IF;

   id_line_var := $11;
   id_plant_var := $12;

   SELECT * INTO existingrow FROM infrastruktur.mastepunkt WHERE nr = $2;
   IF FOUND THEN
    IF (((existingrow.driftsmerking IS NULL AND $3 IS NOT NULL) OR existingrow.driftsmerking IS NOT NULL AND $3 IS NULL) OR existingrow.driftsmerking <> $3) OR
       (((existingrow.pos_lat IS NULL AND $4 IS NOT NULL) OR existingrow.pos_lat IS NOT NULL AND $4 IS NULL) OR existingrow.pos_lat <> $4) OR
       (((existingrow.pos_long IS NULL AND $5 IS NOT NULL) OR existingrow.pos_long IS NOT NULL AND $5 IS NULL) OR existingrow.pos_long <> $5) OR
       (((existingrow.variant IS NULL AND $6 IS NOT NULL) OR existingrow.variant IS NOT NULL AND $6 IS NULL) OR existingrow.variant <> $6) OR
       (((existingrow.strekkode IS NULL AND $7 IS NOT NULL) OR existingrow.strekkode IS NOT NULL AND $7 IS NULL) OR existingrow.strekkode <> $7) OR
       (((existingrow.posisjon IS NULL AND $8 IS NOT NULL) OR existingrow.posisjon IS NOT NULL AND $8 IS NULL) OR existingrow.posisjon <> $8) OR
       (((existingrow.antall IS NULL AND $9 IS NOT NULL) OR existingrow.antall IS NOT NULL AND $9 IS NULL) OR existingrow.antall <> $9) OR
       (((existingrow.katalogvalg IS NULL AND $10 IS NOT NULL) OR existingrow.katalogvalg IS NOT NULL AND $10 IS NULL) OR existingrow.katalogvalg <> $10) OR
       (((existingrow.id_linje IS NULL AND $11 IS NOT NULL) OR existingrow.id_linje IS NOT NULL AND $11 IS NULL) OR existingrow.id_linje <> id_line_var) OR
       (((existingrow.id_anlegg IS NULL AND $12 IS NOT NULL) OR existingrow.id_anlegg IS NOT NULL AND $12 IS NULL) OR existingrow.id_anlegg <> id_plant_var) THEN
      UPDATE infrastruktur.mastepunkt
      SET driftsmerking = $3, pos_lat = $4, pos_long = $5, variant = $6, strekkode = $7, posisjon = $8, antall = $9, katalogvalg = $10, id_linje = id_line_var, id_anlegg = id_plant_var, endret_av = $13, endret_dato = now(), updateid = uidl
      WHERE nr = $2;
    END IF;
   ELSE
      INSERT INTO infrastruktur.mastepunkt (updateid, nr, driftsmerking, pos_lat, pos_long, variant, strekkode, posisjon, antall, katalogvalg, id_linje, id_anlegg, endret_av, endret_dato)
      VALUES (uidl, $2, $3, $4, $5, $6, $7, $8, $9, $10, id_line_var, id_plant_var, $13, now());
   END IF;

   retval = 0;

END;$_$;


ALTER FUNCTION infrastruktur.insertpole(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, barcode character varying, sequence integer, measure integer, description character varying, id_line character varying, id_plant character varying, changed_by character varying) OWNER TO powercatch;

--
-- TOC entry 298 (class 1255 OID 27139)
-- Name: insertswitch(character varying, character varying, double precision, double precision, character varying, character varying, character varying); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION insertswitch(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, address character varying, changed_by character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE
   uidl integer;
   existingrow RECORD;
BEGIN
   SELECT MAX(updateid) + 1 INTO uidl FROM infrastruktur.bryter;
   IF uidl IS NULL THEN
      uidl := 1;
   END IF;

   SELECT * INTO existingrow FROM infrastruktur.bryter WHERE nr = $2;
   IF found THEN
    RAISE NOTICE 'Row found: %', $2;
    IF (((existingrow.driftsmerking IS NULL AND $3 IS NOT NULL) OR existingrow.driftsmerking IS NOT NULL AND $3 IS NULL) OR existingrow.driftsmerking <> $3) OR
       (((existingrow.pos_lat IS NULL AND $4 IS NOT NULL) OR existingrow.pos_lat IS NOT NULL AND $4 IS NULL) OR existingrow.pos_lat <> $4) OR
       (((existingrow.pos_long IS NULL AND $5 IS NOT NULL) OR existingrow.pos_long IS NOT NULL AND $5 IS NULL) OR existingrow.pos_long <> $5) OR
       (((existingrow.variant IS NULL AND $6 IS NOT NULL) OR existingrow.variant IS NOT NULL AND $6 IS NULL) OR existingrow.variant <> $6) OR
       (((existingrow.adresse IS NULL AND $7 IS NOT NULL) OR existingrow.adresse IS NOT NULL AND $7 IS NULL) OR existingrow.adresse <> $7) THEN
      RAISE NOTICE 'About to update row: %', $2;
      UPDATE infrastruktur.bryter
      SET driftsmerking = $3, pos_lat = $4, pos_long = $5, variant = $6, adresse = $7, endret_av = $8, endret_dato = now(), uid = uidl
      WHERE nr = $2;
    ELSE
       RAISE NOTICE 'Nothing to update for row: %', $2;
    END IF;
   ELSE
      RAISE NOTICE 'Row not found: %', $2;
      INSERT INTO infrastruktur.bryter (updateid, nr, driftsmerking, pos_lat, pos_long, variant, adresse, endret_av, endret_dato)
      VALUES (uidl, $2, $3, $4, $5, $6, $7, $8, now());
   END IF;

   retval = 0;

END;$_$;


ALTER FUNCTION infrastruktur.insertswitch(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, catalog character varying, address character varying, changed_by character varying) OWNER TO powercatch;

--
-- TOC entry 299 (class 1255 OID 27140)
-- Name: inserttransformer(character varying, character varying, double precision, double precision, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, integer, double precision, character varying, double precision, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: infrastruktur; Owner: powercatch
--

CREATE FUNCTION inserttransformer(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, type character varying, name character varying, catalog character varying, heigth integer, length integer, width integer, totalweigth integer, oilweigth integer, oiltype character varying, producer character varying, productionyear integer, voltage double precision, voltagesystem character varying, size double precision, gjennomforingstype character varying, konservatortype character varying, transformernote character varying, id_distributiontransformer character varying, id_plant character varying, changed_by character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$DECLARE
   uidl integer;
   existingrow RECORD;
   id_distributiontransformer_var uuid;
   id_plant_var uuid;
BEGIN
   SELECT MAX(updateid) + 1 INTO uidl FROM infrastruktur.trafo;
   IF uidl IS NULL THEN
      uidl := 1;
   END IF;

   id_distributiontransformer_var := $23;
   id_plant_var := $24;

   SELECT * INTO existingrow FROM infrastruktur.trafo WHERE nr = $2;
   IF FOUND THEN
    IF (((existingrow.driftsmerking IS NULL AND $3 IS NOT NULL) OR existingrow.driftsmerking IS NOT NULL AND $3 IS NULL) OR existingrow.driftsmerking <> $3) OR
       (((existingrow.pos_lat IS NULL AND $4 IS NOT NULL) OR existingrow.pos_lat IS NOT NULL AND $4 IS NULL) OR existingrow.pos_lat <> $4) OR
       (((existingrow.pos_long IS NULL AND $5 IS NOT NULL) OR existingrow.pos_long IS NOT NULL AND $5 IS NULL) OR existingrow.pos_long <> $5) OR
       (((existingrow.variant IS NULL AND $6 IS NOT NULL) OR existingrow.variant IS NOT NULL AND $6 IS NULL) OR existingrow.variant <> $6) OR
       (((existingrow.navn IS NULL AND $7 IS NOT NULL) OR existingrow.navn IS NOT NULL AND $7 IS NULL) OR existingrow.navn <> $7) OR
       (((existingrow.katalogvalg IS NULL AND $8 IS NOT NULL) OR existingrow.katalogvalg IS NOT NULL AND $8 IS NULL) OR existingrow.katalogvalg <> $8) OR
       (((existingrow.hoeyde IS NULL AND $9 IS NOT NULL) OR existingrow.hoeyde IS NOT NULL AND $9 IS NULL) OR existingrow.hoeyde <> $9) OR
       (((existingrow.lengde IS NULL AND $10 IS NOT NULL) OR existingrow.lengde IS NOT NULL AND $10 IS NULL) OR existingrow.lengde <> $10) OR
       (((existingrow.bredde IS NULL AND $11 IS NOT NULL) OR existingrow.bredde IS NOT NULL AND $11 IS NULL) OR existingrow.bredde <> $11) OR
       (((existingrow.totalvekt IS NULL AND $12 IS NOT NULL) OR existingrow.totalvekt IS NOT NULL AND $12 IS NULL) OR existingrow.totalvekt <> $12) OR
       (((existingrow.oljevekt IS NULL AND $13 IS NOT NULL) OR existingrow.oljevekt IS NOT NULL AND $13 IS NULL) OR existingrow.oljevekt <> $13) OR
       (((existingrow.oljetype IS NULL AND $14 IS NOT NULL) OR existingrow.oljetype IS NOT NULL AND $14 IS NULL) OR existingrow.oljetype <> $14) OR
       (((existingrow.produsent IS NULL AND $15 IS NOT NULL) OR existingrow.produsent IS NOT NULL AND $15 IS NULL) OR existingrow.produsent <> $15) OR
       (((existingrow.produksjonsaar IS NULL AND $16 IS NOT NULL) OR existingrow.produksjonsaar IS NOT NULL AND $16 IS NULL) OR existingrow.produksjonsaar <> $16) OR
       (((existingrow.spenning IS NULL AND $17 IS NOT NULL) OR existingrow.spenning IS NOT NULL AND $17 IS NULL) OR existingrow.spenning <> $17) OR
       (((existingrow.spenningssystem IS NULL AND $18 IS NOT NULL) OR existingrow.spenningssystem IS NOT NULL AND $18 IS NULL) OR existingrow.spenningssystem <> $18) OR
       (((existingrow.stoerrelse IS NULL AND $19 IS NOT NULL) OR existingrow.stoerrelse IS NOT NULL AND $19 IS NULL) OR existingrow.stoerrelse <> $19) OR
       (((existingrow.gjennomfoeringstype IS NULL AND $20 IS NOT NULL) OR existingrow.gjennomfoeringstype IS NOT NULL AND $20 IS NULL) OR existingrow.gjennomfoeringstype <> $20) OR
       (((existingrow.konservatortype IS NULL AND $21 IS NOT NULL) OR existingrow.konservatortype IS NOT NULL AND $21 IS NULL) OR existingrow.konservatortype <> $21) OR
       (((existingrow.trafomerknad IS NULL AND $22 IS NOT NULL) OR existingrow.trafomerknad IS NOT NULL AND $22 IS NULL) OR existingrow.trafomerknad <> $22) OR
       (((existingrow.id_nettstasjon IS NULL AND $23 IS NOT NULL) OR existingrow.id_nettstasjon IS NOT NULL AND $23 IS NULL) OR existingrow.id_nettstasjon <> id_distributiontransformer_var) OR
       (((existingrow.id_anlegg IS NULL AND $24 IS NOT NULL) OR existingrow.id_anlegg IS NOT NULL AND $24 IS NULL) OR existingrow.id_anlegg <> id_plant_var) THEN
      UPDATE infrastruktur.trafo
      SET driftsmerking = $3, pos_lat = $4, pos_long = $5, variant = $6, navn = $7, katalogvalg = $8, hoeyde = $9, lengde = $10, bredde = $11, totalvekt = $12, oljevekt = $13, oljetype = $14,
	produsent = $15, produksjonsaar = $16, spenning = $17, spenningssystem = $18, stoerrelse = $19, gjennomfoeringstype = $20, konservatortype = $21, trafomerknad = $22,
	id_nettstasjon = id_distributiontransformer_var, id_anlegg = id_plant_var, endret_av = $25, endret_dato = now(), updateid = uidl
      WHERE nr = $2;
    END IF;
   ELSE
      INSERT INTO infrastruktur.trafo (updateid, nr, driftsmerking, pos_lat, pos_long, variant, navn, katalogvalg, hoeyde, lengde, bredde, totalvekt, oljevekt, oljetype, produsent, produksjonsaar,
	spenning, spenningssystem, stoerrelse, gjennomfoeringstype, konservatortype, trafomerknad, id_nettstasjon, id_anlegg, endret_av, endret_dato)
      VALUES (uidl, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, id_distributiontransformer_var, id_plant_var, $25, now());
   END IF;

   retval = 0;

END;$_$;


ALTER FUNCTION infrastruktur.inserttransformer(OUT retval integer, no character varying, label character varying, pos_lat double precision, pos_lon double precision, type character varying, name character varying, catalog character varying, heigth integer, length integer, width integer, totalweigth integer, oilweigth integer, oiltype character varying, producer character varying, productionyear integer, voltage double precision, voltagesystem character varying, size double precision, gjennomforingstype character varying, konservatortype character varying, transformernote character varying, id_distributiontransformer character varying, id_plant character varying, changed_by character varying) OWNER TO powercatch;

SET search_path = konfigurasjon, pg_catalog;

--
-- TOC entry 289 (class 1255 OID 27142)
-- Name: getAllLayouts(); Type: FUNCTION; Schema: konfigurasjon; Owner: powercatch
--

CREATE FUNCTION "getAllLayouts"() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$DECLARE
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
		fp."checkboxvalidationid" as checkboxvalidationid
	from
		konfigurasjon."issuetype" it
	inner join
		konfigurasjon."issuetype_page" ip on it."id" = ip."id_issuetype"
	inner join
		konfigurasjon."page" p on p."id" = ip."id_page"
	left join
		konfigurasjon."page_fieldproperty" pfp on pfp."id_page" = p."id"
	left join
		konfigurasjon."fieldproperty" fp on fp."id" = pfp."id_fieldproperty"
	left join
		konfigurasjon."field" f on f."id" = fp."id_field"
	order by
		it."name", it."project_key", ip."sortorder", pfp."sortorder";
RETURN mycurs;
END;$$;


ALTER FUNCTION konfigurasjon."getAllLayouts"() OWNER TO powercatch;

--
-- TOC entry 300 (class 1255 OID 27143)
-- Name: updateField(uuid, character varying, character varying, numeric, character varying, boolean); Type: FUNCTION; Schema: konfigurasjon; Owner: powercatch
--

CREATE FUNCTION "updateField"(id_field uuid, number character varying, name character varying, customfieldid numeric, changed_by character varying, deleted boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $_$BEGIN
  -- if deleted, update all referenced fieldproperties as deleted too, and all references in table page_fieldproperty
  IF ($6 = true) THEN
    -- update fieldproperty referencing current field
    update konfigurasjon."fieldproperty" set "deleted" = true where fieldproperty."id_field" = $1;

    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon."page_fieldproperty" set "deleted" = true where page_fieldproperty."id_fieldproperty" in
      (select "id" from konfigurasjon."fieldproperty" where fieldproperty."id_field" = $1);
  ELSEIF ($6 = false) THEN
    -- changed deleted for fieldproperty and page_fieldproperty if field.deleted is changed
    IF (select 1 from konfigurasjon."field" where "id" = $1 and field."deleted" = true) THEN
      -- update fieldproperty referencing current field
      update konfigurasjon."fieldproperty" set "deleted" = false where fieldproperty."id_field" = $1;

      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon."page_fieldproperty" set "deleted" = false where page_fieldproperty."id_fieldproperty" in
        (select "id" from konfigurasjon."fieldproperty" where fieldproperty."id_field" = $1);
    END IF;
  END IF;

  update konfigurasjon."field"
  set "number" = $2, "name" = $3, "customfieldid" = $4, "changed_date" = now(), "changed_by" = $5, "deleted" = $6
  where "id" = $1;

  return 1;
END;$_$;


ALTER FUNCTION konfigurasjon."updateField"(id_field uuid, number character varying, name character varying, customfieldid numeric, changed_by character varying, deleted boolean) OWNER TO powercatch;

--
-- TOC entry 284 (class 1255 OID 27144)
-- Name: updateFieldproperty(uuid, character varying, boolean, boolean, integer, character varying, boolean); Type: FUNCTION; Schema: konfigurasjon; Owner: powercatch
--

CREATE FUNCTION "updateFieldproperty"(id_fieldproperty uuid, label character varying, editable boolean, required boolean, checkboxvalidationid integer, changed_by character varying, deleted boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $_$BEGIN
  -- if deleted, update all references in table page_fieldproperty
  IF ($7 = true) THEN
    -- update table page_fieldproperty referencing fieldproperty
    update konfigurasjon."page_fieldproperty" set "deleted" = true where page_fieldproperty."id_fieldproperty" = $1;
  ELSEIF ($7 = false) THEN
    -- change deleted for page_fieldproperty if fieldproperty.deleted is changed
    IF (select 1 from konfigurasjon."fieldproperty" where "id" = $1 and fieldproperty."deleted" = true) THEN
      -- update table page_fieldproperty referencing fieldproperty
      update konfigurasjon."page_fieldproperty" set "deleted" = false where page_fieldproperty."id_fieldproperty" = $1;
    END IF;
  END IF;

  update konfigurasjon."fieldproperty"
  set "label" = $2, "editable" = $3, "required" = $4, "checkboxvalidationid" = $5, "changed_date" = now(), "changed_by" = $6, "deleted" = $7
  where "id" = $1;

  return 1;
END;$_$;


ALTER FUNCTION konfigurasjon."updateFieldproperty"(id_fieldproperty uuid, label character varying, editable boolean, required boolean, checkboxvalidationid integer, changed_by character varying, deleted boolean) OWNER TO powercatch;

SET search_path = public, pg_catalog;

--
-- TOC entry 280 (class 1255 OID 27153)
-- Name: modified_stamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION modified_stamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- get timestamp
        NEW.endret_dato := current_timestamp;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.modified_stamp() OWNER TO postgres;

SET search_path = infrastruktur, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 180 (class 1259 OID 27154)
-- Name: kabelskap; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE kabelskap (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr character varying(30),
    driftsmerking1 character varying(50),
    driftsmerking2 character varying(50),
    fabrikat character varying(30),
    variant character varying(50),
    spenning double precision,
    adresse character varying(150),
    kommunenr character varying(5),
    kommunenavn character varying(100),
    pos_lat double precision,
    pos_long double precision,
    strekkode character varying(50),
    id_nettstasjon uuid,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    nettstasjon text,
    updateid double precision DEFAULT 0 NOT NULL,
    katalogvalg character varying(100),
    id_anlegg uuid
);


ALTER TABLE infrastruktur.kabelskap OWNER TO powercatch;

--
-- TOC entry 2688 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN kabelskap.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN kabelskap.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2689 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN kabelskap.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN kabelskap.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2690 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN kabelskap.id_nettstasjon; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN kabelskap.id_nettstasjon IS 'Referanse til tilhÃ¸rende nettstasjon objekt.';


--
-- TOC entry 2691 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN kabelskap.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN kabelskap.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2692 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN kabelskap.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN kabelskap.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2693 (class 0 OID 0)
-- Dependencies: 180
-- Name: COLUMN kabelskap.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN kabelskap.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


SET search_path = public, pg_catalog;

--
-- TOC entry 281 (class 1255 OID 27164)
-- Name: updatekabelskapuid(); Type: FUNCTION; Schema: public; Owner: powercatch
--

CREATE FUNCTION updatekabelskapuid() RETURNS SETOF infrastruktur.kabelskap
    LANGUAGE plpgsql
    AS $$
DECLARE
r infrastruktur."kabelskap"%rowtype;
i integer;
	BEGIN
	i := 0;
	FOR r IN SELECT * FROM infrastruktur."kabelskap"
	WHERE uid = 0
	LOOP
	update infrastruktur."kabelskap" set "uid" = i + 1 where r."id" = kabelskap."id";
	i := i + 1;
	RETURN NEXT r; --return current row of SELECT
	END LOOP;
	RETURN;
	END
$$;


ALTER FUNCTION public.updatekabelskapuid() OWNER TO powercatch;

SET search_path = infrastruktur, pg_catalog;

--
-- TOC entry 181 (class 1259 OID 27165)
-- Name: nettstasjon; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE nettstasjon (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr character varying(30),
    navn character varying(100),
    variant character varying(100),
    adresse character varying(100),
    kommunenr character varying(5),
    kommunenavn character varying(100),
    balansemaaling integer,
    beroeringsikker integer,
    max_uttak_siste_aar character varying(10),
    strekkode character varying(50),
    pos_lat double precision,
    pos_long double precision,
    id_omraade uuid,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    driftsmerking character varying(32)
);


ALTER TABLE infrastruktur.nettstasjon OWNER TO powercatch;

--
-- TOC entry 2694 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN nettstasjon.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nettstasjon.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2695 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN nettstasjon.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nettstasjon.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2696 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN nettstasjon.id_omraade; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nettstasjon.id_omraade IS 'Referanse til tilhÃ¸rende omrÃ¥de';


--
-- TOC entry 2697 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN nettstasjon.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nettstasjon.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2698 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN nettstasjon.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nettstasjon.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2699 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN nettstasjon.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nettstasjon.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


SET search_path = public, pg_catalog;

--
-- TOC entry 282 (class 1255 OID 27175)
-- Name: updatenettstasjonuid(); Type: FUNCTION; Schema: public; Owner: powercatch
--

CREATE FUNCTION updatenettstasjonuid() RETURNS SETOF infrastruktur.nettstasjon
    LANGUAGE plpgsql
    AS $$
DECLARE
r infrastruktur."nettstasjon"%rowtype;
i integer;
	BEGIN
	i := 0;
	FOR r IN SELECT * FROM infrastruktur."nettstasjon"
	WHERE uid = 0
	LOOP
	update infrastruktur."nettstasjon" set "uid" = i + 1 where r."id" = nettstasjon."id";
	i := i + 1;
	RETURN NEXT r; --return current row of SELECT
	END LOOP;
	RETURN;
	END
$$;


ALTER FUNCTION public.updatenettstasjonuid() OWNER TO powercatch;

SET search_path = infrastruktur, pg_catalog;

--
-- TOC entry 182 (class 1259 OID 27176)
-- Name: mastepunkt; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE mastepunkt (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr character varying(50),
    driftsmerking character varying(50),
    variant character varying(50),
    pos_lat double precision,
    pos_long double precision,
    strekkode character varying(50),
    id_linje uuid,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    posisjon integer,
    antall integer,
    katalogvalg character varying(100),
    id_anlegg uuid,
    showinmap integer DEFAULT 0
);


ALTER TABLE infrastruktur.mastepunkt OWNER TO powercatch;

--
-- TOC entry 2700 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN mastepunkt.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN mastepunkt.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2701 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN mastepunkt.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN mastepunkt.nr IS 'Fagsystemets nÃƒÂ¸kkelverdi for objektet.';


--
-- TOC entry 2702 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN mastepunkt.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN mastepunkt.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2703 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN mastepunkt.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN mastepunkt.endret_dato IS 'NÃƒÂ¥r tid ble raden sist endret.';


--
-- TOC entry 2704 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN mastepunkt.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN mastepunkt.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


SET search_path = public, pg_catalog;

--
-- TOC entry 283 (class 1255 OID 27183)
-- Name: updatenmastepunktuid(); Type: FUNCTION; Schema: public; Owner: powercatch
--

CREATE FUNCTION updatenmastepunktuid() RETURNS SETOF infrastruktur.mastepunkt
    LANGUAGE plpgsql
    AS $$
DECLARE
r infrastruktur."mastepunkt"%rowtype;
i integer;
	BEGIN
	i := 0;
	FOR r IN SELECT * FROM infrastruktur."mastepunkt"
	WHERE uid = 0
	LOOP
	update infrastruktur."mastepunkt" set "uid" = i + 1 where r."id" = mastepunkt."id";
	i := i + 1;
	RETURN NEXT r; --return current row of SELECT
	END LOOP;
	RETURN;
	END
$$;


ALTER FUNCTION public.updatenmastepunktuid() OWNER TO powercatch;

SET search_path = tekla, pg_catalog;

--
-- TOC entry 285 (class 1255 OID 27184)
-- Name: getattrvalues(integer, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getattrvalues(object_id integer, order_id integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$DECLARE
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select av.field, av.value
	from tekla.attrvalue av
	inner join tekla.teklaobject ob on av.id_object = ob.id
	inner join tekla.teklaorder o on ob.id_order = o.id
        where o.order_id = $2 and ob.object_id = $1;
RETURN mycurs;
END;$_$;


ALTER FUNCTION tekla.getattrvalues(object_id integer, order_id integer) OWNER TO powercatch;

--
-- TOC entry 286 (class 1255 OID 27185)
-- Name: getclasses(); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getclasses() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$DECLARE
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select c.id, c.name, t.table_id, t.name as tablename
	from tekla.sysdataclass c
	inner join tekla.sysdatatable t on t.id = c.id_table and c.deleted = 0 and t.deleted = 0
	order by t.table_id asc;
RETURN mycurs;
END;$$;


ALTER FUNCTION tekla.getclasses() OWNER TO powercatch;

--
-- TOC entry 301 (class 1255 OID 27186)
-- Name: getclassname(integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getclassname(OUT classname character varying, classid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$DECLARE

BEGIN
	select c.name into classname
	from tekla.sysdataclass c
	where id = $2;
END;$_$;


ALTER FUNCTION tekla.getclassname(OUT classname character varying, classid integer) OWNER TO powercatch;

--
-- TOC entry 302 (class 1255 OID 27187)
-- Name: getcondclass(integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getcondclass(condclassid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$DECLARE
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select cc.condclass_id, cc.name, cc.defaultvalue, cc.valuetype, cc.datatype, cc.actiontype
	from tekla.condclass cc
        where cc.condclass_id = $1;
RETURN mycurs;
END;$_$;


ALTER FUNCTION tekla.getcondclass(condclassid integer) OWNER TO powercatch;

--
-- TOC entry 303 (class 1255 OID 27188)
-- Name: getcondvalues(integer, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getcondvalues(object_id integer, order_id integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$DECLARE
	mycurs refcursor := 'mycursor';
	tempcurs1 refcursor;
	tempcurs2 refcursor;
	tempcurs3 refcursor;
	mainParentRow RECORD;
	childRow RECORD;
	child2Row RECORD;
BEGIN
-- need temp table to store data to be returned
-- first check if table exists. If true then truncate table. If not create it.
CREATE TEMP TABLE iF NOT EXISTS temp2(id_condclass_id integer, id_parent_condclass_id integer, value character varying, comment character varying, id_urgency integer, id integer, datatype integer, globalsortorder serial) ON COMMIT DROP;
IF ((select count(*) from temp2) > 0) THEN
	delete from temp2;
END IF;

-- first get all main parent rows
OPEN tempcurs1 FOR
	select cv.id_condclass_id, cv.id_parent_condclass_id, cv.value, cv.comment, cv.id_urgency, cv.id, cc.datatype, cv.id_action
	from tekla.condvalue cv
	inner join tekla.teklaobject ob on cv.id_object = ob.id
	inner join tekla.teklaorder o on ob.id_order = o.id and o.order_id = $2 and ob.object_id = $1
	inner join tekla.condclass cc on cc.condclass_id = cv.id_condclass_id and cc.deleted = 0
	where cv.id_parent_condclass_id = 0
	order by cv.sortorder, cv.id_parent_condclass_id, cv.id;

	-- loop main parent rows
	LOOP
		FETCH tempcurs1 INTO mainParentRow;
		EXIT WHEN NOT FOUND;

		insert into temp2 values (mainParentRow.id_condclass_id, mainParentRow.id_parent_condclass_id, mainParentRow.value, mainParentRow.comment, mainParentRow.id_urgency, mainParentRow.id, mainParentRow.datatype);
		-- get child rows for each main parent row
		OPEN tempcurs2 FOR
			select cv.id_condclass_id, cv.id_parent_condclass_id, cv.value, cv.comment, cv.id_urgency, cv.id, cc.datatype, cv.id_action
			from tekla.condvalue cv
			inner join tekla.teklaobject ob on cv.id_object = ob.id
			inner join tekla.teklaorder o on ob.id_order = o.id and o.order_id = $2 and ob.object_id = $1
			inner join tekla.condclass cc on cc.condclass_id = cv.id_condclass_id and cc.deleted = 0
			where cv.id_parent_condclass_id = mainParentRow.id_condclass_id and cv.id_action = mainParentRow.id_action
			order by cv.sortorder, cv.id_parent_condclass_id, cv.id;

			LOOP
				FETCH tempcurs2 INTO childRow;
				EXIT WHEN NOT FOUND;

				insert into temp2 values (childRow.id_condclass_id, childRow.id_parent_condclass_id, childRow.value, childRow.comment, childRow.id_urgency, childRow.id, childRow.datatype);
				-- get child rows of child rows
				OPEN tempcurs3 FOR
					select cv.id_condclass_id, cv.id_parent_condclass_id, cv.value, cv.comment, cv.id_urgency, cv.id, cc.datatype
					from tekla.condcalue cv
					inner join tekla.teklaobject ob on cv.id_object = ob.id
					inner join tekla.teklaorder o on ob.id_order = o.id and o.order_id = $2 and ob.object_id = $1
					inner join tekla.condclass cc on cc.condclass_id = cv.id_condclass_id and cc.deleted = 0
					where cv.id_parent_condclass_id = childRow.id_condClass_id and cv.id_action = childRow.id_action
					order by ob.object_id, cv.sortorder, cv.id_parent_condclass_id, cv.id;

					LOOP
						FETCH tempcurs3 INTO child2Row;
						EXIT WHEN NOT FOUND;

						insert into temp2 values (child2Row.id_condclass_id, child2Row.id_parent_condclass_id, child2Row.value, child2Row.comment, child2Row.id_urgency, child2Row.id, child2Row.datatype);

					END LOOP;
				CLOSE tempcurs3;
			END LOOP;
		 CLOSE tempcurs2;
	END LOOP;

CLOSE tempcurs1;

OPEN mycurs FOR
	select id_condclass_id, id_parent_condclass_id, value, comment, id_urgency, id, datatype from temp2 order by globalsortorder asc;
RETURN mycurs;
CLOSE mycurs;

END;$_$;


ALTER FUNCTION tekla.getcondvalues(object_id integer, order_id integer) OWNER TO powercatch;

--
-- TOC entry 304 (class 1255 OID 27189)
-- Name: getissueattributes(integer, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getissueattributes(orderid integer, objectid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$DECLARE
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select av.field, av.value, f.visiblename
	from tekla.attrvalue av
	inner join tekla.teklaobject ob on av.id_object = ob.id
	inner join tekla.teklaorder o on ob.id_order = o.id
	inner join tekla.field f on lower(f.name) = lower(av.field) and f.id_table = ob.id_table and f.deleted = 0
	where o.order_id = $1 and ob.object_id = $2;
RETURN mycurs;
END;$_$;


ALTER FUNCTION tekla.getissueattributes(orderid integer, objectid integer) OWNER TO powercatch;

--
-- TOC entry 305 (class 1255 OID 27190)
-- Name: getissueconditions(integer, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getissueconditions(orderid integer, objectid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$DECLARE
	mycurs refcursor := 'mycursor';
	tempcurs1 refcursor;
	tempcurs2 refcursor;
	tempcurs3 refcursor;
	tempcurs4 refcursor;
	mainParentRow RECORD;
	childRow RECORD;
	child2Row RECORD;
BEGIN
-- need temp table to store data to be returned
CREATE TEMP TABLE temp2(object_id integer, objectid integer, id_condclass_id integer, id_parent_condclass_id integer, sortorder integer, value character varying, name character varying, valuetype integer, comment character varying, id_urgency integer, condvalid integer, id_action integer, datatype integer, unit character varying, description character varying, globalsortorder serial) ON COMMIT DROP;

-- first get all main parent rows
OPEN tempcurs1 FOR
	select ob.object_id, ob.id as objectid, cv.id_condclass_id, cv.id_parent_condclass_id, cv.sortorder, cv.value, cc.name, cc.valuetype, cv.comment, cv.id_urgency, cv.id as condvalid, cv.id_action, cc.datatype, cc.unit, cc.description
	from tekla.condvalue cv
	inner join tekla.teklaobject ob on cv.id_object = ob.id
	inner join tekla.teklaorder o on ob.id_order = o.id and o.order_id = $1 and ob.object_id = $2
	inner join tekla.condclass cc on cc.condclass_id = cv.id_condclass_id and cc.deleted = 0
	where cv.id_parent_condclass_id = 0
	order by ob.object_id, cv.sortorder, cv.id_parent_condclass_id, cv.id;

	-- loop main parent rows
	LOOP
		FETCH tempcurs1 INTO mainParentRow;
		EXIT WHEN NOT FOUND;

		insert into temp2 values (mainParentRow.object_id, mainParentRow.objectid, mainParentRow.id_condclass_id, mainParentRow.id_parent_condclass_id, mainParentRow.sortorder, mainParentRow.value, mainParentRow.name, mainParentRow.valuetype, mainParentRow.comment, mainParentRow.id_urgency, mainParentRow.condvalid, mainParentRow.id_action, mainParentRow.datatype, mainParentRow.unit, mainParentRow.description);
		-- get child rows for each main parent row
		OPEN tempcurs2 FOR
			select ob.object_id, ob.id as objectid, cv.id_condclass_id, cv.id_parent_condclass_id, cv.sortorder, cv.value, cc.name, cc.valuetype, cv.comment, cv.id_urgency, cv.id as condvalid, cv.id_action, cc.datatype, cc.unit, cc.description
			from tekla.condvalue cv
			inner join tekla.teklaobject ob on cv.id_object = ob.id
			inner join tekla.teklaorder o on ob.id_order = o.id and o.order_id = $1 and ob.object_id = $2
			inner join tekla.condclass cc on cc.condclass_id = cv.id_condclass_id and cc.deleted = 0
			where cv.id_parent_condclass_id = mainParentRow.id_condclass_id and cv.id_action = mainParentRow.id_action
			order by ob.object_id, cv.sortorder, cv.id_parent_condclass_id, cv.id;

			LOOP
				FETCH tempcurs2 INTO childRow;
				EXIT WHEN NOT FOUND;

				insert into temp2 values (childRow.object_id, childRow.objectid, childRow.id_condclass_id, childRow.id_parent_condclass_id, childRow.sortorder, childRow.value, childRow.name, childRow.valuetype, childRow.comment, childRow.id_urgency, childRow.condvalid, childRow.id_action, childRow.datatype, childRow.unit, childRow.description);
				-- get child rows of child rows
				OPEN tempcurs3 FOR
					select ob.object_id, ob.id as objectid, cv.id_condclass_id, cv.id_parent_condclass_id, cv.sortorder, cv.value, cc.name, cc.valuetype, cv.comment, cv.id_urgency, cv.id as condvalid, cv.id_action, cc.datatype, cc.unit, cc.description
					from tekla.condvalue cv
					inner join tekla.teklaobject ob on cv.id_object = ob.id
					inner join tekla.teklaorder o on ob.id_order = o.id and o.order_id = $1 and ob.object_id = $2
					inner join tekla.condclass cc on cc.condclass_id = cv.id_condclass_id and cc.deleted = 0
					where cv.id_parent_condclass_id = childRow.id_condclass_id and cv.id_action = childRow.id_action
					order by ob.object_id, cv.sortorder, cv.id_parent_condclass_id, cv.id;

					LOOP
						FETCH tempcurs3 INTO child2Row;
						EXIT WHEN NOT FOUND;

						insert into temp2 values (child2Row.object_id, child2Row.objectid, child2Row.id_condclass_id, child2Row.id_parent_condclass_id, child2Row.sortorder, child2Row.value, child2Row.name, child2Row.valuetype, child2Row.comment, child2Row.id_urgency, child2Row.condvalid, child2Row.id_action, child2Row.datatype, child2Row.unit, child2Row.description);

					END LOOP;
				CLOSE tempcurs3;
			END LOOP;
		 CLOSE tempcurs2;
	END LOOP;

CLOSE tempcurs1;

OPEN mycurs FOR
	select object_id, temp2.objectid, id_condclass_id, id_parent_condclass_id, sortorder, value, name, valuetype, comment, id_urgency, condvalid, id_action, datatype, unit, description from temp2 order by globalsortorder asc;
RETURN mycurs;

END;$_$;


ALTER FUNCTION tekla.getissueconditions(orderid integer, objectid integer) OWNER TO powercatch;

--
-- TOC entry 306 (class 1255 OID 27191)
-- Name: getissueconditionvalues(integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getissueconditionvalues(id_condclass_id integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$DECLARE
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select ccv.id_condclass_id, ccv.code, ccv.description
	from tekla.condclassvalues ccv
	inner join tekla.condclass cc on ccv.id_condclass_id = cc.condclass_id and ccv.deleted = 0
	where cc.condclass_id = $1
	order by ccv.code;
RETURN mycurs;
END;$_$;


ALTER FUNCTION tekla.getissueconditionvalues(id_condclass_id integer) OWNER TO powercatch;

--
-- TOC entry 307 (class 1255 OID 27192)
-- Name: getobjectlinks(character varying[]); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION getobjectlinks(issuekeys character varying[]) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$DECLARE
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select o1.issue_key as parentkey, o2.issue_key as childkey
	from tekla.teklaobject o1
	inner join tekla.teklaobject o2 on o1.id = o2.id_object
	where o2.issue_key =  any($1) and o1.id_object = 0
	order by o1.issue_key, o2.issue_key;
RETURN mycurs;
END;$_$;


ALTER FUNCTION tekla.getobjectlinks(issuekeys character varying[]) OWNER TO powercatch;

--
-- TOC entry 308 (class 1255 OID 27193)
-- Name: geturgencyvalues(); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION geturgencyvalues() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$DECLARE
	mycurs refcursor;
BEGIN
OPEN mycurs FOR
	select code, value
	from tekla.urgency
	where deleted = 0
	order by code;
RETURN mycurs;
END;$$;


ALTER FUNCTION tekla.geturgencyvalues() OWNER TO powercatch;

--
-- TOC entry 309 (class 1255 OID 27194)
-- Name: insertaction(integer, integer, integer, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertaction(actionid integer, mmsclassid integer, actiontype integer, id_object integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE retval integer;
BEGIN
  insert into tekla.action(action_id, id_condclass_id, actiontype, id_object) values ($1,$2,$3,$4);

  select max(id) into retval from tekla.action a where a.action_id = $1 and a.id_object = $4;

  RETURN retval;
END;

$_$;


ALTER FUNCTION tekla.insertaction(actionid integer, mmsclassid integer, actiontype integer, id_object integer) OWNER TO powercatch;

--
-- TOC entry 310 (class 1255 OID 27195)
-- Name: insertattrvalue(character varying, character varying, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertattrvalue(_field character varying, _value character varying, _id_object integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
  IF (select 1 from tekla.attrvalue where field = $1 and id_object =$3) THEN
    update tekla.attrvalue set value = $2 where field = $1 and id_object = $3;
  ELSE
    insert into tekla.attrvalue(field, value, id_object) values ($1,$2,$3);
  END IF;

return 0;

END;
$_$;


ALTER FUNCTION tekla.insertattrvalue(_field character varying, _value character varying, _id_object integer) OWNER TO powercatch;

--
-- TOC entry 311 (class 1255 OID 27196)
-- Name: insertcondclass(integer, character varying, character varying, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertcondclass(id integer, name character varying, description character varying, valuetype integer, actiontype integer, datatype integer, defaultvalue character varying, unit character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
begin
  if (select 1 from tekla.condclass where condclass_id = $1) then
    update tekla.condclass set name = $2, description = $3, valuetype = $4, actiontype = $5, datatype = $6, defaultvalue = $7, unit = $8, updateddate = now(), deleted = 0 where condclass_id = $1;
  else
    insert into tekla.condclass(condclass_id, name, description, valuetype, actiontype, datatype, defaultvalue, unit) values ($1,$2,$3,$4,$5,$6,$7,$8);
  end if;

  return $1;

end;
$_$;


ALTER FUNCTION tekla.insertcondclass(id integer, name character varying, description character varying, valuetype integer, actiontype integer, datatype integer, defaultvalue character varying, unit character varying) OWNER TO powercatch;

--
-- TOC entry 312 (class 1255 OID 27197)
-- Name: insertcondclassvalue(integer, character varying, character varying); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertcondclassvalue(id_condclass integer, _code character varying, _description character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
begin
  if (select 1 from tekla.condclassvalues where id_condclass_id = $1 and code = $2) then
    update tekla.condclassvalues set description = $3, updateddate = now(), deleted = 0 where id_condclass_id = $1 and code = $2;
  else
    insert into tekla.condclassvalues(id_condclass_id, code, description) values ($1,$2,$3);
  end if;

return 0;

end;$_$;


ALTER FUNCTION tekla.insertcondclassvalue(id_condclass integer, _code character varying, _description character varying) OWNER TO powercatch;

--
-- TOC entry 313 (class 1255 OID 27198)
-- Name: insertcondvalue(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, character varying); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertcondvalue(_id integer, _id_condclass_id integer, _parent_condclass_id integer, _sortorder integer, _objectid integer, _condclassname character varying, _defaultvalue character varying, _defaulturgency integer, _id_action integer, _comment character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
  IF (select 1 from tekla.condvalue where id_condclass_id = $2 and id_parent_condclass_id = $3 and id_object =$5 and id = $1) THEN
    update tekla.condvalue set id = $1, value = $7, id_urgency = $8, comment = $10 where id_condclass_id = $2 and id_object = $5;
  ELSE
    insert into tekla.condvalue(id, id_condclass_id, id_parent_condclass_id, sortorder, id_object, condclassname, value, id_urgency, id_action, comment) values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10);
  END IF;

return 0;

END;
$_$;


ALTER FUNCTION tekla.insertcondvalue(_id integer, _id_condclass_id integer, _parent_condclass_id integer, _sortorder integer, _objectid integer, _condclassname character varying, _defaultvalue character varying, _defaulturgency integer, _id_action integer, _comment character varying) OWNER TO powercatch;

--
-- TOC entry 314 (class 1255 OID 27199)
-- Name: insertfield(integer, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertfield(id_table integer, name character varying, category character varying, visiblename character varying, fieldlength integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
  IF (select 1 from tekla.field where field.id_table = $1 and field.name = $2) THEN
    update tekla.field set category = $3, visiblename = $4, fieldlength = $5, updateddate = now(), deleted = 0 where field.id_table = $1 and field.name = $2;
  ELSE
    insert into tekla.field(id_table, name, category, visiblename, fieldlength) values ($1,$2,$3,$4,$5);
  END IF;

return 0;

END;
$_$;


ALTER FUNCTION tekla.insertfield(id_table integer, name character varying, category character varying, visiblename character varying, fieldlength integer) OWNER TO powercatch;

--
-- TOC entry 315 (class 1255 OID 27200)
-- Name: insertmmsobject(integer, integer, integer, character varying, integer, integer, character varying, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertmmsobject(object_id integer, id_order integer, id_table integer, label character varying, sortorder integer, locked integer, comment character varying, id_object integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE retval integer;
DECLARE tableid integer;
BEGIN
  select id into tableid from tekla.sysdatatable where table_id = $3;
  insert into tekla.teklaobject(object_id, id_order, id_table, label, sortorder, locked, comment, id_object) values ($1,$2,tableId,$4,$5,$6,$7,$8);

  select max(id) into retval from tekla.teklaobject o where o.object_id = $1 and o.id_order = $2 and o.id_table = tableid;

  RETURN retval;
END;

$_$;


ALTER FUNCTION tekla.insertmmsobject(object_id integer, id_order integer, id_table integer, label character varying, sortorder integer, locked integer, comment character varying, id_object integer) OWNER TO powercatch;

--
-- TOC entry 291 (class 1255 OID 27201)
-- Name: insertmmsorder(xml, bigint, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertmmsorder(orderxml xml, orderid bigint, ordertype integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE retval integer;
BEGIN
-- order exists
  IF (select 1 from tekla.teklaorder where order_id = $2) THEN
	select -99 into retval;
  ELSE
	insert into tekla.teklaorder(xml_order, order_id, order_type) values ($1,$2,$3);

	select max(id) into retval from tekla.teklaorder where order_id = $2;
  END IF;
  RETURN retval;
--select 1
END;
$_$;


ALTER FUNCTION tekla.insertmmsorder(orderxml xml, orderid bigint, ordertype integer) OWNER TO powercatch;

--
-- TOC entry 296 (class 1255 OID 27202)
-- Name: insertsysdataclass(integer, character varying, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION insertsysdataclass(id_table integer, name character varying, id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
  IF (select 1 from tekla.sysdataclass where sysdataclass.id_table = $1 and sysdataclass.id = $3) THEN
    update tekla.sysdataclass set name = $2, updateddate = now(), deleted = false where sysdataclass.id_table = $1 and sysdataclass.id = $3;
  ELSE
    insert into tekla.sysdataclass(id_table, name, id) values ($1,$2,$3);
  END IF;

return 0;

END;
$_$;


ALTER FUNCTION tekla.insertsysdataclass(id_table integer, name character varying, id integer) OWNER TO powercatch;

--
-- TOC entry 316 (class 1255 OID 27203)
-- Name: inserttable(integer, character varying, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION inserttable(tableid integer, tablename character varying, typeid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
  IF (select 1 from tekla.sysdatatable where table_id = $1) THEN
    update tekla.sysdatatable set name = $2, typeid = $3, updateddate = now(), deleted = 0 where table_id = $1;
    return (select id from tekla.sysdatatable where table_id = $1);
  ELSE
    insert into tekla.sysdatatable(table_id, name, typeid) values ($1,$2,$3);
    return (select max(id) from tekla.sysdatatable where table_id = $1);
  END IF;

END;
$_$;


ALTER FUNCTION tekla.inserttable(tableid integer, tablename character varying, typeid integer) OWNER TO powercatch;

--
-- TOC entry 317 (class 1255 OID 27204)
-- Name: inserturgency(integer, character varying); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION inserturgency(code integer, value character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
begin
  if (select 1 from tekla.urgency where urgency.code = $1) then
    update tekla.urgency set value = $2, updateddate = now(), deleted = 0 where urgency.code = $1;
  else
    insert into tekla.urgency(code, value) values ($1,$2);
  end if;
return 0;

end;
$_$;


ALTER FUNCTION tekla.inserturgency(code integer, value character varying) OWNER TO powercatch;

--
-- TOC entry 287 (class 1255 OID 27205)
-- Name: updateIssueConditionComment(character varying, character varying, integer); Type: FUNCTION; Schema: tekla; Owner: postgres
--

CREATE FUNCTION "updateIssueConditionComment"(issuekey character varying, comment character varying, id_condclass_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
	update tekla."condValue" cv
	set "comment" = $2
	from tekla."object" o where o."id" = cv."id_object" and o."issue_key" = $1 and cv."id_condClass_id" = $3;
RETURN 0;
END;$_$;


ALTER FUNCTION tekla."updateIssueConditionComment"(issuekey character varying, comment character varying, id_condclass_id integer) OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 27206)
-- Name: updateIssueConditionValue(character varying, character varying, integer, integer); Type: FUNCTION; Schema: tekla; Owner: postgres
--

CREATE FUNCTION "updateIssueConditionValue"(issuekey character varying, value character varying, id_condclass_id integer, urgency integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
	update tekla."condValue" cv
	set "value" = $2, "id_urgency" = $4
	from tekla."object" o where o."id" = cv."id_object" and o."issue_key" = $1 and cv."id_condClass_id" = $3;
RETURN 0;
END;$_$;


ALTER FUNCTION tekla."updateIssueConditionValue"(issuekey character varying, value character varying, id_condclass_id integer, urgency integer) OWNER TO postgres;

--
-- TOC entry 318 (class 1255 OID 27207)
-- Name: updateissueattributevalue(character varying, character varying, character varying); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION updateissueattributevalue(issuekey character varying, value character varying, field character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
	update tekla.attrvalue av
	set value = $2
	from tekla.teklaobject o where o.id = av.id_object and o.issue_key = $1 and av.field = $3;
RETURN 0;
END;$_$;


ALTER FUNCTION tekla.updateissueattributevalue(issuekey character varying, value character varying, field character varying) OWNER TO powercatch;

--
-- TOC entry 319 (class 1255 OID 27208)
-- Name: updateissueconditioncomment(character varying, character varying, integer, integer, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION updateissueconditioncomment(issuekey character varying, comment character varying, id_condclass_id integer, id_parent_condclass_id integer, id_action integer DEFAULT 0) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
	update tekla.condvalue cv
	set comment = $2
	from tekla.teklaobject o where o.id = cv.id_object and o.issue_key = $1 and cv.id_condclass_id = $3 and cv.id_parent_condclass_id = $4 and cv.id_action = $5;
RETURN 0;
END;$_$;


ALTER FUNCTION tekla.updateissueconditioncomment(issuekey character varying, comment character varying, id_condclass_id integer, id_parent_condclass_id integer, id_action integer) OWNER TO powercatch;

--
-- TOC entry 320 (class 1255 OID 27209)
-- Name: updateissueconditionvalue(character varying, character varying, integer, integer, integer, integer); Type: FUNCTION; Schema: tekla; Owner: powercatch
--

CREATE FUNCTION updateissueconditionvalue(issuekey character varying, value character varying, id_condclass_id integer, id_parent_condclass_id integer, urgency integer, id_action integer DEFAULT 0) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
	update tekla.condvalue cv
	set value = $2, id_urgency = $5
	from tekla.teklaobject o where o.id = cv.id_object and o.issue_key = $1 and cv.id_condclass_id = $3 and cv.id_action = $6 and cv.id_parent_condclass_id = $4;
RETURN 0;
END;$_$;


ALTER FUNCTION tekla.updateissueconditionvalue(issuekey character varying, value character varying, id_condclass_id integer, id_parent_condclass_id integer, urgency integer, id_action integer) OWNER TO powercatch;

SET search_path = equipment, pg_catalog;

--
-- TOC entry 183 (class 1259 OID 27210)
-- Name: consumption; Type: TABLE; Schema: equipment; Owner: powercatch; Tablespace:
--

CREATE TABLE consumption (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    issueid character varying(10) NOT NULL,
    templateid uuid NOT NULL,
    userid character varying(30) NOT NULL,
    usagedate timestamp without time zone,
    changed_by character varying(30),
    changed_date timestamp without time zone,
    deleted integer DEFAULT 0 NOT NULL
);


ALTER TABLE equipment.consumption OWNER TO powercatch;

--
-- TOC entry 184 (class 1259 OID 27215)
-- Name: consumption_item; Type: TABLE; Schema: equipment; Owner: powercatch; Tablespace:
--

CREATE TABLE consumption_item (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    itemid character varying(20) NOT NULL,
    itemqty integer DEFAULT 0 NOT NULL,
    storageid character varying(20),
    consumptionid uuid NOT NULL,
    transferred integer DEFAULT 0 NOT NULL,
    changed_by character varying(30),
    changed_date timestamp without time zone,
    deleted integer DEFAULT 0 NOT NULL
);


ALTER TABLE equipment.consumption_item OWNER TO powercatch;

--
-- TOC entry 185 (class 1259 OID 27222)
-- Name: item; Type: TABLE; Schema: equipment; Owner: powercatch; Tablespace:
--

CREATE TABLE item (
    id character varying(20) NOT NULL,
    name character varying(60),
    description character varying(200),
    supplier character varying(60),
    supplierid character varying(20),
    category character varying(60),
    categoryid character varying(20),
    vendor character varying(60),
    vendorid character varying(20),
    unit character varying(20),
    unitid character varying(20),
    todevice integer DEFAULT 0 NOT NULL,
    changed_by character varying(30),
    changed_date timestamp without time zone,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    series character varying(32)
);


ALTER TABLE equipment.item OWNER TO powercatch;

--
-- TOC entry 186 (class 1259 OID 27231)
-- Name: stock; Type: TABLE; Schema: equipment; Owner: powercatch; Tablespace:
--

CREATE TABLE stock (
    id character varying(20) NOT NULL,
    name character varying(30) NOT NULL,
    address character varying(50),
    category character varying(20),
    buildingid uuid,
    changed_by character varying(30),
    changed_date timestamp without time zone,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL
);


ALTER TABLE equipment.stock OWNER TO powercatch;

--
-- TOC entry 187 (class 1259 OID 27236)
-- Name: template_issue; Type: TABLE; Schema: equipment; Owner: powercatch; Tablespace:
--

CREATE TABLE template_issue (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    issuetype character varying(10) NOT NULL,
    jobtype character varying(30),
    changed_by character varying(30),
    changed_date timestamp without time zone,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL
);


ALTER TABLE equipment.template_issue OWNER TO powercatch;

--
-- TOC entry 188 (class 1259 OID 27242)
-- Name: template_issue_item; Type: TABLE; Schema: equipment; Owner: powercatch; Tablespace:
--

CREATE TABLE template_issue_item (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    itemid character varying(32) NOT NULL,
    storageid character varying(20),
    templateid uuid NOT NULL,
    changed_by character varying(30),
    changed_date timestamp without time zone,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    defaultqty integer
);


ALTER TABLE equipment.template_issue_item OWNER TO powercatch;

SET search_path = infrastruktur, pg_catalog;

--
-- TOC entry 189 (class 1259 OID 27248)
-- Name: anlegg; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE anlegg (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    nr character varying(100),
    driftsmerking character varying(100),
    variant character varying(50),
    navn character varying(100),
    pos_lat double precision,
    pos_long double precision,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE infrastruktur.anlegg OWNER TO powercatch;

--
-- TOC entry 190 (class 1259 OID 27254)
-- Name: bryter; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE bryter (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    nr character varying(30),
    driftsmerking character varying(50),
    variant character varying(50),
    adresse character varying(150),
    pos_lat double precision,
    pos_long double precision,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE infrastruktur.bryter OWNER TO powercatch;

--
-- TOC entry 191 (class 1259 OID 27260)
-- Name: bygning; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE bygning (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    nr character varying(30),
    driftsmerking character varying(50),
    variant character varying(20),
    adresse character varying(150),
    katalogvalg character varying(100),
    pos_lat double precision,
    pos_long double precision,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    id_anlegg uuid
);


ALTER TABLE infrastruktur.bygning OWNER TO powercatch;

--
-- TOC entry 192 (class 1259 OID 27266)
-- Name: linje; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE linje (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr character varying(30),
    navn character varying(100),
    spenning double precision,
    id_linje uuid,
    endret_av character varying(100),
    endret_dato timestamp with time zone,
    slettet integer DEFAULT 0,
    id_omraade uuid,
    id_anlegg uuid,
    pos_liste text,
    antall double precision,
    variant character varying(30),
    katalogvalg character varying(100),
    driftsmerking character varying(100),
    pos_lat double precision,
    pos_long double precision,
    updateid double precision DEFAULT 0 NOT NULL,
    short_id character(4)
);


ALTER TABLE infrastruktur.linje OWNER TO powercatch;

--
-- TOC entry 2705 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2706 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2707 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.navn; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.navn IS 'Navn pÃ¥ linje objekt';


--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.spenning; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.spenning IS 'Spenningen pÃ¥ linje objekt.';


--
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.id_linje; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.id_linje IS 'Referanse til tilhÃ¸rende linje objekt.';


--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN linje.id_omraade; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN linje.id_omraade IS 'Referanse til tilhÃ¸rende omrÃ¥de';


--
-- TOC entry 193 (class 1259 OID 27275)
-- Name: node; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE node (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr character varying(30),
    id_plctype uuid,
    tlfnr character varying(13),
    id_nettstasjon uuid,
    maalerid character varying(20),
    trafo1 character varying(20),
    trafo2 character varying(20),
    trafo3 character varying(20),
    omkobler character varying(10),
    jordfeilovervaaking integer,
    pos_lat character varying(20),
    pos_long character varying(20),
    plassering character varying(100),
    montasjehoyde double precision,
    frekvens character varying(10),
    sendestyrke character varying(10),
    rekkevidde_urbant double precision,
    rekkevidde_land double precision,
    id_nodetype uuid,
    endret_av character varying(50),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL
);


ALTER TABLE infrastruktur.node OWNER TO powercatch;

--
-- TOC entry 2714 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2715 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2716 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.id_nettstasjon; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.id_nettstasjon IS 'Referanse til tilhÃ¸rende nettstasjon objekt.';


--
-- TOC entry 2717 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.rekkevidde_urbant; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.rekkevidde_urbant IS 'Rekkevidde i meter';


--
-- TOC entry 2718 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.rekkevidde_land; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.rekkevidde_land IS 'Rekkevidde i meter';


--
-- TOC entry 2719 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.id_nodetype; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.id_nodetype IS 'Referanse til id i tabell nodetype';


--
-- TOC entry 2720 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2721 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2722 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN node.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN node.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


--
-- TOC entry 194 (class 1259 OID 27281)
-- Name: nodetype; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE nodetype (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr numeric(10,0),
    navn character varying(20),
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL
);


ALTER TABLE infrastruktur.nodetype OWNER TO powercatch;

--
-- TOC entry 2723 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE nodetype; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON TABLE nodetype IS 'Inneholder informasjon om de ulike nodetypene';


--
-- TOC entry 2724 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN nodetype.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nodetype.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2725 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN nodetype.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nodetype.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2726 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN nodetype.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nodetype.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2727 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN nodetype.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nodetype.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2728 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN nodetype.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN nodetype.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


--
-- TOC entry 195 (class 1259 OID 27287)
-- Name: omraade; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE omraade (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr character varying(30),
    navn character varying(100),
    id_omraade uuid,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL
);


ALTER TABLE infrastruktur.omraade OWNER TO powercatch;

--
-- TOC entry 2729 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN omraade.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN omraade.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2730 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN omraade.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN omraade.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2731 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN omraade.id_omraade; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN omraade.id_omraade IS 'Referanse til overordnet omrÃ¥de';


--
-- TOC entry 2732 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN omraade.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN omraade.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2733 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN omraade.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN omraade.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2734 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN omraade.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN omraade.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


--
-- TOC entry 196 (class 1259 OID 27293)
-- Name: plctype; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE plctype (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr numeric(10,0),
    navn character varying(20),
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet boolean DEFAULT false NOT NULL
);


ALTER TABLE infrastruktur.plctype OWNER TO powercatch;

--
-- TOC entry 2735 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE plctype; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON TABLE plctype IS 'Inneholder informasjon om de ulike nodetypene';


--
-- TOC entry 2736 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN plctype.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN plctype.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2737 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN plctype.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN plctype.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2738 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN plctype.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN plctype.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2739 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN plctype.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN plctype.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2740 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN plctype.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN plctype.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


--
-- TOC entry 197 (class 1259 OID 27299)
-- Name: trafo; Type: TABLE; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

CREATE TABLE trafo (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nr character varying(30),
    navn character varying(100),
    spenning double precision,
    spenningssystem character varying(50),
    stoerrelse double precision,
    id_nettstasjon uuid,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    variant character varying(50),
    katalogvalg character varying(100),
    produsent character varying(100),
    produksjonsaar integer,
    hoeyde integer,
    bredde integer,
    lengde integer,
    totalvekt integer,
    oljevekt integer,
    oljetype character varying(100),
    gjennomfoeringstype character varying(100),
    konservatortype character varying(100),
    trafomerknad text,
    pos_lat double precision,
    pos_long double precision,
    updateid double precision DEFAULT 0 NOT NULL,
    driftsmerking character varying(50),
    id_anlegg uuid
);


ALTER TABLE infrastruktur.trafo OWNER TO powercatch;

--
-- TOC entry 2741 (class 0 OID 0)
-- Dependencies: 197
-- Name: TABLE trafo; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON TABLE trafo IS 'Inneholder informasjon om trafoer som er knyttet til nettstasjoner.';


--
-- TOC entry 2742 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN trafo.id; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN trafo.id IS 'PowerCatch sin interne id for objektet.';


--
-- TOC entry 2743 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN trafo.nr; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN trafo.nr IS 'Fagsystemets nÃ¸kkelverdi for objektet.';


--
-- TOC entry 2744 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN trafo.stoerrelse; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN trafo.stoerrelse IS 'StÃ¸rrelse i kVA for trafo objekt.';


--
-- TOC entry 2745 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN trafo.id_nettstasjon; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN trafo.id_nettstasjon IS 'Referanse til tilhÃ¸rende nettstasjon objekt.';


--
-- TOC entry 2746 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN trafo.endret_av; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN trafo.endret_av IS 'Hvem som har endret raden.';


--
-- TOC entry 2747 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN trafo.endret_dato; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN trafo.endret_dato IS 'NÃ¥r tid ble raden sist endret.';


--
-- TOC entry 2748 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN trafo.slettet; Type: COMMENT; Schema: infrastruktur; Owner: powercatch
--

COMMENT ON COLUMN trafo.slettet IS 'Angir om raden er aktiv/slettet eller ikke.';


SET search_path = konfigurasjon, pg_catalog;

--
-- TOC entry 198 (class 1259 OID 27309)
-- Name: config_server_values; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE config_server_values (
    id integer NOT NULL,
    key character varying(255),
    value character varying,
    changed_by character varying,
    reference_element character varying,
    company_key character varying,
    deleted integer DEFAULT 0,
    changed_date timestamp with time zone DEFAULT now()
);


ALTER TABLE konfigurasjon.config_server_values OWNER TO powercatch;

--
-- TOC entry 2749 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE config_server_values; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON TABLE config_server_values IS 'Config values used by the powercatch installation.';


--
-- TOC entry 199 (class 1259 OID 27317)
-- Name: config_server_values_id_seq; Type: SEQUENCE; Schema: konfigurasjon; Owner: powercatch
--

CREATE SEQUENCE config_server_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konfigurasjon.config_server_values_id_seq OWNER TO powercatch;

--
-- TOC entry 2750 (class 0 OID 0)
-- Dependencies: 199
-- Name: config_server_values_id_seq; Type: SEQUENCE OWNED BY; Schema: konfigurasjon; Owner: powercatch
--

ALTER SEQUENCE config_server_values_id_seq OWNED BY config_server_values.id;


--
-- TOC entry 200 (class 1259 OID 27319)
-- Name: config_user; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE config_user (
    id integer NOT NULL,
    key character varying(50) NOT NULL,
    data character varying(1024) NOT NULL,
    endret_av character varying(100),
    slettet integer DEFAULT 0 NOT NULL,
    gradert integer DEFAULT 0 NOT NULL,
    endret_dato time with time zone DEFAULT now() NOT NULL,
    bruker character varying(100) NOT NULL
);


ALTER TABLE konfigurasjon.config_user OWNER TO powercatch;

--
-- TOC entry 201 (class 1259 OID 27328)
-- Name: config_user_id_seq; Type: SEQUENCE; Schema: konfigurasjon; Owner: powercatch
--

CREATE SEQUENCE config_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konfigurasjon.config_user_id_seq OWNER TO powercatch;

--
-- TOC entry 2751 (class 0 OID 0)
-- Dependencies: 201
-- Name: config_user_id_seq; Type: SEQUENCE OWNED BY; Schema: konfigurasjon; Owner: powercatch
--

ALTER SEQUENCE config_user_id_seq OWNED BY config_user.id;


--
-- TOC entry 202 (class 1259 OID 27330)
-- Name: field; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE field (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nbr character varying(60),
    name character varying(255),
    customfieldid numeric(18,0),
    changed_by character varying(255),
    changed_date timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0 NOT NULL
);


ALTER TABLE konfigurasjon.field OWNER TO powercatch;

--
-- TOC entry 2752 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN field.id; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN field.id IS 'PowerCatch internal id';


--
-- TOC entry 2753 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN field.name; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN field.name IS 'Matching Jira database field cfname in table customfield';


--
-- TOC entry 2754 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN field.customfieldid; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN field.customfieldid IS 'Matching Jira database field id in table customfield';


--
-- TOC entry 2755 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN field.changed_by; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN field.changed_by IS 'User who changed current row';


--
-- TOC entry 2756 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN field.changed_date; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN field.changed_date IS 'Timestamp for last update of current row';


--
-- TOC entry 2757 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN field.deleted; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN field.deleted IS 'Is current row active (deleted) or not';


--
-- TOC entry 203 (class 1259 OID 27339)
-- Name: fieldproperty; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE fieldproperty (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    label character varying(255),
    editable integer DEFAULT 0,
    required integer DEFAULT 0,
    checkboxvalidationid integer,
    id_field uuid,
    changed_by character varying(255),
    changed_date timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    hidden integer
);


ALTER TABLE konfigurasjon.fieldproperty OWNER TO powercatch;

--
-- TOC entry 2758 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.id; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.id IS 'PowerCatch internal id';


--
-- TOC entry 2759 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.label; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.label IS 'label property';


--
-- TOC entry 2760 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.editable; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.editable IS 'required property';


--
-- TOC entry 2761 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.checkboxvalidationid; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.checkboxvalidationid IS 'checkboxvalidationid property';


--
-- TOC entry 2762 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.id_field; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.id_field IS 'Reference to field';


--
-- TOC entry 2763 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.changed_by; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.changed_by IS 'User who changed current row';


--
-- TOC entry 2764 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.changed_date; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.changed_date IS 'Timestamp for last update of current row';


--
-- TOC entry 2765 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN fieldproperty.deleted; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN fieldproperty.deleted IS 'Is current row active (deleted) or not';


--
-- TOC entry 204 (class 1259 OID 27350)
-- Name: issuetype; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE issuetype (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nbr character varying(60),
    name character varying(60),
    project_key character varying(255),
    new_issue_enabled integer DEFAULT 0,
    summary_field character varying(255),
    changed_by character varying(255),
    changed_date timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0 NOT NULL
);


ALTER TABLE konfigurasjon.issuetype OWNER TO powercatch;

--
-- TOC entry 2766 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.id; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.id IS 'PowerCatch internal id';


--
-- TOC entry 2767 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.nbr; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.nbr IS 'Matching Jira database field id in table issuetype';


--
-- TOC entry 2768 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.name; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.name IS 'Matching Jira database field pname in table issuetype';


--
-- TOC entry 2769 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.project_key; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.project_key IS 'Matching Jira database field pkey in table project';


--
-- TOC entry 2770 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.new_issue_enabled; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.new_issue_enabled IS 'Shall this issuetype be available for creation on mobile or not';


--
-- TOC entry 2771 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.summary_field; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.summary_field IS 'What to display on line 2 for each issue in tasklist on mobile';


--
-- TOC entry 2772 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.changed_by; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.changed_by IS 'User who changed current row';


--
-- TOC entry 2773 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.changed_date; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.changed_date IS 'Timestamp for last update of current row';


--
-- TOC entry 2774 (class 0 OID 0)
-- Dependencies: 204
-- Name: COLUMN issuetype.deleted; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype.deleted IS 'Is current row active (deleted) or not';


--
-- TOC entry 205 (class 1259 OID 27360)
-- Name: issuetype_page; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE issuetype_page (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    id_issuetype uuid,
    id_page uuid,
    sortorder integer,
    changed_by character varying(255),
    changed_date timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0 NOT NULL
);


ALTER TABLE konfigurasjon.issuetype_page OWNER TO powercatch;

--
-- TOC entry 2775 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN issuetype_page.id; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype_page.id IS 'PowerCatch internal id';


--
-- TOC entry 2776 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN issuetype_page.id_issuetype; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype_page.id_issuetype IS 'Reference to issuetype';


--
-- TOC entry 2777 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN issuetype_page.id_page; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype_page.id_page IS 'Reference to page';


--
-- TOC entry 2778 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN issuetype_page.sortorder; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype_page.sortorder IS 'Sortorder for page in issuetype';


--
-- TOC entry 2779 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN issuetype_page.changed_by; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype_page.changed_by IS 'User who changed current row';


--
-- TOC entry 2780 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN issuetype_page.changed_date; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype_page.changed_date IS 'Timestamp for last update of current row';


--
-- TOC entry 2781 (class 0 OID 0)
-- Dependencies: 205
-- Name: COLUMN issuetype_page.deleted; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN issuetype_page.deleted IS 'Is current row active (deleted) or not';


--
-- TOC entry 206 (class 1259 OID 27366)
-- Name: page; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE page (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nbr integer NOT NULL,
    name character varying(60),
    signaturerequired integer DEFAULT 0,
    changed_by character varying(255),
    changed_date timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    commentpresent integer DEFAULT 0
);


ALTER TABLE konfigurasjon.page OWNER TO powercatch;

--
-- TOC entry 2782 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN page.id; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page.id IS 'PowerCatch internal id';


--
-- TOC entry 2783 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN page.nbr; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page.nbr IS 'Auto incremental id for page';


--
-- TOC entry 2784 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN page.name; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page.name IS 'Matching Jira database field pname in table issuetype';


--
-- TOC entry 2785 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN page.signaturerequired; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page.signaturerequired IS 'Is signature required on this page or not';


--
-- TOC entry 2786 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN page.changed_by; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page.changed_by IS 'User who changed current row';


--
-- TOC entry 2787 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN page.changed_date; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page.changed_date IS 'Timestamp for last update of current row';


--
-- TOC entry 2788 (class 0 OID 0)
-- Dependencies: 206
-- Name: COLUMN page.deleted; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page.deleted IS 'Is current row active (deleted) or not';


--
-- TOC entry 207 (class 1259 OID 27373)
-- Name: page_fieldproperty; Type: TABLE; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

CREATE TABLE page_fieldproperty (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    id_page uuid,
    id_fieldproperty uuid,
    sortorder integer,
    changed_by character varying(255),
    changed_date timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0 NOT NULL
);


ALTER TABLE konfigurasjon.page_fieldproperty OWNER TO powercatch;

--
-- TOC entry 2789 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN page_fieldproperty.id; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page_fieldproperty.id IS 'PowerCatch internal id';


--
-- TOC entry 2790 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN page_fieldproperty.id_page; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page_fieldproperty.id_page IS 'Reference to page';


--
-- TOC entry 2791 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN page_fieldproperty.id_fieldproperty; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page_fieldproperty.id_fieldproperty IS 'Reference to fieldproperty';


--
-- TOC entry 2792 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN page_fieldproperty.sortorder; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page_fieldproperty.sortorder IS 'Sortorder for field in page';


--
-- TOC entry 2793 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN page_fieldproperty.changed_by; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page_fieldproperty.changed_by IS 'User who changed current row';


--
-- TOC entry 2794 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN page_fieldproperty.changed_date; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page_fieldproperty.changed_date IS 'Timestamp for last update of current row';


--
-- TOC entry 2795 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN page_fieldproperty.deleted; Type: COMMENT; Schema: konfigurasjon; Owner: powercatch
--

COMMENT ON COLUMN page_fieldproperty.deleted IS 'Is current row active (deleted) or not';


--
-- TOC entry 208 (class 1259 OID 27379)
-- Name: page_number_seq; Type: SEQUENCE; Schema: konfigurasjon; Owner: powercatch
--

CREATE SEQUENCE page_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE konfigurasjon.page_number_seq OWNER TO powercatch;

--
-- TOC entry 2796 (class 0 OID 0)
-- Dependencies: 208
-- Name: page_number_seq; Type: SEQUENCE OWNED BY; Schema: konfigurasjon; Owner: powercatch
--

ALTER SEQUENCE page_number_seq OWNED BY page.nbr;


SET search_path = netbas, pg_catalog;

--
-- TOC entry 209 (class 1259 OID 27381)
-- Name: arbeidsbeskrivelse; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE arbeidsbeskrivelse (
    tid integer NOT NULL,
    xml character varying
);


ALTER TABLE netbas.arbeidsbeskrivelse OWNER TO powercatch;

--
-- TOC entry 210 (class 1259 OID 27387)
-- Name: arbeidshistorie; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE arbeidshistorie (
    tid integer NOT NULL,
    wid integer NOT NULL,
    xml character varying
);


ALTER TABLE netbas.arbeidshistorie OWNER TO powercatch;

--
-- TOC entry 211 (class 1259 OID 27393)
-- Name: arbeidsoppdrag; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE arbeidsoppdrag (
    tid integer NOT NULL,
    issueid integer DEFAULT 0 NOT NULL,
    xml character varying NOT NULL,
    issuekey character varying(64),
    received timestamp without time zone,
    confirmed timestamp without time zone,
    closed timestamp without time zone,
    reported timestamp without time zone,
    issue_values text,
    closing timestamp without time zone,
    status_id integer
);


ALTER TABLE netbas.arbeidsoppdrag OWNER TO powercatch;

--
-- TOC entry 212 (class 1259 OID 27400)
-- Name: attr; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE attr (
    name character varying(64) NOT NULL,
    value character varying(64),
    updateid integer DEFAULT 0 NOT NULL
);


ALTER TABLE netbas.attr OWNER TO powercatch;

--
-- TOC entry 2797 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE attr; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON TABLE attr IS 'AttributeCategories';


--
-- TOC entry 213 (class 1259 OID 27404)
-- Name: cl_id_seq; Type: SEQUENCE; Schema: netbas; Owner: powercatch
--

CREATE SEQUENCE cl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE netbas.cl_id_seq OWNER TO powercatch;

--
-- TOC entry 214 (class 1259 OID 27406)
-- Name: codelist; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE codelist (
    id integer DEFAULT nextval('cl_id_seq'::regclass) NOT NULL,
    name character varying(64) NOT NULL,
    xml character varying,
    html character varying,
    updateid integer DEFAULT 0 NOT NULL
);


ALTER TABLE netbas.codelist OWNER TO powercatch;

--
-- TOC entry 215 (class 1259 OID 27414)
-- Name: cvd_id_seq; Type: SEQUENCE; Schema: netbas; Owner: powercatch
--

CREATE SEQUENCE cvd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE netbas.cvd_id_seq OWNER TO powercatch;

--
-- TOC entry 216 (class 1259 OID 27416)
-- Name: codevd; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE codevd (
    id integer DEFAULT nextval('cvd_id_seq'::regclass) NOT NULL,
    name character varying(64) NOT NULL,
    xml character varying,
    html character varying,
    updateid integer DEFAULT 0 NOT NULL
);


ALTER TABLE netbas.codevd OWNER TO powercatch;

--
-- TOC entry 2798 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE codevd; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON TABLE codevd IS 'CcodeValueDefinitions';


--
-- TOC entry 217 (class 1259 OID 27424)
-- Name: delkomponent; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE delkomponent (
    tid integer NOT NULL,
    wid integer NOT NULL,
    oid integer NOT NULL,
    did integer NOT NULL,
    xml character varying
);


ALTER TABLE netbas.delkomponent OWNER TO powercatch;

--
-- TOC entry 218 (class 1259 OID 27430)
-- Name: kontrollpunkt; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE kontrollpunkt (
    tid integer NOT NULL,
    wid integer NOT NULL,
    oid integer NOT NULL,
    did integer DEFAULT 0,
    id integer NOT NULL,
    xml character varying
);


ALTER TABLE netbas.kontrollpunkt OWNER TO powercatch;

--
-- TOC entry 2799 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN kontrollpunkt.tid; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON COLUMN kontrollpunkt.tid IS 'Task id from ARBEIDSOPPDRAG';


--
-- TOC entry 2800 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN kontrollpunkt.wid; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON COLUMN kontrollpunkt.wid IS 'Work id from ARBEIDSHISTORIE';


--
-- TOC entry 2801 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN kontrollpunkt.oid; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON COLUMN kontrollpunkt.oid IS 'OBJNR';


--
-- TOC entry 2802 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN kontrollpunkt.did; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON COLUMN kontrollpunkt.did IS 'Object id from DELKOMPONENTER';


--
-- TOC entry 2803 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN kontrollpunkt.id; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON COLUMN kontrollpunkt.id IS 'Sjekkpunkt id';


--
-- TOC entry 219 (class 1259 OID 27437)
-- Name: object_status; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE object_status (
    id integer NOT NULL,
    status_id integer,
    status_name character varying
);


ALTER TABLE netbas.object_status OWNER TO powercatch;

--
-- TOC entry 220 (class 1259 OID 27443)
-- Name: objektinformasjon; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE objektinformasjon (
    tid integer NOT NULL,
    xml character varying
);


ALTER TABLE netbas.objektinformasjon OWNER TO powercatch;

--
-- TOC entry 221 (class 1259 OID 27449)
-- Name: sjekkpunkt; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE sjekkpunkt (
    tid integer NOT NULL,
    id integer NOT NULL,
    xml character varying
);


ALTER TABLE netbas.sjekkpunkt OWNER TO powercatch;

--
-- TOC entry 179 (class 1259 OID 27145)
-- Name: unique_controlpoints; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE unique_controlpoints (
    id integer NOT NULL,
    xml character varying NOT NULL,
    updateid integer DEFAULT 0 NOT NULL
);


ALTER TABLE netbas.unique_controlpoints OWNER TO powercatch;

--
-- TOC entry 2804 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN unique_controlpoints.id; Type: COMMENT; Schema: netbas; Owner: powercatch
--

COMMENT ON COLUMN unique_controlpoints.id IS 'The controlpoint id';


--
-- TOC entry 222 (class 1259 OID 27455)
-- Name: vedlikeholdsobjekt; Type: TABLE; Schema: netbas; Owner: powercatch; Tablespace:
--

CREATE TABLE vedlikeholdsobjekt (
    tid integer NOT NULL,
    wid integer NOT NULL,
    oid integer NOT NULL,
    xml character varying,
    issue_values text,
    closed timestamp without time zone,
    status_id integer,
    updated timestamp without time zone
);


ALTER TABLE netbas.vedlikeholdsobjekt OWNER TO powercatch;

SET search_path = prosjekt, pg_catalog;

--
-- TOC entry 223 (class 1259 OID 27461)
-- Name: activemq_failures; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE activemq_failures (
    issue_id character varying(20) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    id integer NOT NULL,
    type character varying(50),
    queue character varying(100),
    message character varying(2048) NOT NULL
);


ALTER TABLE prosjekt.activemq_failures OWNER TO powercatch;

--
-- TOC entry 2805 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE activemq_failures; Type: COMMENT; Schema: prosjekt; Owner: powercatch
--

COMMENT ON TABLE activemq_failures IS 'Content that has failed when calling activeMQ, well be resent when activeMQ is up and running again.';


--
-- TOC entry 2806 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN activemq_failures.message; Type: COMMENT; Schema: prosjekt; Owner: powercatch
--

COMMENT ON COLUMN activemq_failures.message IS 'The message to send to activeMQ';


--
-- TOC entry 224 (class 1259 OID 27468)
-- Name: customfield; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE customfield (
    id integer NOT NULL,
    nr character varying(20),
    navn character varying(255),
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    locale character varying(5)
);


ALTER TABLE prosjekt.customfield OWNER TO powercatch;

--
-- TOC entry 225 (class 1259 OID 27474)
-- Name: fc_connection; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE fc_connection (
    id_issuetype character varying(255),
    id_value character varying(255),
    sortorder integer DEFAULT 0 NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.fc_connection OWNER TO powercatch;

--
-- TOC entry 226 (class 1259 OID 27485)
-- Name: fc_value; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE fc_value (
    pc_key character varying(255),
    locale character varying(5),
    pc_text character varying(255),
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.fc_value OWNER TO powercatch;

--
-- TOC entry 251 (class 1259 OID 27746)
-- Name: jira_subissue; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE jira_subissue (
    id_issuetype character varying(255),
    pc_text character varying(255),
    locale character varying(5),
    sortorder integer DEFAULT 0 NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.jira_subissue OWNER TO powercatch;

--
-- TOC entry 227 (class 1259 OID 27495)
-- Name: risiko; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE risiko (
    id integer NOT NULL,
    navn character varying(50),
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    locale character varying(5),
    value character varying(50)
);


ALTER TABLE prosjekt.risiko OWNER TO powercatch;

--
-- TOC entry 254 (class 1259 OID 27782)
-- Name: risks; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE risks (
    pc_category character varying(255),
    pc_description character varying(255),
    pc_level character varying(255),
    pc_selection character varying(255),
    locale character varying(5),
    sortorder integer DEFAULT 0 NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.risks OWNER TO powercatch;

--
-- TOC entry 228 (class 1259 OID 27501)
-- Name: sa_action; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE sa_action (
    id_risk character varying(255),
    pc_key character varying(255),
    locale character varying(5),
    pc_text character varying(255),
    sortorder integer DEFAULT 0 NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.sa_action OWNER TO powercatch;

--
-- TOC entry 229 (class 1259 OID 27512)
-- Name: sa_connection; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE sa_connection (
    id_issuetype character varying(255),
    id_task character varying(255),
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.sa_connection OWNER TO powercatch;

--
-- TOC entry 230 (class 1259 OID 27522)
-- Name: sa_issuetype; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE sa_issuetype (
    pc_key character varying(255),
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.sa_issuetype OWNER TO powercatch;

--
-- TOC entry 231 (class 1259 OID 27529)
-- Name: sa_risk; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE sa_risk (
    id_task character varying(255),
    pc_key character varying(255),
    locale character varying(5),
    pc_text character varying(255),
    sortorder integer DEFAULT 0 NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.sa_risk OWNER TO powercatch;

--
-- TOC entry 232 (class 1259 OID 27540)
-- Name: sa_task; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE sa_task (
    pc_key character varying(255),
    locale character varying(5),
    pc_text character varying(255),
    sortorder integer DEFAULT 0 NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.sa_task OWNER TO powercatch;

--
-- TOC entry 255 (class 1259 OID 27793)
-- Name: task_objectdata; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE task_objectdata (
    pc_task character varying(255),
    pc_key character varying(255),
    pc_text character varying(255),
    locale character varying(5),
    sortorder integer DEFAULT 0 NOT NULL,
    deleted integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    changed_by character varying(100) DEFAULT 'admin'::character varying,
    changed_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE prosjekt.task_objectdata OWNER TO powercatch;

--
-- TOC entry 233 (class 1259 OID 27551)
-- Name: threelevels; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE threelevels (
    id integer NOT NULL,
    nr character varying(20),
    level1 character varying(255),
    level2 character varying(255),
    level3 character varying(255),
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    locale character varying(5),
    value character varying(255)
);


ALTER TABLE prosjekt.threelevels OWNER TO powercatch;

--
-- TOC entry 234 (class 1259 OID 27560)
-- Name: tiltak; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE tiltak (
    id integer NOT NULL,
    navn character varying(255),
    id_risiko integer,
    id_customfield integer,
    endret_av character varying(100),
    endret_dato timestamp with time zone DEFAULT now() NOT NULL,
    slettet integer DEFAULT 0 NOT NULL,
    updateid double precision DEFAULT 0 NOT NULL,
    locale character varying(5),
    value character varying(255)
);


ALTER TABLE prosjekt.tiltak OWNER TO powercatch;

--
-- TOC entry 235 (class 1259 OID 27569)
-- Name: webservice_failures; Type: TABLE; Schema: prosjekt; Owner: powercatch; Tablespace:
--

CREATE TABLE webservice_failures (
    issue_id character varying(20) NOT NULL,
    id integer NOT NULL,
    url character varying(200),
    query_parameters character varying(1000),
    message character varying(400),
    created timestamp with time zone DEFAULT now(),
    update_existing_project integer DEFAULT 0
);


ALTER TABLE prosjekt.webservice_failures OWNER TO powercatch;

--
-- TOC entry 2807 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE webservice_failures; Type: COMMENT; Schema: prosjekt; Owner: powercatch
--

COMMENT ON TABLE webservice_failures IS 'Content that has failed when calling external webservice, well be resent when webservice is up and running again.';


--
-- TOC entry 2808 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN webservice_failures.url; Type: COMMENT; Schema: prosjekt; Owner: powercatch
--

COMMENT ON COLUMN webservice_failures.url IS 'The url to reach the webservice. Contain protocol, port, address and service-name.';


--
-- TOC entry 2809 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN webservice_failures.query_parameters; Type: COMMENT; Schema: prosjekt; Owner: powercatch
--

COMMENT ON COLUMN webservice_failures.query_parameters IS 'Parameters or JSON containing data required by external service to return correct data.';


--
-- TOC entry 2810 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN webservice_failures.message; Type: COMMENT; Schema: prosjekt; Owner: powercatch
--

COMMENT ON COLUMN webservice_failures.message IS 'Information regarding the failure. Can be error code, number of retries, etc...';


--
-- TOC entry 2811 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN webservice_failures.update_existing_project; Type: COMMENT; Schema: prosjekt; Owner: powercatch
--

COMMENT ON COLUMN webservice_failures.update_existing_project IS 'Indicates if project in external system should be updated or a new project should be created';


SET search_path = sync, pg_catalog;

--
-- TOC entry 253 (class 1259 OID 27774)
-- Name: deviation; Type: TABLE; Schema: sync; Owner: powercatch; Tablespace:
--

CREATE TABLE deviation (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    sync_date timestamp with time zone DEFAULT now() NOT NULL,
    content bytea NOT NULL,
    comment text
);


ALTER TABLE sync.deviation OWNER TO powercatch;

--
-- TOC entry 252 (class 1259 OID 27766)
-- Name: issue; Type: TABLE; Schema: sync; Owner: powercatch; Tablespace:
--

CREATE TABLE issue (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    sync_status integer NOT NULL,
    sync_date timestamp with time zone DEFAULT now() NOT NULL,
    content bytea NOT NULL,
    comment text,
    mobilesyncstatus integer,
    steps_executed integer
);


ALTER TABLE sync.issue OWNER TO powercatch;

--
-- TOC entry 256 (class 1259 OID 27806)
-- Name: issue_backup; Type: TABLE; Schema: sync; Owner: powercatch; Tablespace:
--

CREATE TABLE issue_backup (
    id uuid,
    key character varying(255),
    username character varying(255),
    sync_status integer,
    sync_date timestamp with time zone,
    content bytea,
    comment text,
    mobilesyncstatus integer,
    steps_executed integer
);


ALTER TABLE sync.issue_backup OWNER TO powercatch;

--
-- TOC entry 257 (class 1259 OID 27812)
-- Name: issue_error; Type: TABLE; Schema: sync; Owner: powercatch; Tablespace:
--

CREATE TABLE issue_error (
    id uuid,
    key character varying(255),
    username character varying(255),
    sync_status integer,
    sync_date timestamp with time zone,
    content bytea,
    comment text,
    mobilesyncstatus integer,
    steps_executed integer
);


ALTER TABLE sync.issue_error OWNER TO powercatch;

SET search_path = tekla, pg_catalog;

--
-- TOC entry 236 (class 1259 OID 27577)
-- Name: action; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE action (
    id_condclass_id integer,
    action_id integer,
    actiontype integer,
    id_object integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE tekla.action OWNER TO powercatch;

--
-- TOC entry 237 (class 1259 OID 27580)
-- Name: action_id_seq; Type: SEQUENCE; Schema: tekla; Owner: powercatch
--

CREATE SEQUENCE action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tekla.action_id_seq OWNER TO powercatch;

--
-- TOC entry 2812 (class 0 OID 0)
-- Dependencies: 237
-- Name: action_id_seq; Type: SEQUENCE OWNED BY; Schema: tekla; Owner: powercatch
--

ALTER SEQUENCE action_id_seq OWNED BY action.id;


--
-- TOC entry 238 (class 1259 OID 27582)
-- Name: attrvalue; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE attrvalue (
    field character varying(100) NOT NULL,
    value character varying(255),
    id_object integer NOT NULL
);


ALTER TABLE tekla.attrvalue OWNER TO powercatch;

--
-- TOC entry 239 (class 1259 OID 27585)
-- Name: condclass; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE condclass (
    condclass_id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    valuetype integer,
    createddate timestamp with time zone DEFAULT now() NOT NULL,
    updateddate timestamp with time zone DEFAULT now() NOT NULL,
    datatype integer,
    actiontype integer,
    deleted integer DEFAULT 0,
    defaultvalue character varying(255),
    unit character varying(64)
);


ALTER TABLE tekla.condclass OWNER TO powercatch;

--
-- TOC entry 240 (class 1259 OID 27594)
-- Name: condclassvalues; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE condclassvalues (
    description character varying(100),
    id_condclass_id integer NOT NULL,
    code character varying(50) NOT NULL,
    createddate timestamp with time zone DEFAULT now() NOT NULL,
    updateddate timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0
);


ALTER TABLE tekla.condclassvalues OWNER TO powercatch;

--
-- TOC entry 241 (class 1259 OID 27600)
-- Name: condvalue; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE condvalue (
    id_condclass_id integer NOT NULL,
    value character varying(255),
    id_parent_condclass_id integer,
    id_object integer NOT NULL,
    sortorder integer,
    condclassname character varying(255),
    id_urgency integer,
    comment character varying(255),
    id_action integer,
    id integer
);


ALTER TABLE tekla.condvalue OWNER TO powercatch;

--
-- TOC entry 242 (class 1259 OID 27606)
-- Name: field; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE field (
    name character varying(100),
    visiblename character varying(255),
    category character varying(50),
    fieldlength integer,
    id_table integer,
    createddate timestamp with time zone DEFAULT now() NOT NULL,
    updateddate timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0,
    id_class integer
);


ALTER TABLE tekla.field OWNER TO powercatch;

--
-- TOC entry 243 (class 1259 OID 27612)
-- Name: teklaobject; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE teklaobject (
    object_id integer NOT NULL,
    issue_key character varying(255),
    id_order integer NOT NULL,
    id integer NOT NULL,
    id_table integer,
    sortorder integer,
    locked integer,
    comment character varying(1024),
    id_object integer,
    label character varying(255)
);


ALTER TABLE tekla.teklaobject OWNER TO powercatch;

--
-- TOC entry 2813 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN teklaobject.id_object; Type: COMMENT; Schema: tekla; Owner: powercatch
--

COMMENT ON COLUMN teklaobject.id_object IS 'Reference to parent object';


--
-- TOC entry 244 (class 1259 OID 27618)
-- Name: object_id_seq; Type: SEQUENCE; Schema: tekla; Owner: powercatch
--

CREATE SEQUENCE object_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tekla.object_id_seq OWNER TO powercatch;

--
-- TOC entry 2814 (class 0 OID 0)
-- Dependencies: 244
-- Name: object_id_seq; Type: SEQUENCE OWNED BY; Schema: tekla; Owner: powercatch
--

ALTER SEQUENCE object_id_seq OWNED BY teklaobject.id;


--
-- TOC entry 245 (class 1259 OID 27620)
-- Name: teklaorder; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE teklaorder (
    id integer NOT NULL,
    issue_key character varying(255),
    xml_order xml,
    order_id integer,
    createddate timestamp with time zone DEFAULT now() NOT NULL,
    updateddate timestamp with time zone DEFAULT now() NOT NULL,
    order_type integer
);


ALTER TABLE tekla.teklaorder OWNER TO powercatch;

--
-- TOC entry 2815 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN teklaorder.order_type; Type: COMMENT; Schema: tekla; Owner: powercatch
--

COMMENT ON COLUMN teklaorder.order_type IS '0 = maintenance, 1 = repair';


--
-- TOC entry 246 (class 1259 OID 27628)
-- Name: order_id_seq; Type: SEQUENCE; Schema: tekla; Owner: powercatch
--

CREATE SEQUENCE order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tekla.order_id_seq OWNER TO powercatch;

--
-- TOC entry 2816 (class 0 OID 0)
-- Dependencies: 246
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: tekla; Owner: powercatch
--

ALTER SEQUENCE order_id_seq OWNED BY teklaorder.id;


--
-- TOC entry 247 (class 1259 OID 27630)
-- Name: sysdataclass; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE sysdataclass (
    id integer,
    name character varying(255),
    id_table integer,
    createddate timestamp with time zone DEFAULT now() NOT NULL,
    updateddate timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0
);


ALTER TABLE tekla.sysdataclass OWNER TO powercatch;

--
-- TOC entry 248 (class 1259 OID 27636)
-- Name: sysdatatable; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE sysdatatable (
    table_id integer NOT NULL,
    name character varying(255),
    id integer NOT NULL,
    typeid integer,
    createddate timestamp with time zone DEFAULT now() NOT NULL,
    updateddate timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0
);


ALTER TABLE tekla.sysdatatable OWNER TO powercatch;

--
-- TOC entry 249 (class 1259 OID 27642)
-- Name: table_id_seq; Type: SEQUENCE; Schema: tekla; Owner: powercatch
--

CREATE SEQUENCE table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tekla.table_id_seq OWNER TO powercatch;

--
-- TOC entry 2817 (class 0 OID 0)
-- Dependencies: 249
-- Name: table_id_seq; Type: SEQUENCE OWNED BY; Schema: tekla; Owner: powercatch
--

ALTER SEQUENCE table_id_seq OWNED BY sysdatatable.id;


--
-- TOC entry 250 (class 1259 OID 27644)
-- Name: urgency; Type: TABLE; Schema: tekla; Owner: powercatch; Tablespace:
--

CREATE TABLE urgency (
    code integer NOT NULL,
    value character varying(255),
    createddate timestamp with time zone DEFAULT now() NOT NULL,
    updateddate timestamp with time zone DEFAULT now() NOT NULL,
    deleted integer DEFAULT 0
);


ALTER TABLE tekla.urgency OWNER TO powercatch;

SET search_path = konfigurasjon, pg_catalog;

--
-- TOC entry 2279 (class 2604 OID 27650)
-- Name: id; Type: DEFAULT; Schema: konfigurasjon; Owner: powercatch
--

ALTER TABLE ONLY config_server_values ALTER COLUMN id SET DEFAULT nextval('config_server_values_id_seq'::regclass);


--
-- TOC entry 2283 (class 2604 OID 27651)
-- Name: id; Type: DEFAULT; Schema: konfigurasjon; Owner: powercatch
--

ALTER TABLE ONLY config_user ALTER COLUMN id SET DEFAULT nextval('config_user_id_seq'::regclass);


--
-- TOC entry 2303 (class 2604 OID 27652)
-- Name: nbr; Type: DEFAULT; Schema: konfigurasjon; Owner: powercatch
--

ALTER TABLE ONLY page ALTER COLUMN nbr SET DEFAULT nextval('page_number_seq'::regclass);


SET search_path = tekla, pg_catalog;

--
-- TOC entry 2362 (class 2604 OID 27653)
-- Name: id; Type: DEFAULT; Schema: tekla; Owner: powercatch
--

ALTER TABLE ONLY action ALTER COLUMN id SET DEFAULT nextval('action_id_seq'::regclass);


--
-- TOC entry 2382 (class 2604 OID 27654)
-- Name: id; Type: DEFAULT; Schema: tekla; Owner: powercatch
--

ALTER TABLE ONLY sysdatatable ALTER COLUMN id SET DEFAULT nextval('table_id_seq'::regclass);


--
-- TOC entry 2372 (class 2604 OID 27655)
-- Name: id; Type: DEFAULT; Schema: tekla; Owner: powercatch
--

ALTER TABLE ONLY teklaobject ALTER COLUMN id SET DEFAULT nextval('object_id_seq'::regclass);


--
-- TOC entry 2375 (class 2604 OID 27656)
-- Name: id; Type: DEFAULT; Schema: tekla; Owner: powercatch
--

ALTER TABLE ONLY teklaorder ALTER COLUMN id SET DEFAULT nextval('order_id_seq'::regclass);


SET search_path = equipment, pg_catalog;

--
-- TOC entry 2604 (class 0 OID 27210)
-- Dependencies: 183
-- Data for Name: consumption; Type: TABLE DATA; Schema: equipment; Owner: powercatch
--

COPY consumption (id, issueid, templateid, userid, usagedate, changed_by, changed_date, deleted) FROM stdin;
\.


--
-- TOC entry 2605 (class 0 OID 27215)
-- Dependencies: 184
-- Data for Name: consumption_item; Type: TABLE DATA; Schema: equipment; Owner: powercatch
--

COPY consumption_item (id, itemid, itemqty, storageid, consumptionid, transferred, changed_by, changed_date, deleted) FROM stdin;
\.


--
-- TOC entry 2606 (class 0 OID 27222)
-- Dependencies: 185
-- Data for Name: item; Type: TABLE DATA; Schema: equipment; Owner: powercatch
--

COPY item (id, name, description, supplier, supplierid, category, categoryid, vendor, vendorid, unit, unitid, todevice, changed_by, changed_date, deleted, updateid, series) FROM stdin;
\.


--
-- TOC entry 2607 (class 0 OID 27231)
-- Dependencies: 186
-- Data for Name: stock; Type: TABLE DATA; Schema: equipment; Owner: powercatch
--

COPY stock (id, name, address, category, buildingid, changed_by, changed_date, deleted, updateid) FROM stdin;
\.


--
-- TOC entry 2608 (class 0 OID 27236)
-- Dependencies: 187
-- Data for Name: template_issue; Type: TABLE DATA; Schema: equipment; Owner: powercatch
--

COPY template_issue (id, issuetype, jobtype, changed_by, changed_date, deleted, updateid) FROM stdin;
\.


--
-- TOC entry 2609 (class 0 OID 27242)
-- Dependencies: 188
-- Data for Name: template_issue_item; Type: TABLE DATA; Schema: equipment; Owner: powercatch
--

COPY template_issue_item (id, itemid, storageid, templateid, changed_by, changed_date, deleted, updateid, defaultqty) FROM stdin;
\.


SET search_path = infrastruktur, pg_catalog;

--
-- TOC entry 2610 (class 0 OID 27248)
-- Dependencies: 189
-- Data for Name: anlegg; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY anlegg (id, updateid, nr, driftsmerking, variant, navn, pos_lat, pos_long, endret_av, endret_dato) FROM stdin;
\.


--
-- TOC entry 2611 (class 0 OID 27254)
-- Dependencies: 190
-- Data for Name: bryter; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY bryter (id, updateid, nr, driftsmerking, variant, adresse, pos_lat, pos_long, endret_av, endret_dato) FROM stdin;
\.


--
-- TOC entry 2612 (class 0 OID 27260)
-- Dependencies: 191
-- Data for Name: bygning; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY bygning (id, updateid, nr, driftsmerking, variant, adresse, katalogvalg, pos_lat, pos_long, endret_av, endret_dato, id_anlegg) FROM stdin;
\.


--
-- TOC entry 2601 (class 0 OID 27154)
-- Dependencies: 180
-- Data for Name: kabelskap; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY kabelskap (id, nr, driftsmerking1, driftsmerking2, fabrikat, variant, spenning, adresse, kommunenr, kommunenavn, pos_lat, pos_long, strekkode, id_nettstasjon, endret_av, endret_dato, slettet, nettstasjon, updateid, katalogvalg, id_anlegg) FROM stdin;
\.


--
-- TOC entry 2613 (class 0 OID 27266)
-- Dependencies: 192
-- Data for Name: linje; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY linje (id, nr, navn, spenning, id_linje, endret_av, endret_dato, slettet, id_omraade, id_anlegg, pos_liste, antall, variant, katalogvalg, driftsmerking, pos_lat, pos_long, updateid, short_id) FROM stdin;
\.


--
-- TOC entry 2603 (class 0 OID 27176)
-- Dependencies: 182
-- Data for Name: mastepunkt; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY mastepunkt (id, nr, driftsmerking, variant, pos_lat, pos_long, strekkode, id_linje, endret_av, endret_dato, slettet, updateid, posisjon, antall, katalogvalg, id_anlegg, showinmap) FROM stdin;
\.


--
-- TOC entry 2602 (class 0 OID 27165)
-- Dependencies: 181
-- Data for Name: nettstasjon; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY nettstasjon (id, nr, navn, variant, adresse, kommunenr, kommunenavn, balansemaaling, beroeringsikker, max_uttak_siste_aar, strekkode, pos_lat, pos_long, id_omraade, endret_av, endret_dato, slettet, updateid, driftsmerking) FROM stdin;
\.


--
-- TOC entry 2614 (class 0 OID 27275)
-- Dependencies: 193
-- Data for Name: node; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY node (id, nr, id_plctype, tlfnr, id_nettstasjon, maalerid, trafo1, trafo2, trafo3, omkobler, jordfeilovervaaking, pos_lat, pos_long, plassering, montasjehoyde, frekvens, sendestyrke, rekkevidde_urbant, rekkevidde_land, id_nodetype, endret_av, endret_dato, slettet) FROM stdin;
\.


--
-- TOC entry 2615 (class 0 OID 27281)
-- Dependencies: 194
-- Data for Name: nodetype; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY nodetype (id, nr, navn, endret_av, endret_dato, slettet) FROM stdin;
\.


--
-- TOC entry 2616 (class 0 OID 27287)
-- Dependencies: 195
-- Data for Name: omraade; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY omraade (id, nr, navn, id_omraade, endret_av, endret_dato, slettet) FROM stdin;
\.


--
-- TOC entry 2617 (class 0 OID 27293)
-- Dependencies: 196
-- Data for Name: plctype; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY plctype (id, nr, navn, endret_av, endret_dato, slettet) FROM stdin;
\.


--
-- TOC entry 2618 (class 0 OID 27299)
-- Dependencies: 197
-- Data for Name: trafo; Type: TABLE DATA; Schema: infrastruktur; Owner: powercatch
--

COPY trafo (id, nr, navn, spenning, spenningssystem, stoerrelse, id_nettstasjon, endret_av, endret_dato, slettet, variant, katalogvalg, produsent, produksjonsaar, hoeyde, bredde, lengde, totalvekt, oljevekt, oljetype, gjennomfoeringstype, konservatortype, trafomerknad, pos_lat, pos_long, updateid, driftsmerking, id_anlegg) FROM stdin;
\.


SET search_path = konfigurasjon, pg_catalog;

--
-- TOC entry 2619 (class 0 OID 27309)
-- Dependencies: 198
-- Data for Name: config_server_values; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY config_server_values (id, key, value, changed_by, reference_element, company_key, deleted, changed_date) FROM stdin;
18	mobileclient_show_renblader	true	admin	\N	powercatch	0	2014-05-16 09:42:57.084+02
5	common_start_coordinates	68.7986342,16.5414502	admin	\N	powercatch	0	2015-01-28 14:37:53.675+01
25	common_days_before_values_refresh	7	admin	\N	powercatch	0	2015-01-28 14:37:53.675+01
26	common_days_to_keep_map_cache	30	admin	\N	powercatch	0	2015-01-28 14:37:53.676+01
2	mobilservlet_filterids	filter1:12345,plukklistefilter:13200	admin	\N	powercatch	0	2015-01-28 14:37:53.676+01
3	mobilservlet_relevant_mobile_projects	LHS, LLS, LD, NS, LEVPKT, SLK, NY,NM	admin	\N	powercatch	0	2015-01-28 14:37:53.677+01
4	mobilservlet_relevant_attachmenttypes	.bmp,.gif,.jpeg,.png,.pdf,.jpg	admin	\N	powercatch	0	2015-01-28 14:37:53.678+01
22	mobilservlet_not_relevant_status_names	PC_ISSUESTATUS_CLOSED,PC_ISSUESTATUS_RESOLVED	admin	\N	powercatch	0	2015-01-28 14:37:53.678+01
23	mobilservlet_mutiplevalue_checkbox_not_complete_or_ok_labelvalues	ikke_kontrollert:Ikke kontrollert,avvik:Avvik	admin	\N	powercatch	0	2015-01-28 14:37:53.682+01
6	common_start_zoomlevel	12	admin	\N	powercatch	0	2015-01-28 14:37:53.683+01
7	common_default_map	osm	admin	\N	powercatch	0	2015-01-28 14:37:53.684+01
8	common_maps_to_show	topo2,topo2_gray,osm,sjokart	admin	\N	powercatch	0	2015-01-28 14:37:53.685+01
9	mobileclient_startuplogo_url	null	admin	\N	powercatch	0	2015-01-28 14:37:53.685+01
10	mobileclient_show_timeregistration_issue	true	admin	\N	powercatch	0	2015-01-28 14:37:53.687+01
11	mobileclient_show_timeregistration_menu	true	admin	\N	powercatch	0	2015-01-28 14:37:53.688+01
12	mobileclient_show_chat	false	admin	\N	powercatch	0	2015-01-28 14:37:53.689+01
13	mobileclient_show_map	true	admin	\N	powercatch	0	2015-01-28 14:37:53.689+01
14	mobileclient_show_augmented_reality	true	admin	\N	powercatch	0	2015-01-28 14:37:53.69+01
15	mobileclient_show_tracking	true	admin	\N	powercatch	0	2015-01-28 14:37:53.69+01
17	mobileclient_show_object_register	true	admin	\N	powercatch	0	2015-01-28 14:37:53.691+01
65	mobileclient_show_equipment	false	admin	\N	powercatch	0	2015-01-28 14:37:53.692+01
38	mobileclient_current_mobile_app_version	2.0.1	admin	\N	powercacth	0	2015-01-28 14:37:53.692+01
39	mobileclient_current_mobile_app_url	https://powercatch-3.teleplan.no/jira/MobileClientReleases/powercatch-test-2.0.1.apk	admin	\N	powercatch	0	2015-01-28 14:37:53.693+01
57	mobileclient_force_mobile_app_upgrade_counter	4	admin	\N	powercatch	0	2015-01-28 14:37:53.693+01
62	mobileclient_sync_connection_timeout	200	admin	\N	powercatch	0	2015-01-28 14:37:53.694+01
63	mobileclient_location_max_time	10	admin	\N	powercatch	0	2015-01-28 14:37:53.695+01
64	mobileclient_location_max_accuracy	50	admin	\N	powercatch	0	2015-01-28 14:37:53.695+01
78	mobileclient_login_session_timeout	168	admin	\N	powercatch	0	2015-01-28 14:37:53.696+01
20	powermap_show_powermap_infrastructure_checkboxes	true	admin	\N	powercatch	0	2015-01-28 14:37:53.696+01
21	powermap_user_can_create_issue_from_powermap_search	true	admin	\N	powercatch	0	2015-01-28 14:37:53.697+01
27	common_should_save_user_data	true	admin	\N	powercatch	0	2015-01-28 14:37:53.697+01
28	piu_projects_not_relevant_for_piu	AD,NFEED,IP	admin	\N	powercatch	0	2015-01-28 14:37:53.698+01
29	piu_filenames_not_relevant_for_map	signature.png, signature_old.png, signature-1.png, signature-2.png, signature-3.png	admin	\N	powercatch	0	2015-01-28 14:37:53.698+01
34	powermap_create_issue_links	createkabelskap:true,createdriftsoppgave:true,createnettstasjon1year:true,createnettstasjon5year:true	admin	\N	powercatch	0	2015-01-28 14:37:53.7+01
41	integration_activemq_push	false	admin	\N	\N	0	2015-01-28 14:37:53.7+01
43	integration_activemq_title_issue		admin	\N	\N	0	2015-01-28 14:37:53.701+01
52	integration_activemq_title_hour		admin	\N	\N	0	2015-01-28 14:37:53.702+01
53	integration_activemq_title_material		admin	\N	\N	0	2015-01-28 14:37:53.702+01
42	integration_activemq_message_issue		admin	\N	\N	0	2015-01-28 14:37:53.703+01
50	integration_activemq_message_hour		admin	\N	\N	0	2015-01-28 14:37:53.703+01
51	integration_activemq_message_material		admin	\N	\N	0	2015-01-28 14:37:53.704+01
54	integration_db_message_issue		admin	\N	\N	0	2015-01-28 14:37:53.704+01
55	integration_db_message_hour		admin	\N	\N	0	2015-01-28 14:37:53.705+01
56	integration_db_message_material		admin	\N	\N	0	2015-01-28 14:37:53.705+01
44	integration_db_type	mssqldev	admin	\N	\N	0	2015-01-28 14:37:53.706+01
45	integration_db_name		admin	\N	\N	0	2015-01-28 14:37:53.706+01
46	integration_db_schema		admin	\N	\N	0	2015-01-28 14:37:53.707+01
47	integration_db_table_issue		admin	\N	\N	0	2015-01-28 14:37:53.707+01
48	integration_db_table_hour		admin	\N	\N	0	2015-01-28 14:37:53.708+01
49	integration_db_table_material		admin	\N	\N	0	2015-01-28 14:37:53.708+01
58	integration_sql_definition	null	admin	\N	powercatch	0	2015-01-28 14:37:53.709+01
59	integration_sql_mapping	null	admin	\N	powercatch	0	2015-01-28 14:37:53.709+01
61	nfeed_config_location	propertytext#5.2.4.9	admin	\N	powercatch	0	2015-01-28 14:37:53.71+01
66	mobilservlet_max_filterissues	300	admin	\N	powercatch	0	2015-01-28 14:37:53.711+01
79	common_powercatch_is_offline	false	admin	\N	powercatch	0	2015-01-28 14:37:53.717+01
80	powermap_user_can_move_marker	false	admin	\N	powercatch	0	2015-01-28 14:37:53.717+01
1	common_baseurl	https://powercatch-3.teleplan.no	admin	\N	powercatch	0	2015-01-28 14:37:53.672+01
31	common_jira_context	/jira	admin	\N	powercatch	0	2015-01-28 14:37:53.674+01
32	common_map_api_keys		admin	\N	powercatch	0	2015-01-28 14:37:53.674+01
24	common_jira_custom_ids	spenning:10123,driftsmerking:10018,adresse:10100,maalerpunktid:23421,nettknutepunkt:10112,object_driftsmerking:10018,object_type:10004,object_strekkode:10002,longitude:10007,zip:2334,faser:10122,object_driftsmerking2:10019,ordrenummer:10103,object_id:10000,maalerid:10119,maalertype:11407,trafokoblet:11111,anleggstatus:11403,object_fabrikat:10003,fjernavlest:11406,startdate:10106,plassering:13900,address:10005,ampere:11405,anleggbeskrivelse:11402,object_name:10306,locality:10102,latitude:10006	admin	\N	powercatch	1	2014-12-08 07:14:55.995+01
19	common_jira_status_names	transition_netbas_resolve:PC_TRANSITION_CLOSE_ISSUE_DEFAULT,status_in_progress:PC_ISSUESTATUS_IN_PROGRESS,resolution_not_completed:PC_RESOLUTION_NOT_COMPLETED,status_closed:PC_ISSUESTATUS_CLOSED,transition_resolve:PC_TRANSITION_RESOLVE_ISSUE_DEFAULT,resolution_error:PC_RESOLUTION_ERROR_FOUND,status_resolved:PC_ISSUESTATUS_RESOLVED	admin	\N	powercatch	0	2015-01-28 14:37:53.677+01
77	mobileclient_timeregistration_is_mandatory	true	admin	\N	powercatch	0	2015-01-28 14:37:53.687+01
35	mobileclient_allowed_transition_names	PC_TRANSITION_START_PROGRESS_DEFAULT,PC_TRANSITION_STOP_PROGRESS_DEFAULT,PC_TRANSITION_START_WORK	admin	\N	powercatch	0	2015-01-28 14:37:53.699+01
33	powermap_relevant_infrastructure_checkboxes	mast:false,bryter:false,kabelskap:true,nettstasjon:true,linje-ls:false,linje-hs:false,jordkabel-ls:false,jordkabel-hs:false,linje-regional:false	admin	\N	powercatch	0	2015-01-28 14:37:53.699+01
60	resource_planner	{"hoursPerWorkday": "8","startHourMorning": "8","startMinutesMorning": "0","endHourEvening": "16","endMinutesEvening": "0","colorOpen": "ffe763","colorWorking": "1e90ff","colorDone": "1ed278","colorTextIssue": "000000","awayBillingKeys": ["666", "667", "33"],"awayMonthsPast": "6","awayMonthsFuture": "12","colorAway": "000000","colorTextAway": "ffe763","awayIcon": "information.gif","dayNumberMonday": "2","debugIssue": "LLS-21"}	admin	\N	powercatch	0	2015-01-28 14:37:53.71+01
67	common_database_to_use	POSTGRES	admin	\N	powercatch	0	2015-01-28 14:37:53.711+01
69	mobileclient_infrastructure_db_source	db	admin	\N	powercatch	0	2015-01-28 14:37:53.712+01
70	mobileclient_infrastructure_db_tables	nettstasjon,kabelskap	admin	\N	powercatch	0	2015-01-28 14:37:53.713+01
71	mobileclient_image_scaling	4	admin	\N	powercatch	0	2015-01-28 14:37:53.713+01
72	mobileclient_time_to_populate_issue	0.8	admin	\N	powercatch	0	2015-01-28 14:37:53.714+01
73	common_position_utm	32	admin	\N	powercatch	0	2015-01-28 14:37:53.715+01
74	mobilservlet_netbas_customer_config	2	admin	\N	powercatch	0	2015-01-28 14:37:53.715+01
75	mobileservlet_netbas_webservice_user	username:reSight,password:reSight	admin	\N	powercatch	0	2015-01-28 14:37:53.716+01
76	webservice_config	{"webservice_project":{"companyId":"ser","enabled":false,"config":{"protocol":"http","address":"domain.com","port":"80","webservice":"/servicename/serviceCreate/","webserviceUpdate":"/servicename/serviceUpdate/","projectField":"Ax Prosjekt","issue_types":[{"issue_type":"LD","data_out":{"IssueId":"#issueId","CustomerId":"Ax Kunde","Name":"#issueTitle","ParentId":"Ax Overordnet prosjekt","CompanyId":"#companyId","Department":"Ax Avdeling","Responsible":"#assignee","ProjGroupId":"Ax Prosjektgruppe","Type":"Ax Prosjekttype","ProjInvoiceProjId":"Ax Prosjektkontrakt"},"data_in":{"Prosjektnummer":"ProjectId"},"data_out_update":{"IssueId":"#issueId","CompanyId":"#companyId","ProjectId":"Ax Prosjekt"},"data_in_update":{"CustomerId":"Ax Kunde","ParentId":"Ax Overordnet prosjekt","Department":"Ax Avdeling","ProjGroupId":"Ax Prosjektgruppe","Type":"Ax Prosjekttype","ProjInvoiceProjId":"Ax Prosjektkontrakt"}},{"issue_type":"AO","data_out":{"pc_issue_id":"#issueId","ax_customer_id":"Ax Kunde","ax_parent_project":"#parentId"},"data_in":{"Prosjektnummer":"ProjectId"}}]}},"webservice_hours":{"companyId":"ser","networkAlias":"Axapta","approvedStatus":"Approved","enabled":false,"config":{"protocol":"http","address":"domain.com","port":"80","webservice":"/servicename/serviceHours/","queuetype":"powercatch.axapta.hours","data_out":{"CompanyId":"#companyId","NetworkAlias":"#networkAlias","CategoryId":"CategoryId","Hours":"Qty","ProjectId":"ProjectExt","TransDate":"Transdate","Approver":"AttestedBy","AttestCode":"#approved","Txt":"Txt"},"data_in":{"JournalId":"#Log","LineNum":"#Log"}}}}	admin	\N	powercatch	0	2015-01-28 14:37:53.716+01
81	hours_config	{"showHolidays":true,"showBalance":true,"hoursPerDay":7.5,"numberOfWeeks":"4","hoursPerWeek":"40","costAccountCategories":["Kostnader","Fiktive kostnader"],"holidayBillingKeys":["33"],"holidayIssues":["AD-1","AD-7"]}	admin	\N	powercatch	0	\N
82	mobileclient_location_max_distance	10	admin	\N	powercatch	0	2016-11-01 12:55:51.812+01
83	mobileclient_location_provider	0	admin	\N	powercatch	0	2016-11-01 12:55:51.812+01
84	mobileclient_timeregistration_show_field		admin	\N	powercatch	0	2016-11-01 12:57:05.226+01
68	mobileclient_menu_items	nettstasjon,kabelskap,linje-hs,linje-ls,linje-regional,jordkabel-hs,jordkabel-ls,jordkabel-regional	admin	\N	powercatch	0	2015-01-28 14:37:53.712+01
85	mobileclient_current_vectortile_version		admin	\N	powercatch	0	2016-11-01 12:57:05.226+01
86	mobileclient_current_vectortile_url		admin	\N	powercatch	0	2016-11-01 12:57:05.226+01
87	mobileservlet_netbas_xml_internal_netbas_path	C:\\netbas\\attachments\\NM\\	admin	\N	powercatch	0	2016-11-01 12:57:05.226+01
\.


--
-- TOC entry 2818 (class 0 OID 0)
-- Dependencies: 199
-- Name: config_server_values_id_seq; Type: SEQUENCE SET; Schema: konfigurasjon; Owner: powercatch
--

SELECT pg_catalog.setval('config_server_values_id_seq', 87, true);


--
-- TOC entry 2621 (class 0 OID 27319)
-- Dependencies: 200
-- Data for Name: config_user; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY config_user (id, key, data, endret_av, slettet, gradert, endret_dato, bruker) FROM stdin;
\.


--
-- TOC entry 2819 (class 0 OID 0)
-- Dependencies: 201
-- Name: config_user_id_seq; Type: SEQUENCE SET; Schema: konfigurasjon; Owner: powercatch
--

SELECT pg_catalog.setval('config_user_id_seq', 3, true);


--
-- TOC entry 2623 (class 0 OID 27330)
-- Dependencies: 202
-- Data for Name: field; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY field (id, nbr, name, customfieldid, changed_by, changed_date, deleted) FROM stdin;
0c859911-5b69-4b72-b4bc-65ed0ec74c4f	\N	summary	\N	\N	2013-11-08 14:22:08.437+01	0
f4aa34f0-71cf-43e1-a17f-a1259a4e4de0	\N	duedate	\N	\N	2013-11-08 14:26:01.009+01	0
fea10ee5-b8e6-40c5-9e0e-1598c721725c	\N	PC_OBSERVATION_EL_SAFETY	\N	PowerCatch Update Script	2013-11-12 00:47:23.958+01	0
4469077d-1a73-456e-ad6e-a4b8d0c8c53f	\N	PC_VENTILATION	\N	PowerCatch Update Script	2013-11-19 15:27:41.684+01	0
ad144347-408a-48ab-9a07-b481333de705	\N	PC_PROJECT_MANAGER_MAIN_PROJECT	\N	PowerCatch Update Script	2015-01-27 14:58:40.888+01	0
192c7bc4-b454-4262-9e27-213c14305469	\N	description	\N	\N	2013-11-08 14:23:09.558+01	0
4378a639-8a83-442a-977c-7dc17747dfcf	\N	timetracking	\N	\N	2013-11-08 14:27:00.444+01	0
113e0c5b-b254-4512-9db7-bba8ec4d6a53	\N	components	\N	\N	2013-11-08 14:31:06.692+01	0
fa847e28-f2e1-43d9-9f81-0215426635e6	\N	PC_LONGITUDE	\N	PowerCatch Update Script	2013-11-08 14:32:10.26+01	0
ba8bd0dc-04f6-40ab-aae9-355e9d1e4012	\N	PC_INSTALLATION_CITY	\N	PowerCatch Update Script	2013-11-08 14:36:42.498+01	0
2da613f2-5986-418a-a60f-eed5728389fe	\N	PC_INSTALLATION_ADDRESS	\N	PowerCatch Update Script	2013-11-08 14:36:06.538+01	0
8f2bae67-31c6-4099-915f-2ae70746db98	\N	PC_NETWORK_HUB	\N	PowerCatch Update Script	2013-11-08 14:29:36.981+01	0
efd83f7e-f454-4e30-8228-516539f50d8e	\N	PC_METER_REMOTE_REGISTRATED	\N	PowerCatch Update Script	2013-11-08 14:52:28.424+01	0
caed4189-d0a4-4437-8442-98973a204cf8	\N	PC_REGISTERED_METER_ID	\N	PowerCatch Update Script	2013-11-08 14:52:50.932+01	0
0dddf1ad-db73-4ecd-a5ee-7c8507704901	\N	PC_REGISTERED_VOLTAGE	\N	PowerCatch Update Script	2013-11-08 14:54:28.452+01	0
c7eacbb3-bc1f-4ba6-b9a3-03775b81efbf	\N	PC_NEW_METER_TYPE	\N	PowerCatch Update Script	2013-11-08 15:02:10.155+01	0
0e35c9f7-136e-475e-9518-4fab2e8d5d40	\N	PC_ORDER_NUMBER	\N	PowerCatch Update Script	2013-11-08 14:24:11.345+01	0
3aada81e-3a62-4218-8c93-fc738ba5f064	\N	PC_OBJECT_NAME	\N	PowerCatch Update Script	2013-11-12 00:18:08.721+01	0
42adcfd9-9836-459c-9f46-67f655df6ae9	\N	PC_OBJECT_ID	\N	PowerCatch Update Script	2013-11-08 14:28:11.649+01	0
860d40fe-a0ed-460d-b4cc-fee9128718e6	\N	PC_OBJECT_BARCODE	\N	PowerCatch Update Script	2013-11-08 14:31:30.55+01	0
cb9065dc-2a72-4e55-ad46-aa983c40de87	\N	PC_OPERATION_LABEL_1	\N	PowerCatch Update Script	2013-11-12 00:20:15.762+01	0
ae005cd5-f86d-4b79-aa8c-945e3ec2c72c	\N	PC_OBJECT_MANUFACTURER	\N	PowerCatch Update Script	2013-11-12 00:21:10.379+01	0
596b4d00-2c5d-426c-bf3b-da14f6d2e362	\N	PC_PLANNED_DATE	\N	PowerCatch Update Script	2013-11-08 14:24:52.964+01	0
e8af3bf5-92d3-4187-966c-a5a1818b49b5	\N	PC_SUPERSET_OBJECT_ID	\N	PowerCatch Update Script	2013-11-12 00:28:39.44+01	0
a7a58814-102c-4201-8e04-f187e41f7dc8	\N	PC_OBSERVATION_LABEL	\N	PowerCatch Update Script	2013-11-12 00:31:52.263+01	0
446bddae-dd60-49ea-b33a-1b911243c30b	\N	PC_CUSTOMER_PHONE	\N	PowerCatch Update Script	2013-11-08 14:33:08.423+01	0
4feb2c5b-be02-4170-a24f-8c863b17ac90	\N	PC_CUSTOMER_EMAIL	\N	PowerCatch Update Script	2013-11-08 14:34:58.228+01	0
178ac866-4348-49bb-ada4-752c940ad12d	\N	PC_CUSTOMER_NAME	\N	PowerCatch Update Script	2013-11-08 14:32:50.613+01	0
6edc2d7c-f958-4a80-bcec-a385b30b4591	\N	PC_INSTALLATION_LOCATION	\N	PowerCatch Update Script	2013-11-08 14:37:00.647+01	0
0f7a16b8-2a71-4325-9aa4-eaa50e2eeb61	\N	PC_VOLTAGE_LEVEL	\N	PowerCatch Update Script	2013-11-08 14:29:57.511+01	0
ce8f41e4-5c3b-4317-a920-a26a8a5ff762	\N	PC_DISCONNECT_PERFORMED	\N	PowerCatch Update Script	2013-11-08 14:38:18.072+01	0
6af56af7-7e38-4027-adc8-fc9a9e3afc56	\N	PC_WORK_ONGOING	\N	PowerCatch Update Script	2013-11-08 14:38:44.911+01	0
94359216-5ba2-4531-97c8-0b3c5bda9d85	\N	PC_SEALING	\N	PowerCatch Update Script	2013-11-08 14:51:48.276+01	0
7f8e370b-99b1-45e2-aa07-05252affff56	\N	PC_IS_METER_TRAFO_CONNECTED	\N	PowerCatch Update Script	2013-11-08 14:52:09.667+01	0
b133e553-f4ad-4121-a1f9-94d88e8ae292	\N	PC_REGISTERED_METER_ID_DIGITS	\N	PowerCatch Update Script	2013-11-08 14:53:12.107+01	0
f3eb6284-53e6-4585-88b0-010369fdd5b8	\N	PC_EXISTING_METER_ID_OK	\N	PowerCatch Update Script	2013-11-08 14:55:58.185+01	0
f259a9bc-24b9-45cb-b4da-f10238d573ec	\N	PC_EXISTING_METER_ID_DIGITS	\N	PowerCatch Update Script	2013-11-08 14:56:19.774+01	0
a4c4be42-2e19-4b9c-b787-6fc2d6f9db3d	\N	PC_EXISTING_METER_READING	\N	PowerCatch Update Script	2013-11-08 14:56:46.767+01	0
b754cc82-79a7-45d7-b531-0d7f3ccd1f8a	\N	PC_NEW_METER_IS_TRAFO_CONNECTED	\N	PowerCatch Update Script	2013-11-08 15:01:33.462+01	0
e979d334-eacb-4484-8ec1-b3aeb165582a	\N	PC_NEW_METER_VOLTAGE	\N	PowerCatch Update Script	2013-11-08 15:00:28.394+01	0
1630529d-0a7e-446f-a49a-46ed8995a51e	\N	PC_NEW_METER_ID	\N	PowerCatch Update Script	2013-11-08 15:00:08.358+01	0
c2851f1a-0876-42c5-86d9-1913616febfe	\N	PC_NEW_METER_READING	\N	PowerCatch Update Script	2013-11-08 14:59:49.957+01	0
d746d470-d687-49a8-84f8-2cedab3923c4	\N	PC_NEW_METER_COMMUTATOR	\N	PowerCatch Update Script	2013-11-08 14:58:11.537+01	0
13c8019b-64f5-4b0f-b7ec-6ae697c56a41	\N	PC_REGISTERED_METER_TRAFO_ID1	\N	PowerCatch Update Script	2013-11-08 14:54:48.478+01	0
beec8eb8-5a37-4899-b696-7ad91d7a9555	\N	PC_REGISTERED_METER_TRAFO_ID2	\N	PowerCatch Update Script	2013-11-08 14:55:15+01	0
5a890bec-71a7-4866-a372-d42e9c145d38	\N	PC_NEW_METER_TRAFO_ID1	\N	PowerCatch Update Script	2013-11-08 14:58:55.246+01	0
e9cecd60-ea5f-4113-acc7-3ae1072a0360	\N	PC_NEW_METER_TRAFO_ID2	\N	PowerCatch Update Script	2013-11-08 14:59:13.219+01	0
009e2e99-4552-4cf5-93c2-84f7a67fe7f4	\N	PC_NEW_METER_TRAFO_ID3	\N	PowerCatch Update Script	2013-11-08 14:59:30.355+01	0
0557a437-6657-432b-9f83-a3ea79290722	\N	PC_TIME_DRIVE_MIN	\N	PowerCatch Update Script	2013-11-08 15:02:57.827+01	0
445637d7-b030-4099-aacc-27866997c8a4	\N	PC_LINE_BRANCH	\N	PowerCatch Update Script	2013-11-12 00:29:22.89+01	0
781df1c6-f106-4f6e-b638-679013fa3531	\N	PC_GROUND_STRAP_DIAMETER	\N	PowerCatch Update Script	2013-11-12 00:35:54.79+01	0
db0441ff-3b3e-465e-9196-6ef0cad62495	\N	PC_OBSERVATION_POLE	\N	PowerCatch Update Script	2013-11-12 00:36:27.486+01	0
fdc15790-9abf-48a6-a133-7962d2d514bd	\N	PC_BRACE_ROD	\N	PowerCatch Update Script	2013-11-12 00:34:53.011+01	0
4ec9a34c-723e-41ff-8263-77a2567c96ee	\N	PC_INSPECTION_TYPE	\N	PowerCatch Update Script	2013-11-12 00:35:25.353+01	0
a51d4e58-4d97-47e0-b211-18fdfcb0ff02	\N	PC_CLEANING_REQUIRED	\N	PowerCatch Update Script	2013-11-12 00:23:15.04+01	0
d8b84793-c29e-4830-83a7-ecc5a3e09349	\N	PC_LV_BUSBAR_1_SYSTEM_VOLTAGE	\N	PowerCatch Update Script	2013-11-12 00:23:48+01	0
05f62bfd-344d-4703-96c0-baf88dd607a7	\N	PC_LV_BUSBAR_1_MAIN_VOLTAGE	\N	PowerCatch Update Script	2013-11-12 00:24:13.835+01	0
d1b18fbc-98c0-4520-9364-21a6e69af703	\N	PC_LV_BUSBAR_1_PHASE_VOLTAGE_L2_0	\N	PowerCatch Update Script	2013-11-12 00:25:06.927+01	0
9b6816ca-df1b-4cbb-b206-0afc9d8bd77a	\N	PC_LV_BUSBAR_1_PHASE_VOLTAGE_L3_0	\N	PowerCatch Update Script	2013-11-12 00:25:27.733+01	0
5149ece7-0c19-40cc-8680-c5a9cfc804c9	\N	PC_LV_BUSBAR_2_SYSTEM_VOLTAGE	\N	PowerCatch Update Script	2013-11-12 00:25:55.267+01	0
3c6563af-057e-40df-943a-40abbbf39e37	\N	PC_LV_BUSBAR_2_MAIN_VOLTAGE	\N	PowerCatch Update Script	2013-11-12 00:26:21.163+01	0
84be5f07-24b2-4e9b-b5fb-88015c34807b	\N	PC_LV_BUSBAR_2_PHASE_VOLTAGE_L2_0	\N	PowerCatch Update Script	2013-11-12 00:27:01.209+01	0
16ee56f8-75e5-49a7-9634-02096f37298c	\N	PC_LV_BUSBAR_2_PHASE_VOLTAGE_L3_0	\N	PowerCatch Update Script	2013-11-12 00:27:21.402+01	0
58c436ff-eabc-4f4c-912f-36bfcd5be624	\N	PC_MAX_LOAD_AMPERE	\N	PowerCatch Update Script	2013-11-12 00:29:58.233+01	0
95598dcd-c2af-4b37-9361-a6a8a98f1040	\N	PC_OBSERVATION_TRANSFORMER	\N	PowerCatch Update Script	2013-11-12 00:33:23.28+01	0
73660fed-ddd6-465b-957d-b73fc40cce8c	\N	PC_OBSERVATION_BUILDING_EXTERIOR	\N	PowerCatch Update Script	2013-11-12 00:30:49.661+01	0
03a63764-eeb2-43c4-a6ef-e00169b5d51a	\N	PC_OBSERVATION_BUILDING_INTERIOR	\N	PowerCatch Update Script	2013-11-12 00:31:18.715+01	0
4c391a38-46dc-4a6c-8b34-3cf5ad56c32a	\N	PC_OBSERVATION_SWITCHING_STATION	\N	PowerCatch Update Script	2013-11-12 00:32:18.822+01	0
30621d8d-b5ea-4b16-a4cf-9d64335a525d	\N	PC_METER_ID	\N	PowerCatch Update Script	2013-11-08 14:28:47.117+01	0
6f7f826f-9450-45f2-9bc3-146bf603a879	\N	PC_PROJECT_NUMBER	\N	PowerCatch Update Script	2013-11-12 00:17:18.931+01	0
b1e340e9-4187-49e6-9c29-8033d54f3de5	\N	PC_OBSERVATION_DAMAGES	\N	PowerCatch Update Script	2013-11-12 00:46:42.364+01	0
fc25df71-3cbc-45dc-8e7f-1248b823a1c1	\N	PC_COMMON_CONDUCT	\N	PowerCatch Update Script	2013-11-12 00:39:06.973+01	0
a556816e-b796-495a-89a0-cc8e37296151	\N	PC_OBSERVATION_TOTAL_EVALUATION	\N	PowerCatch Update Script	2013-11-12 00:39:35.993+01	0
c3aea1e5-3a20-4d13-9e8b-fafb1061df16	\N	PC_OBSERVATION_CORD	\N	PowerCatch Update Script	2013-11-12 00:43:02.684+01	0
019e3eee-9742-4109-8761-258c2dbff78a	\N	Disneuter	\N	PowerCatch Update Script	2013-11-12 00:22:47.206+01	1
24ae4ab8-d897-4a04-8ca9-2f6fbcfba35d	\N	PC_OBSERVATION_GROUNDING_CABLE	\N	PowerCatch Update Script	2013-11-12 00:45:05.182+01	0
be082a04-cbef-40d5-a9b7-762edba45ac8	\N	PC_OBSERVATION_SUSPENSION	\N	PowerCatch Update Script	2013-11-12 00:43:28.021+01	0
58b7792f-31a9-4bd3-8cbf-373667034a34	\N	PC_OBSERVATION_POLE_WOOD	\N	PowerCatch Update Script	2013-11-12 00:40:34.382+01	0
33fb4714-ee14-4771-9327-a56dd55fc845	\N	PC_OBSERVATION_POLE_BRACE_ROD	\N	PowerCatch Update Script	2013-11-12 00:42:19.632+01	0
5277c870-944b-4b20-ab82-1c8b8479c39e	\N	PC_CABLE_TRAY3	\N	PowerCatch Update Script	2013-11-20 10:39:58.501+01	0
694bc0df-cdb0-4f3c-bb3a-076efa2d50ed	\N	PC_PROJECT_NAME	\N	PowerCatch Update Script	2013-11-18 09:43:07.337+01	0
7865e966-0985-457a-a6bb-dce41806f8d5	\N	PC_GROUND_CONDITIONS	\N	PowerCatch Update Script	2013-11-18 11:14:32.069+01	0
1bc1d6bc-b38d-4049-b448-743b4e8909f2	\N	PC_FOREST_TYPE	\N	PowerCatch Update Script	2013-11-18 11:15:22.455+01	0
80f6222f-b70c-43f7-a24d-6f4a9bb3cf19	\N	PC_ANCHORING_BRACING_WIRE	\N	PowerCatch Update Script	2013-11-18 11:15:46.541+01	0
2b20e523-4066-4fdb-9e5c-729f580b2874	\N	PC_INFORMATION_EXISTING_LINE	\N	PowerCatch Update Script	2013-11-18 11:16:17.52+01	0
637d6388-eeaf-4b61-8d88-a5e12ebe9973	\N	Objekttype	\N	PowerCatch Update Script	2013-11-12 00:59:49.569+01	1
05c8424b-f6d6-4731-8ad3-bd601809da5b	\N	PC_LIVE_WORKING	\N	PowerCatch Update Script	2013-11-18 11:32:24.818+01	0
a530ac65-dbc6-42dd-a8d9-334e01da488b	\N	PC_WORK_CLOSE_TO_HIGH_VOLTAGE_INSTALLATION	\N	PowerCatch Update Script	2013-11-18 11:32:45.452+01	0
36d95c1b-b098-4430-9a66-db01e2d83317	\N	PC_WORK_ON_DISCONNECTED_INSTALLATION	\N	PowerCatch Update Script	2013-11-18 11:33:12.604+01	0
7e56415a-b556-43e3-8596-33957eb69353	\N	PC_GOVERNMENT_SAFETY_REGULATIONS_APPLY	\N	PowerCatch Update Script	2013-11-18 11:32:06.966+01	0
513e1357-9336-4b5b-893b-fe7a9ac5c0b4	\N	PC_ASSEMBLED_TRANSFORMER_NUMBER	\N	PowerCatch Update Script	2013-11-18 14:16:36.54+01	0
29cc6c92-2174-461b-b2dc-f0a4e9d08116	\N	PC_TRANSFORMER_TYPE	\N	PowerCatch Update Script	2013-11-18 14:16:57.639+01	0
bc90e212-1eb6-4d4d-99c4-ad8fe240d4b2	\N	PC_TRANSFORMER_SIZE_KVA	\N	PowerCatch Update Script	2013-11-18 14:17:14.358+01	0
8e1dd386-ff2d-43c0-b52c-b9906896edcb	\N	PC_SUBSTATION_TYPE	\N	PowerCatch Update Script	2013-11-18 13:00:29.975+01	0
2411c955-0d11-4d64-ba79-8378d2a729b5	\N	PC_INTERNAL_EXTERNAL_CONTROLLED	\N	PowerCatch Update Script	2013-11-18 13:00:45.331+01	0
e3c29df2-b390-4e0c-82f0-3730c00f16c4	\N	PC_SUBSTATION_NUMBER	\N	PowerCatch Update Script	2013-11-18 13:01:35.656+01	0
99543702-f608-4748-b226-4e3e3f0ad17e	\N	PC_SWITCH_TYPE	\N	PowerCatch Update Script	2013-11-18 13:58:43.992+01	0
51397b49-eb4d-4f73-a0db-683e312ae2ba	\N	PC_SWITCH_SERIAL_NUMBER	\N	PowerCatch Update Script	2013-11-18 13:59:02.092+01	0
b15a6788-3dd6-47e0-8863-6dea45cb186e	\N	PC_SWITCH_ID	\N	PowerCatch Update Script	2013-11-18 13:59:18.04+01	0
5d0322d8-4e33-4d1f-be33-200f4eccc545	\N	PC_SWITCH_MANUFACTURE	\N	PowerCatch Update Script	2013-11-18 13:59:49.35+01	0
e6fc46c7-407a-475f-a36d-b5875de2f14f	\N	PC_CABLE_TERMINAL_TYPE	\N	PowerCatch Update Script	2013-11-19 09:08:01.01+01	0
70a0347a-48dd-400b-b5d2-348a0a54f60f	\N	PC_CABLE_JOINT_TYPE	\N	PowerCatch Update Script	2013-11-19 09:08:56.25+01	0
ddd1bd5b-b605-4b16-bae6-2487be9d9fe7	\N	PC_POLE_TYPE	\N	PowerCatch Update Script	2013-11-18 15:02:10.438+01	0
f76bfdde-c7dc-4f13-a20c-f00afed3da95	\N	PC_BASEMENT_TYPE	\N	PowerCatch Update Script	2013-11-18 13:31:17.203+01	0
4d84cc75-8b47-4170-8038-a36f4ea50f3a	\N	PC_POLE_LENGTH	\N	PowerCatch Update Script	2013-11-18 15:02:51.134+01	0
f59043f8-8e07-4526-a124-4d61a42a31d0	\N	PC_IMPREGNATION_TYPE	\N	PowerCatch Update Script	2013-11-18 15:03:06.062+01	0
e9ecb5b6-800b-4b87-b9b3-4cf964ff0d5e	\N	PC_CABINET_TYPE_MANUFACTURE	\N	PowerCatch Update Script	2013-11-18 14:28:24.412+01	0
ce92bcf6-cb18-4a27-8d0e-504a9bbf26b3	\N	PC_CABINET_NUMBER	\N	PowerCatch Update Script	2013-11-18 14:28:44.097+01	0
6ab86eaf-e45f-4751-bce4-982c87b61999	\N	PC_CABINET_WIDTH	\N	PowerCatch Update Script	2013-11-18 14:29:03.133+01	0
9e04fd7a-5244-4793-b574-4c3ef5b2ebaf	\N	PC_CABLE_TYPE	\N	PowerCatch Update Script	2013-11-19 08:59:09.958+01	0
cd169a71-f5cd-4847-aa86-f4463c324d07	\N	PC_CABLE_CROSS_SECTION	\N	PowerCatch Update Script	2013-11-19 08:56:17.152+01	0
19e7b5ac-4117-4732-9d2f-ae967d166e31	\N	PC_FINAL_CHECK_SUBSTATION_BASEMENT	\N	PowerCatch Update Script	2013-11-18 13:36:06.353+01	0
31c24f78-93fe-4d39-881b-0e499a5dcc0e	\N	PC_FINAL_CHECK_ASSEMBLY_HV_SWITCH_POLE	\N	PowerCatch Update Script	2013-11-18 14:09:03.939+01	0
93886579-3037-4e0f-9960-20308f014d41	\N	PC_FINAL_CHECK_ASSEMBLY_HV_INSTALLATION_SUBSTATION	\N	PowerCatch Update Script	2013-11-18 15:20:35.182+01	0
b92bdca7-3b58-4eca-be76-b9b7de13b8d3	\N	PC_FINAL_CHECK_ASSEMBLY_SUBSTATION_GROUND	\N	PowerCatch Update Script	2013-11-18 13:07:20.012+01	0
c18f2d03-cc42-46c3-93ff-0dda9bcd0a95	\N	PC_FINAL_CHECK_MATERIAL_TRANSPORTATION	\N	PowerCatch Update Script	2013-11-18 15:27:33.171+01	0
1168b528-cd03-4c9b-9f93-0212561debca	\N	PC_FINAL_CHECK_ASSEMBLY_SUBSTATION_POLE	\N	PowerCatch Update Script	2013-11-18 13:18:47.017+01	0
700bbef0-e7d3-436b-9a20-d64cd3ff1dd9	\N	PC_FINAL_CHECK_POLE_ERECTION	\N	PowerCatch Update Script	2013-11-18 15:10:15.674+01	0
9ffa9433-8fe8-4008-977f-032d59e8be92	\N	PC_FINAL_CHECK_CABLE_TERMINATION_HV	\N	PowerCatch Update Script	2013-11-19 09:11:25.201+01	0
fbabaf3e-2176-4e26-b780-1ab11c343481	\N	PC_FINAL_CHECK_ASSEMBLY_TRANSFORMATOR_GROUND	\N	PowerCatch Update Script	2013-11-18 15:35:18.148+01	0
47324346-9f5f-4cba-879d-719033f8677e	\N	PC_FINAL_CHECK_GROUND_PLATE_MEASUREMENT	\N	PowerCatch Update Script	2013-11-19 08:50:09.522+01	0
bd9fe340-0e82-4664-b6e7-d4c8aa348aac	\N	PC_FINAL_CHECK_ASSEMBLY_CABLE_PIPE_IN_DITCH	\N	PowerCatch Update Script	2013-11-19 09:00:48.797+01	0
69d4217f-ac2c-4375-b723-aca238139fe7	\N	PC_FINAL_CHECK_ASSEMBLY_CABINET	\N	PowerCatch Update Script	2013-11-18 14:52:06.805+01	0
48ce902b-5423-4463-b4da-1585b4cb62b5	\N	PC_FINAL_CHECK_ALTERATION_SUBSTATION_POLE	\N	PowerCatch Update Script	2013-11-18 14:22:16.518+01	0
0cfef08f-a592-4c32-8329-d16a68c33bb1	\N	PC_HIGH_RISK_OF_INJURY	\N	PowerCatch Update Script	2013-11-18 12:41:03.496+01	0
b476921f-afa1-4565-b63e-609541e00a63	\N	PC_UNKNOWN_TASK	\N	PowerCatch Update Script	2013-11-18 12:41:26.127+01	0
a13ae77c-6566-4d7e-a641-642d03e7ec23	\N	PC_LACKS_INSTRUCTION_OR_PROCEDURE	\N	PowerCatch Update Script	2013-11-18 12:42:54.703+01	0
91ed2745-c4ad-4aa9-96da-724a8d4b3bfe	\N	PC_KNOWN_RISK_FACTORS	\N	PowerCatch Update Script	2013-11-18 12:41:52.084+01	0
005fe715-7c64-4359-83d1-71d981848a4b	\N	PC_OTHER_TASKS_ONGOING	\N	PowerCatch Update Script	2013-11-18 12:42:07.778+01	0
168cfe5a-a69e-4909-b6b1-048cea2eca95	\N	PC_INSUFFICIENT_TIME	\N	PowerCatch Update Script	2013-11-18 12:42:22.658+01	0
1683671d-75f1-4000-a5fe-3e5fa6ea8861	\N	PC_UNCLEAR_RISK_ASSESSMENT	\N	PowerCatch Update Script	2013-11-18 12:42:37.803+01	0
0a3975c3-715b-447c-bb1f-1294d0ea3c4f	\N	PC_SAFETY_LEADER_WORK_RESPONSIBLE	\N	PowerCatch Update Script	2013-11-18 11:33:28.799+01	0
a3376898-774e-4a3c-8efd-54c69631da9b	\N	PC_REQUIRED_TRAINING_WORK_TOOLS	\N	PowerCatch Update Script	2013-11-18 12:43:12.13+01	0
c30d180c-7b0f-47c5-b565-3e7605b11c00	\N	PC_BUILDING_CONSTRUCTION_STATUS	\N	PowerCatch Update Script	2013-11-19 15:26:44.429+01	0
e4ecd993-638a-4ec7-94da-83c383359954	\N	PC_LIGHTING	\N	PowerCatch Update Script	2013-11-19 15:28:51.428+01	0
6f86eeed-fa03-4ffa-b4c9-fc7912cf9925	\N	PC_LOW_VOLTAGE_INSTALLATION_SS_GROUND	\N	PowerCatch Update Script	2013-11-19 15:30:47.979+01	0
b030798c-5865-41d7-895b-864b13a86303	\N	PC_TRANSFORMATOR_SS_GROUND	\N	PowerCatch Update Script	2013-11-19 15:31:54.563+01	0
45604dff-0499-4217-80f3-e33872dbd4a2	\N	PC_FINAL_CHECK_SS_GROUND_CABINET_LABEL	\N	PowerCatch Update Script	2013-11-19 15:32:45.475+01	0
94e2d918-0244-4df5-a0ee-33a89eb2cd46	\N	PC_CLEARING	\N	PowerCatch Update Script	2013-11-19 14:57:06.802+01	0
ab1bbd19-0362-4126-9265-2538c324497e	\N	PC_POLE	\N	PowerCatch Update Script	2013-11-19 14:35:43.834+01	0
befa41fc-ff56-49a3-924c-d425b99b8670	\N	PC_BRACING_WIRE	\N	PowerCatch Update Script	2013-11-19 14:52:52.812+01	0
c023134b-eaaa-49ea-aa61-2663197b6fc3	\N	PC_HV_DIVERTER	\N	PowerCatch Update Script	2013-11-19 14:43:55.479+01	0
39a1d0f3-90b6-49a7-b801-cb78da963778	\N	PC_FINAL_CHECK_SS_POLE_HV_LINE_LIVE_CONNECTION	\N	PowerCatch Update Script	2013-11-19 14:45:13.647+01	0
2a3e89d1-b6e8-4e52-859c-a1f128aec03b	\N	PC_GROUNDING_PERSONNEL_SAFETY_SS_POLE	\N	PowerCatch Update Script	2013-11-19 14:48:09.422+01	0
f532baac-3ed9-4aaa-8f8a-949a7a1b145b	\N	PC_HIGH_VOLTAGE_INSTALLATION_SS_POLE	\N	PowerCatch Update Script	2013-11-19 14:49:27.141+01	0
143cdae5-6d39-40e2-a7c7-d563bc0bc45c	\N	PC_LOW_VOLTAGE_INSTALLATION_SS_POLE	\N	PowerCatch Update Script	2013-11-19 14:54:07.403+01	0
47d4a5c0-c9ef-4ec2-bbd1-8369c2d34e2e	\N	PC_FINAL_CHECK_SS_POLE_LABEL	\N	PowerCatch Update Script	2013-11-19 14:55:50.106+01	0
5924fe11-ef14-4cbb-8b7e-d81fb9e92967	\N	PC_PLACEMENT_LIMIT_SWITCH	\N	PowerCatch Update Script	2013-11-19 15:45:18.822+01	0
17834413-3d7e-42db-ba14-cd26ef202db3	\N	PC_BASEMENT_CABINET	\N	PowerCatch Update Script	2013-11-19 15:48:01.42+01	0
0f90b610-f599-4b2d-bff0-58b926589d4a	\N	PC_CABINET_CABLE_ENTRY_POINT	\N	PowerCatch Update Script	2013-11-19 15:51:23.603+01	0
f4f95f7f-af7b-40d3-85c0-09382f31a4f9	\N	PC_CORD_WIRE	\N	PowerCatch Update Script	2013-11-19 16:12:36.474+01	0
575fa992-c2c2-42dd-8af3-f57be846db06	\N	PC_AERIAL_CABLE	\N	PowerCatch Update Script	2013-11-19 16:17:47.383+01	0
93761b4a-38f5-4f6f-9db2-a0f0ed339f89	\N	PC_WIRING_ROUTE	\N	PowerCatch Update Script	2013-11-19 16:19:04.071+01	0
ddbe76ad-b83f-44b6-9478-8320b5086e66	\N	PC_HV_INSTALLATION	\N	PowerCatch Update Script	2013-11-19 16:20:02.398+01	0
462e936d-0d0d-4cc5-a5e0-a9667bb81e3a	\N	PC_LV_INSTALLATION	\N	PowerCatch Update Script	2013-11-20 09:56:17.48+01	0
7c22d0fc-4c8b-4cf2-bf8b-1c95e58aac26	\N	PC_FINAL_CHECK_CABINET_GROUNDING_ENTRY_POINT	\N	PowerCatch Update Script	2013-11-19 15:52:10.362+01	0
7f444795-ea41-4b0d-b58b-406ce4238b21	\N	PC_FINAL_CHECK_CABINET_CABLE_PLACEMENT	\N	PowerCatch Update Script	2013-11-19 15:54:00.978+01	0
609e8025-24e5-4bc8-815d-d9e5ff2820ec	\N	PC_FINAL_CHECK_CABLE_ASSEMBLY_POWER_RAIL	\N	PowerCatch Update Script	2013-11-19 15:55:05.049+01	0
a7c5f5a9-7b35-48d1-9bfc-19dbd86485f4	\N	PC_FINAL_CHECK_CABINET_CABLE_LABELING	\N	PowerCatch Update Script	2013-11-19 15:57:50.809+01	0
a64a720c-5e32-4815-ad96-3a148a2dc1e2	\N	PC_TAG_LABEL	\N	PowerCatch Update Script	2013-11-19 16:21:21.478+01	0
22892165-d9a3-49ca-b16f-b48ac2c6cf72	\N	PC_FINAL_CHECK_CABINET_LABELLING	\N	PowerCatch Update Script	2013-11-19 15:58:36.48+01	0
2b184350-f92e-44ea-bc46-f590eca51142	\N	PC_CONTROL_BEFORE_VOLTAGE_ENABLED	\N	PowerCatch Update Script	2013-11-20 10:02:31.612+01	0
f87390e0-27a7-40ef-a0e9-3646609390eb	\N	PC_FINAL_CHECK_ATTACHMENT_MODULE_ATTACHED	\N	PowerCatch Update Script	2013-11-19 16:00:32.287+01	0
5ac86566-26b2-42b0-8a85-5bae60c38311	\N	PC_FINAL_CHECK_DOCUMENTATION	\N	PowerCatch Update Script	2013-11-19 16:01:59.686+01	0
eb7d73fc-6ce4-4040-8212-39032a7eb367	\N	PC_SPARK_GAP	\N	PowerCatch Update Script	2013-11-20 10:09:02.954+01	0
9aee362c-9266-4216-afbd-6284e9df40e9	\N	PC_CONTROL_AFTER_VOLTAGE_ENABLED	\N	PowerCatch Update Script	2013-11-20 10:16:48.334+01	0
15792a80-25bb-4354-bf9c-c5d9f042c1a8	\N	PC_HIGH_LOW_VOLTAGE	\N	PowerCatch Update Script	2013-11-20 10:05:13.188+01	0
921d8472-548f-429b-96a3-75821ed2616d	\N	PC_DITCH_CONTROL	\N	PowerCatch Update Script	2013-11-20 10:30:58.809+01	0
3035e929-9160-418a-bfde-c1080ba83b4a	\N	PC_ATT2_SPUR_CABLE_FIBRE_PIPE	\N	PowerCatch Update Script	2013-11-20 10:33:09.696+01	0
712f19da-2322-423f-b594-d6d28dcc3dc9	\N	PC_ATT3_CABLES_PIPES_FIELDS	\N	PowerCatch Update Script	2013-11-20 10:33:53.639+01	0
15fd0496-631f-496a-916b-731846620315	\N	PC_ATT4_CABLES_PIPES_NO_CONTROL_POSSIBLE	\N	PowerCatch Update Script	2013-11-20 10:34:49.871+01	0
24029956-ee43-4cd9-99a3-04a23d44d524	\N	PC_ATT5_CABLES_PIPES_AGRICULTURAL_AREA	\N	PowerCatch Update Script	2013-11-20 10:35:46.279+01	0
6e8672ef-6231-442d-b77e-ee05f1f90e57	\N	PC_REG_BY_OTHER_PROPERTY_OWNER	\N	PowerCatch Update Script	2013-11-20 10:36:32.55+01	0
3be0b12b-c794-4deb-a8c9-d9cc89479512	\N	PC_CABLE_TRAY	\N	PowerCatch Update Script	2013-11-20 10:38:46.582+01	0
f50cad58-e302-4d85-9ef1-4d24f95f749d	\N	PC_CABLE_TRAY2	\N	PowerCatch Update Script	2013-11-20 10:39:40.173+01	0
f6982a0e-79b9-404f-9b9a-07a0031abd47	\N	PC_FINAL_CHECK_GROUNDING_PERSONNEL_SAFETY_HV_LINE	\N	PowerCatch Update Script	2013-11-19 16:16:12.088+01	0
022a9204-77e7-47cc-8d81-6e10a8b4a694	\N	PC_FINAL_CHECK_BRACING_WIRE_LV_LINE	\N	PowerCatch Update Script	2013-11-20 09:51:14.394+01	0
02b515dd-a5fc-4108-bfc2-61939d8db011	\N	PC_FINAL_CHECK_INSULATOR_CONNECTION_SUSPENSION_FASTEN_LV_LINE	\N	PowerCatch Update Script	2013-11-20 09:53:09.817+01	0
08c01e7c-cf40-468b-8d8f-d9b325b8b05a	\N	PC_FINAL_CHECK_REPLACE_TRANSFORMATOR_POLE	\N	PowerCatch Update Script	2013-11-19 13:41:24.426+01	0
392340f6-d5ea-4447-886f-022d4c477409	\N	PC_FINAL_CHECK_DIGGING_DITCH_FOR_CABLE	\N	PowerCatch Update Script	2013-11-19 13:45:26.872+01	0
a4601121-4c91-4b51-a5d6-e019bc36acfb	\N	PC_FINAL_CHECK_COMPLETE_ASSEMBLY_SPUR_CABLE_INCL_METER	\N	PowerCatch Update Script	2013-11-19 12:38:45.172+01	0
09f538a0-d7a3-4c9f-a173-38aec6475d68	\N	PC_FINAL_CHECK_COMPLETE_ASSEMBLY_SPUR_CABLE	\N	PowerCatch Update Script	2013-11-19 12:46:26.193+01	0
12cffb1e-ef22-4b6f-bbf4-c4ae18502f82	\N	PC_FINAL_CHECK_CONNECT_CABLE_IN_POLE	\N	PowerCatch Update Script	2013-11-19 10:31:54.209+01	0
e533651a-4434-42fa-975b-ee1cb6da9e96	\N	PC_FINAL_CHECK_LV_LINE_STRETCHING	\N	PowerCatch Update Script	2013-11-19 09:29:40.665+01	0
fbb9c59b-f30e-45ba-ba16-adc0e0581e99	\N	PC_ASSEMBLED_CENTRAL_SAFETY_FUSE_SIZE	\N	PowerCatch Update Script	2013-11-19 13:13:57.558+01	0
50a59c7d-111e-4dc6-ad47-e9e02e990bea	\N	PC_MAIN_FUSE_SIZE	\N	PowerCatch Update Script	2013-11-19 13:16:05.677+01	0
ec02dfb9-fb25-4217-903c-5fec8dece6e2	\N	PC_ASSEMBLY_DATE	\N	PowerCatch Update Script	2013-11-19 13:19:03.099+01	0
5ed945df-f687-466a-9ffe-7b1a87405805	\N	PC_CENTRAL_NUMBER	\N	PowerCatch Update Script	2013-11-19 13:20:09.763+01	0
c6275c3c-1776-4109-8891-76d66c3481ca	\N	PC_METER_NUMBER	\N	PowerCatch Update Script	2013-11-19 13:22:02.482+01	0
b0c3d079-544a-4562-9674-6cf81d9efb7e	\N	PC_CENTRAL_ASSEMBLY_METHOD	\N	PowerCatch Update Script	2013-11-19 13:24:18.841+01	0
643790a0-1326-4aef-ba10-c3c39ead3341	\N	PC_FINAL_CHECK_ASSEMBLY_TEMP_POWER_SUPPLY	\N	PowerCatch Update Script	2013-11-19 13:27:09.456+01	0
2b12cf08-9527-4885-bbb6-3895ba24f1ba	\N	PC_DISASSEMBLY_DATE	\N	PowerCatch Update Script	2013-11-19 13:33:11.07+01	0
5e762146-3767-457a-87b5-65b69bd57947	\N	PC_CENTRAL_CABINET_OR_POLE_NUMBER	\N	PowerCatch Update Script	2013-11-19 13:26:05.096+01	0
17e85dcf-cd58-4e76-9a9d-647c2b79dbe2	\N	PC_ROUTE_LV_LINE	\N	PowerCatch Update Script	2013-11-20 09:53:55.753+01	0
3b5e008d-0a8e-4328-badd-05c9b933d25c	\N	PC_LATITUDE	\N	PowerCatch Update Script	2013-11-08 14:31:53.108+01	0
012338b0-e20b-4d59-b576-407878a92c89	\N	PC_INSTALLATION_ZIPCODE	\N	PowerCatch Update Script	2013-11-08 14:36:25.228+01	0
d4034a39-fe17-40d8-9a43-95f74e4f1c08	\N	PC_INSTALLATION_DESCRIPTION	\N	PowerCatch Update Script	2013-11-20 11:19:46.508+01	0
1ee35fa3-e6b8-4c26-a1e6-7e5256a496ee	\N	PC_REGISTERED_NO_OF_PHASES	\N	PowerCatch Update Script	2013-11-08 14:53:55.838+01	0
9a08e1d7-37e4-4f71-a3ac-1fab129a4efa	\N	PC_BILLING_ADDRESS	\N	PowerCatch Update Script	2013-11-08 14:30:44.515+01	0
1a06eb7a-6b1d-48c9-b008-c1cb4f54dba5	\N	PC_LOCATION	\N	PowerCatch Update Script	2013-11-12 00:59:24.426+01	0
e4fe1634-90a1-4e02-bb91-6148fc990a52	\N	PC_OBJECT_TYPE	\N	PowerCatch Update Script	2013-11-12 00:21:36.858+01	0
985dab9a-5b78-4c48-a447-fccb360bbfd0	\N	PC_OPERATION_LABEL_2	\N	PowerCatch Update Script	2013-11-12 00:20:38.399+01	0
6f8f2726-9268-45ca-a88e-20bc1bc24024	\N	PC_TIME_AGREED_WITH_CUSTOMER	\N	PowerCatch Update Script	2013-11-08 14:26:37.049+01	0
897cbd79-ace7-4ea4-b290-ecb4ee4bd2ba	\N	PC_COMPLETION_DATE	\N	PowerCatch Update Script	2013-11-12 00:38:00.714+01	0
c39018e5-b1d1-4713-9171-fcd7c6ac763f	\N	PC_CUSTOMER_MOBILE	\N	PowerCatch Update Script	2013-11-08 14:34:40.95+01	0
0a123997-7511-4978-8dcc-67653e47e005	\N	Leveringsadresse	\N	PowerCatch Update Script	2013-11-08 14:37:15.018+01	1
7287ae0a-ddbf-408b-831a-496abf5c74d6	\N	PC_VOLTAGE_CHECK_PERFORMED	\N	PowerCatch Update Script	2013-11-08 14:39:06.499+01	0
b6445073-2043-4018-bd59-a578dc12816e	\N	PC_REGISTERED_METER_READING	\N	PowerCatch Update Script	2013-11-08 14:53:36.13+01	0
6af12968-5bb0-4c21-8d18-4f9252e7e037	\N	PC_NEW_METER_NO_OF_PHASES	\N	PowerCatch Update Script	2013-11-08 15:01:14.709+01	0
d9d9e9a1-2b94-43ee-91e6-d58089e8b129	\N	PC_NEW_METER_MODEM	\N	PowerCatch Update Script	2013-11-08 14:58:31.633+01	0
7c41b804-d21a-42db-ad44-f665a052ff37	\N	PC_REGISTERED_METER_TRAFO_ID3	\N	PowerCatch Update Script	2013-11-08 14:55:35.152+01	0
d30ed4f4-eca1-4f45-a7ec-e14ec0d5aa4f	\N	PC_TIME_WORK_MIN	\N	PowerCatch Update Script	2013-11-08 15:02:35.929+01	0
bc326c56-be19-4e14-9ac1-a09868076e19	\N	PC_OBSERVATION_BRACING_WIRE	\N	PowerCatch Update Script	2013-11-12 00:37:10.026+01	0
eccc7c90-f882-4502-b366-01e00e137af3	\N	PC_OBSERVATION_TOP	\N	PowerCatch Update Script	2013-11-12 00:36:48.675+01	0
9bac0d40-40fe-4675-b3ca-85046fa58a4b	\N	PC_OBSERVATION_LAYOUT	\N	PowerCatch Update Script	2013-11-12 00:37:30.1+01	0
be7e1796-4f0d-4568-a015-804e92a6935c	\N	PC_LV_BUSBAR_1_PHASE_VOLTAGE_L1_0	\N	PowerCatch Update Script	2013-11-12 00:24:38.226+01	0
26aa3602-5dff-4ccd-bbaa-34b3a4c28364	\N	PC_LV_BUSBAR_2_PHASE_VOLTAGE_L1_0	\N	PowerCatch Update Script	2013-11-12 00:26:42.176+01	0
4b7d8b1c-01cf-4861-95c3-f16202e70909	\N	PC_OBSERVATION_CABLE_INSTALLATION_LV	\N	PowerCatch Update Script	2013-11-12 00:34:07.865+01	0
d1d3abae-88e7-4288-847b-6bf76119e92a	\N	PC_SIGNATURE_EXECUTER	\N	PowerCatch Update Script	2014-02-24 11:19:14.153+01	0
e67c0f45-1b31-4b7b-ab4c-d2785de4af05	\N	PC_OWNER_BUILDER	\N	PowerCatch Update Script	2013-12-04 00:06:52.198+01	0
579a5a70-fce4-4613-b523-82edc355b7b8	\N	PC_DATE_SECTION_INSTALLATION_OPERATION	\N	PowerCatch Update Script	2013-12-04 00:08:47.142+01	0
1fb8eeb0-0c38-4efc-9d18-af066980049d	\N	PC_CONFIRMATIONS	\N	PowerCatch Update Script	2013-12-04 00:06:27.885+01	0
85209d30-5cc9-4c1d-b89b-35986ccc80b9	\N	PC_SIGNATURE_OWNER_OPERATOR	\N	PowerCatch Update Script	2013-12-04 00:08:47.144+01	0
b4aac9a1-33dc-4be2-a767-555c06e1d879	\N	PC_SIGNATURE_DATE	\N	PowerCatch Update Script	2013-12-04 00:08:47.143+01	0
e7d43001-f2df-4c4c-b798-ef2e8d4f33a2	\N	PC_BASEMENT_POLE	\N	PowerCatch Update Script	2014-01-22 15:20:55.022+01	0
c2ed37d4-9419-4cf0-af97-b3469192dd5d	\N	PC_ROCK_DRILL_USAGE	\N	PowerCatch Update Script	2014-01-22 15:49:27.499+01	0
0bd94fa4-8a00-4e27-b61a-0e4492e9a279	\N	PC_CONNECTION_LV_CABLE	\N	PowerCatch Update Script	2014-01-22 16:10:58.37+01	0
44bb2529-8e86-4ae4-b49b-dd03cece2706	\N	PC_CONNECTION_HV_CABLE	\N	PowerCatch Update Script	2014-01-23 09:14:32.757+01	0
5e85cad4-8d1b-4fb4-9787-a78d1fcd4938	\N	PC_LIFTING_HOISTING	\N	PowerCatch Update Script	2014-01-23 11:08:31.608+01	0
0f77502c-70db-448b-ab44-9738a09b3192	\N	PC_POLE_ERECTION_MANUAL	\N	PowerCatch Update Script	2014-01-22 15:50:41.421+01	0
10e65967-09a2-4b87-a437-4b99ac8dd2cf	\N	PC_POLE_ERECTION_MACHINE	\N	PowerCatch Update Script	2014-01-22 15:51:14.795+01	0
495d021a-3ae9-4396-9906-b6b084afc7ee	\N	PC_POLE_CLIMBING	\N	PowerCatch Update Script	2014-01-22 16:02:51.171+01	0
f380c4a0-17f5-4ad7-ba76-1bde09c5fe0e	\N	PC_FINAL_CHECK_METER_ASSEMBLY	\N	PowerCatch Update Script	2014-01-23 08:35:53.206+01	0
96fdfd98-fa88-45be-9754-90c3eac90ba9	\N	PC_AREA_OF_OPERATIONS	\N	PowerCatch Update Script	2014-01-31 10:48:59.892+01	0
8053627b-4fb1-4e63-8941-e813461d4930	\N	PC_ASSEMBLY_CABLE_DUCT	\N	PowerCatch Update Script	2014-01-22 16:08:06.207+01	0
6265db2b-32e7-4072-9d16-398fc8299b23	\N	PC_ASSEMBLY_STRAIN_RELIEF	\N	PowerCatch Update Script	2014-01-22 16:08:53.539+01	0
94573bd7-6b17-428a-9e89-c178eb63dc69	\N	PC_HOIST_CABLE_IN_POLE	\N	PowerCatch Update Script	2014-01-22 16:09:30.285+01	0
a284cf01-cc2e-4bdb-95cb-a8dffb61e49a	\N	PC_DISMANTLE_CABLE	\N	PowerCatch Update Script	2014-01-23 08:40:22.139+01	0
9193ddec-cb4c-4542-ae48-1f9206393bc5	\N	PC_CLEANING	\N	PowerCatch Update Script	2014-01-23 08:40:59.04+01	0
59455c01-34a3-46db-97f4-6291b97832c5	\N	PC_PRESSURE_BRACKET	\N	PowerCatch Update Script	2014-01-23 08:41:34.796+01	0
94f28fcb-9ae1-4d96-ac4d-a53ae15e731b	\N	PC_CRIMPLE_HEAT	\N	PowerCatch Update Script	2014-01-23 08:42:08.634+01	0
21122e0f-213a-4668-88d4-c579a11acc06	\N	PC_DIGGING_PLOT_TRANSFORMATOR	\N	PowerCatch Update Script	2014-01-23 09:18:15.486+01	0
d18ba1ab-d104-41bb-b82f-8c2cd2f2c9fe	\N	PC_ASSEMBLY_BASEMENT_KIOSK	\N	PowerCatch Update Script	2014-01-23 09:18:51.251+01	0
3d6f615f-938e-49a6-9398-36e029419d73	\N	PC_DIGGING_DITCH	\N	PowerCatch Update Script	2014-01-23 09:22:07.187+01	0
3d5b2587-bfe0-4349-bcb0-942f7265ece1	\N	PC_SWITCH_ATTACHMENT	\N	PowerCatch Update Script	2014-01-23 11:09:02.013+01	0
c9543dab-99a8-4f75-b6e9-ea717317e8b9	\N	PC_SWITCHBOARD_ASSEMBLY	\N	PowerCatch Update Script	2014-01-23 11:17:13.918+01	0
6fafc31e-1f0c-4331-b52f-9bc59430ae69	\N	PC_DISASSEMBLY_OLD_SWITCH	\N	PowerCatch Update Script	2014-01-23 11:22:58.43+01	0
19c9b393-f076-45bd-ac0c-91a79357aaf4	\N	PC_SWITCH_TRANSPORTATION	\N	PowerCatch Update Script	2014-01-23 11:23:26.346+01	0
642e1b4a-bfc9-4035-8e7f-e21b2a2119e2	\N	PC_ASSEMBLY_NEW_SWITCH	\N	PowerCatch Update Script	2014-01-23 11:23:53.06+01	0
05365c87-98a6-4a87-a538-28239bdde6c6	\N	PC_CONNECT_DISSCONNECT_HV_CABLE	\N	PowerCatch Update Script	2014-01-23 11:24:53.7+01	0
4e2b3641-4fc2-4ccb-9c38-addc7e70f92e	\N	PC_ASSEMBLY_DISASSEMBLY_CABINET	\N	PowerCatch Update Script	2014-01-23 11:40:10.75+01	0
6034017d-27c6-4ee0-a390-4fabbf659086	\N	PC_ASSEMBLY_DISASSEMBLY_SUPPORTING_BAR	\N	PowerCatch Update Script	2014-01-23 12:23:22.776+01	0
19ed2943-1bdd-461e-b16d-6f09f817aa7d	\N	PC_ASSEMBLY_METER_DIRECTLY_MEASURED	\N	PowerCatch Update Script	2014-01-23 11:30:06.235+01	0
517c720f-2cd8-4e8d-9054-d933b9c6ac68	\N	PC_ASSEMBLY_METER_TRANSFORMATOR_MEASURED	\N	PowerCatch Update Script	2014-01-23 11:30:34.931+01	0
553f0824-511a-40ac-86aa-c0f80ef4ac96	\N	PC_ASSEMBLY_MEASURING_DEVICE	\N	PowerCatch Update Script	2014-01-23 11:16:25.982+01	0
b94f1be3-ec06-4fec-85f6-8dfc3bc2eb09	\N	PC_GENERIC_SAFETY_ASSESSMENT	\N	PowerCatch Update Script	2014-03-15 18:59:09.521+01	0
bd96a33c-a4bb-406b-891f-068efe5fd11e	\N	PC_OBSERVATION_CABLE_INSTALLATION_HV	\N	PowerCatch Update Script	2013-11-12 00:33:44.602+01	0
093ec3fe-093e-4702-a1c8-ba5c50f9eda0	\N	PC_OBSERVATION_DIVERTER	\N	PowerCatch Update Script	2013-11-12 00:43:56.981+01	0
ae3cb724-c46d-4cab-add9-576b038ecb28	\N	PC_OBSERVATION_POLE_METAL	\N	PowerCatch Update Script	2013-11-12 00:40:13.184+01	0
b924770d-72b1-49a3-8974-c7959e9fc0dc	\N	PC_GROUND_BASEMENT	\N	PowerCatch Update Script	2013-11-19 15:17:40.649+01	0
f2e0db4d-3b19-46ad-bd68-e30b6513958d	\N	PC_GROUNDING_PERSONNEL_SAFETY_SS_GROUND	\N	PowerCatch Update Script	2013-11-19 15:24:19.294+01	0
3ee2d386-d27c-4965-b359-ab3b858ecbd9	\N	PC_ACCESS	\N	PowerCatch Update Script	2014-01-06 11:10:08.782+01	0
530f7542-e5fa-4873-8bd2-9461da8d2f22	\N	PC_HIGH_VOLTAGE_INSTALLATION_SS_GROUND	\N	PowerCatch Update Script	2013-11-19 15:29:54.028+01	0
be5ac55e-4321-49ce-8609-fb8d9a660f28	\N	PC_BASEMENT	\N	PowerCatch Update Script	2013-11-19 14:28:44.358+01	0
4826f73d-4d2f-470e-bba5-f3dac141e8f8	\N	PC_HV_SPARK_GAP	\N	PowerCatch Update Script	2013-11-19 14:42:30.591+01	0
5e064e68-7699-4805-8c02-e511895ffd99	\N	PC_SWITCH_AERIAL_GRID	\N	PowerCatch Update Script	2013-11-19 14:46:19.647+01	0
e1d452da-ddf7-413e-b0dd-cd27c36c12bf	\N	PC_TRANSFORMER_SS_POLE	\N	PowerCatch Update Script	2013-11-19 14:54:57.098+01	0
3e6142cf-cf5b-48fa-866b-eebc21549a99	\N	PC_PLACEMENT_INFLAMMABLE_WALL	\N	PowerCatch Update Script	2013-11-19 15:50:29.427+01	0
89302344-8165-41bb-9b5d-55c8b5937ad5	\N	PC_FINAL_CHECK_INSULATOR_CONNECTION_SUSPENSION_FASTEN	\N	PowerCatch Update Script	2013-11-19 16:13:47.425+01	0
0a6b44bd-d7a1-4f78-9f6b-bc51c44596b5	\N	PC_FINAL_CHECK_SPACE_COMMON_TRAY	\N	PowerCatch Update Script	2013-11-20 09:55:04.424+01	0
41bbfbef-96e9-41fa-a151-efc16bb0fae7	\N	PC_FINAL_CHECK_GROUNDING_TO_PEN	\N	PowerCatch Update Script	2013-11-19 15:57:02.088+01	0
3fce5b44-0130-423f-adec-df07d301aaf8	\N	PC_FINAL_CHECK_PHASE_SEQUENCE_ROTATION_DIRECTION	\N	PowerCatch Update Script	2013-11-19 15:59:50.735+01	0
2c873c9e-0f44-4191-9981-0829b0c04410	\N	PC_FINAL_CHECK_VOLTAGE_CONTROL_OUTLET	\N	PowerCatch Update Script	2013-11-19 16:01:15.727+01	0
a76b0b63-614c-4816-9a0b-65463e43981f	\N	PC_SAFETY_MEASURE_CANCELLED	\N	PowerCatch Update Script	2013-11-20 10:04:19.541+01	0
c72432f6-ebee-4828-a00d-d3899d60180d	\N	PC_ATT1_DENSELY_BUILT_AREA_AND_ROADS	\N	PowerCatch Update Script	2013-11-20 10:32:20.92+01	0
8a6d900f-74ed-4bfc-a292-eb04a1cca35d	\N	PC_FINAL_CHECK_CORD_WIRE_LV_LINE	\N	PowerCatch Update Script	2013-11-20 09:52:13.177+01	0
c808ea96-d83f-4ea5-946d-2c415e08e189	\N	PC_DIGGING	\N	PowerCatch Update Script	2013-11-18 11:14:03.82+01	0
aaf56607-b395-4d2d-a2cd-8fcb0529a771	\N	PC_POSSIBLE_WORK_METHODS	\N	PowerCatch Update Script	2013-11-18 11:15:01.409+01	0
68aa9e74-bb2f-4bf2-850e-32f5fec2138a	\N	Typebetegnelse	\N	PowerCatch Update Script	2013-11-12 01:00:15.423+01	1
ca0c3d30-4632-4fd1-a34f-8e25847c2719	\N	PC_DATE_INSTALLATION_OPERATION	\N	PowerCatch Update Script	2013-12-04 00:08:47.14+01	0
cf2185e8-a704-4811-81c8-6d653d12e2d9	\N	PC_FINAL_CHECK_CABLE_TERMINATION_LV	\N	PowerCatch Update Script	2013-11-19 09:16:01.431+01	0
65ea22d4-9603-429b-82d3-06132ae67f36	\N	PC_METER_TRANSFORMER_SIZE	\N	PowerCatch Update Script	2013-11-19 13:17:24.835+01	0
c830a4e9-f6be-41eb-85be-e9d7e0655d7e	\N	PC_METER_READING	\N	PowerCatch Update Script	2013-11-19 13:23:28.105+01	0
9762007e-8602-4e9d-a6c2-c25c6f7ddf92	\N	PC_FINAL_CHECK_DISASSEMBLY_TEMP_POWER_SUPPLY	\N	PowerCatch Update Script	2013-11-19 13:35:08.164+01	0
afe1c492-90c0-4e07-bfa2-8d2978487228	\N	PC_BASEMENT_BLASTING_WORK	\N	PowerCatch Update Script	2014-01-22 15:24:43.06+01	0
8aec8381-320f-44d1-a314-59aecff884f5	\N	PC_ASSEMBLY_CABLE_PIPE	\N	PowerCatch Update Script	2014-01-23 09:24:36.895+01	0
5ca65412-e345-49d9-8c19-17efa01b2cea	\N	PC_ASSEMBLY_BASEMENT_SUBSTATION	\N	PowerCatch Update Script	2014-01-23 11:36:21.752+01	0
fa942b87-8507-435e-ac90-2e53d1bba64b	\N	PC_GROUNDING_CONNECTION	\N	PowerCatch Update Script	2014-01-23 11:15:45.186+01	0
35cd0d2c-762a-434a-9b48-f300fa3ece4f	\N	PC_ACTIVITY_TYPE	\N	PowerCatch Update Script	2014-01-31 10:49:59.714+01	1
38855134-13eb-4161-bdca-f81301843cc2	\N	PC_SAFETY_ASSESSMENT_TASK	14502	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
c3758398-e2e1-4162-9e8a-02fe04c7e06f	\N	PC_SAFETY_ASSESSMENT_RISK	14501	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
02fc7f12-edfb-4d0c-bf29-e056040fecc6	\N	PC_SAFETY_ASSESSMENT_ACTION	14500	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
3d1cf3cb-4be3-4e08-b55f-eba1672f8f55	\N	PC_FINAL_CHECK	14701	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
8acc965b-2be4-4dc2-98b4-7ebbc9484222	\N	Ax Kunde	14200	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
4cd0b4c6-909c-4210-a2ef-187f33f6ce22	\N	Ax Prosjekt	14206	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
cf848725-edc9-4360-9a50-382b5b86a691	\N	PC_SUBTASK_TYPE	14900	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
eeb6d4d9-9245-4d13-9239-352654454a68	\N	PC_SUBTASK_TYPE_SYSTEM	15200	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
8500a60c-31d6-4ea8-a53f-236203a004a2	\N	PC_SIGNATURE_REQUIRED	\N	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
2efe51c4-28c4-10f9-40e7-48fd2453973b	\N	PC_TEXTAREA_DEFAULT_SQL	99999	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
\.


--
-- TOC entry 2624 (class 0 OID 27339)
-- Dependencies: 203
-- Data for Name: fieldproperty; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY fieldproperty (id, label, editable, required, checkboxvalidationid, id_field, changed_by, changed_date, deleted, hidden) FROM stdin;
9b2d8dfd-9b5e-483c-9729-bc8d3b020a46	\N	1	0	\N	019e3eee-9742-4109-8761-258c2dbff78a	\N	2013-11-15 09:03:11.012+01	0	\N
ae9ac878-7cfa-4817-bc3c-7c80181cb4e3	\N	1	0	1	73660fed-ddd6-465b-957d-b73fc40cce8c	\N	2013-11-15 09:03:11.012+01	0	\N
1cc73687-7d36-4bdb-88e4-7ed9d3c774c5	\N	1	0	1	03a63764-eeb2-43c4-a6ef-e00169b5d51a	\N	2013-11-15 09:03:11.012+01	0	\N
fe743a5b-3016-44ae-bed8-0b9c560429d9	\N	1	0	1	a7a58814-102c-4201-8e04-f187e41f7dc8	\N	2013-11-15 09:03:11.012+01	0	\N
e4b92d2b-e7cc-4d7c-ba3f-9b044ddbeac8	\N	1	0	1	4c391a38-46dc-4a6c-8b34-3cf5ad56c32a	\N	2013-11-15 09:03:11.012+01	0	\N
7b5adeb5-77a4-427b-910e-488f7862eaec	\N	1	0	1	95598dcd-c2af-4b37-9361-a6a8a98f1040	\N	2013-11-15 09:03:11.012+01	0	\N
d6d019a7-5a0d-402a-9e9d-1d1657aacfc9	\N	1	0	1	bd96a33c-a4bb-406b-891f-068efe5fd11e	\N	2013-11-15 09:03:11.012+01	0	\N
182abf30-e866-45f0-9586-c16601efdc72	\N	1	0	1	4b7d8b1c-01cf-4861-95c3-f16202e70909	\N	2013-11-15 09:03:11.012+01	0	\N
884469dc-18fd-4c5c-bb72-5bc2e163eba6	\N	1	0	\N	fdc15790-9abf-48a6-a133-7962d2d514bd	\N	2013-11-15 09:03:11.012+01	0	\N
0ad9dd9b-b390-4ad1-abda-8b55ccc4e1dc	\N	1	0	\N	4ec9a34c-723e-41ff-8263-77a2567c96ee	\N	2013-11-15 09:03:11.012+01	0	\N
414abb1b-3235-4521-bd7d-a53081f0137f	\N	1	0	\N	99543702-f608-4748-b226-4e3e3f0ad17e	\N	2013-11-18 14:00:31.513+01	0	\N
bfc4f408-3d24-4970-af8a-1a3d1ac04114	\N	1	0	1	5924fe11-ef14-4cbb-8b7e-d81fb9e92967	\N	2013-11-19 15:45:49.653+01	0	\N
34c75c60-df48-4de5-aa9c-03e32fbf7c26	\N	1	0	\N	44bb2529-8e86-4ae4-b49b-dd03cece2706	Eirik Frantzen	2014-01-23 09:14:41.824+01	0	\N
f5f3dec1-18f7-43e2-8e57-9140e01ccc4d	\N	1	0	\N	21122e0f-213a-4668-88d4-c579a11acc06	Eirik Frantzen	2014-01-23 09:18:29.376+01	0	\N
c95289f2-0844-47e2-aa4b-db9c7a606564	\N	1	0	\N	d18ba1ab-d104-41bb-b82f-8c2cd2f2c9fe	Eirik Frantzen	2014-01-23 09:19:02.143+01	0	\N
a3a7dd48-1bba-493a-81ef-10da9ec319ea	\N	1	0	\N	3d6f615f-938e-49a6-9398-36e029419d73	Eirik Frantzen	2014-01-23 09:22:15.312+01	0	\N
e4b9d51a-ba2f-4bd5-b9d7-b1a76d094ad4	\N	1	0	\N	8aec8381-320f-44d1-a314-59aecff884f5	Eirik Frantzen	2014-01-23 09:24:45.785+01	0	\N
7740f924-d424-4a8e-874f-6170453c8e6f	\N	1	0	\N	fa942b87-8507-435e-ac90-2e53d1bba64b	Eirik Frantzen	2014-01-23 11:15:55.518+01	0	\N
25a356dd-5147-42f7-a8a9-2d4564861c38	\N	1	0	\N	a51d4e58-4d97-47e0-b211-18fdfcb0ff02	\N	2013-11-15 09:03:11.012+01	0	\N
15aadd9c-611b-44da-9525-c01029a583ea	\N	0	0	\N	0c859911-5b69-4b72-b4bc-65ed0ec74c4f	\N	2013-11-15 09:03:11.012+01	0	\N
2c44e699-173c-4091-9a5c-873e459618a3	\N	0	0	\N	596b4d00-2c5d-426c-bf3b-da14f6d2e362	\N	2013-11-15 09:03:11.012+01	0	\N
549ab99d-d4a4-4454-a418-deb6d3423f8b	\N	0	0	\N	f4aa34f0-71cf-43e1-a17f-a1259a4e4de0	\N	2013-11-15 09:03:11.012+01	0	\N
f06c52cc-cc5e-480b-9696-3c76dfb55cf8	\N	1	0	\N	6f8f2726-9268-45ca-a88e-20bc1bc24024	\N	2013-11-15 09:03:11.012+01	0	\N
d11aa057-050d-4673-a5b3-43244be6a0a0	\N	0	0	\N	4378a639-8a83-442a-977c-7dc17747dfcf	\N	2013-11-15 09:03:11.012+01	0	\N
97594e2d-e0ab-4338-ac33-a8bcacf2f26c	\N	0	0	\N	30621d8d-b5ea-4b16-a4cf-9d64335a525d	\N	2013-11-15 09:03:11.012+01	0	\N
9d0c6cea-3bfc-4680-b862-5f03e2d77f46	\N	0	0	\N	8f2bae67-31c6-4099-915f-2ae70746db98	\N	2013-11-15 09:03:11.012+01	0	\N
9b1854a1-25c2-4716-a8ee-9ebbcd3c4b9f	\N	0	0	\N	0f7a16b8-2a71-4325-9aa4-eaa50e2eeb61	\N	2013-11-15 09:03:11.012+01	0	\N
c30fbbfa-c9ce-4fc2-8380-148a59572f59	\N	0	0	\N	9a08e1d7-37e4-4f71-a3ac-1fab129a4efa	\N	2013-11-15 09:03:11.012+01	0	\N
7a2edd9d-20f7-4213-b9c6-bbedcfa20b0c	\N	0	0	\N	113e0c5b-b254-4512-9db7-bba8ec4d6a53	\N	2013-11-15 09:03:11.012+01	0	\N
18de1c08-3c4c-4f4f-a5ed-4d93a454e617	\N	0	0	\N	860d40fe-a0ed-460d-b4cc-fee9128718e6	\N	2013-11-15 09:03:11.012+01	0	\N
f03990b2-ca7e-4701-8ba3-207d16661a25	\N	0	0	\N	3b5e008d-0a8e-4328-badd-05c9b933d25c	\N	2013-11-15 09:03:11.012+01	0	\N
2ccb651f-754e-416d-bfcc-3e347baf3969	\N	0	0	\N	fa847e28-f2e1-43d9-9f81-0215426635e6	\N	2013-11-15 09:03:11.012+01	0	\N
b1de6368-e72b-4db6-8d7d-9a88b5dae3d0	\N	0	0	\N	178ac866-4348-49bb-ada4-752c940ad12d	\N	2013-11-15 09:03:11.012+01	0	\N
90fca990-9c3c-40fc-9b9f-b091cc60220b	\N	0	0	\N	446bddae-dd60-49ea-b33a-1b911243c30b	\N	2013-11-15 09:03:11.012+01	0	\N
55254909-80a4-44a3-b5f5-4339413e6b27	\N	0	0	\N	c39018e5-b1d1-4713-9171-fcd7c6ac763f	\N	2013-11-15 09:03:11.012+01	0	\N
abbcbe8c-d6f3-41da-bca4-810eee92b16f	\N	0	0	\N	4feb2c5b-be02-4170-a24f-8c863b17ac90	\N	2013-11-15 09:03:11.012+01	0	\N
84e10dc1-9463-400d-8614-d947ca066e13	\N	0	0	\N	012338b0-e20b-4d59-b576-407878a92c89	\N	2013-11-15 09:03:11.012+01	0	\N
51d7ece3-cec1-4444-93c1-cd7d7ecfb5ef	\N	0	0	\N	ba8bd0dc-04f6-40ab-aae9-355e9d1e4012	\N	2013-11-15 09:03:11.012+01	0	\N
f222070b-0c9c-4721-8f9f-b74d6cf2f243	\N	0	0	\N	6edc2d7c-f958-4a80-bcec-a385b30b4591	\N	2013-11-15 09:03:11.012+01	0	\N
d0fd02e4-86c3-4610-a9e0-2079b1c8bd96	\N	0	0	\N	0a123997-7511-4978-8dcc-67653e47e005	\N	2013-11-15 09:03:11.012+01	0	\N
0993a9b3-0e64-4ce4-88fa-bcb2610a884b	\N	1	0	\N	ce8f41e4-5c3b-4317-a920-a26a8a5ff762	\N	2013-11-15 09:03:11.012+01	0	\N
60bf3710-a94d-4c79-8cce-81c477623c3a	\N	1	0	\N	6af56af7-7e38-4027-adc8-fc9a9e3afc56	\N	2013-11-15 09:03:11.012+01	0	\N
044e035f-8b8b-4f4c-b742-f1cc0d7805f9	\N	1	0	\N	7287ae0a-ddbf-408b-831a-496abf5c74d6	\N	2013-11-15 09:03:11.012+01	0	\N
325bf757-479e-4953-a96b-82a268c2efa7	\N	1	0	\N	94359216-5ba2-4531-97c8-0b3c5bda9d85	\N	2013-11-15 09:03:11.012+01	0	\N
f21df6fb-f0fd-4515-b649-b999d49ca93e	\N	0	0	\N	7f8e370b-99b1-45e2-aa07-05252affff56	\N	2013-11-15 09:03:11.012+01	0	\N
f7ef9514-d203-4c34-8afb-b3ff54590b44	\N	0	0	\N	efd83f7e-f454-4e30-8228-516539f50d8e	\N	2013-11-15 09:03:11.012+01	0	\N
e56876d2-fcc3-4965-92ec-ad843915cba3	\N	0	0	\N	caed4189-d0a4-4437-8442-98973a204cf8	\N	2013-11-15 09:03:11.012+01	0	\N
ffa88b48-a6c6-472d-89ce-3f3d0efbf562	\N	0	0	\N	b133e553-f4ad-4121-a1f9-94d88e8ae292	\N	2013-11-15 09:03:11.012+01	0	\N
b83d7ceb-5ad3-45f0-b83a-adee76ef99d3	\N	0	0	\N	b6445073-2043-4018-bd59-a578dc12816e	\N	2013-11-15 09:03:11.012+01	0	\N
5f27b427-8682-427e-bcbe-38468e01f4db	\N	0	0	\N	1ee35fa3-e6b8-4c26-a1e6-7e5256a496ee	\N	2013-11-15 09:03:11.012+01	0	\N
0fe17d8a-feaa-4510-9722-e9b62e232f32	\N	0	0	\N	0dddf1ad-db73-4ecd-a5ee-7c8507704901	\N	2013-11-15 09:03:11.012+01	0	\N
eb95c00f-149a-4923-bb17-a9bff8f09c28	\N	0	0	\N	13c8019b-64f5-4b0f-b7ec-6ae697c56a41	\N	2013-11-15 09:03:11.012+01	0	\N
7589fd27-d5c0-43b1-9c59-2a32c1e04a96	\N	0	0	\N	beec8eb8-5a37-4899-b696-7ad91d7a9555	\N	2013-11-15 09:03:11.012+01	0	\N
b1d16c74-5ab5-469c-bcdf-70c19f92a58f	\N	0	0	\N	7c41b804-d21a-42db-ad44-f665a052ff37	\N	2013-11-15 09:03:11.012+01	0	\N
78787420-ebfb-45ea-8907-548e4843bd34	\N	1	0	\N	a4c4be42-2e19-4b9c-b787-6fc2d6f9db3d	\N	2013-11-15 09:03:11.012+01	0	\N
650e0111-4952-4918-97c6-748d4fe09af8	\N	1	0	\N	f259a9bc-24b9-45cb-b4da-f10238d573ec	\N	2013-11-15 09:03:11.012+01	0	\N
42149447-cd81-4afb-8d1b-e6ab60e878c1	\N	1	0	\N	f3eb6284-53e6-4585-88b0-010369fdd5b8	\N	2013-11-15 09:03:11.012+01	0	\N
4915aafc-4cc3-4a73-abfc-b75f9a7c83b0	\N	1	0	\N	d746d470-d687-49a8-84f8-2cedab3923c4	\N	2013-11-15 09:03:11.012+01	0	\N
bd639d5b-ac8f-4048-9407-1339204502de	\N	1	0	\N	d9d9e9a1-2b94-43ee-91e6-d58089e8b129	\N	2013-11-15 09:03:11.012+01	0	\N
bb8f38be-b932-4535-8d47-865cf259f16b	\N	1	0	\N	5a890bec-71a7-4866-a372-d42e9c145d38	\N	2013-11-15 09:03:11.012+01	0	\N
64950977-4d03-4ff6-9a33-b6527c145021	\N	1	0	\N	e9cecd60-ea5f-4113-acc7-3ae1072a0360	\N	2013-11-15 09:03:11.012+01	0	\N
2566d38c-771e-4e0d-9ed0-6f9f70e0d01c	\N	1	0	\N	553f0824-511a-40ac-86aa-c0f80ef4ac96	Eirik Frantzen	2014-01-23 11:16:35.344+01	0	\N
2c78776f-8ce8-4c45-923a-dfca9be67cc2	\N	1	0	\N	19ed2943-1bdd-461e-b16d-6f09f817aa7d	Eirik Frantzen	2014-01-23 11:30:13.738+01	0	\N
99633213-6308-47b3-b1e4-b0a9e50699ea	\N	1	0	\N	009e2e99-4552-4cf5-93c2-84f7a67fe7f4	\N	2013-11-15 09:03:11.012+01	0	\N
60716744-b2ad-4327-9b71-1989e5815973	\N	1	0	\N	c2851f1a-0876-42c5-86d9-1913616febfe	\N	2013-11-15 09:03:11.012+01	0	\N
2c0a43a5-9b24-46d8-87b4-20aa4d350da8	\N	1	0	\N	1630529d-0a7e-446f-a49a-46ed8995a51e	\N	2013-11-15 09:03:11.012+01	0	\N
3cc64e62-a979-43ef-aa09-030b31cf7831	\N	1	0	\N	e979d334-eacb-4484-8ec1-b3aeb165582a	\N	2013-11-15 09:03:11.012+01	0	\N
911c6d03-8e9b-44d8-aa33-3ec1bf3510dd	\N	1	0	\N	6af12968-5bb0-4c21-8d18-4f9252e7e037	\N	2013-11-15 09:03:11.012+01	0	\N
e0fb40e1-2ad6-47d3-add7-edf4a422290c	\N	1	0	\N	b754cc82-79a7-45d7-b531-0d7f3ccd1f8a	\N	2013-11-15 09:03:11.012+01	0	\N
cac3b0be-b8a3-4713-ba46-d64381151ea7	\N	1	0	\N	c7eacbb3-bc1f-4ba6-b9a3-03775b81efbf	\N	2013-11-15 09:03:11.012+01	0	\N
006041b0-56a6-4c4f-b21d-99f2e3df4589	\N	1	0	\N	d30ed4f4-eca1-4f45-a7ec-e14ec0d5aa4f	\N	2013-11-15 09:03:11.012+01	0	\N
de94ce8f-2966-4b8c-9837-130e7b2e5766	\N	1	0	\N	0557a437-6657-432b-9f83-a3ea79290722	\N	2013-11-15 09:03:11.012+01	0	\N
f7170f93-75f0-4422-8a45-1d3ebb17fb34	\N	0	0	\N	3aada81e-3a62-4218-8c93-fc738ba5f064	\N	2013-11-15 09:03:11.012+01	0	\N
71f25906-c204-432c-a38c-be73d09be9da	\N	0	0	\N	0e35c9f7-136e-475e-9518-4fab2e8d5d40	\N	2013-11-15 09:03:11.012+01	0	\N
1344ca85-aef8-4588-bb68-5bfa3c4831e5	\N	0	0	\N	cb9065dc-2a72-4e55-ad46-aa983c40de87	\N	2013-11-15 09:03:11.012+01	0	\N
dfd4fa2c-daf5-4b61-92d6-ffba87778310	\N	0	0	\N	985dab9a-5b78-4c48-a447-fccb360bbfd0	\N	2013-11-15 09:03:11.012+01	0	\N
d9583663-fe88-4aa8-8fa3-83236959e238	\N	0	0	\N	ae005cd5-f86d-4b79-aa8c-945e3ec2c72c	\N	2013-11-15 09:03:11.012+01	0	\N
daedcc99-3e82-4e31-82e9-478220735fd3	\N	0	0	\N	e4fe1634-90a1-4e02-bb91-6148fc990a52	\N	2013-11-15 09:03:11.012+01	0	\N
b58cf0ba-2c8b-4acb-81e8-1ccc9af23950	\N	1	0	\N	d8b84793-c29e-4830-83a7-ecc5a3e09349	\N	2013-11-15 09:03:11.012+01	0	\N
1db62648-46f5-4b2c-838b-93007359a7d8	\N	1	0	\N	05f62bfd-344d-4703-96c0-baf88dd607a7	\N	2013-11-15 09:03:11.012+01	0	\N
9ed38125-d90f-4c06-bb27-0e1ce4dbce1b	\N	1	0	\N	be7e1796-4f0d-4568-a015-804e92a6935c	\N	2013-11-15 09:03:11.012+01	0	\N
c5389313-661f-47cc-9116-d319e324735d	\N	1	0	\N	d1b18fbc-98c0-4520-9364-21a6e69af703	\N	2013-11-15 09:03:11.012+01	0	\N
0cea6818-f24a-454b-b405-7fc24059f847	\N	1	0	\N	9b6816ca-df1b-4cbb-b206-0afc9d8bd77a	\N	2013-11-15 09:03:11.012+01	0	\N
18cf003a-b2b7-46fb-97f8-e441c1485c2f	\N	1	0	\N	5149ece7-0c19-40cc-8680-c5a9cfc804c9	\N	2013-11-15 09:03:11.012+01	0	\N
e4786a68-136d-4dea-ae8e-e4a9895fc261	\N	1	0	\N	3c6563af-057e-40df-943a-40abbbf39e37	\N	2013-11-15 09:03:11.012+01	0	\N
4d562f4c-0989-4bb0-a2ed-2f5ea8c88afc	\N	1	0	\N	26aa3602-5dff-4ccd-bbaa-34b3a4c28364	\N	2013-11-15 09:03:11.012+01	0	\N
e62bfa27-3e51-42a3-b55c-7e76ba52727f	\N	1	0	\N	84be5f07-24b2-4e9b-b5fb-88015c34807b	\N	2013-11-15 09:03:11.012+01	0	\N
2b7f98ae-eb58-4df0-836e-3fb25d48a86d	\N	1	0	\N	16ee56f8-75e5-49a7-9634-02096f37298c	\N	2013-11-15 09:03:11.012+01	0	\N
4a28ee02-35a8-4147-909a-8da989716d1b	\N	0	0	\N	e8af3bf5-92d3-4187-966c-a5a1818b49b5	\N	2013-11-15 09:03:11.012+01	0	\N
77c7568d-3f25-4b36-8a66-da0ac0c4bba3	\N	0	0	\N	445637d7-b030-4099-aacc-27866997c8a4	\N	2013-11-15 09:03:11.012+01	0	\N
aa32237d-e432-404d-953e-4c320f2966a1	\N	1	0	\N	58c436ff-eabc-4f4c-912f-36bfcd5be624	\N	2013-11-15 09:03:11.012+01	0	\N
a3f60254-6ed4-4a17-94bc-86d080abd3d1	\N	0	0	\N	42adcfd9-9836-459c-9f46-67f655df6ae9	\N	2013-11-15 09:03:11.012+01	0	\N
4a019e67-69be-4a0a-82f3-5ac65780db35	\N	0	0	\N	192c7bc4-b454-4262-9e27-213c14305469	Eirik Frantzen	2013-11-30 01:30:12.546+01	0	\N
b9fc3bc8-9094-4745-bc70-92e68ed57760	\N	1	0	\N	781df1c6-f106-4f6e-b638-679013fa3531	\N	2013-11-15 09:03:11.012+01	0	\N
22f4d3a7-ac96-40ba-958f-9b742bb46b30	\N	1	0	\N	db0441ff-3b3e-465e-9196-6ef0cad62495	\N	2013-11-15 09:03:11.012+01	0	\N
8e8267e7-be46-46b3-8d7b-9962e6a036e0	\N	1	0	\N	eccc7c90-f882-4502-b366-01e00e137af3	\N	2013-11-15 09:03:11.012+01	0	\N
d84d2dc2-3492-4713-a85f-08eb887d020c	\N	1	0	\N	bc326c56-be19-4e14-9ac1-a09868076e19	\N	2013-11-15 09:03:11.012+01	0	\N
f1080469-c025-4155-8281-5d82c6bf8de3	\N	1	0	\N	897cbd79-ace7-4ea4-b290-ecb4ee4bd2ba	\N	2013-11-15 09:03:11.012+01	0	\N
ea4dfb16-1b47-46df-b77b-4ad25eadebe7	\N	1	0	\N	fc25df71-3cbc-45dc-8e7f-1248b823a1c1	\N	2013-11-15 09:03:11.012+01	0	\N
b3ca1718-0534-4d90-b8fa-ca68270b08df	\N	1	0	1	a556816e-b796-495a-89a0-cc8e37296151	\N	2013-11-15 09:03:11.012+01	0	\N
b3219b40-a2d0-4a52-9274-53179067fb1d	\N	1	0	1	ae3cb724-c46d-4cab-add9-576b038ecb28	\N	2013-11-15 09:03:11.012+01	0	\N
33ce6993-45b3-4a81-88df-6b501bb87464	\N	1	0	1	58b7792f-31a9-4bd3-8cbf-373667034a34	\N	2013-11-15 09:03:11.012+01	0	\N
f0adbe48-7e2f-4c2c-b55a-8b9ff2d28930	\N	1	0	1	33fb4714-ee14-4771-9327-a56dd55fc845	\N	2013-11-15 09:03:11.012+01	0	\N
6eaa4b4a-b6cf-440a-9d58-ab60a294e6b6	\N	1	0	1	c3aea1e5-3a20-4d13-9e8b-fafb1061df16	\N	2013-11-15 09:03:11.012+01	0	\N
bba6b581-8c01-40b4-b414-6ea6db033b47	\N	1	0	1	be082a04-cbef-40d5-a9b7-762edba45ac8	\N	2013-11-15 09:03:11.012+01	0	\N
1dcdbd82-e7fc-4839-8650-387811e31b30	\N	1	0	1	093ec3fe-093e-4702-a1c8-ba5c50f9eda0	\N	2013-11-15 09:03:11.012+01	0	\N
e68b1c01-ad12-4455-a92b-05a0661ba5db	\N	1	0	1	24ae4ab8-d897-4a04-8ca9-2f6fbcfba35d	\N	2013-11-15 09:03:11.012+01	0	\N
f07ab1bb-c45b-4e11-9e63-43608c971c78	\N	1	0	1	9bac0d40-40fe-4675-b3ca-85046fa58a4b	\N	2013-11-15 09:03:11.012+01	0	\N
6a233c42-9512-4230-ad34-8e89f6ff9b96	\N	1	0	1	b1e340e9-4187-49e6-9c29-8033d54f3de5	\N	2013-11-15 09:03:11.012+01	0	\N
05df1370-ba54-4531-abe7-5606574bd545	\N	1	0	1	fea10ee5-b8e6-40c5-9e0e-1598c721725c	\N	2013-11-15 09:03:11.012+01	0	\N
59d5dde8-bcb2-4157-bbd6-12233eab3e03	\N	0	0	\N	1a06eb7a-6b1d-48c9-b008-c1cb4f54dba5	\N	2013-11-15 09:03:11.012+01	0	\N
96c726d6-35d0-4490-a9b7-eee54dbe219b	\N	0	0	\N	637d6388-eeaf-4b61-8d88-a5e12ebe9973	\N	2013-11-15 09:03:11.012+01	0	\N
5241d8fa-d382-4d38-a21d-dc562bbf0b84	\N	0	0	\N	68aa9e74-bb2f-4bf2-850e-32f5fec2138a	\N	2013-11-15 09:03:11.012+01	0	\N
45fca5ff-c819-4745-8ffe-668ea1cf852e	\N	0	0	\N	6f7f826f-9450-45f2-9bc3-146bf603a879	\N	2013-11-15 09:03:11.012+01	0	\N
b0bebb73-a9ea-444b-ac81-becc48ade8ef	\N	1	0	\N	0c859911-5b69-4b72-b4bc-65ed0ec74c4f	\N	2013-11-18 08:54:34.678+01	0	\N
250b1d86-34fd-47ff-a9b6-de5aec805e3e	\N	1	0	\N	0a3975c3-715b-447c-bb1f-1294d0ea3c4f	\N	2013-11-18 11:40:05.183+01	0	\N
9306a315-17d8-4187-a367-c7b4cdaf0b26	\N	0	0	\N	694bc0df-cdb0-4f3c-bb3a-076efa2d50ed	\N	2013-11-18 09:44:16.262+01	0	\N
fdb3d49b-fb03-4ab1-80c3-b9ddf52ae1d8	\N	1	0	\N	2b20e523-4066-4fdb-9e5c-729f580b2874	\N	2013-11-18 11:18:37.66+01	0	\N
546d93ad-7427-47cb-aa46-16fa77668bd3	\N	1	0	\N	c808ea96-d83f-4ea5-946d-2c415e08e189	\N	2013-11-18 11:17:18.628+01	0	\N
2905fd62-1d92-453a-bd49-91dcc60a1a0a	\N	1	0	\N	7865e966-0985-457a-a6bb-dce41806f8d5	\N	2013-11-18 11:17:41.422+01	0	\N
d504721d-a016-4fc0-9bad-491fa96180e4	\N	1	0	\N	80f6222f-b70c-43f7-a24d-6f4a9bb3cf19	\N	2013-11-18 11:18:22.466+01	0	\N
e1491b53-8460-482e-8652-deca2e891dbb	\N	1	0	\N	aaf56607-b395-4d2d-a2cd-8fcb0529a771	\N	2013-11-18 11:17:57.506+01	0	\N
e23cddfe-e31d-411a-8af9-f94e17371d8f	\N	1	0	\N	1bc1d6bc-b38d-4049-b448-743b4e8909f2	\N	2013-11-18 11:18:11.194+01	0	\N
19836408-8571-4638-9782-d7d7fe48b310	\N	1	0	\N	7e56415a-b556-43e3-8596-33957eb69353	\N	2013-11-18 11:38:56.695+01	0	\N
1e34f253-ece4-494f-81a6-27f03f8c2762	\N	1	0	\N	05c8424b-f6d6-4731-8ad3-bd601809da5b	\N	2013-11-18 11:39:18.512+01	0	\N
ca2b5c12-399f-4f0c-ba81-7abdec204c00	\N	1	0	\N	a530ac65-dbc6-42dd-a8d9-334e01da488b	\N	2013-11-18 11:39:32.794+01	0	\N
442076d2-52a2-4c39-82fd-fec7dc7ac563	\N	1	0	\N	36d95c1b-b098-4430-9a66-db01e2d83317	\N	2013-11-18 11:39:50.66+01	0	\N
9b4c4430-59ec-44a3-9b78-f90c2ff6adf4	\N	1	0	\N	a3376898-774e-4a3c-8efd-54c69631da9b	\N	2013-11-18 12:45:49.017+01	0	\N
21ab6a04-591f-418c-bfd7-f6be119b6baa	\N	1	0	\N	a13ae77c-6566-4d7e-a641-642d03e7ec23	\N	2013-11-18 12:45:34.673+01	0	\N
c1c870bf-d359-4b3c-b0a1-b3f5d5adb13a	\N	1	0	\N	1683671d-75f1-4000-a5fe-3e5fa6ea8861	\N	2013-11-18 12:45:15.197+01	0	\N
5ad9bb16-82e9-480c-abff-794acba9cbff	\N	1	0	\N	168cfe5a-a69e-4909-b6b1-048cea2eca95	\N	2013-11-18 12:44:58.715+01	0	\N
4287c627-fa36-43e2-a165-327632a93c8d	\N	1	0	\N	005fe715-7c64-4359-83d1-71d981848a4b	\N	2013-11-18 12:44:45.281+01	0	\N
d9ecb0a3-3d10-4bc3-9c87-a365b7be3081	\N	1	0	\N	91ed2745-c4ad-4aa9-96da-724a8d4b3bfe	\N	2013-11-18 12:44:30.989+01	0	\N
e1435163-eff6-4b9b-9b45-6164242bab0a	\N	1	0	\N	b476921f-afa1-4565-b63e-609541e00a63	\N	2013-11-18 12:44:16.355+01	0	\N
33f7eb2b-feee-433c-93c8-8a8c36fe0275	\N	1	0	\N	0cfef08f-a592-4c32-8329-d16a68c33bb1	\N	2013-11-18 12:43:54.091+01	0	\N
26ef6d77-7ba6-48d4-92aa-f5f8d53d2e2f	\N	1	0	\N	b92bdca7-3b58-4eca-be76-b9b7de13b8d3	\N	2013-11-18 13:08:22.319+01	0	\N
38b7181e-196d-433f-8c26-cccb6d6e2150	\N	1	0	\N	e3c29df2-b390-4e0c-82f0-3730c00f16c4	\N	2013-11-18 13:03:12.273+01	0	\N
b8db2c5c-1fff-4fef-aacb-f7b752522634	\N	1	0	\N	2411c955-0d11-4d64-ba79-8378d2a729b5	\N	2013-11-18 13:02:55.589+01	0	\N
938173c1-d837-4901-a3be-c1d3d33fa527	\N	1	0	\N	8e1dd386-ff2d-43c0-b52c-b9906896edcb	\N	2013-11-18 13:02:43.133+01	0	\N
8b29cf79-4509-4cca-adff-01a1f7158e1c	\N	1	0	\N	1168b528-cd03-4c9b-9f93-0212561debca	\N	2013-11-18 13:19:30.888+01	0	\N
c42664c1-3453-4881-8f38-887566d1609c	\N	1	0	\N	f76bfdde-c7dc-4f13-a20c-f00afed3da95	\N	2013-11-18 13:33:19.663+01	0	\N
25739f18-ead3-4bb8-be4a-6d985a3916cf	\N	1	0	\N	51397b49-eb4d-4f73-a0db-683e312ae2ba	\N	2013-11-18 14:00:56.684+01	0	\N
23827785-926b-44e1-8619-05b69c8433ca	\N	1	0	\N	b15a6788-3dd6-47e0-8863-6dea45cb186e	\N	2013-11-18 14:01:20.223+01	0	\N
35f91513-97e9-41ee-bcb6-3ab6eb8b1142	\N	1	0	\N	5d0322d8-4e33-4d1f-be33-200f4eccc545	\N	2013-11-18 14:01:44.803+01	0	\N
1cacb95d-6ab0-41a7-b473-67a9ba2aafb5	\N	1	0	\N	31c24f78-93fe-4d39-881b-0e499a5dcc0e	\N	2013-11-18 14:09:47.977+01	0	\N
17286d7b-6e7a-4daa-b3a9-dabfe38aa259	\N	1	0	\N	19e7b5ac-4117-4732-9d2f-ae967d166e31	\N	2013-11-18 13:36:38.143+01	0	\N
939841e5-57ad-48f3-b972-7c8ace6a0e76	\N	1	0	\N	513e1357-9336-4b5b-893b-fe7a9ac5c0b4	\N	2013-11-18 14:18:11.11+01	0	\N
f691c37e-be06-4f16-abd6-5faa75e8a8c7	\N	1	0	\N	29cc6c92-2174-461b-b2dc-f0a4e9d08116	\N	2013-11-18 14:18:45.625+01	0	\N
2b529692-ff92-4258-9821-b5eabc4f09e3	\N	1	0	\N	bc90e212-1eb6-4d4d-99c4-ad8fe240d4b2	\N	2013-11-18 14:19:15.205+01	0	\N
23f5fc88-cae8-452a-b973-0bd70b57847a	\N	1	0	\N	48ce902b-5423-4463-b4da-1585b4cb62b5	\N	2013-11-18 14:22:48.45+01	0	\N
b0fba0a8-958b-4738-a2fa-588eec9ec6ef	\N	1	0	\N	e9ecb5b6-800b-4b87-b9b3-4cf964ff0d5e	\N	2013-11-18 14:48:14.329+01	0	\N
5eddabca-d49b-4cf1-be3d-3ac9702ad19d	\N	1	0	\N	ce92bcf6-cb18-4a27-8d0e-504a9bbf26b3	\N	2013-11-18 14:48:53.617+01	0	\N
32525d9f-611c-4a75-8f86-8bc2441dc2fa	\N	1	0	\N	6ab86eaf-e45f-4751-bce4-982c87b61999	\N	2013-11-18 14:49:16.146+01	0	\N
3ee93ee1-356c-4b53-bc75-8e43ca2f1716	\N	1	0	\N	69d4217f-ac2c-4375-b723-aca238139fe7	\N	2013-11-18 14:52:26.007+01	0	\N
26714acc-8121-4588-98b9-afed8d586ee4	\N	1	0	\N	ddd1bd5b-b605-4b16-bae6-2487be9d9fe7	\N	2013-11-18 15:03:38.862+01	0	\N
5262e721-f37d-48f2-99ef-9009e126707e	\N	1	0	\N	4d84cc75-8b47-4170-8038-a36f4ea50f3a	\N	2013-11-18 15:04:05.213+01	0	\N
e2285c5e-375d-4316-8010-8d1079dfa550	\N	1	0	\N	f59043f8-8e07-4526-a124-4d61a42a31d0	\N	2013-11-18 15:04:39.773+01	0	\N
8da690e3-bcdb-4044-ab7e-9da28bf61ff7	\N	1	0	\N	700bbef0-e7d3-436b-9a20-d64cd3ff1dd9	\N	2013-11-18 15:10:46.026+01	0	\N
bf7c2d4f-621f-451b-b00a-d2e37ed5fda5	\N	1	0	\N	93886579-3037-4e0f-9960-20308f014d41	\N	2013-11-18 15:21:12.734+01	0	\N
5c4913f5-c737-4fbf-bd35-f417ddf8cd22	\N	1	0	\N	c18f2d03-cc42-46c3-93ff-0dda9bcd0a95	\N	2013-11-18 15:28:05.323+01	0	\N
e765e972-0db5-4c8b-8d99-2c9f09f12b1e	\N	1	0	\N	fbabaf3e-2176-4e26-b780-1ab11c343481	\N	2013-11-18 15:35:48.904+01	0	\N
3578745a-5b85-4ac0-88c1-216300c8c994	\N	1	0	\N	47324346-9f5f-4cba-879d-719033f8677e	\N	2013-11-19 08:50:34.154+01	0	\N
27ab1720-a951-4ebe-9642-221a99183c6c	\N	1	0	\N	cd169a71-f5cd-4847-aa86-f4463c324d07	\N	2013-11-19 08:56:41.951+01	0	\N
9a227dd4-4627-4fc4-952f-b31e0cc73786	\N	1	0	\N	9e04fd7a-5244-4793-b574-4c3ef5b2ebaf	\N	2013-11-19 08:59:43.294+01	0	\N
6d48a379-1a71-4466-a3ad-e892485204e6	\N	1	0	\N	bd9fe340-0e82-4664-b6e7-d4c8aa348aac	\N	2013-11-19 09:01:11.494+01	0	\N
df4457ff-f4b8-4e6d-93da-49ddb539abab	\N	1	0	\N	e6fc46c7-407a-475f-a36d-b5875de2f14f	\N	2013-11-19 09:08:20.058+01	0	\N
6e0b0cc2-3d59-45df-91d2-bce12270e102	\N	1	0	\N	70a0347a-48dd-400b-b5d2-348a0a54f60f	\N	2013-11-19 09:09:14.57+01	0	\N
93d97663-150d-4d28-ba08-95b014edbc1f	\N	1	0	\N	9ffa9433-8fe8-4008-977f-032d59e8be92	\N	2013-11-19 09:11:53.592+01	0	\N
695c39f4-2da4-495f-aa3b-e367be051f26	\N	1	0	\N	cf2185e8-a704-4811-81c8-6d653d12e2d9	\N	2013-11-19 09:16:32.134+01	0	\N
230a059b-d4a3-43db-b386-627b4110adbc	\N	1	0	\N	e533651a-4434-42fa-975b-ee1cb6da9e96	\N	2013-11-19 09:30:02.057+01	0	\N
7a229b0b-cb12-493d-83f9-8b88953122bc	\N	1	0	\N	12cffb1e-ef22-4b6f-bbf4-c4ae18502f82	\N	2013-11-19 10:32:26.897+01	0	\N
dda8f240-7f0e-44bd-ae2b-e51d5ad67216	\N	1	0	\N	09f538a0-d7a3-4c9f-a173-38aec6475d68	\N	2013-11-19 12:46:55.345+01	0	\N
0973c92c-a954-49e4-a856-f9db16438858	\N	1	0	1	befa41fc-ff56-49a3-924c-d425b99b8670	\N	2013-11-19 14:53:18.611+01	0	\N
73356894-3289-4a53-811e-c024a5eadacd	\N	1	0	\N	a4601121-4c91-4b51-a5d6-e019bc36acfb	\N	2013-11-19 12:39:19.828+01	0	\N
5e93d490-ef48-4ca1-aaf6-d33a8d8123c1	\N	1	0	\N	fbb9c59b-f30e-45ba-ba16-adc0e0581e99	\N	2013-11-19 13:14:42.173+01	0	\N
1b32086a-dbad-4528-81d7-7e18157b52f9	\N	1	0	\N	50a59c7d-111e-4dc6-ad47-e9e02e990bea	\N	2013-11-19 13:16:33.324+01	0	\N
ffa1b779-4a28-446f-86f1-49ef02095a48	\N	1	0	\N	65ea22d4-9603-429b-82d3-06132ae67f36	\N	2013-11-19 13:17:53.171+01	0	\N
82a02684-66f3-4336-8419-2573f650ab50	\N	1	0	\N	ec02dfb9-fb25-4217-903c-5fec8dece6e2	\N	2013-11-19 13:19:37.339+01	0	\N
33566f9f-6b6a-4431-a62b-21a6ee1e9338	\N	1	0	\N	5ed945df-f687-466a-9ffe-7b1a87405805	\N	2013-11-19 13:20:32.202+01	0	\N
d90a3684-064f-4a3e-9fd4-0312d2f98193	\N	1	0	1	143cdae5-6d39-40e2-a7c7-d563bc0bc45c	\N	2013-11-19 14:54:28.682+01	0	\N
50298f52-5dac-4c8e-8b93-72a20bb0bd2e	\N	1	0	\N	c6275c3c-1776-4109-8891-76d66c3481ca	\N	2013-11-19 13:22:27.65+01	0	\N
bd4244d6-f612-4571-93c7-477cbc279078	\N	1	0	\N	c830a4e9-f6be-41eb-85be-e9d7e0655d7e	\N	2013-11-19 13:23:50.433+01	0	\N
9d78564b-7da1-493f-9782-1ea9af404edd	\N	1	0	\N	b0c3d079-544a-4562-9674-6cf81d9efb7e	\N	2013-11-19 13:24:39.096+01	0	\N
58f1e7da-435f-494f-ad60-27a069f1dd3b	\N	1	0	\N	643790a0-1326-4aef-ba10-c3c39ead3341	\N	2013-11-19 13:27:37.303+01	0	\N
b36b9e71-ebec-4f98-a445-4cea3a6203f8	\N	1	0	\N	2b12cf08-9527-4885-bbb6-3895ba24f1ba	\N	2013-11-19 13:33:34.725+01	0	\N
a830a836-4c82-4607-9997-a3536bb6b691	\N	1	0	\N	9762007e-8602-4e9d-a6c2-c25c6f7ddf92	\N	2013-11-19 13:35:35.724+01	0	\N
8fd51566-5717-4d5b-af5c-1da7e66513af	\N	1	0	\N	08c01e7c-cf40-468b-8d8f-d9b325b8b05a	\N	2013-11-19 13:41:35.554+01	0	\N
3fd669bc-4d9a-4839-a2c3-088b78b36112	\N	1	0	\N	392340f6-d5ea-4447-886f-022d4c477409	\N	2013-11-19 13:45:50.936+01	0	\N
6595f5c8-11b0-44c4-a2d9-a22ded709f8d	\N	1	0	\N	cb9065dc-2a72-4e55-ad46-aa983c40de87	\N	2013-11-19 14:14:17.132+01	0	\N
c092a21f-8353-4966-8d88-7ff341536f6e	\N	1	0	1	be5ac55e-4321-49ce-8609-fb8d9a660f28	\N	2013-11-19 14:29:12.582+01	0	\N
95344471-9798-47f7-8af1-890afc7210e4	\N	1	0	1	ab1bbd19-0362-4126-9265-2538c324497e	\N	2013-11-19 14:36:07.699+01	0	\N
7dde7956-9bbd-465c-a2a1-ed62e340be00	\N	1	0	1	4826f73d-4d2f-470e-bba5-f3dac141e8f8	\N	2013-11-19 14:42:57.919+01	0	\N
710a208c-1801-4f8e-85e5-81c51c549e09	\N	1	0	1	c023134b-eaaa-49ea-aa61-2663197b6fc3	\N	2013-11-19 14:44:37.359+01	0	\N
6b35a28c-f9ea-4cc2-947c-11fe70f18e64	\N	1	0	1	39a1d0f3-90b6-49a7-b801-cb78da963778	\N	2013-11-19 14:45:38.622+01	0	\N
95e64dbb-a87e-4e80-9db6-cde1fd47ae82	\N	1	0	1	5e064e68-7699-4805-8c02-e511895ffd99	\N	2013-11-19 14:46:42.79+01	0	\N
8c80893d-5ab2-4918-bfde-5283d8106711	\N	1	0	1	2a3e89d1-b6e8-4e52-859c-a1f128aec03b	\N	2013-11-19 14:48:34.997+01	0	\N
385c7c09-3fc9-4d80-9130-58c4ce47189b	\N	1	0	1	f532baac-3ed9-4aaa-8f8a-949a7a1b145b	\N	2013-11-19 14:49:48.604+01	0	\N
0940460c-9588-4338-a13a-d11c0a0bd93a	\N	1	0	1	e1d452da-ddf7-413e-b0dd-cd27c36c12bf	\N	2013-11-19 14:55:17.81+01	0	\N
acd524a2-eee8-469c-bb77-68ea6d40dd37	\N	1	0	1	47d4a5c0-c9ef-4ec2-bbd1-8369c2d34e2e	\N	2013-11-19 14:56:10.714+01	0	\N
0b7dc40b-2694-4384-88f6-5af6c2d9b590	\N	1	0	1	94e2d918-0244-4df5-a0ee-33a89eb2cd46	\N	2013-11-19 14:57:25.57+01	0	\N
2482c4de-cb58-47ce-8a51-54eee427427d	\N	1	0	1	b924770d-72b1-49a3-8974-c7959e9fc0dc	\N	2013-11-19 15:18:06.009+01	0	\N
199bcd70-9b78-4f09-bb3b-3572dd4921ab	\N	1	0	1	f2e0db4d-3b19-46ad-bd68-e30b6513958d	\N	2013-11-19 15:24:52.11+01	0	\N
a5fb696f-99d2-4505-81a2-f1f95bac7e16	\N	1	0	1	c30d180c-7b0f-47c5-b565-3e7605b11c00	\N	2013-11-19 15:27:14.813+01	0	\N
910e8591-7afe-4388-a70e-b2576afe8a72	\N	1	0	1	4469077d-1a73-456e-ad6e-a4b8d0c8c53f	\N	2013-11-19 15:28:07.621+01	0	\N
72426144-3d7e-4bb0-8261-23622400c68a	\N	1	0	1	e4ecd993-638a-4ec7-94da-83c383359954	\N	2013-11-19 15:29:18.396+01	0	\N
02295184-e53b-4b75-b543-4abb69116b7a	\N	1	0	1	530f7542-e5fa-4873-8bd2-9461da8d2f22	\N	2013-11-19 15:30:14.484+01	0	\N
ce53ab3d-b3da-4c59-8667-fb21ac833c3e	\N	1	0	1	6f86eeed-fa03-4ffa-b4c9-fc7912cf9925	\N	2013-11-19 15:31:12.099+01	0	\N
18c571e6-d0c9-467b-a2c5-2b30896a5e6f	\N	1	0	1	b030798c-5865-41d7-895b-864b13a86303	\N	2013-11-19 15:32:14.498+01	0	\N
af7c3a87-0a08-48fa-a187-8ec3515db172	\N	1	0	1	45604dff-0499-4217-80f3-e33872dbd4a2	\N	2013-11-19 15:33:08.65+01	0	\N
1d1ffb3d-5458-4f25-b0d2-20492d03ed67	\N	1	0	1	17834413-3d7e-42db-ba14-cd26ef202db3	\N	2013-11-19 15:48:24.204+01	0	\N
9a0c4905-1181-49d7-b688-59a10b846d48	\N	1	0	1	3e6142cf-cf5b-48fa-866b-eebc21549a99	\N	2013-11-19 15:50:53.316+01	0	\N
03ec4441-19e9-47ff-99ad-366f03a17734	\N	1	0	1	0f90b610-f599-4b2d-bff0-58b926589d4a	\N	2013-11-19 15:51:41.531+01	0	\N
12074fa7-4c79-431e-83b8-62f648edf1f0	\N	1	0	1	7c22d0fc-4c8b-4cf2-bf8b-1c95e58aac26	\N	2013-11-19 15:53:34.193+01	0	\N
b51c3ab9-c909-468e-bbab-eb8b2597fde3	\N	1	0	1	7f444795-ea41-4b0d-b58b-406ce4238b21	\N	2013-11-19 15:54:18.674+01	0	\N
d5a9bf72-f6c6-4d19-9d16-d6f417be9753	\N	1	0	1	609e8025-24e5-4bc8-815d-d9e5ff2820ec	\N	2013-11-19 15:55:24.929+01	0	\N
4ff21660-2f5e-4aec-939a-9f179af8d307	\N	1	0	1	41bbfbef-96e9-41fa-a151-efc16bb0fae7	\N	2013-11-19 15:57:24.056+01	0	\N
b77141f8-c2c4-4f47-88e6-da17ac13313b	\N	1	0	1	a7c5f5a9-7b35-48d1-9bfc-19dbd86485f4	\N	2013-11-19 15:58:12.088+01	0	\N
c338d883-e3e8-4592-a641-e18612305282	\N	1	0	1	22892165-d9a3-49ca-b16f-b48ac2c6cf72	\N	2013-11-19 15:58:53.96+01	0	\N
af6e4b50-a1ef-47b6-88a1-222d9f84a552	\N	1	0	1	3fce5b44-0130-423f-adec-df07d301aaf8	\N	2013-11-19 16:00:06.287+01	0	\N
9da026ac-0320-4871-89cf-f1c92ef290ce	\N	1	0	1	f87390e0-27a7-40ef-a0e9-3646609390eb	\N	2013-11-19 16:00:49.734+01	0	\N
4499392f-9c0d-4882-89fb-574dfaedc4a4	\N	1	0	1	2c873c9e-0f44-4191-9981-0829b0c04410	\N	2013-11-19 16:01:33.375+01	0	\N
11f877f6-69a8-4e80-b7b4-c2b72b845396	\N	1	0	1	5ac86566-26b2-42b0-8a85-5bae60c38311	\N	2013-11-19 16:02:13.318+01	0	\N
f6bc52b2-9f4b-4d96-9ed5-01f093a9b898	\N	1	0	1	f4f95f7f-af7b-40d3-85c0-09382f31a4f9	\N	2013-11-19 16:13:00.873+01	0	\N
bb4a9b0b-9b31-4747-8e9e-0f1a32ab0132	\N	1	0	1	89302344-8165-41bb-9b5d-55c8b5937ad5	\N	2013-11-19 16:14:13.793+01	0	\N
0bcd5bd2-bace-4db5-840f-2aaaed43a65e	\N	1	0	1	f6982a0e-79b9-404f-9b9a-07a0031abd47	\N	2013-11-19 16:16:37.12+01	0	\N
ce5673dc-74f1-43dc-8494-9c4cb0f4c13f	\N	1	0	1	575fa992-c2c2-42dd-8af3-f57be846db06	\N	2013-11-19 16:18:08.712+01	0	\N
c8b96bbd-ce0f-45ae-8179-e6613f6fe155	\N	1	0	1	93761b4a-38f5-4f6f-9db2-a0f0ed339f89	\N	2013-11-19 16:19:25.343+01	0	\N
fd655c73-2f36-46a3-8e58-0f8b0b7f5635	\N	1	0	1	ddbe76ad-b83f-44b6-9478-8320b5086e66	\N	2013-11-19 16:20:21.958+01	0	\N
2f231300-fc3f-442e-b01f-6d3b7cd38859	\N	1	0	1	a64a720c-5e32-4815-ad96-3a148a2dc1e2	\N	2013-11-19 16:21:40.575+01	0	\N
e01cac79-e2a0-4ac4-8a03-6743e120d372	\N	1	0	1	022a9204-77e7-47cc-8d81-6e10a8b4a694	\N	2013-11-20 09:51:43.313+01	0	\N
e69056b9-96e8-415e-aba4-b1d0c9bab650	\N	1	0	1	02b515dd-a5fc-4108-bfc2-61939d8db011	\N	2013-11-20 09:53:30.704+01	0	\N
d611d55d-0ffe-4afd-91d4-815c18e384d8	\N	1	0	1	17e85dcf-cd58-4e76-9a9d-647c2b79dbe2	\N	2013-11-20 09:54:12.345+01	0	\N
7dc8df3f-7743-4d2c-a860-f83bb2addd50	\N	1	0	1	0a6b44bd-d7a1-4f78-9f6b-bc51c44596b5	\N	2013-11-20 09:55:26.744+01	0	\N
ab004a48-3a51-4d22-9108-be22e374b74f	\N	1	0	1	462e936d-0d0d-4cc5-a5e0-a9667bb81e3a	\N	2013-11-20 09:56:36.343+01	0	\N
3763496d-1cbe-4b9e-bc1c-e9f4c7af416f	\N	1	0	1	2b184350-f92e-44ea-bc46-f590eca51142	\N	2013-11-20 10:03:09.902+01	0	\N
8d8dc593-1ee6-4d60-beb8-00ba90fcedb3	\N	1	0	1	8a6d900f-74ed-4bfc-a292-eb04a1cca35d	\N	2013-11-20 09:52:32.121+01	0	\N
3fc81beb-ae84-4b91-8eab-586fa4c5e00f	\N	1	0	\N	a76b0b63-614c-4816-9a0b-65463e43981f	\N	2013-11-20 10:04:38.916+01	0	\N
35566528-b05d-496b-8144-c3c2d6a05191	\N	1	0	\N	15792a80-25bb-4354-bf9c-c5d9f042c1a8	\N	2013-11-20 10:05:39.803+01	0	\N
27e343fd-300b-4046-840d-9b9d25dfda72	\N	1	0	1	eb7d73fc-6ce4-4040-8212-39032a7eb367	\N	2013-11-20 10:09:43.018+01	0	\N
caeee364-c5da-401f-b017-751578af53c9	\N	1	0	1	9aee362c-9266-4216-afbd-6284e9df40e9	\N	2013-11-20 10:17:08.919+01	0	\N
5400f400-d376-471d-b2ff-ed403979ca08	\N	1	0	1	921d8472-548f-429b-96a3-75821ed2616d	\N	2013-11-20 10:31:37.312+01	0	\N
4d869ca5-8ede-4486-bf6f-ecf83e6895a2	\N	1	0	1	c72432f6-ebee-4828-a00d-d3899d60180d	\N	2013-11-20 10:32:42.296+01	0	\N
00db69bc-9618-4ef1-9e4b-8a7af467875f	\N	1	0	1	3035e929-9160-418a-bfde-c1080ba83b4a	\N	2013-11-20 10:33:28.544+01	0	\N
ca6924c1-8723-4868-be9a-a5ca534e638b	\N	1	0	1	712f19da-2322-423f-b594-d6d28dcc3dc9	\N	2013-11-20 10:34:09.944+01	0	\N
0e10ec00-61d0-4afc-9f37-5fa34a55cf0d	\N	1	0	1	15fd0496-631f-496a-916b-731846620315	\N	2013-11-20 10:35:08.799+01	0	\N
d7eb20f9-0e39-4d81-933c-89cfc62d1d20	\N	1	0	1	24029956-ee43-4cd9-99a3-04a23d44d524	\N	2013-11-20 10:36:06.007+01	0	\N
76e504b9-d8dd-4404-b801-acbba0d42ef3	\N	1	0	1	6e8672ef-6231-442d-b77e-ee05f1f90e57	\N	2013-11-20 10:36:51.894+01	0	\N
2d875754-21bb-449b-82db-c5786f2254b1	\N	1	0	1	3be0b12b-c794-4deb-a8c9-d9cc89479512	\N	2013-11-20 10:39:07.237+01	0	\N
d603d061-cd25-46d6-b713-48d42bec444f	\N	1	0	1	f50cad58-e302-4d85-9ef1-4d24f95f749d	\N	2013-11-20 10:40:21.949+01	0	\N
1fbe07af-321c-48a2-b23c-7a26873061f2	\N	1	0	1	5277c870-944b-4b20-ab82-1c8b8479c39e	\N	2013-11-20 10:40:55.124+01	0	\N
c2e2f57f-5cf8-407c-980b-af0ab513a58b	\N	0	0	\N	d4034a39-fe17-40d8-9a43-95f74e4f1c08	\N	2013-11-20 11:20:14.772+01	0	\N
0dbd18b6-fd05-4e15-b574-3a72a32b82c7	\N	1	0	\N	5e762146-3767-457a-87b5-65b69bd57947	\N	2013-11-19 13:26:28.247+01	0	\N
a58330ca-439b-4bac-aef8-00e34a0be43b	\N	1	0	\N	c2ed37d4-9419-4cf0-af97-b3469192dd5d	Eirik Frantzen	2014-01-22 15:49:41.716+01	0	\N
4c80df83-3d29-436d-b41d-36e65fbdf31f	\N	1	0	\N	0f77502c-70db-448b-ab44-9738a09b3192	Eirik Frantzen	2014-01-22 15:50:51.712+01	0	\N
0951c17e-7129-453e-b17f-1d1d04bd8ada	\N	1	0	\N	10e65967-09a2-4b87-a437-4b99ac8dd2cf	Eirik Frantzen	2014-01-22 15:51:24.894+01	0	\N
cd7776b9-d0bd-4e1a-a589-beb38d615a93	\N	1	0	\N	1fb8eeb0-0c38-4efc-9d18-af066980049d	Eirik Frantzen	2013-12-04 00:12:59.392+01	0	\N
dbe3a2f1-f6a6-4cc8-abf1-917718ddd202	\N	1	0	\N	e67c0f45-1b31-4b7b-ab4c-d2785de4af05	Eirik Frantzen	2013-12-04 00:14:29.441+01	0	\N
c391e3ea-5364-4362-8684-84311273190f	\N	1	0	\N	85209d30-5cc9-4c1d-b89b-35986ccc80b9	Eirik Frantzen	2013-12-04 00:17:01.172+01	0	\N
bfb2b69f-112c-4bc7-ad1f-b8ae3ae7aab2	\N	1	0	\N	b4aac9a1-33dc-4be2-a767-555c06e1d879	Eirik Frantzen	2013-12-04 00:17:01.193+01	0	\N
4d53807d-4dfd-4884-9227-0c0202e7df47	\N	1	0	\N	ca0c3d30-4632-4fd1-a34f-8e25847c2719	Eirik Frantzen	2013-12-04 00:19:23.267+01	0	\N
3bc810f4-d9aa-4244-85d3-84bcb83d0124	\N	0	0	1	3ee2d386-d27c-4965-b359-ab3b858ecbd9	Eirik Frantzen	2014-01-06 11:15:57.945+01	0	\N
1dd6d754-09dc-4450-b7b4-df0fbd4dee70	\N	1	0	\N	e7d43001-f2df-4c4c-b798-ef2e8d4f33a2	Eirik Frantzen	2014-01-22 15:21:32.481+01	0	\N
e9163c73-a685-41ef-9725-65b0e4a5ab86	\N	1	0	\N	579a5a70-fce4-4613-b523-82edc355b7b8	Eirik Frantzen	2013-12-04 00:20:04.14+01	0	\N
4453ac02-cb38-4a83-a1bc-55191d911943	\N	1	0	\N	495d021a-3ae9-4396-9906-b6b084afc7ee	Eirik Frantzen	2014-01-22 16:03:01.88+01	0	\N
13aef1f5-3f55-45c5-99ff-9248a4382f63	\N	1	0	\N	afe1c492-90c0-4e07-bfa2-8d2978487228	Eirik Frantzen	2014-01-22 15:24:59.109+01	0	\N
027d1232-383d-4d0b-8eb9-f6be184aec65	\N	1	0	\N	8053627b-4fb1-4e63-8941-e813461d4930	Eirik Frantzen	2014-01-22 16:08:23.282+01	0	\N
ab80f4ea-fda7-4291-acb3-bfcd128173bf	\N	1	0	\N	6265db2b-32e7-4072-9d16-398fc8299b23	Eirik Frantzen	2014-01-22 16:09:06.093+01	0	\N
45a370c5-1d19-449b-aaf5-1d1635528416	\N	1	0	\N	94573bd7-6b17-428a-9e89-c178eb63dc69	Eirik Frantzen	2014-01-22 16:09:41.711+01	0	\N
590851fe-b98d-4698-a54f-15e7eccc3a88	\N	1	0	\N	0bd94fa4-8a00-4e27-b61a-0e4492e9a279	Eirik Frantzen	2014-01-22 16:11:07.32+01	0	\N
5f1a7475-6c74-46bd-92d2-6a1c47b8140f	\N	1	0	\N	f380c4a0-17f5-4ad7-ba76-1bde09c5fe0e	Eirik Frantzen	2014-01-23 08:36:21.772+01	0	\N
4dcf6743-c59d-4ced-bc15-6410833db859	\N	1	0	\N	a284cf01-cc2e-4bdb-95cb-a8dffb61e49a	Eirik Frantzen	2014-01-23 08:40:34.994+01	0	\N
fcfd6eb2-b1a4-4e97-82bb-0832e279c968	\N	1	0	\N	9193ddec-cb4c-4542-ae48-1f9206393bc5	Eirik Frantzen	2014-01-23 08:41:10.883+01	0	\N
5fac5ea1-4c86-4bbb-8b51-5d35956b8895	\N	1	0	\N	59455c01-34a3-46db-97f4-6291b97832c5	Eirik Frantzen	2014-01-23 08:41:44.289+01	0	\N
051197b1-842d-44f2-880c-bd6b46a6ae76	\N	1	0	\N	517c720f-2cd8-4e8d-9054-d933b9c6ac68	Eirik Frantzen	2014-01-23 11:30:42.983+01	0	\N
07042c35-0595-4669-8583-e9eeb09ceffe	\N	1	0	\N	5ca65412-e345-49d9-8c19-17efa01b2cea	Eirik Frantzen	2014-01-23 11:36:29.704+01	0	\N
40644954-b3c8-40ad-90df-66d050b00307	\N	1	0	\N	94f28fcb-9ae1-4d96-ac4d-a53ae15e731b	Eirik Frantzen	2014-01-23 08:46:19.433+01	0	\N
9f4cc43a-a153-443c-bad0-aa3a7a763a64	\N	1	0	\N	5e85cad4-8d1b-4fb4-9787-a78d1fcd4938	Eirik Frantzen	2014-01-23 11:08:41.128+01	0	\N
78f0ebb8-1ec1-4504-bd04-aaaff7406da8	\N	1	0	\N	3d5b2587-bfe0-4349-bcb0-942f7265ece1	Eirik Frantzen	2014-01-23 11:09:30.89+01	0	\N
c9f40f4f-2bbd-44e4-b9e1-b57fb8c28c55	\N	1	0	\N	c9543dab-99a8-4f75-b6e9-ea717317e8b9	Eirik Frantzen	2014-01-23 11:10:27.693+01	0	\N
080830de-c44d-41d2-a755-4bf3c2c459df	\N	1	0	\N	6fafc31e-1f0c-4331-b52f-9bc59430ae69	Eirik Frantzen	2014-01-23 11:23:06.145+01	0	\N
dffb8327-bd67-4641-9de6-1a68e34a3905	\N	1	0	\N	19c9b393-f076-45bd-ac0c-91a79357aaf4	Eirik Frantzen	2014-01-23 11:23:34.222+01	0	\N
8abe6200-ab3f-4e30-b364-a4d7bec56ca9	\N	1	0	\N	642e1b4a-bfc9-4035-8e7f-e21b2a2119e2	Eirik Frantzen	2014-01-23 11:24:01.462+01	0	\N
93ce2c62-862c-47d0-a3e7-9326523547cc	\N	1	0	\N	05365c87-98a6-4a87-a538-28239bdde6c6	Eirik Frantzen	2014-01-23 11:25:02.981+01	0	\N
8c29bfe2-20d3-420c-9bbf-3a9104707d6d	\N	1	0	\N	4e2b3641-4fc2-4ccb-9c38-addc7e70f92e	Eirik Frantzen	2014-01-23 11:40:17.236+01	0	\N
05e30f20-c89e-424c-8e72-93d8f7222f45	\N	1	0	\N	6034017d-27c6-4ee0-a390-4fabbf659086	Eirik Frantzen	2014-01-23 12:23:29.155+01	0	\N
7bc3c141-93f0-4fb9-9187-6a1394a1e4fe	\N	0	0	\N	96fdfd98-fa88-45be-9754-90c3eac90ba9	Eirik Frantzen	2014-01-31 10:49:19.758+01	0	\N
759e160a-aae9-4c57-b473-30db0677cbc0	\N	1	0	\N	d1d3abae-88e7-4288-847b-6bf76119e92a	PowerCatch admin	2014-02-24 11:19:36.122+01	0	\N
e921c5b0-7946-45f5-8fb6-3fcc3b947173	\N	1	0	\N	b94f1be3-ec06-4fec-85f6-8dfc3bc2eb09	PowerCatch admin	2014-03-15 18:59:23.033+01	0	\N
d6d21257-30f3-4e6c-9bf4-e2e503ab79f5	\N	0	0	\N	2da613f2-5986-418a-a60f-eed5728389fe	PowerCatch admin	2014-06-26 11:23:20.405+02	0	\N
4e8a31ff-3040-4e14-9d60-9eae17e1b7b3	\N	0	0	\N	ad144347-408a-48ab-9a07-b481333de705	PowerCatch Update Script	2015-01-27 14:58:40.909+01	0	\N
dc14abb7-e926-4f15-92c6-a4d97cf901a2	\N	0	0	\N	35cd0d2c-762a-434a-9b48-f300fa3ece4f	Eirik Frantzen	2014-01-31 10:50:12.6+01	1	\N
1f5b8feb-b9dc-4d91-876f-7e5ee0e5862c	Arbeidsoppgave	1	\N	\N	38855134-13eb-4161-bdca-f81301843cc2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	\N
4b8658db-9925-4ba9-9de5-363288bd78e6	Risiko	1	\N	\N	c3758398-e2e1-4162-9e8a-02fe04c7e06f	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	\N
396b805f-8a76-42f5-8e6d-0a759803bc21	Tiltak	1	\N	\N	02fc7f12-edfb-4d0c-bf29-e056040fecc6	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	\N
d0d92b32-de6c-4eab-9940-e7b6c5ea72fa	Sluttkontroll	1	\N	\N	3d1cf3cb-4be3-4e08-b55f-eba1672f8f55	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	\N
df6f604b-ec10-414c-ba3b-0459d4488c56	Ax Kunde	0	\N	\N	8acc965b-2be4-4dc2-98b4-7ebbc9484222	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	\N
68b68acc-d2a1-4744-bc8b-f65446da0961	Ax Prosjekt	0	\N	\N	4cd0b4c6-909c-4210-a2ef-187f33f6ce22	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	\N
3909dc3d-f9af-4dbc-8601-ee658554b63b	Oppgave	0	\N	\N	cf848725-edc9-4360-9a50-382b5b86a691	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	1
e1805c8c-5082-470c-be45-6af0791931c2	PC_SUBTASK_TYPE_SYSTEM	0	\N	\N	eeb6d4d9-9245-4d13-9239-352654454a68	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	1
2802bf3b-089c-4657-9d00-c9e98c568503	PC_SIGNATURE_REQUIRED	0	\N	\N	8500a60c-31d6-4ea8-a53f-236203a004a2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	1
522f1834-772c-9acd-ddc2-1d26624cfadd	Objektdata	1	\N	\N	2efe51c4-28c4-10f9-40e7-48fd2453973b	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0	\N
\.


--
-- TOC entry 2625 (class 0 OID 27350)
-- Dependencies: 204
-- Data for Name: issuetype; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY issuetype (id, nbr, name, project_key, new_issue_enabled, summary_field, changed_by, changed_date, deleted) FROM stdin;
f6ad8df2-bd01-4433-a3c5-0411f9f5d73b	\N	SK idriftsettelse	SLK	0	\N	\N	2013-11-20 09:58:48.047+01	0
5d274f43-07b8-46fd-b2f8-1413ebfa1240	\N	PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	LD	0	summary	PowerCatch Update Script	2014-01-23 09:27:13.604+01	0
3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	\N	PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	LD	0	summary	PowerCatch Update Script	2014-01-23 09:27:13.606+01	0
5f07451e-7113-4b7c-8976-9e82a471581b	\N	PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	NY	0	summary	PowerCatch Update Script	2013-11-19 09:03:40.892+01	0
63ef0eb1-53a6-4567-b777-3801016cc65e	\N	PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	NY	0	summary	PowerCatch Update Script	2013-11-19 09:13:15.376+01	0
5570564c-a7f5-4902-8e24-a8288729e55c	\N	PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	NY	0	summary	PowerCatch Update Script	2013-11-18 13:23:24.353+01	0
63a9496a-9455-4664-beb2-e8e75a7cf043	\N	PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	NY	0	summary	PowerCatch Update Script	2013-11-19 13:43:23.073+01	0
ee77e006-38a2-470c-9877-78399dcd8371	\N	PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	NY	0	summary	PowerCatch Update Script	2013-11-19 12:41:23.179+01	0
9713e3f0-c8cf-4793-8d53-76fdde10ffa8	\N	PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	LD	0	summary	PowerCatch Update Script	2014-06-24 10:33:15.798+02	0
57e0ba97-1f40-494f-9ce3-efadf52d8b20	\N	PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	LD	1	summary	PowerCatch Update Script	2014-05-21 21:46:33.192+02	0
b5c2c02c-e88f-4013-9799-f970978ba8b2	\N	PC_ISSUETYPE_FIELD_INSPECTION	NY	1	summary	PowerCatch Update Script	2013-11-18 09:07:30.371+01	0
ebad0433-524f-4aed-87dc-3aa2827c173f	\N	PC_ISSUETYPE_ASSEMBLY_HELPER	NY	0	summary	PowerCatch Update Script	2013-11-19 12:49:41.839+01	0
b1001bac-07d0-47a2-b2ef-9a369edf0baf	\N	PC_ISSUETYPE_ASSEMBLY_HELPER	LD	0	summary	PowerCatch Update Script	2014-05-22 16:23:35.859+02	0
b503caae-1400-4e32-87fb-95f43a83e1dd	\N	PC_ISSUETYPE_INSTALLATION_OPERATION	NY	0	summary	PowerCatch Update Script	2014-05-26 08:45:11.393+02	0
119a2834-bda1-4607-849c-4c25b3f4670f	\N	PC_ISSUETYPE_CONTROL_CABINET	LLS	0	\N	PowerCatch Update Script	2014-05-21 21:42:59.362+02	0
5d59d730-68c0-4cf0-9f3d-7687ccae308b	\N	PC_ISSUETYPE_CONTROL_POLE_HV	LHS	0	\N	PowerCatch Update Script	2013-11-15 12:45:06.582+01	0
4d23796b-0341-4fe0-8fe7-4ace4a9eb62a	\N	PC_ISSUETYPE_CONTROL_POLE_LV	LLS	0	\N	PowerCatch Update Script	2013-11-15 12:45:22.931+01	0
2e44fc5b-541d-420b-b0e7-c208bb4f68cc	\N	PC_ISSUETYPE_CONTROL_SS_1_YR	NS	0	\N	PowerCatch Update Script	2013-11-15 12:42:56.672+01	0
099732f3-6c88-435f-8904-208a547cf218	\N	PC_ISSUETYPE_CONTROL_SS_5_YR	NS	0	\N	PowerCatch Update Script	2013-11-15 12:44:59.8+01	0
fa3265d4-f742-47db-bec1-07f52930762b	\N	PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	NY	0	summary	PowerCatch Update Script	2013-11-18 13:44:51.473+01	0
a146f0d5-1a55-40b6-8a42-fa2a029b76fb	\N	PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	NY	0	summary	PowerCatch Update Script	2013-11-19 08:47:57.026+01	0
7e2bc36a-45ba-4273-a607-2e904158e853	\N	PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	NY	0	summary	PowerCatch Update Script	2013-11-19 08:53:13.536+01	0
7fe7c776-f958-471c-8946-9eff9b9f98a2	\N	PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	NY	0	summary	PowerCatch Update Script	2013-11-18 15:12:29.401+01	0
879cb62e-1a88-44fb-b064-0fc84ad7ceba	\N	PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	NY	0	summary	PowerCatch Update Script	2013-11-19 13:47:39.367+01	0
6f502148-04b3-438f-be94-0961b34d8747	\N	PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	NY	0	summary	PowerCatch Update Script	2013-11-18 14:12:06.872+01	0
b076848f-c590-447a-a104-812098a392cc	\N	PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	NY	0	summary	PowerCatch Update Script	2013-11-18 11:27:05.985+01	0
abd4023d-9ef8-41c7-ae03-5ada4259f1a1	\N	PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	NY	0	summary	PowerCatch Update Script	2013-11-18 13:11:01.328+01	0
950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	\N	PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	NY	0	summary	PowerCatch Update Script	2013-11-18 14:57:55.167+01	0
0c15d3a1-167e-4524-bf40-37f373d97db2	\N	PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	NY	0	summary	PowerCatch Update Script	2013-11-18 14:25:43.691+01	0
88a3a83e-c9c2-497f-95bd-801536443895	\N	PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	NY	0	summary	PowerCatch Update Script	2013-11-19 13:36:48.988+01	0
a29e3fc0-e8a0-4f55-95b4-39b622a44248	\N	PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	NY	0	summary	PowerCatch Update Script	2013-11-19 09:21:14.284+01	0
26debf83-b32e-4264-95b8-8daf96c4f07b	\N	PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	NY	0	summary	PowerCatch Update Script	2013-11-19 09:59:10.024+01	0
f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	\N	PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	NY	0	summary	PowerCatch Update Script	2013-11-19 10:35:00.833+01	0
c73494ab-ff4b-4548-b182-d628147ae77f	\N	PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	NY	0	summary	PowerCatch Update Script	2013-11-18 15:29:55.81+01	0
b15e295e-f586-438c-a0a9-12ec6e086168	\N	PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	NY	0	summary	PowerCatch Update Script	2013-11-18 15:24:05.589+01	0
075bbaef-422f-4d7b-8d2a-667162b56519	\N	PC_ISSUETYPE_METER_REPLACEMENT	LEVPKT	0	\N	PowerCatch Update Script	2013-11-11 09:15:58.175+01	0
811d36f6-a6da-4e3f-9a7b-5cb7087191ce	\N	PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	SLK	0	\N	PowerCatch Update Script	2013-11-20 10:19:10.526+01	0
ee978fc7-4d0f-45ff-a3ba-6ffb4da38dff	\N	PC_ISSUETYPE_FINAL_CHECK_CABINET	SLK	0	\N	PowerCatch Update Script	2013-11-19 15:42:13.334+01	0
2d6958b1-7157-4fb5-a0ba-71c90fc49a22	\N	PC_ISSUETYPE_FINAL_CHECK_HV_LINE	SLK	0	\N	PowerCatch Update Script	2013-11-19 16:06:11.669+01	0
b443603a-11d7-45af-b331-e6d9f30f1f87	\N	PC_ISSUETYPE_FINAL_CHECK_LV_LINE	SLK	0	\N	PowerCatch Update Script	2013-11-19 16:23:05.822+01	0
7d56c6ca-3524-4b7b-9fcf-8e1585d06f00	\N	PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	SLK	0	\N	PowerCatch Update Script	2013-11-19 13:52:33.061+01	0
a944240b-2750-4427-9003-5d63c3af555a	\N	PC_ISSUETYPE_FINAL_CHECK_SS_POLE	SLK	0	\N	PowerCatch Update Script	2013-11-19 15:34:10.73+01	0
267a31f1-f8be-48df-a39a-aaf0a9c526ef	\N	PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	NY	0	summary	PowerCatch Update Script	2014-06-24 10:22:02.86+02	1
373c1836-659b-479f-957e-d2f69a1f97e6	\N	Driftsoppgave	LD	0	\N	PowerCatch Update Script	2013-11-30 01:25:19.853+01	1
44f77965-cb2c-415c-bfaa-1b5b3fe714ed	\N	PC_ISSUETYPE_WO_NET	NETT	0	summary	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
78a83cf4-e305-422a-9cf9-8eb752333691	\N	PC_ISSUETYPE_SUB_TASK_NET	NETT	0	summary	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
d628e7d3-4347-41b0-a113-136f53d8f911	\N	PC_ISSUETYPE_ASSEMBLY_HELPER	NETT	0	summary	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
664881ac-3245-403f-afd8-94ec6a8bf1ce	\N	PC_ISSUETYPE_FIELD_INSPECTION	NETT	1	summary	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
\.


--
-- TOC entry 2626 (class 0 OID 27360)
-- Dependencies: 205
-- Data for Name: issuetype_page; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY issuetype_page (id, id_issuetype, id_page, sortorder, changed_by, changed_date, deleted) FROM stdin;
c493e6d0-d025-4d3b-b31f-085d51cf8685	075bbaef-422f-4d7b-8d2a-667162b56519	79619cfe-01de-4cb5-a05c-4a3ed570ffee	1	\N	2013-11-11 09:28:58.536+01	0
45f1ac2f-27a5-480c-bfcc-8686bcbd5bcf	075bbaef-422f-4d7b-8d2a-667162b56519	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-11 09:28:58.536+01	0
1b4cd40f-3633-41ad-9a9b-37edde3578f7	075bbaef-422f-4d7b-8d2a-667162b56519	75d13b7a-376f-426a-9e97-58c0c70ab355	3	\N	2013-11-11 09:28:58.536+01	0
01a136c4-ffcb-4535-b118-507cb4af4f23	075bbaef-422f-4d7b-8d2a-667162b56519	6e088fd0-60dc-420d-a23c-2551edd34682	4	\N	2013-11-11 09:28:58.536+01	0
8fff6b65-77a5-4f0d-a473-8d5abec4bc1b	075bbaef-422f-4d7b-8d2a-667162b56519	b08ca4dd-dc5b-4ec1-8281-ef45d8b25c84	5	\N	2013-11-11 09:28:58.536+01	0
671f8790-e583-4e30-8c85-beeadbf71c56	075bbaef-422f-4d7b-8d2a-667162b56519	6c85f93f-777c-46d4-94c2-00168d235977	6	\N	2013-11-11 09:28:58.536+01	0
363107a1-5b78-4c81-a3e2-8a9825e205e6	075bbaef-422f-4d7b-8d2a-667162b56519	73ad131a-4752-460c-9798-013282608b26	7	\N	2013-11-11 09:28:58.536+01	0
448a9385-b1cb-46f5-91d1-42b6032663da	075bbaef-422f-4d7b-8d2a-667162b56519	8e053a96-ffaf-49e8-91e6-931858bbe5a8	8	\N	2013-11-11 09:28:58.536+01	0
0c2ce910-6782-4e19-8752-91240b34435c	075bbaef-422f-4d7b-8d2a-667162b56519	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-11 09:28:58.536+01	0
684d2b6c-d8e7-40a3-910a-2d646a34d735	2e44fc5b-541d-420b-b0e7-c208bb4f68cc	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-15 13:28:38.183+01	0
5c1cffff-977b-4f3b-b122-30d9d3c7e3db	2e44fc5b-541d-420b-b0e7-c208bb4f68cc	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-15 14:55:37.453+01	0
1ae63c87-75f4-4265-a90f-2c5351c36191	2e44fc5b-541d-420b-b0e7-c208bb4f68cc	56504e89-ae03-4169-922a-7d5f0d222ab7	3	\N	2013-11-15 15:01:50.995+01	0
3a0b946b-a912-4a0a-a3ba-19d9ec96d0f2	2e44fc5b-541d-420b-b0e7-c208bb4f68cc	180780d8-f03f-48e0-b829-88fbbec2a5b2	4	\N	2013-11-15 15:18:44.956+01	0
f44aebec-1f05-4129-a4a1-8a1f0ae36a36	099732f3-6c88-435f-8904-208a547cf218	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-15 22:10:54.211+01	0
b6344a3d-25f5-487a-9307-9d3fe95e06d2	099732f3-6c88-435f-8904-208a547cf218	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-15 22:14:05.291+01	0
cfba3264-8e3c-4a20-8025-3e6514b45252	b5c2c02c-e88f-4013-9799-f970978ba8b2	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 09:08:51.028+01	0
cfde1a98-7f5f-4b08-ba84-741a7ee10456	099732f3-6c88-435f-8904-208a547cf218	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	5	\N	2013-11-15 22:56:28.918+01	0
848dfb07-d4fd-4566-a70f-88b4d66c5851	099732f3-6c88-435f-8904-208a547cf218	f3b63b5a-9b9f-473e-a165-6a3f537b0989	6	\N	2013-11-15 23:00:27.662+01	0
8f08fad8-21f7-44e8-a6b4-941eb2482d4f	5d59d730-68c0-4cf0-9f3d-7687ccae308b	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-15 23:14:39.333+01	0
23c4d5e6-85f3-4e55-b299-09a4d3062408	5d59d730-68c0-4cf0-9f3d-7687ccae308b	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-15 23:17:44.782+01	0
4590c0c0-7322-4768-961f-6f41f3dc4788	5d59d730-68c0-4cf0-9f3d-7687ccae308b	3fcdc058-a3d1-40f0-a645-b4f076ec2a00	4	\N	2013-11-15 23:29:24.315+01	0
563d2a7c-d750-4ce4-b8ef-044150e5dd05	5d59d730-68c0-4cf0-9f3d-7687ccae308b	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-15 23:32:44.545+01	0
e5349ddf-1143-410b-91b2-2f019668dc2c	4d23796b-0341-4fe0-8fe7-4ace4a9eb62a	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-15 23:37:16.579+01	0
1a62e8b6-dc9f-42d4-8888-d23beffe15be	4d23796b-0341-4fe0-8fe7-4ace4a9eb62a	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-15 23:39:19.835+01	0
6a51f517-d873-4367-83d3-7b5ef5de603e	4d23796b-0341-4fe0-8fe7-4ace4a9eb62a	f3b63b5a-9b9f-473e-a165-6a3f537b0989	6	\N	2013-11-15 23:42:21.624+01	0
39afc6ea-c36f-4a62-adbc-9e18ff5c2a2b	4d23796b-0341-4fe0-8fe7-4ace4a9eb62a	d0211769-49ac-4ff1-8aa9-6351899619c4	4	\N	2013-11-15 23:43:49.297+01	0
f5310daa-1050-4dc0-a2fd-6b52fd629886	4d23796b-0341-4fe0-8fe7-4ace4a9eb62a	c70c24a8-dd37-4e0b-b5d7-60e241439c82	5	\N	2013-11-15 23:44:34.568+01	0
9e8fc549-0813-4f8a-987e-6c4a04d68c43	119a2834-bda1-4607-849c-4c25b3f4670f	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-15 23:48:17.846+01	0
78ebd826-2901-45ed-8c7c-7b15c8e621a4	119a2834-bda1-4607-849c-4c25b3f4670f	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-15 23:53:13.304+01	0
46c0b342-89d7-4819-96f8-329d8bb89a05	119a2834-bda1-4607-849c-4c25b3f4670f	d995e4d5-094b-481b-8817-d09b5320ab03	4	\N	2013-11-15 23:55:22.41+01	0
d5d2f759-5c3c-4343-be6a-fd77ff782dfb	119a2834-bda1-4607-849c-4c25b3f4670f	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-15 23:56:50.719+01	0
1e4888f5-d334-4f39-abc0-4b95f52769e0	b5c2c02c-e88f-4013-9799-f970978ba8b2	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 11:07:35.371+01	0
215432ac-bdf2-4d33-a425-bef69f7eb5f9	b5c2c02c-e88f-4013-9799-f970978ba8b2	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	3	\N	2013-11-18 11:09:13.786+01	0
246cb2e5-0557-47fb-83e0-52a4b88289bb	b5c2c02c-e88f-4013-9799-f970978ba8b2	083bbac1-bafa-40a3-95eb-743b18faefaf	4	\N	2013-11-18 11:12:13.037+01	0
3d75c643-ce34-47e0-befb-ad38c356cf53	b076848f-c590-447a-a104-812098a392cc	61240b23-8f2e-4127-9f52-987092cb9443	7	\N	2013-11-18 12:57:24.424+01	0
54a5ed85-6964-4199-aa28-952c2bb7f2b5	b5c2c02c-e88f-4013-9799-f970978ba8b2	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-18 11:25:29.226+01	0
b10f4f6f-ed93-420d-aeea-755771fa8c3f	b076848f-c590-447a-a104-812098a392cc	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 11:29:12.388+01	0
155151bf-3a50-4683-b0d0-effbe7ad26c8	b076848f-c590-447a-a104-812098a392cc	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 11:30:29.393+01	0
8ccbbbf7-850c-4aa2-9200-63e821df0e80	b076848f-c590-447a-a104-812098a392cc	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 11:31:15.239+01	0
fdcadd8e-e303-44b9-877b-139e94976734	b076848f-c590-447a-a104-812098a392cc	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 12:39:12.204+01	0
137698d0-edb0-4eba-9fff-84a84558f5d2	b076848f-c590-447a-a104-812098a392cc	8b92c005-2284-48e4-8d71-e34257973349	8	\N	2013-11-18 12:58:44.983+01	0
ec8857c0-1e70-4f15-adb4-ee51b61c52d8	b076848f-c590-447a-a104-812098a392cc	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 12:59:18.591+01	0
3fca4f39-17cc-4914-a092-fbbfba3f9213	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 13:11:40.217+01	0
60baa622-a5a4-41d5-9b41-cd7c1a7b2cb1	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 13:14:11.992+01	0
003a4f7f-0b20-45ae-8ef0-771fb661181e	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 13:14:39.001+01	0
2ec8b89a-978c-4ace-bb26-9c0a415b6cb5	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 13:15:02.893+01	0
e24070ec-6338-4c4b-9fbd-897a512a0e4b	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	61240b23-8f2e-4127-9f52-987092cb9443	7	\N	2013-11-18 13:16:30.583+01	0
371bb287-b71b-475e-aaa8-0503b5499ecd	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	49b9af3a-6460-41e4-9b18-1e08d7e757e5	8	\N	2013-11-18 13:17:46.747+01	0
21ee854a-44c0-4b6a-bd15-1e771afd09c5	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 13:22:21.431+01	0
ad0f5785-9c36-4d58-aea5-3c4d5da2274b	5570564c-a7f5-4902-8e24-a8288729e55c	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 13:23:57.295+01	0
189b2da3-f7e6-4b10-95bf-96e88ab2911f	5570564c-a7f5-4902-8e24-a8288729e55c	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 13:24:28.042+01	0
f95d6053-1ef8-4122-9be0-3935bab2d1f3	5570564c-a7f5-4902-8e24-a8288729e55c	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 13:24:58.212+01	0
c1f706b5-4ab3-45d1-b0a0-bbab5fa7d5e5	5570564c-a7f5-4902-8e24-a8288729e55c	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 13:25:40.375+01	0
4047ec58-52e6-4a6c-8b70-18ce4d438a41	5570564c-a7f5-4902-8e24-a8288729e55c	cbad3998-ccfc-4621-8390-6e16397c6ee9	7	\N	2013-11-18 13:27:40.01+01	0
7eb41be2-3661-41ea-83d0-709e8180e640	5570564c-a7f5-4902-8e24-a8288729e55c	2bf172b1-993e-472c-9291-04ddd207c196	8	\N	2013-11-18 13:34:58.364+01	0
96462715-ed94-4681-b341-5a0481a49d2e	5570564c-a7f5-4902-8e24-a8288729e55c	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 13:43:15.254+01	0
e81dcae5-470a-4e5e-bd6a-b6d5e10b5016	fa3265d4-f742-47db-bec1-07f52930762b	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 13:50:34.099+01	0
acb231ea-b1cb-4ef3-bc7e-d40e608f58c2	fa3265d4-f742-47db-bec1-07f52930762b	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 13:56:20.573+01	0
40d0911d-0792-4d2d-b129-b39411a57002	fa3265d4-f742-47db-bec1-07f52930762b	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 13:56:44.942+01	0
845741d2-e330-490b-8d80-6ecd37b288c0	fa3265d4-f742-47db-bec1-07f52930762b	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 13:57:11.207+01	0
4c0b3324-3f39-40f3-9058-08acef9ead04	fa3265d4-f742-47db-bec1-07f52930762b	c7891240-7441-4af0-ad3f-8942d5f3743a	7	\N	2013-11-18 14:05:42.985+01	0
86a9d836-c9bd-4619-a018-044d1b6abdee	fa3265d4-f742-47db-bec1-07f52930762b	5243e759-cca1-4b72-8ea7-2b32a34362f8	8	\N	2013-11-18 14:06:53.715+01	0
3e713a00-f807-48b3-920b-7691f8704ce1	fa3265d4-f742-47db-bec1-07f52930762b	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 14:07:20.012+01	0
2d6da8bd-1ade-4c95-af32-bf1f4aaf434c	6f502148-04b3-438f-be94-0961b34d8747	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 14:13:13.106+01	0
708e15cf-c030-4ecb-aa03-7acb76421444	6f502148-04b3-438f-be94-0961b34d8747	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 14:13:32.758+01	0
ed97b7c8-6391-4d11-b61c-cd6f3d470108	6f502148-04b3-438f-be94-0961b34d8747	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 14:14:02.836+01	0
6b698f33-e236-474b-8f1b-4154c50e3518	6f502148-04b3-438f-be94-0961b34d8747	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 14:14:37.612+01	0
106687fa-1aa3-429d-b573-47d6edd101f3	6f502148-04b3-438f-be94-0961b34d8747	6056d92c-0df0-4c40-ba7a-47755ff6644c	7	\N	2013-11-18 14:15:59.221+01	0
49bb0af0-cab5-4dc0-96d2-7cbaf89dbbac	6f502148-04b3-438f-be94-0961b34d8747	17d71398-0fc3-46ff-b40a-96b0fa4c7fd1	8	\N	2013-11-18 14:24:04.315+01	0
e924a4e8-8f1e-471c-8774-b0277f360b14	6f502148-04b3-438f-be94-0961b34d8747	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 14:24:25.903+01	0
ee5d7a95-cfd6-4c31-ab73-a1be989ec91d	0c15d3a1-167e-4524-bf40-37f373d97db2	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 14:26:01.162+01	0
8f320033-6968-44e6-8fbc-12f2a059441c	0c15d3a1-167e-4524-bf40-37f373d97db2	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 14:26:42.574+01	0
6778db5f-7ae0-49e0-b651-179067102c58	0c15d3a1-167e-4524-bf40-37f373d97db2	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 14:26:50.444+01	0
ac713677-c91a-4b34-ac7e-c1fa99124e05	099732f3-6c88-435f-8904-208a547cf218	56504e89-ae03-4169-922a-7d5f0d222ab7	3	\N	2013-11-15 22:32:54.742+01	0
c07b771e-141d-4490-b960-20eef6f34e87	0c15d3a1-167e-4524-bf40-37f373d97db2	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 14:26:30.318+01	0
55eb44e8-c652-4386-b77f-7e6edb7341f9	0c15d3a1-167e-4524-bf40-37f373d97db2	12c06ff2-d2b6-4cc9-a3e4-a542c03ad51e	7	\N	2013-11-18 14:27:53.392+01	0
93e93b25-3359-4f91-8cd5-b839d1e8f6a4	0c15d3a1-167e-4524-bf40-37f373d97db2	f9a03410-e081-4cd8-849d-8e0c8e38f5e9	8	\N	2013-11-18 14:53:40.825+01	0
88d968b3-e1d7-49b3-874f-8d2f19ea475f	0c15d3a1-167e-4524-bf40-37f373d97db2	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 14:54:04.097+01	0
10be87d0-6552-4ce6-9182-0257c7a3a1a8	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 14:58:13.072+01	0
c23f767a-75d1-4eae-9862-e9cc88a6c4ce	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 14:58:35.191+01	0
fe3d6542-1ba6-4744-91bd-b6396efadd9a	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 14:58:42.775+01	0
56ef42f5-fb2b-49e3-be45-c429c1f34390	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 14:59:01.207+01	0
d7c4c602-59ea-487f-a2f0-6f02ad5bfc57	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	1f8b46a4-8da7-4784-9c00-a4ed43fd3798	7	\N	2013-11-18 15:01:20.599+01	0
3b20a564-f726-4f53-87dd-e42a52c70d63	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	33e187fc-d4ee-4e14-80f4-e8b852099953	8	\N	2013-11-18 15:08:26.579+01	0
e5f9dafa-a110-48ba-a8d2-58e04eb960be	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 15:11:28.763+01	0
90f15682-65c7-4983-ba88-edbb436cba6a	7fe7c776-f958-471c-8946-9eff9b9f98a2	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 15:12:50.857+01	0
bb47a90d-142e-4e86-8830-210b52ff95a2	7fe7c776-f958-471c-8946-9eff9b9f98a2	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 15:13:02.825+01	0
b3e15018-e6ef-4b7c-ad8e-180a20574052	7fe7c776-f958-471c-8946-9eff9b9f98a2	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 15:13:10.329+01	0
6ba47b23-58c5-4d6e-8dcf-eba3ab2effa8	7fe7c776-f958-471c-8946-9eff9b9f98a2	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 15:13:18.393+01	0
932dc414-5142-44fc-a429-e90ecedc98a4	7fe7c776-f958-471c-8946-9eff9b9f98a2	c7891240-7441-4af0-ad3f-8942d5f3743a	7	\N	2013-11-18 15:18:14.496+01	0
d5c18ac1-0ca8-47d8-88ce-8e75615b2a4c	7fe7c776-f958-471c-8946-9eff9b9f98a2	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 15:19:43.527+01	0
1cb24b34-516f-4dde-9af3-2e16e149e837	7fe7c776-f958-471c-8946-9eff9b9f98a2	2ba216de-eede-4c1a-96fc-ae0e373de9cb	8	\N	2013-11-18 15:19:34.006+01	0
676566fb-b0c9-4a69-bf27-2683369c1126	b15e295e-f586-438c-a0a9-12ec6e086168	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 15:24:24.086+01	0
41cad789-47e0-460d-8eff-5d2b72feceed	b15e295e-f586-438c-a0a9-12ec6e086168	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 15:24:41.148+01	0
b56ed4bc-23d6-4801-a465-984cc2b337fa	b15e295e-f586-438c-a0a9-12ec6e086168	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 15:24:50.54+01	0
d05aa21c-8e08-45fd-8cbe-d85083f0a31a	b15e295e-f586-438c-a0a9-12ec6e086168	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 15:25:03.524+01	0
66b7813f-f706-4d53-a6fd-4a139f588394	7e2bc36a-45ba-4273-a607-2e904158e853	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 08:53:45.232+01	0
ec750b15-94dc-477d-9b3f-f1579d9c844e	b15e295e-f586-438c-a0a9-12ec6e086168	f33c6af7-0b3a-4fde-8e31-5cd63231cd29	7	\N	2013-11-18 15:25:13.013+01	0
b4ddf98e-b82d-4294-8cb5-fcc4baee7fae	b15e295e-f586-438c-a0a9-12ec6e086168	f3b63b5a-9b9f-473e-a165-6a3f537b0989	8	\N	2013-11-18 15:25:29.908+01	0
430d4436-5129-4ea5-ba47-5270a6621d26	c73494ab-ff4b-4548-b182-d628147ae77f	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-18 15:30:15.106+01	0
59f7bbc9-b87b-4d1f-a612-77b3cb5ad6a9	c73494ab-ff4b-4548-b182-d628147ae77f	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-18 15:30:22.505+01	0
5aba441f-04dd-4b63-82c4-ca903a8218d6	c73494ab-ff4b-4548-b182-d628147ae77f	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-18 15:30:31.922+01	0
aef02c08-867a-4464-badd-5bdeeb44c4fe	c73494ab-ff4b-4548-b182-d628147ae77f	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-18 15:30:38.881+01	0
cc3dd6d4-5af3-4293-b6c0-25bdf30e65f8	c73494ab-ff4b-4548-b182-d628147ae77f	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-18 15:31:14.185+01	0
2dd25561-8195-4288-bc34-982e545398dd	c73494ab-ff4b-4548-b182-d628147ae77f	6056d92c-0df0-4c40-ba7a-47755ff6644c	7	\N	2013-11-18 15:30:59.97+01	0
35592484-c6b4-4e1f-a3cf-1dabb74c9aa1	c73494ab-ff4b-4548-b182-d628147ae77f	6051a1dc-afd8-40a0-ba6e-9e695be6db82	8	\N	2013-11-18 15:31:07.082+01	0
eec7e792-4c47-4806-adb1-b07a722752d2	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 08:48:23.387+01	0
f8feb16f-2516-4032-a9cb-931bad16c63a	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 08:48:34.714+01	0
fc44e463-075f-428e-9aff-d35de599a123	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 08:48:40.915+01	0
688faee4-33c6-4c46-ae90-cefefe4fb85a	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 08:48:48.587+01	0
31e1fadb-d381-4a06-94a6-146bb66f2d6b	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	ad438256-7907-4668-a794-b45a328bb94e	7	\N	2013-11-19 08:51:32.602+01	0
b56dddd3-f785-4bab-806f-dc19cf80c5ca	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	f3b63b5a-9b9f-473e-a165-6a3f537b0989	8	\N	2013-11-19 08:51:49.533+01	0
ecc6d128-c960-42d8-8438-979fca32ef69	7e2bc36a-45ba-4273-a607-2e904158e853	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 08:53:30.704+01	0
083c6846-b6b4-4aa7-a128-dd0a75c5b9a3	7e2bc36a-45ba-4273-a607-2e904158e853	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 08:53:38.289+01	0
f9fedc70-6cec-432e-8d00-18498c5a6189	7e2bc36a-45ba-4273-a607-2e904158e853	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 08:53:53.24+01	0
ca3564d7-0b1c-4684-8f1f-2e24684bdf9c	7e2bc36a-45ba-4273-a607-2e904158e853	678065f9-dc10-4db4-ba7d-67dd99b39af8	7	\N	2013-11-19 08:55:12.856+01	0
77c5ff18-a839-4f46-a104-2140f8487950	7e2bc36a-45ba-4273-a607-2e904158e853	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 08:55:36.976+01	0
a6d989ed-0119-4d81-a0f5-7ede3f5d28cf	7e2bc36a-45ba-4273-a607-2e904158e853	5f1803ef-1936-4e7d-bdcb-267e5c89d8dd	8	\N	2013-11-19 08:55:29.224+01	0
1787a328-f682-4fb1-8090-50f1f8b107c2	5f07451e-7113-4b7c-8976-9e82a471581b	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 09:04:04.356+01	0
87c8a10c-1276-4d2d-bd79-db188ed7ce9d	5f07451e-7113-4b7c-8976-9e82a471581b	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 09:04:10.02+01	0
79215b7f-9d06-433f-a1b3-db24f05623e6	5f07451e-7113-4b7c-8976-9e82a471581b	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 09:04:16.748+01	0
dac0d65c-f9dc-4ef3-83cd-bb208036335c	5f07451e-7113-4b7c-8976-9e82a471581b	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 09:04:24.1+01	0
03379c87-33a7-486b-9a5a-032fc8c1103a	5f07451e-7113-4b7c-8976-9e82a471581b	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 09:05:00.892+01	0
8331367c-b1f1-4124-b750-51eb091b6272	5f07451e-7113-4b7c-8976-9e82a471581b	caebf2d9-cf37-4e8d-827f-eccc83ebb3c9	7	\N	2013-11-19 09:04:46.636+01	0
9ab10549-c792-41e0-a572-1724b4638703	5f07451e-7113-4b7c-8976-9e82a471581b	438d2e22-26eb-4022-b7d5-cefd8acd9226	8	\N	2013-11-19 09:04:54.339+01	0
1e557a43-14d1-46f9-9a28-bde343cc3052	63ef0eb1-53a6-4567-b777-3801016cc65e	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 09:13:28.504+01	0
a225c0b0-fc32-40cf-9a04-658d7c2fd418	63ef0eb1-53a6-4567-b777-3801016cc65e	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 09:13:34.736+01	0
cd8cdd27-5525-40c2-8eab-16a589448a12	63ef0eb1-53a6-4567-b777-3801016cc65e	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 09:13:40.617+01	0
f3c29250-ae14-4ee8-9166-9d7338608d78	63ef0eb1-53a6-4567-b777-3801016cc65e	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 09:13:46.248+01	0
6f503cce-e02b-4575-9b5e-60f386d7b022	63ef0eb1-53a6-4567-b777-3801016cc65e	caebf2d9-cf37-4e8d-827f-eccc83ebb3c9	7	\N	2013-11-19 09:13:55.688+01	0
58b38959-ddb3-406b-be45-9c8f1645d101	63ef0eb1-53a6-4567-b777-3801016cc65e	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 09:14:46.383+01	0
f42024ff-72e9-4138-a117-938ec59bedf2	63ef0eb1-53a6-4567-b777-3801016cc65e	625929e4-43f6-407d-a43f-05604071aa6e	8	\N	2013-11-19 09:14:04.376+01	0
4a5858b8-6763-43a8-ace0-7c186cb7765d	a29e3fc0-e8a0-4f55-95b4-39b622a44248	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 09:21:49.692+01	0
c346897b-f4c7-418f-87d9-9b3f0dd7cb75	a29e3fc0-e8a0-4f55-95b4-39b622a44248	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 09:21:55.262+01	0
4f35ebd3-ad65-4f0d-b4a3-98b409ba7ffc	a29e3fc0-e8a0-4f55-95b4-39b622a44248	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 09:22:01.692+01	0
15791d6d-d1e0-4cd9-8193-3585f7cbcb62	a29e3fc0-e8a0-4f55-95b4-39b622a44248	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 09:22:07.893+01	0
a039c62b-d617-437d-96ef-5b660b52102c	a29e3fc0-e8a0-4f55-95b4-39b622a44248	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 09:22:50.308+01	0
b036cc79-1de6-4f53-a6e3-e6d46b8ee0c2	a29e3fc0-e8a0-4f55-95b4-39b622a44248	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	7	\N	2013-11-19 09:22:14.828+01	0
27bee4b2-d720-4455-bfaf-1d84ba402528	a29e3fc0-e8a0-4f55-95b4-39b622a44248	1c078554-eb73-4196-b0dd-10e4d2a27389	8	\N	2013-11-19 09:22:22.868+01	0
97233673-66cf-4d2b-b19c-2e9e8d7c13c8	26debf83-b32e-4264-95b8-8daf96c4f07b	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 10:00:03.503+01	0
6a108cca-4f35-4a66-bee1-5a0d96f13f35	26debf83-b32e-4264-95b8-8daf96c4f07b	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 10:00:09.287+01	0
145bc44a-9019-4c71-bbf1-4d7773793f63	26debf83-b32e-4264-95b8-8daf96c4f07b	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 10:00:39.407+01	0
31495d05-379d-46c7-835d-c8f0373a7165	26debf83-b32e-4264-95b8-8daf96c4f07b	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 10:01:29.303+01	0
a9d04a28-02a2-41f9-9952-4f08ce006e49	26debf83-b32e-4264-95b8-8daf96c4f07b	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 10:02:32.287+01	0
47e3823b-e8d5-47a1-836a-3f9ab014c813	26debf83-b32e-4264-95b8-8daf96c4f07b	de1ad443-157b-43f5-b7a8-ec8b8371c368	7	\N	2013-11-19 10:01:37.774+01	0
89aa6608-c5e2-492f-a863-8207c149f7d6	26debf83-b32e-4264-95b8-8daf96c4f07b	e89d4206-ff2f-4756-99b5-e9a1309f98f9	8	\N	2013-11-19 10:01:45.67+01	0
e2cb3e29-4ebd-466d-a00f-6eb331a4fbd2	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 10:35:24.864+01	0
bf9b1002-a813-4040-9698-2f0e93b01af0	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 10:35:29.841+01	0
85117593-f7b1-4f0e-90da-ca2aa455c5c0	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 10:35:36.648+01	0
05cf41eb-530f-4cd9-a6b8-86d10d897507	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 10:36:01.209+01	0
6a5215ea-a08c-440c-8961-90493a51362a	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	f38be589-b7ad-4803-82aa-045ae26cafa9	8	\N	2013-11-19 10:35:53+01	0
af67e710-e0dc-42d0-a788-8ea6f7129e8e	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 10:35:15.41+01	0
c0526b7d-b3d6-415c-bcb8-5037fab6d7e3	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	7	\N	2013-11-19 10:35:45.265+01	0
95be4ac2-56d0-4409-8f9b-e2e16efd028f	ee77e006-38a2-470c-9877-78399dcd8371	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 12:41:49.835+01	0
8dbf4408-6d94-46cd-a016-cbda39c06651	ee77e006-38a2-470c-9877-78399dcd8371	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 12:41:55.779+01	0
7a363e41-d655-4afc-963c-10105a14d65a	ee77e006-38a2-470c-9877-78399dcd8371	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 12:42:02.323+01	0
b3d05878-0ab1-427f-9278-797dc623c190	ee77e006-38a2-470c-9877-78399dcd8371	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 12:42:11.026+01	0
c3112388-7000-4b0b-b181-82ffcf4a63ea	ee77e006-38a2-470c-9877-78399dcd8371	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 12:42:35.795+01	0
d9b2cb14-67f6-4ce0-a0db-59aed117cbad	ee77e006-38a2-470c-9877-78399dcd8371	678065f9-dc10-4db4-ba7d-67dd99b39af8	7	\N	2013-11-19 12:42:18.195+01	0
98568c3f-21f8-4835-80a3-617965996335	ee77e006-38a2-470c-9877-78399dcd8371	ff9c6584-d8be-46a6-b09f-35c1341056ff	8	\N	2013-11-19 12:42:24.85+01	0
b04a0108-0bf4-46dd-bcfa-e816a765ccae	ebad0433-524f-4aed-87dc-3aa2827c173f	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 12:49:59.807+01	0
742384c7-6f90-43c7-a2c0-a4c0d8feef7c	ebad0433-524f-4aed-87dc-3aa2827c173f	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 12:50:13.927+01	0
5b1fb2a1-f905-48e8-ac62-892e5bf09692	ebad0433-524f-4aed-87dc-3aa2827c173f	f3b63b5a-9b9f-473e-a165-6a3f537b0989	4	\N	2013-11-19 12:50:28.439+01	0
5a9a92e5-a9e7-4af9-8ead-e3499b561580	5d274f43-07b8-46fd-b2f8-1413ebfa1240	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 12:54:15.182+01	0
7909c099-3398-4394-889b-5edfc64471ac	5d274f43-07b8-46fd-b2f8-1413ebfa1240	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 12:54:21.213+01	0
29bede6c-eecb-4a36-b1f0-f52356147f65	5d274f43-07b8-46fd-b2f8-1413ebfa1240	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 12:54:28.126+01	0
0ac41ab6-83da-4f48-9bcd-f84369188892	5d274f43-07b8-46fd-b2f8-1413ebfa1240	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 12:54:34.781+01	0
564a1b71-7104-49ca-a8c6-b5b56b92f2e8	5d274f43-07b8-46fd-b2f8-1413ebfa1240	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 12:54:56.317+01	0
e0b56c32-f22d-49b0-827c-50ae5fa8244a	5d274f43-07b8-46fd-b2f8-1413ebfa1240	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	7	\N	2013-11-19 12:54:42.053+01	0
126b3f7f-45ba-401d-ab25-e68c3c57caac	5d274f43-07b8-46fd-b2f8-1413ebfa1240	631e442f-1532-4086-b15d-0dab83b07e13	8	\N	2013-11-19 12:54:49.366+01	0
63de424d-10d7-4362-9d76-16ba76ea1dd1	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 13:29:30.487+01	0
add36eb4-7ee2-4657-b3bd-fa2048caf591	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 13:29:36.23+01	0
76a555d0-7dde-4795-b501-241bd3a438bf	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 13:29:42.639+01	0
fed8e144-e6f3-48f5-a565-bbf1bb8d3169	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 13:30:23.815+01	0
a4fc2fd5-7859-4313-9aad-9b8ae52115f4	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	b32009d7-2df1-4a11-be50-5603f41b5a20	7	\N	2013-11-19 13:29:56.838+01	0
ce373974-10d3-4d83-a008-7ecfb50e9661	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 13:29:49.039+01	0
1e8c7e93-1017-46fd-825b-6817c4a06924	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	3dae6ead-2bec-4956-a262-3fd36f2f7e55	8	\N	2013-11-19 13:30:02.471+01	0
fe96c7dd-a5ee-482e-aa51-2712ebbfb6c7	88a3a83e-c9c2-497f-95bd-801536443895	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 13:37:30.651+01	0
b5ee4c8b-dbd6-4665-aedb-0c4e9ef71bdb	88a3a83e-c9c2-497f-95bd-801536443895	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 13:37:37.475+01	0
872644bc-5765-4346-89cf-cc4c9cf3ba40	88a3a83e-c9c2-497f-95bd-801536443895	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 13:37:44.099+01	0
deac70eb-177a-4965-8ed4-cdeaa85ea735	88a3a83e-c9c2-497f-95bd-801536443895	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 13:37:50.868+01	0
2d033baf-0d1d-4312-b5c3-9b1c49eccfde	88a3a83e-c9c2-497f-95bd-801536443895	f3b63b5a-9b9f-473e-a165-6a3f537b0989	9	\N	2013-11-19 13:38:08.652+01	0
71525bb4-9a1e-4da5-864a-abbab3196e90	88a3a83e-c9c2-497f-95bd-801536443895	6056d92c-0df0-4c40-ba7a-47755ff6644c	7	\N	2013-11-19 13:37:57.443+01	0
65e4b63c-3890-4564-a6c7-2baea8c70bde	88a3a83e-c9c2-497f-95bd-801536443895	9ba18305-7ce7-4442-8b7c-98a84e93c57b	8	\N	2013-11-19 13:38:02.987+01	0
ee7fb39e-c402-49c4-be07-9730ecf54f1c	63a9496a-9455-4664-beb2-e8e75a7cf043	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 13:43:45.386+01	0
f0f4a457-ab8f-4384-8073-b23c66317355	63a9496a-9455-4664-beb2-e8e75a7cf043	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 13:43:51.888+01	0
98961637-1da4-44aa-85fb-84ee8254ff6f	63a9496a-9455-4664-beb2-e8e75a7cf043	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 13:43:58.441+01	0
874bec11-a492-4e31-bc1c-a7aa9d39636c	63a9496a-9455-4664-beb2-e8e75a7cf043	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 13:44:06.489+01	0
6797213a-738f-4f6c-b06a-15cd09eca4be	63a9496a-9455-4664-beb2-e8e75a7cf043	f3b63b5a-9b9f-473e-a165-6a3f537b0989	8	\N	2013-11-19 13:44:19.465+01	0
dfc26304-8f85-4f5d-a194-6deff17b966c	63a9496a-9455-4664-beb2-e8e75a7cf043	67f40a38-3ee5-4fad-af99-9f7e324d8eb0	7	\N	2013-11-19 13:44:13.744+01	0
795bcf96-4631-4661-865e-323860857c6a	879cb62e-1a88-44fb-b064-0fc84ad7ceba	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	\N	2013-11-19 13:48:36.847+01	0
099b9fa4-b4e3-4eeb-8244-cc173d260dc7	879cb62e-1a88-44fb-b064-0fc84ad7ceba	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 13:48:43.263+01	0
065219b0-db8f-4ee5-92ff-bf0361864565	879cb62e-1a88-44fb-b064-0fc84ad7ceba	5b7e4a0d-2438-4090-9559-923e75659c53	3	\N	2013-11-19 13:48:53.942+01	0
eb10c23c-e29f-4dc5-9a09-65948d8b358d	879cb62e-1a88-44fb-b064-0fc84ad7ceba	b875b562-b921-42a7-b1fb-b9ff66f123b3	4	\N	2013-11-19 13:49:00.127+01	0
849eb134-5856-44bd-a406-890ac44cbe7c	7d56c6ca-3524-4b7b-9fcf-8e1585d06f00	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-19 13:53:28.916+01	0
c73c6876-3014-4e6d-ba63-77987556566f	7d56c6ca-3524-4b7b-9fcf-8e1585d06f00	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 13:53:08.069+01	0
c7bb9c20-80bf-45ef-99e0-58b1e17f93a8	7d56c6ca-3524-4b7b-9fcf-8e1585d06f00	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-19 13:53:02.245+01	0
5160424e-b9b5-4a55-9c86-945aac7b9a35	7d56c6ca-3524-4b7b-9fcf-8e1585d06f00	4a642c45-5a91-4c45-801e-f7b1d1302d4b	3	\N	2013-11-19 13:53:15.036+01	0
d3192748-8ce7-43a8-8eb8-ed80fdccb855	7d56c6ca-3524-4b7b-9fcf-8e1585d06f00	a4c268f8-fc3b-4537-acff-a372bee2fddf	4	\N	2013-11-19 13:53:21.581+01	0
c2c10584-2d28-4ad1-81dc-4100db5f2a17	a944240b-2750-4427-9003-5d63c3af555a	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-19 15:34:22.241+01	0
9c498ff8-6264-4e6b-b9a9-d4463da9f120	a944240b-2750-4427-9003-5d63c3af555a	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 15:34:28.282+01	0
cfc02992-f64b-407e-8846-9e3c3c99aa90	a944240b-2750-4427-9003-5d63c3af555a	4a642c45-5a91-4c45-801e-f7b1d1302d4b	3	\N	2013-11-19 15:34:35.866+01	0
ba9a0573-7ebf-4ee7-8a5b-cc8225431fc0	a944240b-2750-4427-9003-5d63c3af555a	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-19 15:34:57.713+01	0
6ae8e027-e832-4182-85e5-395a24bf761c	a944240b-2750-4427-9003-5d63c3af555a	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	4	\N	2013-11-19 15:34:50.626+01	0
392f9406-6882-499c-95a4-51b971c5d28d	ee978fc7-4d0f-45ff-a3ba-6ffb4da38dff	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-19 15:42:27.806+01	0
21900ca4-b66b-4263-b3e2-065df3b46c34	ee978fc7-4d0f-45ff-a3ba-6ffb4da38dff	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 15:42:34.343+01	0
6dbc8fb5-fbde-43c9-a9a0-4fccf43b6f5d	ee978fc7-4d0f-45ff-a3ba-6ffb4da38dff	4a642c45-5a91-4c45-801e-f7b1d1302d4b	3	\N	2013-11-19 15:42:39.894+01	0
9eca76b7-d2ad-4f9f-a027-d407d23162c7	ee978fc7-4d0f-45ff-a3ba-6ffb4da38dff	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-19 15:43:02.126+01	0
1a51a8b1-70af-4786-afad-99635b9d6151	ee978fc7-4d0f-45ff-a3ba-6ffb4da38dff	175ad376-2621-41e7-ad6c-6451d7cedbbf	4	\N	2013-11-19 15:42:55.543+01	0
750045d6-d692-4f46-a26d-771a43e63045	2d6958b1-7157-4fb5-a0ba-71c90fc49a22	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-19 16:06:29.725+01	0
f0277dfc-6ab4-49df-9cb9-bd1371de5a12	2d6958b1-7157-4fb5-a0ba-71c90fc49a22	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 16:06:35.156+01	0
67120342-e08d-4365-891a-1eeb5f8d465a	2d6958b1-7157-4fb5-a0ba-71c90fc49a22	4a642c45-5a91-4c45-801e-f7b1d1302d4b	3	\N	2013-11-19 16:06:41.756+01	0
b93b5c12-a4d9-4652-976a-1d2ef22d2b78	2d6958b1-7157-4fb5-a0ba-71c90fc49a22	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-19 16:06:54.468+01	0
82e6e671-b41d-4fe5-ad62-995b11c00fd5	2d6958b1-7157-4fb5-a0ba-71c90fc49a22	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	4	\N	2013-11-19 16:06:47.804+01	0
f83a010f-7335-4ffc-b3ac-191558d16861	b443603a-11d7-45af-b331-e6d9f30f1f87	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-19 16:23:17.021+01	0
f72ea829-0f3b-4294-b1fe-c0504823cb47	b443603a-11d7-45af-b331-e6d9f30f1f87	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-19 16:23:23.061+01	0
27f181d7-89ef-4149-8df1-83112e89968a	b443603a-11d7-45af-b331-e6d9f30f1f87	4a642c45-5a91-4c45-801e-f7b1d1302d4b	3	\N	2013-11-19 16:23:28.733+01	0
915dfd47-11d3-4162-9bd6-e23e36a16cd6	b443603a-11d7-45af-b331-e6d9f30f1f87	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-19 16:23:41.541+01	0
9a176be6-a33e-4f50-afb8-f4c21b34bcce	b443603a-11d7-45af-b331-e6d9f30f1f87	97008f82-e648-4e59-a403-dc7be8df289e	4	\N	2013-11-19 16:23:35.045+01	0
f3ebc672-4568-4a99-b426-867bf8d0bb2e	f6ad8df2-bd01-4433-a3c5-0411f9f5d73b	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-20 09:59:18.534+01	0
870ee7d5-a40c-4cbd-bc52-daa10b4f2c22	f6ad8df2-bd01-4433-a3c5-0411f9f5d73b	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-20 09:59:23.135+01	0
a9ec2488-3a8b-4806-bd83-acb57f6bd0a6	f6ad8df2-bd01-4433-a3c5-0411f9f5d73b	4a642c45-5a91-4c45-801e-f7b1d1302d4b	3	\N	2013-11-20 09:59:29.158+01	0
e0616864-39b8-4065-951c-f86b45f94577	f6ad8df2-bd01-4433-a3c5-0411f9f5d73b	f3b63b5a-9b9f-473e-a165-6a3f537b0989	6	\N	2013-11-20 09:59:44.726+01	0
4721c968-765e-4b00-babf-ce3923b540d0	f6ad8df2-bd01-4433-a3c5-0411f9f5d73b	368513d0-172d-43a0-a475-be4f138c7196	4	\N	2013-11-20 09:59:33.83+01	0
a50a70d1-9415-4139-80a4-4ea7c0c87ab4	f6ad8df2-bd01-4433-a3c5-0411f9f5d73b	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	5	\N	2013-11-20 09:59:39.407+01	0
6ec95948-4fba-4026-bbf6-1408fbe6588a	811d36f6-a6da-4e3f-9a7b-5cb7087191ce	4f0f380c-e58e-4222-a59b-5ac41c145793	2	\N	2013-11-20 10:25:28.595+01	0
c3d0cd03-1d17-40e6-b29c-51389be0e1f5	811d36f6-a6da-4e3f-9a7b-5cb7087191ce	4a642c45-5a91-4c45-801e-f7b1d1302d4b	3	\N	2013-11-20 10:25:33.939+01	0
d5351fab-c032-49fd-bcac-4ca34ad0bb81	879cb62e-1a88-44fb-b064-0fc84ad7ceba	f3b63b5a-9b9f-473e-a165-6a3f537b0989	8	Eirik Frantzen	2014-01-23 11:31:53.374+01	0
c2775960-ec2a-4d43-9ad5-1ecbcba9e1a0	811d36f6-a6da-4e3f-9a7b-5cb7087191ce	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	1	\N	2013-11-20 10:25:23.501+01	0
27e04928-2931-42d0-8473-14503a6c7e96	811d36f6-a6da-4e3f-9a7b-5cb7087191ce	f3b63b5a-9b9f-473e-a165-6a3f537b0989	6	\N	2013-11-20 10:25:49.331+01	0
f48b8055-a6e2-42f8-82b2-fca79cb9f2cc	811d36f6-a6da-4e3f-9a7b-5cb7087191ce	7243960f-e462-4a79-854f-6d2a83f5da51	4	\N	2013-11-20 10:25:39.092+01	0
2cf2f0f8-712c-42b9-8cae-7b28d193a8ff	811d36f6-a6da-4e3f-9a7b-5cb7087191ce	fb8e9224-f278-4f4d-bdf9-7be264d4bc06	5	\N	2013-11-20 10:25:44.059+01	0
5f4a5b86-17c6-434d-b38e-a0f2079e9a70	b076848f-c590-447a-a104-812098a392cc	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:36.558+01	0
ea0cfd5e-34d3-4709-8eaf-d04cb5974998	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:44.262+01	0
28e222e3-055d-4417-87c7-0e35f856f75c	5570564c-a7f5-4902-8e24-a8288729e55c	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:52.413+01	0
e7a6a2a8-4871-43eb-bea4-27f79638bf92	fa3265d4-f742-47db-bec1-07f52930762b	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:26.454+01	0
e8d04c63-e03e-464b-90e8-593b2cad47c3	6f502148-04b3-438f-be94-0961b34d8747	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:31.046+01	0
5ead26cb-ec75-463f-a27e-eda6437e62a4	0c15d3a1-167e-4524-bf40-37f373d97db2	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:22.269+01	0
083bff08-ca38-407c-a00e-b09643dbbf3b	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:33.518+01	0
4796477d-1e10-44e0-82b0-08a2a637766e	7fe7c776-f958-471c-8946-9eff9b9f98a2	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:43.229+01	0
b0175dfd-f35b-447f-aaa3-ccdcdc06a140	b15e295e-f586-438c-a0a9-12ec6e086168	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:54.965+01	0
3bcd663c-0a41-4368-8a8a-e266c589a9f5	c73494ab-ff4b-4548-b182-d628147ae77f	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:36:05.413+01	0
dc6de326-24b6-4917-8677-038d49b6d29c	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:36:15.645+01	0
dcadfc29-d270-4711-879b-7883b31825be	7e2bc36a-45ba-4273-a607-2e904158e853	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:16.166+01	0
2c9fdc82-9b06-468d-913b-17e6d85c7fc9	5f07451e-7113-4b7c-8976-9e82a471581b	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:21.2+01	0
79f67fe5-14fb-4f0a-bde0-dfea1d064406	63ef0eb1-53a6-4567-b777-3801016cc65e	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:17.35+01	0
67f38fc5-555f-47d9-8fc9-f9084552fdbb	a29e3fc0-e8a0-4f55-95b4-39b622a44248	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:49.902+01	0
03c3106f-d938-4e82-9435-bd772ada9e13	26debf83-b32e-4264-95b8-8daf96c4f07b	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:34:10.734+01	0
97bee5b1-80da-43d4-af20-e285673295c1	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:38.533+01	0
b4241e81-14fe-4b88-81b6-12e8591fa8b9	ee77e006-38a2-470c-9877-78399dcd8371	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:27.189+01	0
4e6fff49-c025-4448-ad6c-ad0a7fbc3232	88a3a83e-c9c2-497f-95bd-801536443895	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:35:06.214+01	0
d19d342a-1ab9-48a2-bad3-cf67407fbd69	63a9496a-9455-4664-beb2-e8e75a7cf043	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 11:36:00.237+01	0
cb4de6cb-7ef8-4def-b694-efbdcc060afb	63a9496a-9455-4664-beb2-e8e75a7cf043	d7ee8c3b-1b8b-4301-92b2-2a46ce2dda1f	5	Eirik Frantzen	2014-01-23 09:23:22.512+01	0
03186ff4-5699-4885-8206-b05cf741df47	5d274f43-07b8-46fd-b2f8-1413ebfa1240	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 12:35:37.028+01	0
9a33b900-4593-4380-a292-c6773a16f3ee	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	\N	2013-11-20 12:35:42.06+01	0
4658aa28-6df9-418b-8902-876009cfef1a	ebad0433-524f-4aed-87dc-3aa2827c173f	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	3	\N	2013-11-20 12:35:48.291+01	0
7069628f-d0dc-4834-b529-a9d08e8e8035	119a2834-bda1-4607-849c-4c25b3f4670f	56504e89-ae03-4169-922a-7d5f0d222ab7	3	\N	2013-11-20 14:46:07.165+01	0
ec252921-3a6c-4464-87cb-17d153d5a9d1	099732f3-6c88-435f-8904-208a547cf218	180780d8-f03f-48e0-b829-88fbbec2a5b2	4	\N	2013-11-21 09:06:32.571+01	0
34def178-3a99-493d-814a-eefec417bedf	2e44fc5b-541d-420b-b0e7-c208bb4f68cc	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	\N	2013-11-15 15:21:59.356+01	0
d74387b8-68a1-44ab-9114-14f36003b96b	b503caae-1400-4e32-87fb-95f43a83e1dd	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	Eirik Frantzen	2013-12-03 14:21:23.485+01	0
23ae525d-1e31-44e3-bc84-d2caaa0be660	b503caae-1400-4e32-87fb-95f43a83e1dd	4f0f380c-e58e-4222-a59b-5ac41c145793	2	Eirik Frantzen	2013-12-03 14:21:33.913+01	0
aac25cdd-f76f-437d-9fa0-f238273e2df0	b503caae-1400-4e32-87fb-95f43a83e1dd	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	3	Eirik Frantzen	2013-12-03 14:22:27.982+01	0
ce834253-7b16-4264-b753-1197e3432468	7e2bc36a-45ba-4273-a607-2e904158e853	8a00261b-42e2-49a3-89b7-ff9efbc31046	5	Eirik Frantzen	2014-01-23 09:25:52.978+01	0
807eb4ca-cd59-4ce5-92d3-4051aefb0755	b503caae-1400-4e32-87fb-95f43a83e1dd	4a642c45-5a91-4c45-801e-f7b1d1302d4b	4	Eirik Frantzen	2013-12-04 13:02:55.299+01	0
d210aa28-11ab-485f-b84b-a14adc9230c7	b503caae-1400-4e32-87fb-95f43a83e1dd	dc59a0e7-7efe-4de8-80a1-576609e8120d	5	Eirik Frantzen	2013-12-04 13:02:55.305+01	0
d9210fe2-adc8-4576-ace1-8e724da2c76e	b503caae-1400-4e32-87fb-95f43a83e1dd	f3b63b5a-9b9f-473e-a165-6a3f537b0989	6	Eirik Frantzen	2013-12-04 13:02:55.306+01	0
c63f2b02-b66a-4360-894e-b5dd71f0ff74	950b1c35-4b6e-4d00-98dd-a3e98f7d86a6	d24e11e9-3766-4836-b313-d3f3027eeafb	5	Eirik Frantzen	2014-01-22 15:53:34.814+01	0
d9c4278a-abe9-4e59-883d-2903f5e92c1c	26debf83-b32e-4264-95b8-8daf96c4f07b	f8ad99aa-d0af-4e67-978a-0786029e47df	5	Eirik Frantzen	2014-01-22 16:13:17.417+01	0
5680ea06-8a51-4b8b-94e6-953daa9def16	5f07451e-7113-4b7c-8976-9e82a471581b	e691abbb-a386-4e5c-86dd-2488e70ad7b9	5	Eirik Frantzen	2014-01-23 09:16:48.002+01	0
4e945992-4ba1-46e9-ad47-ee16b56102e4	5570564c-a7f5-4902-8e24-a8288729e55c	23260e4b-5011-4c6d-b451-93eea4eab395	5	Eirik Frantzen	2014-01-23 09:20:47.079+01	0
c9285953-1a31-408a-b892-28a092955612	63ef0eb1-53a6-4567-b777-3801016cc65e	e691abbb-a386-4e5c-86dd-2488e70ad7b9	5	Eirik Frantzen	2014-01-23 11:07:16.79+01	0
47548b8e-559c-49ab-a7f4-276fbe3fc747	fa3265d4-f742-47db-bec1-07f52930762b	47078b75-dc68-4686-8858-bf6c314549e1	5	Eirik Frantzen	2014-01-23 11:13:21.619+01	0
4a8ff87b-401b-4c17-ae17-5c4885841e06	a146f0d5-1a55-40b6-8a42-fa2a029b76fb	0699f82f-0215-42d6-8b27-a18ff997e1ac	5	Eirik Frantzen	2014-01-23 11:19:10.125+01	0
4339ac82-f20f-49df-92c1-5ffc95f7c320	ee77e006-38a2-470c-9877-78399dcd8371	38aff070-7ba7-48fa-a7d4-afd17153e96c	5	Eirik Frantzen	2014-01-23 11:22:06.484+01	0
a8d29725-0361-4e8a-b94a-7e9bcf868692	7fe7c776-f958-471c-8946-9eff9b9f98a2	c1cee990-2fc3-4ce3-bf44-40eea456d61c	5	Eirik Frantzen	2014-01-23 11:26:50.225+01	0
c3ba23f8-6d9f-4ece-8331-d533014c5d43	879cb62e-1a88-44fb-b064-0fc84ad7ceba	cd279ec8-b22b-406c-a329-45b6a001f42c	5	Eirik Frantzen	2014-01-23 11:31:53.368+01	0
bf75b90a-498f-40c2-a19b-5d3bdda3da48	879cb62e-1a88-44fb-b064-0fc84ad7ceba	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	6	Eirik Frantzen	2014-01-23 11:31:53.371+01	0
d5d4d9f0-2c55-4b75-95b4-5ffd637a7227	879cb62e-1a88-44fb-b064-0fc84ad7ceba	952334af-347d-49d8-a2bf-43849d098639	7	Eirik Frantzen	2014-01-23 11:31:53.372+01	0
fc1d5ade-6f76-4ad6-b8f8-fda86016129e	b076848f-c590-447a-a104-812098a392cc	fe97fd37-171a-4847-9298-6fd420183db8	5	Eirik Frantzen	2014-01-23 11:39:02.08+01	0
2e631a1b-1187-4b05-b71e-1cc24c7a2e9c	abd4023d-9ef8-41c7-ae03-5ada4259f1a1	fe97fd37-171a-4847-9298-6fd420183db8	5	Eirik Frantzen	2014-01-23 11:39:30.146+01	0
3f3d9ef7-4db0-403e-86a5-e11be25fdd6a	0c15d3a1-167e-4524-bf40-37f373d97db2	2bda5f98-9755-4416-a565-08e48c33979d	5	Eirik Frantzen	2014-01-23 11:41:15.4+01	0
e0e325b0-7075-4feb-b10f-49575a9e19e7	6f502148-04b3-438f-be94-0961b34d8747	37c73f0d-59db-4bb9-8f98-08bf38d8d8bf	5	Eirik Frantzen	2014-01-23 12:26:38.549+01	0
7f997ed6-a1a9-46ae-a4f5-44a031b45e1f	88a3a83e-c9c2-497f-95bd-801536443895	45e8a418-0cf2-4a58-a608-c6fc79ac9657	5	Eirik Frantzen	2014-01-23 12:27:59.358+01	0
dbc6a35a-16f7-4427-885e-e6979b7ef4c1	c73494ab-ff4b-4548-b182-d628147ae77f	affbd02c-61e4-44f6-a519-cc1237d653d2	5	Eirik Frantzen	2014-01-23 12:30:22.938+01	0
3706cffe-0050-434a-8a8c-d4e99a18ed12	a29e3fc0-e8a0-4f55-95b4-39b622a44248	7c2c7772-aaa9-415f-9664-5c6b5f2f89ed	5	Eirik Frantzen	2014-01-23 12:33:00.524+01	0
d6b127bf-1084-4c09-afd1-a4b2272ce49c	f6fa77fc-d702-422b-ac68-4d1a62a4f1c1	8cf69fda-cfdb-4981-a66e-cbf0e992583d	5	Eirik Frantzen	2014-01-23 12:35:49.418+01	0
3cea597b-ba95-4969-8077-ab3a758908fe	5d274f43-07b8-46fd-b2f8-1413ebfa1240	9a4479df-b887-46d6-84f2-ebc802a19e3e	5	Eirik Frantzen	2014-01-23 15:06:46.531+01	0
51273978-2ba1-44ef-a546-c21c0d2ce35b	3e802ed5-c39e-411a-9ac0-393bfc9d3c1d	9a4479df-b887-46d6-84f2-ebc802a19e3e	5	Eirik Frantzen	2014-01-23 15:07:02.62+01	0
84790fa0-df85-4054-bf9a-90ce1388db92	b15e295e-f586-438c-a0a9-12ec6e086168	c7ab72ff-2248-45c7-9c6b-1936346cc7d2	5	Eirik Frantzen	2014-01-23 15:09:20.821+01	0
6aa26738-d844-4104-8969-80f8ad5b7976	57e0ba97-1f40-494f-9ce3-efadf52d8b20	53584e38-400d-4905-a563-08e56853f2ec	1	PowerCatch admin	2014-02-18 15:44:46.264+01	0
d4835229-b533-4605-a33d-6713b1de97ae	57e0ba97-1f40-494f-9ce3-efadf52d8b20	8c1026cd-269c-44ba-88a2-25d95d332df8	2	PowerCatch admin	2014-02-18 15:44:46.209+01	0
c9040d4b-9abf-4cf9-90f1-22bb68dde0d0	57e0ba97-1f40-494f-9ce3-efadf52d8b20	f3b63b5a-9b9f-473e-a165-6a3f537b0989	3	PowerCatch admin	2014-02-18 15:44:46.265+01	0
a879660d-ae02-49f8-b07b-7c293a659616	9713e3f0-c8cf-4793-8d53-76fdde10ffa8	53584e38-400d-4905-a563-08e56853f2ec	1	PowerCatch admin	2014-02-18 15:45:47.111+01	0
4899db9f-49f4-4e7e-9cba-3876a7cac7f8	9713e3f0-c8cf-4793-8d53-76fdde10ffa8	5b7e4a0d-2438-4090-9559-923e75659c53	2	PowerCatch admin	2014-02-18 15:45:47.114+01	0
68b94c1e-9eac-4676-b00d-f6f5a68f2550	9713e3f0-c8cf-4793-8d53-76fdde10ffa8	b875b562-b921-42a7-b1fb-b9ff66f123b3	3	PowerCatch admin	2014-02-18 15:45:47.113+01	0
7604dea8-557e-49c3-9ffb-90ca3a2b94bd	9713e3f0-c8cf-4793-8d53-76fdde10ffa8	4eca141c-da35-4935-a05e-8efbae52a929	4	PowerCatch admin	2014-03-15 19:03:55.243+01	0
f795a3a7-255f-4485-a5ea-f4a8fc8af06d	9713e3f0-c8cf-4793-8d53-76fdde10ffa8	8c1026cd-269c-44ba-88a2-25d95d332df8	5	PowerCatch admin	2014-03-15 19:03:55.267+01	0
35a21e3b-3f27-46cd-b986-2a6546a17b5c	9713e3f0-c8cf-4793-8d53-76fdde10ffa8	f3b63b5a-9b9f-473e-a165-6a3f537b0989	6	PowerCatch admin	2014-03-15 19:03:55.273+01	0
19c0f0c1-996b-4605-9d59-54a12609dd85	b1001bac-07d0-47a2-b2ef-9a369edf0baf	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	PowerCatch admin	2014-05-22 16:28:58.922+02	0
6345b00e-c5cc-4fd4-b878-9162f14c7d87	b1001bac-07d0-47a2-b2ef-9a369edf0baf	4f0f380c-e58e-4222-a59b-5ac41c145793	2	PowerCatch admin	2014-05-22 16:28:58.958+02	0
efc2ab10-e290-411b-9d10-99e6297185a3	b1001bac-07d0-47a2-b2ef-9a369edf0baf	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	3	PowerCatch admin	2014-05-22 16:28:58.959+02	0
1e8f0edb-7e9f-487d-8b3f-db55f4897ac2	b1001bac-07d0-47a2-b2ef-9a369edf0baf	f3b63b5a-9b9f-473e-a165-6a3f537b0989	4	PowerCatch admin	2014-05-22 16:28:58.961+02	0
9367e0b5-dca0-43fa-9cac-9e43041b89e5	267a31f1-f8be-48df-a39a-aaf0a9c526ef	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	PowerCatch admin	2014-06-24 10:16:03.175+02	0
6c010aa3-33b4-4ddb-becc-e6067290892f	267a31f1-f8be-48df-a39a-aaf0a9c526ef	f3b63b5a-9b9f-473e-a165-6a3f537b0989	2	PowerCatch admin	2014-06-24 10:16:03.209+02	0
3df173ed-7f7e-49e0-b75c-871d4bda777f	44f77965-cb2c-415c-bfaa-1b5b3fe714ed	335321c9-58d7-4aba-85fc-f208e963fee1	1	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
8b57a4e9-39fd-4926-8888-9623f8cb0888	44f77965-cb2c-415c-bfaa-1b5b3fe714ed	f4b56786-39b2-4c96-baed-e30c297bca0a	2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
447f1bb1-f781-4aeb-ba44-b02dc7da3ed7	44f77965-cb2c-415c-bfaa-1b5b3fe714ed	4f0f380c-e58e-4222-a59b-5ac41c145793	3	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
87e4b8b1-609a-4a4d-8e5f-363a5453887d	44f77965-cb2c-415c-bfaa-1b5b3fe714ed	f3b63b5a-9b9f-473e-a165-6a3f537b0989	4	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
bf4ab9d0-de59-41af-af88-0363213986b0	78a83cf4-e305-422a-9cf9-8eb752333691	f4b56786-39b2-4c96-baed-e30c297bca0a	2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
db1afcf8-1c23-43d3-8f08-c58e0717e54e	78a83cf4-e305-422a-9cf9-8eb752333691	4f0f380c-e58e-4222-a59b-5ac41c145793	3	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
3f738f67-2c8b-4807-ad50-0521811fb31c	78a83cf4-e305-422a-9cf9-8eb752333691	f3b63b5a-9b9f-473e-a165-6a3f537b0989	4	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
d9ecd06b-1e48-44b6-a5ef-05786b913950	d628e7d3-4347-41b0-a113-136f53d8f911	335321c9-58d7-4aba-85fc-f208e963fee1	1	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
86e6e7f9-e0f3-4390-a8ac-aa80ad01ad95	d628e7d3-4347-41b0-a113-136f53d8f911	f4b56786-39b2-4c96-baed-e30c297bca0a	2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
3bc76209-0f7b-4e5f-a286-6d6a50f6faa6	d628e7d3-4347-41b0-a113-136f53d8f911	4f0f380c-e58e-4222-a59b-5ac41c145793	3	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
ad27811e-6cac-4089-9e11-0a48b9807c7c	d628e7d3-4347-41b0-a113-136f53d8f911	f3b63b5a-9b9f-473e-a165-6a3f537b0989	4	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
53eed443-1fd1-4e1f-b961-bfb4d1141680	44f77965-cb2c-415c-bfaa-1b5b3fe714ed	1905badf-c9f9-456c-82ca-4d9f9c6791d0	6	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
7a39b189-014d-4488-bac0-42cd48220f2c	44f77965-cb2c-415c-bfaa-1b5b3fe714ed	ee363b7d-5f24-48e1-8fff-689c4f80d651	7	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
fc26b058-f484-42cf-a390-3a919e201956	78a83cf4-e305-422a-9cf9-8eb752333691	1905badf-c9f9-456c-82ca-4d9f9c6791d0	6	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
48d9c49f-b298-4298-8424-bcae0e8e6a75	78a83cf4-e305-422a-9cf9-8eb752333691	ee363b7d-5f24-48e1-8fff-689c4f80d651	7	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
6ac94866-7dcd-4d30-89e7-e0a140b36f17	44f77965-cb2c-415c-bfaa-1b5b3fe714ed	5b7e4a0d-2438-4090-9559-923e75659c53	5	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
5a70660a-5704-4879-83df-14db33781a27	78a83cf4-e305-422a-9cf9-8eb752333691	5b7e4a0d-2438-4090-9559-923e75659c53	5	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
39aaf26b-f3c5-4970-ae5a-8e095978903c	0a56fb03-a7c3-303f-e053-2f00500a8ad8	f3b63b5a-9b9f-473e-a165-6a3f537b0989	3	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
30bd3a23-bde8-4a52-bbf1-9da8b8a6e913	b75ac7b6-bb6c-4930-93c7-3b05b332de43	f3b63b5a-9b9f-473e-a165-6a3f537b0989	3	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
92bd80ce-1e6b-0570-ce92-e4356d86f494	78a83cf4-e305-422a-9cf9-8eb752333691	03edfc1f-7663-e593-0151-d7a512cab832	3	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
57fb4b35-79f2-4e18-a187-1d92dafd85cb	664881ac-3245-403f-afd8-94ec6a8bf1ce	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	1	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
d5f7e9ea-1079-4160-a592-4f130354251e	664881ac-3245-403f-afd8-94ec6a8bf1ce	4f0f380c-e58e-4222-a59b-5ac41c145793	2	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
78a65757-b531-416b-9579-bcf5e7b1cfd0	664881ac-3245-403f-afd8-94ec6a8bf1ce	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	3	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
68f51438-5fc7-46b4-be0d-bbfd088ba9b3	664881ac-3245-403f-afd8-94ec6a8bf1ce	083bbac1-bafa-40a3-95eb-743b18faefaf	4	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
ab438739-274f-4b9a-93da-84950dd6a955	664881ac-3245-403f-afd8-94ec6a8bf1ce	f3b63b5a-9b9f-473e-a165-6a3f537b0989	5	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
8b0d1df5-ed71-b898-47d8-fd8b1b5385d8	78a83cf4-e305-422a-9cf9-8eb752333691	7dbb5114-e884-3645-daee-ee421bbf4a8b	1	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
\.


--
-- TOC entry 2627 (class 0 OID 27366)
-- Dependencies: 206
-- Data for Name: page; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY page (id, nbr, name, signaturerequired, changed_by, changed_date, deleted, commentpresent) FROM stdin;
f236aef1-f472-4b78-b6b6-1c936dc9a4a0	18	pc.page.description	0	PowerCatch Update Script	2013-11-18 09:08:27.621+01	0	0
4f0f380c-e58e-4222-a59b-5ac41c145793	2	pc.page.documentation	0	PowerCatch Update Script	2013-12-02 14:42:59.419+01	0	0
dc59a0e7-7efe-4de8-80a1-576609e8120d	70	pc.page.operation.protocol	0	PowerCatch Update Script	2013-12-03 14:32:35.024+01	0	0
180780d8-f03f-48e0-b829-88fbbec2a5b2	12	pc.page.isolationcontrol	0	PowerCatch Update Script	2013-11-15 15:18:09.626+01	0	0
a4c268f8-fc3b-4537-acff-a372bee2fddf	57	pc.page.control	0	PowerCatch Update Script	2013-11-19 14:25:23.719+01	0	0
fb8e9224-f278-4f4d-bdf9-7be264d4bc06	65	pc.page.control.two	0	PowerCatch Update Script	2013-11-20 10:37:24.246+01	0	0
d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	63	pc.page.control.after.voltage	0	PowerCatch Update Script	2013-11-20 10:06:03.035+01	0	0
368513d0-172d-43a0-a475-be4f138c7196	62	pc.page.control.before.voltage	0	PowerCatch Update Script	2013-11-20 10:01:25.51+01	0	0
c70c24a8-dd37-4e0b-b5d7-60e241439c82	16	pc.page.control.cord	0	PowerCatch Update Script	2013-11-15 23:43:20.282+01	0	0
d0211769-49ac-4ff1-8aa9-6351899619c4	15	pc.page.control.pole	0	PowerCatch Update Script	2013-11-15 23:43:08.183+01	0	0
6e088fd0-60dc-420d-a23c-2551edd34682	4	pc.page.customer.info	0	PowerCatch Update Script	2013-11-11 09:17:35.697+01	0	0
6c85f93f-777c-46d4-94c2-00168d235977	5	pc.page.measure.equipment	0	PowerCatch Update Script	2013-11-11 09:17:54.685+01	0	0
73ad131a-4752-460c-9798-013282608b26	6	pc.page.new.meter	0	PowerCatch Update Script	2013-11-11 09:18:07.679+01	0	0
4a642c45-5a91-4c45-801e-f7b1d1302d4b	56	pc.page.object.data	0	PowerCatch Update Script	2013-11-19 14:10:24.765+01	0	0
75d13b7a-376f-426a-9e97-58c0c70ab355	3	pc.page.object.info	0	PowerCatch Update Script	2013-11-11 09:17:25.807+01	0	0
56504e89-ae03-4169-922a-7d5f0d222ab7	11	pc.page.object.info	0	PowerCatch Update Script	2013-11-15 15:01:00.78+01	0	0
79619cfe-01de-4cb5-a05c-4a3ed570ffee	1	pc.page.order.info	0	PowerCatch Update Script	2013-11-11 09:16:49.425+01	0	0
ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	10	pc.page.order.info	0	PowerCatch Update Script	2013-11-15 13:26:45.44+01	0	0
61240b23-8f2e-4127-9f52-987092cb9443	22	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-18 12:57:08.694+01	0	0
cbad3998-ccfc-4621-8390-6e16397c6ee9	25	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-18 13:27:18.113+01	0	0
b875b562-b921-42a7-b1fb-b9ff66f123b3	21	pc.page.risk.rating	0	PowerCatch Update Script	2013-11-18 12:38:48.768+01	0	0
db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	14	pc.page.checkpoints	0	PowerCatch Update Script	2013-11-15 22:55:57.719+01	0	0
083bbac1-bafa-40a3-95eb-743b18faefaf	19	pc.page.checkpoints	0	PowerCatch Update Script	2013-11-18 11:11:51.805+01	0	0
8b92c005-2284-48e4-8d71-e34257973349	23	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 12:58:27.437+01	0	0
49b9af3a-6460-41e4-9b18-1e08d7e757e5	24	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 13:17:27.125+01	0	0
2bf172b1-993e-472c-9291-04ddd207c196	26	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 13:34:37.922+01	0	0
5243e759-cca1-4b72-8ea7-2b32a34362f8	28	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 14:06:32.313+01	0	0
17d71398-0fc3-46ff-b40a-96b0fa4c7fd1	30	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 14:23:21.409+01	0	0
f9a03410-e081-4cd8-849d-8e0c8e38f5e9	32	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 14:53:11.89+01	0	0
33e187fc-d4ee-4e14-80f4-e8b852099953	34	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 15:08:14.644+01	0	0
2ba216de-eede-4c1a-96fc-ae0e373de9cb	35	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 15:21:44.942+01	0	0
f33c6af7-0b3a-4fde-8e31-5cd63231cd29	36	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 15:28:29.315+01	0	0
6051a1dc-afd8-40a0-ba6e-9e695be6db82	37	pc.page.final.check	0	PowerCatch Update Script	2013-11-18 15:36:40.879+01	0	0
ad438256-7907-4668-a794-b45a328bb94e	38	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 08:51:01.762+01	0	0
5f1803ef-1936-4e7d-bdcb-267e5c89d8dd	40	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 09:01:48.669+01	0	0
438d2e22-26eb-4022-b7d5-cefd8acd9226	42	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 09:09:37.298+01	0	0
625929e4-43f6-407d-a43f-05604071aa6e	43	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 09:16:58.15+01	0	0
1c078554-eb73-4196-b0dd-10e4d2a27389	45	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 09:30:25.121+01	0	0
e89d4206-ff2f-4756-99b5-e9a1309f98f9	47	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 10:32:57.273+01	0	0
8e053a96-ffaf-49e8-91e6-931858bbe5a8	7	pc.page.execution	0	PowerCatch Update Script	2013-11-11 09:18:16.076+01	0	0
5b7e4a0d-2438-4090-9559-923e75659c53	20	pc.page.workmethod	0	PowerCatch Update Script	2013-11-18 11:30:59.461+01	0	0
f3b63b5a-9b9f-473e-a165-6a3f537b0989	8	pc.page.attachments	0	PowerCatch Update Script	2013-11-11 09:18:25.689+01	0	0
7a4c2032-54d9-469f-9484-e4b8d58b7d3d	68	pc.page.installation.data	0	PowerCatch Update Script	2013-11-27 12:44:43.16+01	0	0
8c1026cd-269c-44ba-88a2-25d95d332df8	93	pc.page.installation.data	0	PowerCatch Update Script	2014-02-18 15:28:22.131+01	0	0
98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	58	pc.page.control	0	PowerCatch Update Script	2013-11-19 15:36:19.433+01	0	0
175ad376-2621-41e7-ad6c-6451d7cedbbf	59	pc.page.control	0	PowerCatch Update Script	2013-11-19 15:46:16.645+01	0	0
d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	60	pc.page.control	0	PowerCatch Update Script	2013-11-19 16:08:32.228+01	0	0
97008f82-e648-4e59-a403-dc7be8df289e	61	pc.page.control	0	PowerCatch Update Script	2013-11-20 09:45:19.924+01	0	0
7243960f-e462-4a79-854f-6d2a83f5da51	64	pc.page.control	0	PowerCatch Update Script	2013-11-20 10:27:03.803+01	0	0
3fcdc058-a3d1-40f0-a645-b4f076ec2a00	66	pc.page.control	0	PowerCatch Update Script	2013-11-15 23:28:43.692+01	0	0
d995e4d5-094b-481b-8817-d09b5320ab03	67	pc.page.control	0	PowerCatch Update Script	2013-11-15 23:54:23.246+01	0	0
07c1c00e-6b14-409a-99ba-d0d887b3f99a	13	pc.page.object.info	0	PowerCatch Update Script	2013-11-15 22:31:29.211+01	0	0
53584e38-400d-4905-a563-08e56853f2ec	92	pc.page.order.info	0	PowerCatch Update Script	2014-02-18 15:24:35.272+01	0	0
c7891240-7441-4af0-ad3f-8942d5f3743a	27	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-18 13:58:02.029+01	0	0
6056d92c-0df0-4c40-ba7a-47755ff6644c	29	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-18 14:15:37.789+01	0	0
12c06ff2-d2b6-4cc9-a3e4-a542c03ad51e	31	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-18 14:27:34.741+01	0	0
1f8b46a4-8da7-4784-9c00-a4ed43fd3798	33	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-18 15:01:03.295+01	0	0
678065f9-dc10-4db4-ba7d-67dd99b39af8	39	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-19 08:54:57.768+01	0	0
caebf2d9-cf37-4e8d-827f-eccc83ebb3c9	41	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-19 09:06:43.211+01	0	0
8449fff6-d59a-4ed8-8d56-93a68eca1e2e	44	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-19 09:23:52.557+01	0	0
de1ad443-157b-43f5-b7a8-ec8b8371c368	46	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-19 10:09:08.747+01	0	0
8f4c9fab-aee9-4031-a3c5-3ef93fb98354	50	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-19 12:57:03.197+01	0	0
b32009d7-2df1-4a11-be50-5603f41b5a20	52	pc.page.register.object.data	0	PowerCatch Update Script	2013-11-19 13:31:17.766+01	0	0
f38be589-b7ad-4803-82aa-045ae26cafa9	48	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 12:39:54.58+01	0	0
ff9c6584-d8be-46a6-b09f-35c1341056ff	49	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 12:48:01.969+01	0	0
631e442f-1532-4086-b15d-0dab83b07e13	51	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 13:27:51.191+01	0	0
3dae6ead-2bec-4956-a262-3fd36f2f7e55	53	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 13:36:00.1+01	0	0
9ba18305-7ce7-4442-8b7c-98a84e93c57b	54	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 13:42:24.673+01	0	0
67f40a38-3ee5-4fad-af99-9f7e324d8eb0	55	pc.page.final.check	0	PowerCatch Update Script	2013-11-19 13:46:12.647+01	0	0
952334af-347d-49d8-a2bf-43849d098639	73	pc.page.final.check	0	PowerCatch Update Script	2014-01-23 08:37:45.028+01	0	0
eb52c2bd-5710-43a9-9772-6545b0ec10f2	17	pc.page.order.info	0	PowerCatch Update Script	2013-11-16 00:46:48.717+01	1	0
b08ca4dd-dc5b-4ec1-8281-ef45d8b25c84	9	pc.page.generic.safety.assessment	0	PowerCatch Update Script	2013-11-11 09:17:46.457+01	0	1
7c2c7772-aaa9-415f-9664-5c6b5f2f89ed	88	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 12:32:06.711+01	0	1
d24e11e9-3766-4836-b313-d3f3027eeafb	71	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-22 15:19:23.918+01	0	1
f8ad99aa-d0af-4e67-978a-0786029e47df	72	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-22 16:11:35.124+01	0	1
e691abbb-a386-4e5c-86dd-2488e70ad7b9	74	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 08:44:28.742+01	0	1
23260e4b-5011-4c6d-b451-93eea4eab395	75	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 09:19:27.357+01	0	1
d7ee8c3b-1b8b-4301-92b2-2a46ce2dda1f	76	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 09:22:36.345+01	0	1
8a00261b-42e2-49a3-89b7-ff9efbc31046	77	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 09:25:09.573+01	0	1
47078b75-dc68-4686-8858-bf6c314549e1	78	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:11:54.175+01	0	1
0699f82f-0215-42d6-8b27-a18ff997e1ac	79	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:17:54.568+01	0	1
38aff070-7ba7-48fa-a7d4-afd17153e96c	80	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:20:59.676+01	0	1
c1cee990-2fc3-4ce3-bf44-40eea456d61c	81	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:25:30.556+01	0	1
cd279ec8-b22b-406c-a329-45b6a001f42c	82	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:29:07.578+01	0	1
37c73f0d-59db-4bb9-8f98-08bf38d8d8bf	83	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:33:03.596+01	0	1
fe97fd37-171a-4847-9298-6fd420183db8	84	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:36:45.55+01	0	1
2bda5f98-9755-4416-a565-08e48c33979d	85	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 11:40:36.975+01	0	1
45e8a418-0cf2-4a58-a608-c6fc79ac9657	86	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 12:23:47.117+01	0	1
affbd02c-61e4-44f6-a519-cc1237d653d2	87	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 12:28:57.766+01	0	1
8cf69fda-cfdb-4981-a66e-cbf0e992583d	89	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 12:33:45.892+01	0	1
9a4479df-b887-46d6-84f2-ebc802a19e3e	90	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 15:04:40.695+01	0	1
c7ab72ff-2248-45c7-9c6b-1936346cc7d2	91	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-01-23 15:08:36.355+01	0	1
4eca141c-da35-4935-a05e-8efbae52a929	94	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2014-03-15 19:03:07.479+01	0	1
335321c9-58d7-4aba-85fc-f208e963fee1	95	pc.page.order.info	\N	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	0
ee363b7d-5f24-48e1-8fff-689c4f80d651	98	pc.page.final.check	\N	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	0
bad058c4-7f57-4dcd-ab59-65e15a36e691	104	pc.page.edit.documentation	\N	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	0
f4b56786-39b2-4c96-baed-e30c297bca0a	96	pc.page.installation.data	\N	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	0
03edfc1f-7663-e593-0151-d7a512cab832	102	pc.page.object.data	\N	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0	0
1905badf-c9f9-456c-82ca-4d9f9c6791d0	97	pc.page.generic.safety.assessment	1	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0	1
7dbb5114-e884-3645-daee-ee421bbf4a8b	105	pc.page.order.info	\N	PowerCatch Update Script 2.3.0.3	2016-11-01 12:57:38.46+01	0	0
\.


--
-- TOC entry 2628 (class 0 OID 27373)
-- Dependencies: 207
-- Data for Name: page_fieldproperty; Type: TABLE DATA; Schema: konfigurasjon; Owner: powercatch
--

COPY page_fieldproperty (id, id_page, id_fieldproperty, sortorder, changed_by, changed_date, deleted) FROM stdin;
499a0f44-4c6a-4272-bdb8-91f49f5381ea	79619cfe-01de-4cb5-a05c-4a3ed570ffee	15aadd9c-611b-44da-9525-c01029a583ea	1	\N	2013-11-15 10:48:03.107+01	0
87f83c6c-181b-478c-b1d7-edc081349a1e	79619cfe-01de-4cb5-a05c-4a3ed570ffee	4a019e67-69be-4a0a-82f3-5ac65780db35	2	\N	2013-11-15 10:48:03.107+01	0
79130cf3-d25f-44ea-a3fc-66dafd2d0d8a	79619cfe-01de-4cb5-a05c-4a3ed570ffee	71f25906-c204-432c-a38c-be73d09be9da	3	\N	2013-11-15 10:48:03.107+01	0
68c168bb-111e-4186-ac71-c54461c48a74	79619cfe-01de-4cb5-a05c-4a3ed570ffee	2c44e699-173c-4091-9a5c-873e459618a3	4	\N	2013-11-15 10:48:03.107+01	0
f29fd2e0-f21e-4158-95ef-b9eb89f92dfc	79619cfe-01de-4cb5-a05c-4a3ed570ffee	549ab99d-d4a4-4454-a418-deb6d3423f8b	5	\N	2013-11-15 10:48:03.107+01	0
2c627da5-5167-4382-97cd-a3f881b9945f	79619cfe-01de-4cb5-a05c-4a3ed570ffee	f06c52cc-cc5e-480b-9696-3c76dfb55cf8	6	\N	2013-11-15 10:48:03.107+01	0
bdba9c5e-c562-477a-b7f0-c5403ffb102d	79619cfe-01de-4cb5-a05c-4a3ed570ffee	d11aa057-050d-4673-a5b3-43244be6a0a0	7	\N	2013-11-15 10:48:03.107+01	0
69fd3bda-1928-4c28-9f2e-5844dee2b0f2	75d13b7a-376f-426a-9e97-58c0c70ab355	a3f60254-6ed4-4a17-94bc-86d080abd3d1	1	\N	2013-11-15 10:48:03.107+01	0
d4513158-01e7-44d5-ac97-06d89da77f00	75d13b7a-376f-426a-9e97-58c0c70ab355	97594e2d-e0ab-4338-ac33-a8bcacf2f26c	2	\N	2013-11-15 10:48:03.107+01	0
892930af-8522-4806-8058-b54a48bf091e	75d13b7a-376f-426a-9e97-58c0c70ab355	9d0c6cea-3bfc-4680-b862-5f03e2d77f46	3	\N	2013-11-15 10:48:03.107+01	0
175bc79e-6a0f-4137-bd49-0b954e52a88c	75d13b7a-376f-426a-9e97-58c0c70ab355	9b1854a1-25c2-4716-a8ee-9ebbcd3c4b9f	4	\N	2013-11-15 10:48:03.107+01	0
29232966-f756-4b89-983e-217a49484d7a	75d13b7a-376f-426a-9e97-58c0c70ab355	c30fbbfa-c9ce-4fc2-8380-148a59572f59	5	\N	2013-11-15 10:48:03.107+01	0
1fb7c407-6763-4e55-9d04-34a487b17975	75d13b7a-376f-426a-9e97-58c0c70ab355	7a2edd9d-20f7-4213-b9c6-bbedcfa20b0c	6	\N	2013-11-15 10:48:03.107+01	0
768298df-fc40-4c33-9bf0-e460a839f5ce	75d13b7a-376f-426a-9e97-58c0c70ab355	18de1c08-3c4c-4f4f-a5ed-4d93a454e617	7	\N	2013-11-15 10:48:03.107+01	0
a84edac0-de3f-4173-a94a-ca61acc9ae9c	6e088fd0-60dc-420d-a23c-2551edd34682	b1de6368-e72b-4db6-8d7d-9a88b5dae3d0	1	\N	2013-11-15 10:48:03.107+01	0
c43cac6d-d286-48da-879e-aedfdafdd71c	6e088fd0-60dc-420d-a23c-2551edd34682	90fca990-9c3c-40fc-9b9f-b091cc60220b	2	\N	2013-11-15 10:48:03.107+01	0
c2f69cfc-ddc0-4202-b58f-2fad19c701f8	6e088fd0-60dc-420d-a23c-2551edd34682	55254909-80a4-44a3-b5f5-4339413e6b27	3	\N	2013-11-15 10:48:03.107+01	0
825570d9-1dc7-4061-9107-81deaf641478	6e088fd0-60dc-420d-a23c-2551edd34682	abbcbe8c-d6f3-41da-bca4-810eee92b16f	4	\N	2013-11-15 10:48:03.107+01	0
198cc42b-753e-4db7-85fb-36ad0f4999cb	b08ca4dd-dc5b-4ec1-8281-ef45d8b25c84	0993a9b3-0e64-4ce4-88fa-bcb2610a884b	1	\N	2013-11-15 10:48:03.107+01	0
953781a2-c082-4ff9-b1dc-8583056326b3	b08ca4dd-dc5b-4ec1-8281-ef45d8b25c84	60bf3710-a94d-4c79-8cce-81c477623c3a	2	\N	2013-11-15 10:48:03.107+01	0
36f22893-c20a-43d3-bfd2-a361c71fad48	b08ca4dd-dc5b-4ec1-8281-ef45d8b25c84	044e035f-8b8b-4f4c-b742-f1cc0d7805f9	3	\N	2013-11-15 10:48:03.107+01	0
cb8eabdb-c4f7-4621-95e3-b16c9d4c0827	6c85f93f-777c-46d4-94c2-00168d235977	325bf757-479e-4953-a96b-82a268c2efa7	1	\N	2013-11-15 10:48:03.107+01	0
1efe8225-b482-441a-ba3c-49087618dca8	6c85f93f-777c-46d4-94c2-00168d235977	f21df6fb-f0fd-4515-b649-b999d49ca93e	2	\N	2013-11-15 10:48:03.107+01	0
0eed6ed4-0acc-4a88-aafb-310f72ac276a	6c85f93f-777c-46d4-94c2-00168d235977	f7ef9514-d203-4c34-8afb-b3ff54590b44	3	\N	2013-11-15 10:48:03.107+01	0
bbc9ea02-8a9a-4a39-a9cb-3d62ae1aa4a1	6c85f93f-777c-46d4-94c2-00168d235977	e56876d2-fcc3-4965-92ec-ad843915cba3	4	\N	2013-11-15 10:48:03.107+01	0
2e961003-565b-4814-b820-495c6b1bf4dd	6c85f93f-777c-46d4-94c2-00168d235977	ffa88b48-a6c6-472d-89ce-3f3d0efbf562	5	\N	2013-11-15 10:48:03.107+01	0
c6be74c7-94ed-4e83-b3d9-77d652e96d65	6c85f93f-777c-46d4-94c2-00168d235977	b83d7ceb-5ad3-45f0-b83a-adee76ef99d3	6	\N	2013-11-15 10:48:03.107+01	0
90a7b29d-616b-435b-a89b-b7318ad59e63	6c85f93f-777c-46d4-94c2-00168d235977	5f27b427-8682-427e-bcbe-38468e01f4db	7	\N	2013-11-15 10:48:03.107+01	0
b8b32dc8-74ae-482e-8c38-629e17500aad	6c85f93f-777c-46d4-94c2-00168d235977	0fe17d8a-feaa-4510-9722-e9b62e232f32	8	\N	2013-11-15 10:48:03.107+01	0
0b45eea0-f6c5-4424-a574-2776f7f9c9fa	6c85f93f-777c-46d4-94c2-00168d235977	eb95c00f-149a-4923-bb17-a9bff8f09c28	9	\N	2013-11-15 10:48:03.107+01	0
de593161-f9d7-4443-85d2-69dc3f28e6b9	6c85f93f-777c-46d4-94c2-00168d235977	7589fd27-d5c0-43b1-9c59-2a32c1e04a96	10	\N	2013-11-15 10:48:03.107+01	0
9aaad6a8-65c6-4f0e-8960-18fe8d9e7fef	6c85f93f-777c-46d4-94c2-00168d235977	b1d16c74-5ab5-469c-bcdf-70c19f92a58f	11	\N	2013-11-15 10:48:03.107+01	0
e0e0d7bb-c9b1-40c0-b54d-fbaa014b75a0	6c85f93f-777c-46d4-94c2-00168d235977	42149447-cd81-4afb-8d1b-e6ab60e878c1	12	\N	2013-11-15 10:48:03.107+01	0
4269571f-5512-4989-94ba-353120008dab	6c85f93f-777c-46d4-94c2-00168d235977	650e0111-4952-4918-97c6-748d4fe09af8	13	\N	2013-11-15 10:48:03.107+01	0
ddab2e07-2e1d-41ce-a9c2-e84a17d59caf	6c85f93f-777c-46d4-94c2-00168d235977	78787420-ebfb-45ea-8907-548e4843bd34	14	\N	2013-11-15 10:48:03.107+01	0
c8305121-fcab-467a-838c-f178c792eed1	73ad131a-4752-460c-9798-013282608b26	4915aafc-4cc3-4a73-abfc-b75f9a7c83b0	1	\N	2013-11-15 10:48:03.107+01	0
4b6fbe8b-27eb-4aa7-b0f8-6ca4076f5bc0	73ad131a-4752-460c-9798-013282608b26	bd639d5b-ac8f-4048-9407-1339204502de	2	\N	2013-11-15 10:48:03.107+01	0
fcedeb9d-8ed1-4da8-946b-e56a24822c44	73ad131a-4752-460c-9798-013282608b26	bb8f38be-b932-4535-8d47-865cf259f16b	3	\N	2013-11-15 10:48:03.107+01	0
dc24f972-f107-459e-bdd9-fdfc385643d4	73ad131a-4752-460c-9798-013282608b26	64950977-4d03-4ff6-9a33-b6527c145021	4	\N	2013-11-15 10:48:03.107+01	0
fbd11a08-d7be-4649-8be0-908b65cabe8a	73ad131a-4752-460c-9798-013282608b26	99633213-6308-47b3-b1e4-b0a9e50699ea	5	\N	2013-11-15 10:48:03.107+01	0
e6b95302-4caf-4034-972c-91abd0da3ac0	73ad131a-4752-460c-9798-013282608b26	60716744-b2ad-4327-9b71-1989e5815973	6	\N	2013-11-15 10:48:03.107+01	0
1098ce31-8a5d-4a00-b17b-6db5712dd5eb	73ad131a-4752-460c-9798-013282608b26	2c0a43a5-9b24-46d8-87b4-20aa4d350da8	7	\N	2013-11-15 10:48:03.107+01	0
3365b5ca-2eb1-42aa-9852-5cd497af0c66	73ad131a-4752-460c-9798-013282608b26	3cc64e62-a979-43ef-aa09-030b31cf7831	8	\N	2013-11-15 10:48:03.107+01	0
c67cdf4a-9816-4598-9b91-ee6f3ba8c679	73ad131a-4752-460c-9798-013282608b26	911c6d03-8e9b-44d8-aa33-3ec1bf3510dd	9	\N	2013-11-15 10:48:03.107+01	0
0ffb8e3a-a17a-46df-9bed-6005b6aaa8fa	73ad131a-4752-460c-9798-013282608b26	e0fb40e1-2ad6-47d3-add7-edf4a422290c	10	\N	2013-11-15 10:48:03.107+01	0
28e65621-a0d3-4a8b-9e98-373b5d19bede	73ad131a-4752-460c-9798-013282608b26	cac3b0be-b8a3-4713-ba46-d64381151ea7	11	\N	2013-11-15 10:48:03.107+01	0
8793173a-c8dd-47d6-b62e-5f888319e395	8e053a96-ffaf-49e8-91e6-931858bbe5a8	006041b0-56a6-4c4f-b21d-99f2e3df4589	1	\N	2013-11-15 10:48:03.107+01	0
764e5441-39b3-4ac3-8d07-dc91f5ec5102	8e053a96-ffaf-49e8-91e6-931858bbe5a8	de94ce8f-2966-4b8c-9837-130e7b2e5766	2	\N	2013-11-15 10:48:03.107+01	0
8197be59-7fb5-4c8a-8450-1a1731ae4b58	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	15aadd9c-611b-44da-9525-c01029a583ea	1	\N	2013-11-15 14:42:34.19+01	0
f02e73ed-af62-4882-8f5d-a1f2805c1817	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	4a019e67-69be-4a0a-82f3-5ac65780db35	2	\N	2013-11-15 14:52:47.208+01	0
2b2d792c-f752-4cd8-842c-32dd7c88caad	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	45fca5ff-c819-4745-8ffe-668ea1cf852e	3	\N	2013-11-15 14:52:47.208+01	0
284a0669-ff9d-4c84-89fe-6bbfef0a10a9	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	2c44e699-173c-4091-9a5c-873e459618a3	4	\N	2013-11-15 14:52:47.208+01	0
3c77b6c0-621e-41fc-8920-6bd1c411ae63	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	549ab99d-d4a4-4454-a418-deb6d3423f8b	5	\N	2013-11-15 14:52:47.208+01	0
04fde077-673f-49b0-9643-c31b94a3e1d4	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	f06c52cc-cc5e-480b-9696-3c76dfb55cf8	6	\N	2013-11-15 14:52:47.208+01	0
4ef59ad1-fd73-423d-97ef-1cd851dc3110	ef68dbb8-fe8e-4e52-b3d9-f252550c2a0e	d11aa057-050d-4673-a5b3-43244be6a0a0	7	\N	2013-11-15 14:52:47.208+01	0
5ef71a40-191a-49dc-adc1-799dbf425cc2	56504e89-ae03-4169-922a-7d5f0d222ab7	a3f60254-6ed4-4a17-94bc-86d080abd3d1	1	\N	2013-11-15 15:17:21.702+01	0
1a636749-d393-4b1e-abb2-56bc642ae3ac	56504e89-ae03-4169-922a-7d5f0d222ab7	f7170f93-75f0-4422-8a45-1d3ebb17fb34	2	\N	2013-11-15 15:17:21.702+01	0
12a82ed9-ea5a-42e3-83b6-dba588e57560	56504e89-ae03-4169-922a-7d5f0d222ab7	1344ca85-aef8-4588-bb68-5bfa3c4831e5	3	\N	2013-11-15 15:17:21.702+01	0
cccf82e1-ca08-4112-a9bf-e443d81ab534	56504e89-ae03-4169-922a-7d5f0d222ab7	dfd4fa2c-daf5-4b61-92d6-ffba87778310	4	\N	2013-11-15 15:17:21.702+01	0
6cfefe30-1e85-4f20-81a9-cf1604eab301	56504e89-ae03-4169-922a-7d5f0d222ab7	18de1c08-3c4c-4f4f-a5ed-4d93a454e617	5	\N	2013-11-15 15:17:21.702+01	0
0a40157a-f2d6-45cb-a261-52578c8910e5	56504e89-ae03-4169-922a-7d5f0d222ab7	d9583663-fe88-4aa8-8fa3-83236959e238	6	\N	2013-11-15 15:17:21.702+01	0
50a6b8f7-1a3e-4e0d-939a-c931437ceb6e	56504e89-ae03-4169-922a-7d5f0d222ab7	daedcc99-3e82-4e31-82e9-478220735fd3	7	\N	2013-11-15 15:17:21.702+01	0
4a2b4156-bf3a-42bb-8996-a1a409443400	56504e89-ae03-4169-922a-7d5f0d222ab7	c30fbbfa-c9ce-4fc2-8380-148a59572f59	8	\N	2013-11-15 15:17:21.702+01	0
a4d0e54b-2d9b-4102-b7d5-80992e921e7f	180780d8-f03f-48e0-b829-88fbbec2a5b2	25a356dd-5147-42f7-a8a9-2d4564861c38	2	\N	2013-11-15 22:04:47.435+01	0
8a06e595-13a2-4774-9ab0-dd89fe4617da	180780d8-f03f-48e0-b829-88fbbec2a5b2	b58cf0ba-2c8b-4acb-81e8-1ccc9af23950	3	\N	2013-11-15 22:04:47.435+01	0
8de9f15d-8695-4485-bfae-81d71e5a100a	180780d8-f03f-48e0-b829-88fbbec2a5b2	1db62648-46f5-4b2c-838b-93007359a7d8	4	\N	2013-11-15 22:04:47.435+01	0
08a19ac7-d00b-432c-9f23-38e1433ac228	180780d8-f03f-48e0-b829-88fbbec2a5b2	9ed38125-d90f-4c06-bb27-0e1ce4dbce1b	5	\N	2013-11-15 22:04:47.435+01	0
8b962c2e-e1cd-417f-8a6a-4297f8cfaac3	180780d8-f03f-48e0-b829-88fbbec2a5b2	c5389313-661f-47cc-9116-d319e324735d	6	\N	2013-11-15 22:04:47.435+01	0
e55aaab1-55e0-485e-8104-df3abf49511f	180780d8-f03f-48e0-b829-88fbbec2a5b2	0cea6818-f24a-454b-b405-7fc24059f847	7	\N	2013-11-15 22:04:47.435+01	0
8f29284d-5526-4225-89ce-6414ad07ca52	180780d8-f03f-48e0-b829-88fbbec2a5b2	18cf003a-b2b7-46fb-97f8-e441c1485c2f	8	\N	2013-11-15 22:04:47.435+01	0
d797eaa5-7b5f-4c51-b8fe-1d8aab03bf69	180780d8-f03f-48e0-b829-88fbbec2a5b2	e4786a68-136d-4dea-ae8e-e4a9895fc261	9	\N	2013-11-15 22:04:47.435+01	0
12dbea5a-5443-414c-a7ae-52d20b7d1cb5	180780d8-f03f-48e0-b829-88fbbec2a5b2	4d562f4c-0989-4bb0-a2ed-2f5ea8c88afc	10	\N	2013-11-15 22:04:47.435+01	0
df7dd73e-62e5-4ea7-b6c6-d283b7e06500	180780d8-f03f-48e0-b829-88fbbec2a5b2	e62bfa27-3e51-42a3-b55c-7e76ba52727f	11	\N	2013-11-15 22:04:47.435+01	0
3a3f0aed-48b3-4014-b74d-67855f0c5f7b	180780d8-f03f-48e0-b829-88fbbec2a5b2	2b7f98ae-eb58-4df0-836e-3fb25d48a86d	12	\N	2013-11-15 22:04:47.435+01	0
c996d4da-33f3-4ef9-80bf-d1eca6965ccc	180780d8-f03f-48e0-b829-88fbbec2a5b2	27e343fd-300b-4046-840d-9b9d25dfda72	1	\N	2013-11-15 22:04:47.435+01	0
939c897a-19ae-4a4b-b928-6a2c75cefa0b	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	4a019e67-69be-4a0a-82f3-5ac65780db35	2	Eirik Frantzen	2013-11-30 00:24:35.508+01	0
22316677-43a9-462b-8db2-55303f0744d3	083bbac1-bafa-40a3-95eb-743b18faefaf	546d93ad-7427-47cb-aa46-16fa77668bd3	1	\N	2013-11-18 11:24:40.533+01	0
4bc4f71b-317c-4fd1-9e93-dcf1443d542a	083bbac1-bafa-40a3-95eb-743b18faefaf	2905fd62-1d92-453a-bd49-91dcc60a1a0a	2	\N	2013-11-18 11:24:40.533+01	0
e985ff73-4ad1-4835-97a0-aa5d51438811	083bbac1-bafa-40a3-95eb-743b18faefaf	e1491b53-8460-482e-8652-deca2e891dbb	3	\N	2013-11-18 11:24:40.533+01	0
d5afc958-e068-490a-87b2-5c77854f10e3	083bbac1-bafa-40a3-95eb-743b18faefaf	e23cddfe-e31d-411a-8af9-f94e17371d8f	4	\N	2013-11-18 11:24:40.533+01	0
56481d99-2370-486e-b8b2-c2cb52902ea8	083bbac1-bafa-40a3-95eb-743b18faefaf	d504721d-a016-4fc0-9bad-491fa96180e4	5	\N	2013-11-18 11:24:40.533+01	0
5ed189b8-a8da-4b28-8fdd-49f1def260e8	083bbac1-bafa-40a3-95eb-743b18faefaf	fdb3d49b-fb03-4ab1-80c3-b9ddf52ae1d8	6	\N	2013-11-18 11:24:40.533+01	0
ca7fe41d-cce9-4f54-abc7-6db0014193e7	5b7e4a0d-2438-4090-9559-923e75659c53	19836408-8571-4638-9782-d7d7fe48b310	1	\N	2013-11-18 12:36:55.39+01	0
7b539b0c-2a6a-431e-ae15-f50aa73f9d19	5b7e4a0d-2438-4090-9559-923e75659c53	1e34f253-ece4-494f-81a6-27f03f8c2762	2	\N	2013-11-18 12:36:55.39+01	0
4485b82d-27d0-4a1a-9ced-95bcfb838634	5b7e4a0d-2438-4090-9559-923e75659c53	ca2b5c12-399f-4f0c-ba81-7abdec204c00	3	\N	2013-11-18 12:36:55.39+01	0
1981dede-a848-48cc-85f3-2014e8ffd978	5b7e4a0d-2438-4090-9559-923e75659c53	442076d2-52a2-4c39-82fd-fec7dc7ac563	4	\N	2013-11-18 12:36:55.39+01	0
e46f0d96-b71a-4c4c-b3d9-1dba1eb97a30	b875b562-b921-42a7-b1fb-b9ff66f123b3	33f7eb2b-feee-433c-93c8-8a8c36fe0275	1	\N	2013-11-18 12:49:16.53+01	0
53fa6114-bcef-46a3-b222-39910a505a3a	b875b562-b921-42a7-b1fb-b9ff66f123b3	e1435163-eff6-4b9b-9b45-6164242bab0a	2	\N	2013-11-18 12:49:16.53+01	0
bf601069-e093-4289-9b3e-1245768ee080	b875b562-b921-42a7-b1fb-b9ff66f123b3	d9ecb0a3-3d10-4bc3-9c87-a365b7be3081	3	\N	2013-11-18 12:49:16.53+01	0
e6fa5bd2-86f8-42dd-8f5b-215ac8e86310	b875b562-b921-42a7-b1fb-b9ff66f123b3	4287c627-fa36-43e2-a165-327632a93c8d	4	\N	2013-11-18 12:49:16.53+01	0
aff89939-6a82-49bf-93b0-1e2798280783	b875b562-b921-42a7-b1fb-b9ff66f123b3	5ad9bb16-82e9-480c-abff-794acba9cbff	5	\N	2013-11-18 12:49:16.53+01	0
4a261414-82b8-433b-8aa6-8967f0909614	b875b562-b921-42a7-b1fb-b9ff66f123b3	c1c870bf-d359-4b3c-b0a1-b3f5d5adb13a	6	\N	2013-11-18 12:49:16.53+01	0
f9386b61-1707-4ff8-be77-3938f96151c9	b875b562-b921-42a7-b1fb-b9ff66f123b3	21ab6a04-591f-418c-bfd7-f6be119b6baa	7	\N	2013-11-18 12:49:16.53+01	0
26b86d86-be9e-4747-adbd-97dfbd84caa3	b875b562-b921-42a7-b1fb-b9ff66f123b3	9b4c4430-59ec-44a3-9b78-f90c2ff6adf4	8	\N	2013-11-18 12:49:16.53+01	0
69c68be8-622b-48a7-809e-03dada85a76c	61240b23-8f2e-4127-9f52-987092cb9443	938173c1-d837-4901-a3be-c1d3d33fa527	1	\N	2013-11-18 13:06:21.209+01	0
3b2b28cc-bd51-492a-b60c-3d76cb2f6d5d	61240b23-8f2e-4127-9f52-987092cb9443	b8db2c5c-1fff-4fef-aacb-f7b752522634	2	\N	2013-11-18 13:06:21.209+01	0
910765b8-a5ca-4b9e-b683-de2c600ac503	61240b23-8f2e-4127-9f52-987092cb9443	38b7181e-196d-433f-8c26-cccb6d6e2150	3	\N	2013-11-18 13:06:21.209+01	0
698327b0-f2b0-46a4-b8f1-67bcc2b9e335	8b92c005-2284-48e4-8d71-e34257973349	26ef6d77-7ba6-48d4-92aa-f5f8d53d2e2f	1	\N	2013-11-18 13:09:04.105+01	0
3235f78f-9f0c-4a0a-811a-449b7af48c51	49b9af3a-6460-41e4-9b18-1e08d7e757e5	8b29cf79-4509-4cca-adff-01a1f7158e1c	1	\N	2013-11-18 13:20:25.209+01	0
f77299d6-8bc8-47a4-b86f-796b75b8bf13	cbad3998-ccfc-4621-8390-6e16397c6ee9	938173c1-d837-4901-a3be-c1d3d33fa527	1	\N	2013-11-18 13:30:37.482+01	0
c6513f30-2235-44c0-90af-65c2396c16b6	cbad3998-ccfc-4621-8390-6e16397c6ee9	c42664c1-3453-4881-8f38-887566d1609c	2	\N	2013-11-18 13:31:38.953+01	0
de9aeb3a-71ce-4b37-9344-cfe5e39e5d28	2bf172b1-993e-472c-9291-04ddd207c196	17286d7b-6e7a-4daa-b3a9-dabfe38aa259	1	\N	2013-11-18 13:42:04.955+01	0
abad757c-6c62-4631-b238-aa8b8fb4fe94	c7891240-7441-4af0-ad3f-8942d5f3743a	414abb1b-3235-4521-bd7d-a53081f0137f	1	\N	2013-11-18 14:02:25.781+01	0
e800b3bb-2511-48a5-8987-6012e8bb64c9	c7891240-7441-4af0-ad3f-8942d5f3743a	25739f18-ead3-4bb8-be4a-6d985a3916cf	2	\N	2013-11-18 14:02:37.96+01	0
ce671ace-bf4a-48ab-8628-29fa95c30f3e	c7891240-7441-4af0-ad3f-8942d5f3743a	23827785-926b-44e1-8619-05b69c8433ca	3	\N	2013-11-18 14:02:47.695+01	0
21cb039f-0a7f-4862-80a8-da3335150c99	c7891240-7441-4af0-ad3f-8942d5f3743a	35f91513-97e9-41ee-bcb6-3ab6eb8b1142	4	\N	2013-11-18 14:02:56.298+01	0
bf8ed8b2-5b60-4895-8580-93e114677ef8	5243e759-cca1-4b72-8ea7-2b32a34362f8	1cacb95d-6ab0-41a7-b473-67a9ba2aafb5	1	\N	2013-11-18 14:10:35.373+01	0
363a40a4-d1bc-4ec3-91f2-67145ed50d81	6056d92c-0df0-4c40-ba7a-47755ff6644c	939841e5-57ad-48f3-b972-7c8ace6a0e76	1	\N	2013-11-18 14:20:11.725+01	0
407025dc-60e3-4050-85f9-36e313121961	6056d92c-0df0-4c40-ba7a-47755ff6644c	f691c37e-be06-4f16-abd6-5faa75e8a8c7	2	\N	2013-11-18 14:20:23.587+01	0
a312e511-c6d0-4776-bae4-6cb0c22d0841	6056d92c-0df0-4c40-ba7a-47755ff6644c	2b529692-ff92-4258-9821-b5eabc4f09e3	3	\N	2013-11-18 14:20:31.069+01	0
f5565211-d4d1-4753-a21c-084faeb66bce	6056d92c-0df0-4c40-ba7a-47755ff6644c	38b7181e-196d-433f-8c26-cccb6d6e2150	4	\N	2013-11-18 14:20:37.954+01	0
7ecbbdb8-1208-496a-ae6f-aaf2f2a37728	17d71398-0fc3-46ff-b40a-96b0fa4c7fd1	23f5fc88-cae8-452a-b973-0bd70b57847a	1	\N	2013-11-18 14:23:06.616+01	0
8e5c2605-c633-43e6-a437-f0b7eac851de	12c06ff2-d2b6-4cc9-a3e4-a542c03ad51e	b0fba0a8-958b-4738-a2fa-588eec9ec6ef	1	\N	2013-11-18 14:50:08.256+01	0
5f612dd6-af38-4d95-a2c5-e51266ee49a7	12c06ff2-d2b6-4cc9-a3e4-a542c03ad51e	5eddabca-d49b-4cf1-be3d-3ac9702ad19d	2	\N	2013-11-18 14:50:23.87+01	0
a594d0ec-9e04-432a-9767-6664920aca23	12c06ff2-d2b6-4cc9-a3e4-a542c03ad51e	32525d9f-611c-4a75-8f86-8bc2441dc2fa	3	\N	2013-11-18 14:50:35.806+01	0
b1dd7f2a-8043-4a35-9215-e811fd83d6d5	f9a03410-e081-4cd8-849d-8e0c8e38f5e9	3ee93ee1-356c-4b53-bc75-8e43ca2f1716	1	\N	2013-11-18 14:52:56.098+01	0
2fe2378f-8f2d-408e-ab26-9d32bd761ce2	1f8b46a4-8da7-4784-9c00-a4ed43fd3798	26714acc-8121-4588-98b9-afed8d586ee4	1	\N	2013-11-18 15:05:04.533+01	0
a8b0cd9d-c8f2-4d55-bed3-5719f2c2fc4e	1f8b46a4-8da7-4784-9c00-a4ed43fd3798	c42664c1-3453-4881-8f38-887566d1609c	2	\N	2013-11-18 15:05:11.117+01	0
89e78c67-ff64-496c-bf0a-1acb5d4538ba	1f8b46a4-8da7-4784-9c00-a4ed43fd3798	5262e721-f37d-48f2-99ef-9009e126707e	3	\N	2013-11-18 15:05:20.509+01	0
a624e359-2411-46e9-8de0-b2b66dc5bd79	1f8b46a4-8da7-4784-9c00-a4ed43fd3798	e2285c5e-375d-4316-8010-8d1079dfa550	4	\N	2013-11-18 15:05:29.668+01	0
c6630f42-fcf7-483e-aaeb-8680fedada68	33e187fc-d4ee-4e14-80f4-e8b852099953	8da690e3-bcdb-4044-ab7e-9da28bf61ff7	1	\N	2013-11-18 15:11:00.058+01	0
6475fd6f-eaa8-4113-a4d8-5135f11cb036	2ba216de-eede-4c1a-96fc-ae0e373de9cb	bf7c2d4f-621f-451b-b00a-d2e37ed5fda5	1	\N	2013-11-18 15:21:28.038+01	0
ad5fe3e6-54db-4549-8f7e-97d32cc2f068	f33c6af7-0b3a-4fde-8e31-5cd63231cd29	5c4913f5-c737-4fbf-bd35-f417ddf8cd22	1	\N	2013-11-18 15:28:38.427+01	0
266c61ec-cc94-4a90-afac-6d94ff495ae3	6051a1dc-afd8-40a0-ba6e-9e695be6db82	e765e972-0db5-4c8b-8d99-2c9f09f12b1e	1	\N	2013-11-18 15:36:51.408+01	0
7bee07a6-9de9-4884-a7ac-0490af123a06	ad438256-7907-4668-a794-b45a328bb94e	3578745a-5b85-4ac0-88c1-216300c8c994	1	\N	2013-11-19 08:51:15.794+01	0
12f6f9ed-0027-4e59-9a64-6532f6b2d0e7	678065f9-dc10-4db4-ba7d-67dd99b39af8	27ab1720-a951-4ebe-9642-221a99183c6c	1	\N	2013-11-19 08:57:19.086+01	0
4852b426-2347-4b45-b32b-19bc8a2720ad	678065f9-dc10-4db4-ba7d-67dd99b39af8	9a227dd4-4627-4fc4-952f-b31e0cc73786	2	\N	2013-11-19 08:57:29.159+01	0
897eb50a-cf43-4850-b59b-71a898b8228a	5f1803ef-1936-4e7d-bdcb-267e5c89d8dd	6d48a379-1a71-4466-a3ad-e892485204e6	1	\N	2013-11-19 09:01:39.061+01	0
3b23d3c8-ed89-43dd-9559-e3d45f48a73b	caebf2d9-cf37-4e8d-827f-eccc83ebb3c9	df4457ff-f4b8-4e6d-93da-49ddb539abab	1	\N	2013-11-19 09:07:29.41+01	0
8954d3fa-0922-499d-83c9-3e0d6c0b5bd5	caebf2d9-cf37-4e8d-827f-eccc83ebb3c9	6e0b0cc2-3d59-45df-91d2-bce12270e102	2	\N	2013-11-19 09:07:36.419+01	0
a61242b4-a101-4220-a5c0-443075705cd2	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	26714acc-8121-4588-98b9-afed8d586ee4	1	\N	2013-11-19 09:24:12.556+01	0
460422ee-292c-4901-b9ac-04a7de6fa40a	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	e2285c5e-375d-4316-8010-8d1079dfa550	2	\N	2013-11-19 09:24:19.547+01	0
63c33c31-526f-4059-b2d8-54d151f97a74	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	b0fba0a8-958b-4738-a2fa-588eec9ec6ef	3	\N	2013-11-19 09:24:27.484+01	0
8fc97d64-78f7-449e-8358-ee3e8a84370e	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	5eddabca-d49b-4cf1-be3d-3ac9702ad19d	4	\N	2013-11-19 09:24:33.619+01	0
f796eca0-47cc-4bdf-aaab-cf8afa3fdf0f	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	32525d9f-611c-4a75-8f86-8bc2441dc2fa	5	\N	2013-11-19 09:24:40.395+01	0
bc857cf3-fbbd-4652-bc9f-255626e5562b	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	9a227dd4-4627-4fc4-952f-b31e0cc73786	6	\N	2013-11-19 09:24:54.867+01	0
887045d0-bfcc-4f2a-8ee3-e0b2883200de	8449fff6-d59a-4ed8-8d56-93a68eca1e2e	27ab1720-a951-4ebe-9642-221a99183c6c	7	\N	2013-11-19 09:25:02.412+01	0
c9915108-a7a7-4963-9230-626794c7f94c	1c078554-eb73-4196-b0dd-10e4d2a27389	230a059b-d4a3-43db-b386-627b4110adbc	1	\N	2013-11-19 09:30:13.257+01	0
4084861a-1f13-4f50-a9bb-1895e1971bce	de1ad443-157b-43f5-b7a8-ec8b8371c368	26714acc-8121-4588-98b9-afed8d586ee4	1	\N	2013-11-19 10:10:07.011+01	0
8bcb4c45-d919-457f-bd7b-a991645e9cef	de1ad443-157b-43f5-b7a8-ec8b8371c368	e2285c5e-375d-4316-8010-8d1079dfa550	2	\N	2013-11-19 10:10:16.459+01	0
cea23542-3b5c-490d-ba40-f68979fb8e82	e89d4206-ff2f-4756-99b5-e9a1309f98f9	7a229b0b-cb12-493d-83f9-8b88953122bc	1	\N	2013-11-19 10:32:38.961+01	0
6aa5948e-d6e1-436c-9eb5-87ef13a4eccc	f38be589-b7ad-4803-82aa-045ae26cafa9	5f1a7475-6c74-46bd-92d2-6a1c47b8140f	1	\N	2013-11-19 12:39:33.235+01	0
ea47db0d-dfb9-4841-aad0-4e884ef4bec8	f38be589-b7ad-4803-82aa-045ae26cafa9	73356894-3289-4a53-811e-c024a5eadacd	2	\N	2013-11-19 12:39:33.235+01	0
415787ed-3e98-44b2-83da-eedc3e4af3a7	ff9c6584-d8be-46a6-b09f-35c1341056ff	dda8f240-7f0e-44bd-ae2b-e51d5ad67216	1	\N	2013-11-19 12:47:50.576+01	0
2c0286ca-71f8-47eb-a3dd-86befdc20903	625929e4-43f6-407d-a43f-05604071aa6e	93d97663-150d-4d28-ba08-95b014edbc1f	1	\N	2013-11-19 09:16:48.902+01	0
81859594-d408-4dff-948b-463ef265f7fa	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	5e93d490-ef48-4ca1-aaf6-d33a8d8123c1	1	\N	2013-11-19 12:57:34.812+01	0
f0953f3d-6921-44d0-9436-0358296d0abb	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	1b32086a-dbad-4528-81d7-7e18157b52f9	2	\N	2013-11-19 12:57:41.42+01	0
05b9b9cc-fdb7-4b7c-a6b8-95ba81dd64ef	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	ffa1b779-4a28-446f-86f1-49ef02095a48	3	\N	2013-11-19 12:57:47.14+01	0
ed3ea7e9-622f-479a-9db5-fe7160125679	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	82a02684-66f3-4336-8419-2573f650ab50	4	\N	2013-11-19 12:57:52.82+01	0
7312d2bb-1b5d-4246-89f9-6d312a7dce81	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	33566f9f-6b6a-4431-a62b-21a6ee1e9338	5	\N	2013-11-19 12:57:59.788+01	0
6f345e79-4297-455c-addf-c6ee9389fb98	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	50298f52-5dac-4c8e-8b93-72a20bb0bd2e	6	\N	2013-11-19 12:58:07.572+01	0
1fdd06f1-1bf9-4979-a50c-014e59446d0f	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	bd4244d6-f612-4571-93c7-477cbc279078	7	\N	2013-11-19 12:58:13.508+01	0
e2d72edf-996a-473f-83d5-dc7586029a6a	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	9d78564b-7da1-493f-9782-1ea9af404edd	8	\N	2013-11-19 12:58:21.628+01	0
7157edef-885b-488b-a159-700f26322ef6	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	38b7181e-196d-433f-8c26-cccb6d6e2150	9	\N	2013-11-19 12:58:27.739+01	0
7d4d89e9-5d7c-4c92-bee4-4d4f1f15abef	8f4c9fab-aee9-4031-a3c5-3ef93fb98354	0dbd18b6-fd05-4e15-b574-3a72a32b82c7	10	\N	2013-11-19 12:58:34.028+01	0
43209e2e-dfda-44d9-a458-1b2cbbde63c8	631e442f-1532-4086-b15d-0dab83b07e13	58f1e7da-435f-494f-ad60-27a069f1dd3b	1	\N	2013-11-19 13:28:09.407+01	0
e2f1a731-198d-4931-a6e2-0ef9c300ca3b	b32009d7-2df1-4a11-be50-5603f41b5a20	50298f52-5dac-4c8e-8b93-72a20bb0bd2e	1	\N	2013-11-19 13:31:42.557+01	0
276878f7-9399-4cd9-ae55-fa02301b16ff	b32009d7-2df1-4a11-be50-5603f41b5a20	bd4244d6-f612-4571-93c7-477cbc279078	2	\N	2013-11-19 13:31:52.965+01	0
84639b05-6595-455c-b5e9-f24b86fd3fc1	b32009d7-2df1-4a11-be50-5603f41b5a20	b36b9e71-ebec-4f98-a445-4cea3a6203f8	3	\N	2013-11-19 13:31:59.405+01	0
478ba232-4afb-4a83-82d5-73a607be1479	3dae6ead-2bec-4956-a262-3fd36f2f7e55	a830a836-4c82-4607-9997-a3536bb6b691	1	\N	2013-11-19 13:35:49.428+01	0
c284fc5b-883a-4b3a-893a-acca540be89c	9ba18305-7ce7-4442-8b7c-98a84e93c57b	8fd51566-5717-4d5b-af5c-1da7e66513af	1	\N	2013-11-19 13:42:13.914+01	0
e9a17c8c-1a5c-4c10-9a83-08ec41a2c07d	67f40a38-3ee5-4fad-af99-9f7e324d8eb0	3fd669bc-4d9a-4839-a2c3-088b78b36112	1	\N	2013-11-19 13:46:01.92+01	0
f1fcaf68-3259-4554-a53b-e78c50c3467b	4a642c45-5a91-4c45-801e-f7b1d1302d4b	a3f60254-6ed4-4a17-94bc-86d080abd3d1	1	\N	2013-11-19 14:11:00.781+01	0
a0c4968f-6436-449d-ac20-b66e92bcaf8f	4a642c45-5a91-4c45-801e-f7b1d1302d4b	6595f5c8-11b0-44c4-a2d9-a22ded709f8d	2	\N	2013-11-19 14:11:07.269+01	0
d406a1f5-0737-4131-8de1-0fbe17053d97	4a642c45-5a91-4c45-801e-f7b1d1302d4b	c30fbbfa-c9ce-4fc2-8380-148a59572f59	3	\N	2013-11-19 14:11:13.373+01	0
ffb7ec7a-7df1-416f-8057-4fb13d029664	4a642c45-5a91-4c45-801e-f7b1d1302d4b	d9583663-fe88-4aa8-8fa3-83236959e238	4	\N	2013-11-19 14:11:21.405+01	0
5eb5de35-9723-4fd6-add4-737b9e169b93	4a642c45-5a91-4c45-801e-f7b1d1302d4b	daedcc99-3e82-4e31-82e9-478220735fd3	5	\N	2013-11-19 14:11:27.261+01	0
d9afb1f7-9779-4647-a3e2-57221c77b18f	4a642c45-5a91-4c45-801e-f7b1d1302d4b	9b1854a1-25c2-4716-a8ee-9ebbcd3c4b9f	6	\N	2013-11-19 14:11:33.085+01	0
5baf0f16-ac6d-42e9-a3b1-e275a0f405d4	4a642c45-5a91-4c45-801e-f7b1d1302d4b	18de1c08-3c4c-4f4f-a5ed-4d93a454e617	7	\N	2013-11-19 14:11:39.037+01	0
8b05950a-6a1b-4fdf-b113-6110bbed7457	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	c092a21f-8353-4966-8d88-7ff341536f6e	1	\N	2013-11-19 15:36:39.449+01	0
3e11102e-0e94-4d42-a29c-ed0925f7c008	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	95344471-9798-47f7-8af1-890afc7210e4	2	\N	2013-11-19 15:36:46.641+01	0
d5968aa0-4186-44fe-b10e-ae668866b258	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	0973c92c-a954-49e4-a856-f9db16438858	3	\N	2013-11-19 15:36:52.793+01	0
6d4c8f96-02b7-40b4-b91a-6788f10be059	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	7dde7956-9bbd-465c-a2a1-ed62e340be00	4	\N	2013-11-19 15:36:58.944+01	0
88da5deb-5aab-4334-bb28-d4f5e9ba2cca	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	710a208c-1801-4f8e-85e5-81c51c549e09	5	\N	2013-11-19 15:37:08.377+01	0
c46fe5ac-3a45-4ecd-a0ac-5971123a2fdc	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	6b35a28c-f9ea-4cc2-947c-11fe70f18e64	6	\N	2013-11-19 15:37:17.856+01	0
e44162a3-2533-4e6e-9d9f-81bb9d89a5ba	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	95e64dbb-a87e-4e80-9db6-cde1fd47ae82	7	\N	2013-11-19 15:37:23.841+01	0
67e53b00-d28c-4dfb-98c7-8bba07d68239	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	8c80893d-5ab2-4918-bfde-5283d8106711	8	\N	2013-11-19 15:37:29.657+01	0
19538c98-1168-424f-93b2-6d9af29668dc	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	385c7c09-3fc9-4d80-9130-58c4ce47189b	9	\N	2013-11-19 15:37:35.216+01	0
e8e09fea-4707-43bc-a8fd-4d44f9d57117	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	d90a3684-064f-4a3e-9fd4-0312d2f98193	10	\N	2013-11-19 15:37:41.801+01	0
416a1ddb-433b-4941-9e65-fc857ca69704	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	0940460c-9588-4338-a13a-d11c0a0bd93a	11	\N	2013-11-19 15:37:50.512+01	0
42a6e571-55bf-4593-aceb-ddd9e48df2b9	a4c268f8-fc3b-4537-acff-a372bee2fddf	0b7dc40b-2694-4384-88f6-5af6c2d9b590	11	\N	2013-11-19 14:27:14.942+01	0
8f5117a6-7d59-4519-9f29-89a03ae0ba0d	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	acd524a2-eee8-469c-bb77-68ea6d40dd37	12	\N	2013-11-19 15:37:57.161+01	0
64ad7027-64ea-4e76-a844-32dbc4956337	98dcde91-a1ca-4d3b-ab4b-50b7d80c8934	0b7dc40b-2694-4384-88f6-5af6c2d9b590	13	\N	2013-11-19 15:38:03.408+01	0
1bbbdae7-485d-433f-ac95-03c64a0069d7	175ad376-2621-41e7-ad6c-6451d7cedbbf	bfc4f408-3d24-4970-af8a-1a3d1ac04114	1	\N	2013-11-19 15:46:04.037+01	0
c22bf65b-e587-4afb-8ab9-016cdfa266b2	175ad376-2621-41e7-ad6c-6451d7cedbbf	1d1ffb3d-5458-4f25-b0d2-20492d03ed67	2	\N	2013-11-19 15:46:51.164+01	0
ef17b149-8cd4-4fcb-8fef-288f73edc63c	a4c268f8-fc3b-4537-acff-a372bee2fddf	2482c4de-cb58-47ce-8a51-54eee427427d	1	\N	2013-11-19 14:25:45.143+01	0
9c2cdd13-9da3-40b2-ad2a-b87d880bd919	a4c268f8-fc3b-4537-acff-a372bee2fddf	199bcd70-9b78-4f09-bb3b-3572dd4921ab	2	\N	2013-11-19 14:25:51.471+01	0
67ecadd5-411c-4410-8d4f-36b36ffad5ad	a4c268f8-fc3b-4537-acff-a372bee2fddf	3bc810f4-d9aa-4244-85d3-84bcb83d0124	3	\N	2013-11-19 14:25:57.439+01	0
93dc4f9f-4cbd-41ce-927a-c2a68c649734	a4c268f8-fc3b-4537-acff-a372bee2fddf	a5fb696f-99d2-4505-81a2-f1f95bac7e16	4	\N	2013-11-19 14:26:04.511+01	0
c96a5935-8f23-407e-a96f-3baeaec75f33	a4c268f8-fc3b-4537-acff-a372bee2fddf	910e8591-7afe-4388-a70e-b2576afe8a72	5	\N	2013-11-19 14:26:10.878+01	0
7ac7b07d-5842-4521-a316-66bf8c76910c	a4c268f8-fc3b-4537-acff-a372bee2fddf	72426144-3d7e-4bb0-8261-23622400c68a	6	\N	2013-11-19 14:26:34.335+01	0
67cad6ba-9d7c-48eb-81a8-391481d7ab65	a4c268f8-fc3b-4537-acff-a372bee2fddf	02295184-e53b-4b75-b543-4abb69116b7a	7	\N	2013-11-19 14:26:39.287+01	0
843a0b13-5762-4679-873d-5a21be9b61c7	a4c268f8-fc3b-4537-acff-a372bee2fddf	ce53ab3d-b3da-4c59-8667-fb21ac833c3e	8	\N	2013-11-19 14:26:44.638+01	0
d9f4d19d-c0b1-4c35-8236-f0e7806d2490	a4c268f8-fc3b-4537-acff-a372bee2fddf	18c571e6-d0c9-467b-a2c5-2b30896a5e6f	9	\N	2013-11-19 14:26:50.287+01	0
a09981fd-c5f1-42ad-b1f9-1f413672989c	a4c268f8-fc3b-4537-acff-a372bee2fddf	af7c3a87-0a08-48fa-a187-8ec3515db172	10	\N	2013-11-19 14:27:08.119+01	0
f961a090-a531-4d3e-ae96-09bdf91b532b	175ad376-2621-41e7-ad6c-6451d7cedbbf	9a0c4905-1181-49d7-b688-59a10b846d48	3	\N	2013-11-19 15:48:43.396+01	0
f697349a-1d70-4c69-9fec-c200125b7cc8	175ad376-2621-41e7-ad6c-6451d7cedbbf	03ec4441-19e9-47ff-99ad-366f03a17734	4	\N	2013-11-19 15:48:50.756+01	0
be1cf942-9fb8-4d90-b3a3-448dc3863e2f	175ad376-2621-41e7-ad6c-6451d7cedbbf	12074fa7-4c79-431e-83b8-62f648edf1f0	5	\N	2013-11-19 15:48:57.867+01	0
cb13300c-631a-422b-9811-ef52f07dae06	175ad376-2621-41e7-ad6c-6451d7cedbbf	b51c3ab9-c909-468e-bbab-eb8b2597fde3	6	\N	2013-11-19 15:49:03.588+01	0
2e36007e-9433-43d5-9d8d-130d90cf1a6e	175ad376-2621-41e7-ad6c-6451d7cedbbf	d5a9bf72-f6c6-4d19-9d16-d6f417be9753	7	\N	2013-11-19 15:49:09.843+01	0
576d919e-cb38-4f03-a2f0-777800e677d0	175ad376-2621-41e7-ad6c-6451d7cedbbf	4ff21660-2f5e-4aec-939a-9f179af8d307	8	\N	2013-11-19 15:49:27.107+01	0
2f767b66-bc7a-4026-94af-0c9371d5e9a0	175ad376-2621-41e7-ad6c-6451d7cedbbf	b77141f8-c2c4-4f47-88e6-da17ac13313b	9	\N	2013-11-19 15:49:32.979+01	0
052b8278-1ee1-4c41-8367-c3d8c83bcd67	175ad376-2621-41e7-ad6c-6451d7cedbbf	c338d883-e3e8-4592-a641-e18612305282	10	\N	2013-11-19 15:49:38.148+01	0
a8d217ed-415f-4752-a001-13d13dea97de	175ad376-2621-41e7-ad6c-6451d7cedbbf	af6e4b50-a1ef-47b6-88a1-222d9f84a552	11	\N	2013-11-19 15:49:44.083+01	0
0acfec77-edbf-4499-ac28-5c7954337899	175ad376-2621-41e7-ad6c-6451d7cedbbf	9da026ac-0320-4871-89cf-f1c92ef290ce	12	\N	2013-11-19 15:49:50.131+01	0
cbc2ce12-f95e-4549-870e-db5abb759bff	175ad376-2621-41e7-ad6c-6451d7cedbbf	4499392f-9c0d-4882-89fb-574dfaedc4a4	13	\N	2013-11-19 15:49:57.531+01	0
2c5815c2-06c0-4ffb-942a-dda3bbcc1f08	175ad376-2621-41e7-ad6c-6451d7cedbbf	11f877f6-69a8-4e80-b7b4-c2b72b845396	14	\N	2013-11-19 15:50:03.539+01	0
1bf4840d-86e1-4ec8-9ef5-1b6b8903b66a	175ad376-2621-41e7-ad6c-6451d7cedbbf	0b7dc40b-2694-4384-88f6-5af6c2d9b590	15	\N	2013-11-19 15:50:10.443+01	0
4199a63c-fb44-44e5-8659-36d74550a8e1	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	95344471-9798-47f7-8af1-890afc7210e4	2	\N	2013-11-19 16:09:03.067+01	0
6f0003c2-d6de-48f5-90a9-0d602fed5895	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	f6bc52b2-9f4b-4d96-9ed5-01f093a9b898	4	\N	2013-11-19 16:09:16.475+01	0
9003794e-556e-4c5b-8983-68eef943a4ae	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	bb4a9b0b-9b31-4747-8e9e-0f1a32ab0132	5	\N	2013-11-19 16:09:23.587+01	0
9968c837-4c75-4f6f-b543-760886a82b12	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	7dde7956-9bbd-465c-a2a1-ed62e340be00	6	\N	2013-11-19 16:09:29.723+01	0
904b3491-27ad-4fcb-90c5-eb5284522409	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	710a208c-1801-4f8e-85e5-81c51c549e09	7	\N	2013-11-19 16:09:36.683+01	0
50268bf2-920e-42be-a258-49e1d1d4ef58	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	0bcd5bd2-bace-4db5-840f-2aaaed43a65e	9	\N	2013-11-19 16:09:49.531+01	0
0f624120-e89c-4bb2-acec-02d4c0e37da3	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	ce5673dc-74f1-43dc-8494-9c4cb0f4c13f	10	\N	2013-11-19 16:09:58.011+01	0
4e29d2ea-ec4f-4d82-88fa-82d787d1b13f	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	c8b96bbd-ce0f-45ae-8179-e6613f6fe155	11	\N	2013-11-19 16:10:04.899+01	0
197f25b0-9da2-4a21-86d0-eaf003158562	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	fd655c73-2f36-46a3-8e58-0f8b0b7f5635	12	\N	2013-11-19 16:10:10.834+01	0
94bb9f3c-45a9-45a2-9f4a-ace6d467ca3c	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	0b7dc40b-2694-4384-88f6-5af6c2d9b590	14	\N	2013-11-19 16:10:32.211+01	0
d9a75760-1655-42ec-bb06-d6add08b4666	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	c092a21f-8353-4966-8d88-7ff341536f6e	1	\N	2013-11-19 16:08:55.099+01	0
3c4a1826-06f7-4889-a724-021be41f7e69	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	0973c92c-a954-49e4-a856-f9db16438858	3	\N	2013-11-19 16:09:10.299+01	0
c3479ba2-4888-4c59-90a9-18427c1ee89b	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	6b35a28c-f9ea-4cc2-947c-11fe70f18e64	8	\N	2013-11-19 16:09:43.219+01	0
f735bc1e-b900-4857-aba9-11dbb6aed7a4	d6fcd6d8-2564-401f-bdea-c9f3abeb93a8	2f231300-fc3f-442e-b01f-6d3b7cd38859	13	\N	2013-11-19 16:10:16.475+01	0
9601dc78-28a4-41ed-8609-9746f06985b1	97008f82-e648-4e59-a403-dc7be8df289e	c092a21f-8353-4966-8d88-7ff341536f6e	1	\N	2013-11-20 09:47:50.723+01	0
05b33323-c816-4055-a2d6-78fab2ee93f3	97008f82-e648-4e59-a403-dc7be8df289e	95344471-9798-47f7-8af1-890afc7210e4	2	\N	2013-11-20 09:48:04.947+01	0
1fb437d7-e2ce-4cd4-b3cb-9fe5ff70f1c8	97008f82-e648-4e59-a403-dc7be8df289e	e01cac79-e2a0-4ac4-8a03-6743e120d372	3	\N	2013-11-20 09:48:10.067+01	0
ec29f2bf-166d-4a41-b511-427271ac76c8	97008f82-e648-4e59-a403-dc7be8df289e	8d8dc593-1ee6-4d60-beb8-00ba90fcedb3	4	\N	2013-11-20 09:48:16.17+01	0
f2d11c9c-082f-4872-b176-5b5eb9b63562	97008f82-e648-4e59-a403-dc7be8df289e	e69056b9-96e8-415e-aba4-b1d0c9bab650	5	\N	2013-11-20 09:48:21.707+01	0
8543ce44-fe42-4152-8ff3-efa2bf5b3d2e	97008f82-e648-4e59-a403-dc7be8df289e	d611d55d-0ffe-4afd-91d4-815c18e384d8	6	\N	2013-11-20 09:48:28.427+01	0
0d62f6ce-eb95-4b27-9da1-bd22d3a4b27c	97008f82-e648-4e59-a403-dc7be8df289e	7dc8df3f-7743-4d2c-a860-f83bb2addd50	7	\N	2013-11-20 09:48:34.434+01	0
ac4af7eb-2c33-446d-a5e6-3135e4d57f94	97008f82-e648-4e59-a403-dc7be8df289e	ab004a48-3a51-4d22-9108-be22e374b74f	8	\N	2013-11-20 09:48:39.778+01	0
a3906590-e679-4449-93e3-05ba3e9aa4a9	97008f82-e648-4e59-a403-dc7be8df289e	2f231300-fc3f-442e-b01f-6d3b7cd38859	9	\N	2013-11-20 09:48:47.066+01	0
8aa44f50-56c7-46e6-b797-8cf019b833ef	97008f82-e648-4e59-a403-dc7be8df289e	0b7dc40b-2694-4384-88f6-5af6c2d9b590	10	\N	2013-11-20 09:48:54.139+01	0
79ceeeb9-e43c-44b7-9e7f-33a6a8988aed	368513d0-172d-43a0-a475-be4f138c7196	3763496d-1cbe-4b9e-bc1c-e9f4c7af416f	1	\N	2013-11-20 10:01:43.829+01	0
e7c34229-7863-483a-9c38-6f1f72ad1960	368513d0-172d-43a0-a475-be4f138c7196	3fc81beb-ae84-4b91-8eab-586fa4c5e00f	2	\N	2013-11-20 10:01:48.605+01	0
aa8ccb9a-63d3-4f7a-966f-28b895a050dd	368513d0-172d-43a0-a475-be4f138c7196	35566528-b05d-496b-8144-c3c2d6a05191	3	\N	2013-11-20 10:01:53.301+01	0
d695870f-9d13-419f-9687-ea6ae2de7f24	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	27e343fd-300b-4046-840d-9b9d25dfda72	1	\N	2013-11-20 10:06:28.027+01	0
bce95726-6d70-4d16-8e9e-8ddab7af8728	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	b58cf0ba-2c8b-4acb-81e8-1ccc9af23950	2	\N	2013-11-20 10:06:33.259+01	0
4d762baa-868a-45c4-8382-79f72d94081a	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	1db62648-46f5-4b2c-838b-93007359a7d8	3	\N	2013-11-20 10:06:38.083+01	0
86c680d7-640b-4175-a855-8a920ba7d3a1	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	9ed38125-d90f-4c06-bb27-0e1ce4dbce1b	4	\N	2013-11-20 10:06:43.003+01	0
47fa1dfa-14c8-4d87-aa75-0005ea49f145	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	c5389313-661f-47cc-9116-d319e324735d	5	\N	2013-11-20 10:06:58.971+01	0
de88e319-233b-43bf-b114-10227cf6f37f	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	0cea6818-f24a-454b-b405-7fc24059f847	6	\N	2013-11-20 10:07:06.947+01	0
38b28626-22ee-4a3e-899d-d2063efb8d10	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	18cf003a-b2b7-46fb-97f8-e441c1485c2f	7	\N	2013-11-20 10:07:12.25+01	0
6b0fe869-95b0-4826-adc0-cbc9031b7a52	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	e4786a68-136d-4dea-ae8e-e4a9895fc261	8	\N	2013-11-20 10:07:18.307+01	0
c6923fae-364e-4754-9a33-8cfff7d5e77e	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	4d562f4c-0989-4bb0-a2ed-2f5ea8c88afc	9	\N	2013-11-20 10:07:23.443+01	0
e7ec13b9-67b4-494d-b4ce-669435b66425	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	e62bfa27-3e51-42a3-b55c-7e76ba52727f	10	\N	2013-11-20 10:07:28.642+01	0
c27c1be3-a4c3-49cb-b8b0-a8af0161c0b0	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	2b7f98ae-eb58-4df0-836e-3fb25d48a86d	11	\N	2013-11-20 10:07:34.331+01	0
2f743849-5c0a-490b-99a4-bdc1cbaaf4c7	d7e74a7e-89fd-4a4b-b500-0ea39cf5031f	caeee364-c5da-401f-b017-751578af53c9	12	\N	2013-11-20 10:07:39.723+01	0
a0bf2562-41d3-467d-b531-1b5efa65a74b	7243960f-e462-4a79-854f-6d2a83f5da51	5400f400-d376-471d-b2ff-ed403979ca08	1	\N	2013-11-20 10:27:47.17+01	0
759c6909-b074-4f6d-ba95-52d53256d842	7243960f-e462-4a79-854f-6d2a83f5da51	4d869ca5-8ede-4486-bf6f-ecf83e6895a2	2	\N	2013-11-20 10:27:54.05+01	0
f1ab725d-2131-4a4d-88f6-42f7cb96baf1	7243960f-e462-4a79-854f-6d2a83f5da51	00db69bc-9618-4ef1-9e4b-8a7af467875f	3	\N	2013-11-20 10:28:04.682+01	0
d5da08b5-8922-4b5d-b37f-feb257a21c61	7243960f-e462-4a79-854f-6d2a83f5da51	ca6924c1-8723-4868-be9a-a5ca534e638b	4	\N	2013-11-20 10:28:09.41+01	0
8a60917e-a3d5-4081-8b82-0060c994c044	7243960f-e462-4a79-854f-6d2a83f5da51	0e10ec00-61d0-4afc-9f37-5fa34a55cf0d	5	\N	2013-11-20 10:28:14.834+01	0
8de24170-6059-462c-91d8-65afcf938751	7243960f-e462-4a79-854f-6d2a83f5da51	d7eb20f9-0e39-4d81-933c-89cfc62d1d20	6	\N	2013-11-20 10:28:19.866+01	0
35298935-617b-4536-bb03-97101615dfc4	7243960f-e462-4a79-854f-6d2a83f5da51	76e504b9-d8dd-4404-b801-acbba0d42ef3	7	\N	2013-11-20 10:28:25.09+01	0
025fe05b-834a-47d2-b667-253c969b08f1	fb8e9224-f278-4f4d-bdf9-7be264d4bc06	2d875754-21bb-449b-82db-c5786f2254b1	1	\N	2013-11-20 10:37:49.958+01	0
867c7930-533c-48c5-be49-afa6568d505d	fb8e9224-f278-4f4d-bdf9-7be264d4bc06	d603d061-cd25-46d6-b713-48d42bec444f	2	\N	2013-11-20 10:37:55.542+01	0
ed2efd8d-59cb-4999-8d8b-f37b34259eaf	fb8e9224-f278-4f4d-bdf9-7be264d4bc06	1fbe07af-321c-48a2-b23c-7a26873061f2	3	\N	2013-11-20 10:38:00.694+01	0
3002e64d-c32b-4bbb-a819-ce81ffb8a04e	fb8e9224-f278-4f4d-bdf9-7be264d4bc06	0b7dc40b-2694-4384-88f6-5af6c2d9b590	4	\N	2013-11-20 10:38:08.358+01	0
2853ae19-8a8e-44f3-9a7f-999554276ed2	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	d6d21257-30f3-4e6c-9bf4-e2e503ab79f5	1	\N	2013-11-20 11:14:51.071+01	0
6b7abeb8-94ee-4c93-85cb-03992fdf3958	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	c2e2f57f-5cf8-407c-980b-af0ab513a58b	2	\N	2013-11-20 11:14:57.862+01	0
1e1a61ca-4bbe-4427-9493-1422fdfe484f	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	b1de6368-e72b-4db6-8d7d-9a88b5dae3d0	3	\N	2013-11-20 11:15:03.886+01	0
b2295058-9219-4f4b-92eb-73cd65b63821	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	55254909-80a4-44a3-b5f5-4339413e6b27	4	\N	2013-11-20 11:15:11.39+01	0
7d724b63-963e-45f5-ab3a-a739dfc6a3b8	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	abbcbe8c-d6f3-41da-bca4-810eee92b16f	5	\N	2013-11-20 11:15:23.813+01	0
73f0dabd-a498-422b-bb2f-6659c451e1be	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	c30fbbfa-c9ce-4fc2-8380-148a59572f59	6	\N	2013-11-20 11:16:13.413+01	0
a37e1eeb-b4dd-4bbc-9090-39c4a78ec001	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	2c44e699-173c-4091-9a5c-873e459618a3	7	Eirik Frantzen	2013-11-30 00:19:50.882+01	0
9c85de22-7d51-4ece-a3f1-0bc5cc4174ab	7a4c2032-54d9-469f-9484-e4b8d58b7d3d	549ab99d-d4a4-4454-a418-deb6d3423f8b	8	Eirik Frantzen	2013-11-30 00:19:50.885+01	0
c3e6e7f4-54fe-43f7-9034-172cda4fb28c	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	ae9ac878-7cfa-4817-bc3c-7c80181cb4e3	1	\N	2013-11-20 14:03:00.52+01	0
c364738d-035e-417f-b7ee-4e7b0afcc2fb	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	1cc73687-7d36-4bdb-88e4-7ed9d3c774c5	2	\N	2013-11-20 14:03:07.095+01	0
2344ad75-956b-4bfa-b8fd-49fbb581ca02	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	fe743a5b-3016-44ae-bed8-0b9c560429d9	3	\N	2013-11-20 14:03:21.159+01	0
7c011ae0-df40-44c1-aa10-6c3a5b4a4d6f	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	e4b92d2b-e7cc-4d7c-ba3f-9b044ddbeac8	4	\N	2013-11-20 14:03:26.367+01	0
6b06096d-c563-4532-84fe-fd12b0f31469	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	7b5adeb5-77a4-427b-910e-488f7862eaec	5	\N	2013-11-20 14:03:31.734+01	0
8367a6ab-a823-4760-8a9e-b253db9dba36	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	d6d019a7-5a0d-402a-9e9d-1d1657aacfc9	6	\N	2013-11-20 14:03:37.663+01	0
9074c887-6eb2-4706-a694-fe7743028db9	db6bf17d-b04f-4f7c-8e03-00be6a25b0c3	182abf30-e866-45f0-9586-c16601efdc72	7	\N	2013-11-20 14:03:43.023+01	0
e2aa9436-4771-46b3-a41c-b7c9c3669670	3fcdc058-a3d1-40f0-a645-b4f076ec2a00	0ad9dd9b-b390-4ad1-abda-8b55ccc4e1dc	1	\N	2013-11-20 14:18:56.16+01	0
edf359f8-46a4-474f-8ae0-0dfc3d7aed8b	3fcdc058-a3d1-40f0-a645-b4f076ec2a00	b9fc3bc8-9094-4745-bc70-92e68ed57760	2	\N	2013-11-20 14:19:01.537+01	0
3be678d5-3176-41a4-b562-5d174301573e	3fcdc058-a3d1-40f0-a645-b4f076ec2a00	22f4d3a7-ac96-40ba-958f-9b742bb46b30	3	\N	2013-11-20 14:19:07.128+01	0
5ec04741-c4c3-4baa-87d3-f92f3a7f5e14	3fcdc058-a3d1-40f0-a645-b4f076ec2a00	8e8267e7-be46-46b3-8d7b-9962e6a036e0	4	\N	2013-11-20 14:19:12.816+01	0
788be725-f112-4463-80cd-c9895ed31397	3fcdc058-a3d1-40f0-a645-b4f076ec2a00	f07ab1bb-c45b-4e11-9e63-43608c971c78	6	\N	2013-11-20 14:19:29.304+01	0
edd97cce-bf08-40d0-9f08-2df3944350e6	3fcdc058-a3d1-40f0-a645-b4f076ec2a00	d84d2dc2-3492-4713-a85f-08eb887d020c	5	\N	2013-11-20 14:19:22.92+01	0
72396622-1916-41f3-b3b6-9d7d88d039cc	d0211769-49ac-4ff1-8aa9-6351899619c4	b3ca1718-0534-4d90-b8fa-ca68270b08df	1	\N	2013-11-20 14:37:24.961+01	0
55a7cb5f-b58d-4bd7-9a1a-4735f8b54514	d0211769-49ac-4ff1-8aa9-6351899619c4	b3219b40-a2d0-4a52-9274-53179067fb1d	2	\N	2013-11-20 14:38:43.256+01	0
4a6d1b23-34fa-4456-977f-10e9636ba0c2	d0211769-49ac-4ff1-8aa9-6351899619c4	33ce6993-45b3-4a81-88df-6b501bb87464	3	\N	2013-11-20 14:38:52.2+01	0
5654d8a0-3a5b-4784-9343-320e41e7f3c3	d0211769-49ac-4ff1-8aa9-6351899619c4	b9fc3bc8-9094-4745-bc70-92e68ed57760	4	\N	2013-11-20 14:38:57.312+01	0
7f1584f8-5906-481f-b36c-45dc979d38b7	d0211769-49ac-4ff1-8aa9-6351899619c4	f0adbe48-7e2f-4c2c-b55a-8b9ff2d28930	5	\N	2013-11-20 14:39:02.824+01	0
65d19381-81c8-43e3-bd97-6af1111d96be	d0211769-49ac-4ff1-8aa9-6351899619c4	d84d2dc2-3492-4713-a85f-08eb887d020c	6	\N	2013-11-20 14:39:08.704+01	0
9bf76446-3415-4e0a-8ed1-33d86f0c5f61	c70c24a8-dd37-4e0b-b5d7-60e241439c82	6eaa4b4a-b6cf-440a-9d58-ab60a294e6b6	1	\N	2013-11-20 14:37:55.464+01	0
370896e1-be69-4257-8194-bd9143ef2b3e	c70c24a8-dd37-4e0b-b5d7-60e241439c82	bba6b581-8c01-40b4-b414-6ea6db033b47	2	\N	2013-11-20 14:38:13.056+01	0
6154ca17-16f2-4ca5-95d7-a0d28899590f	c70c24a8-dd37-4e0b-b5d7-60e241439c82	1dcdbd82-e7fc-4839-8650-387811e31b30	3	\N	2013-11-20 14:38:18.312+01	0
8c0049b8-1cec-4785-99bb-2486ce8e65d6	c70c24a8-dd37-4e0b-b5d7-60e241439c82	e68b1c01-ad12-4455-a92b-05a0661ba5db	4	\N	2013-11-20 14:38:23.08+01	0
94dcd85a-948b-4bbc-8cbe-197b4a18b26c	c70c24a8-dd37-4e0b-b5d7-60e241439c82	f07ab1bb-c45b-4e11-9e63-43608c971c78	5	\N	2013-11-20 14:38:28.744+01	0
5f9f1f66-6e2a-467b-a2d0-03bc49725d0c	d995e4d5-094b-481b-8817-d09b5320ab03	fe743a5b-3016-44ae-bed8-0b9c560429d9	1	\N	2013-11-20 14:53:57.097+01	0
4e2213fa-d673-4e86-a135-dea45840a78c	d995e4d5-094b-481b-8817-d09b5320ab03	6a233c42-9512-4230-ad34-8e89f6ff9b96	2	\N	2013-11-20 14:54:05.209+01	0
df5ee8f7-c7d3-4a69-a466-4dcaca9c93c1	d995e4d5-094b-481b-8817-d09b5320ab03	05df1370-ba54-4531-abe7-5606574bd545	3	\N	2013-11-20 14:54:10.713+01	0
ef14ccdf-9008-471d-8536-3897521d726e	180780d8-f03f-48e0-b829-88fbbec2a5b2	aa32237d-e432-404d-953e-4c320f2966a1	13	\N	2013-11-21 09:08:47.619+01	0
df04c16e-8e0a-40ed-bb45-001a4465f141	8cf69fda-cfdb-4981-a66e-cbf0e992583d	4453ac02-cb38-4a83-a1bc-55191d911943	1	Eirik Frantzen	2014-01-23 12:34:57.22+01	0
87690368-8b7e-4fc3-970c-7275b6fe6d3d	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	15aadd9c-611b-44da-9525-c01029a583ea	1	Eirik Frantzen	2013-11-30 00:24:35.505+01	0
0780f6de-cb5a-4403-8d30-47363780be66	dc59a0e7-7efe-4de8-80a1-576609e8120d	dbe3a2f1-f6a6-4cc8-abf1-917718ddd202	1	Eirik Frantzen	2013-12-04 00:21:13.735+01	0
1faad4f1-4300-4bfe-a6de-5e17f48419c6	dc59a0e7-7efe-4de8-80a1-576609e8120d	4d53807d-4dfd-4884-9227-0c0202e7df47	2	Eirik Frantzen	2013-12-04 00:21:13.737+01	0
55ebc396-4d63-44ba-a453-f0353737e566	dc59a0e7-7efe-4de8-80a1-576609e8120d	e9163c73-a685-41ef-9725-65b0e4a5ab86	3	Eirik Frantzen	2013-12-04 00:21:13.737+01	0
327739f7-1666-4783-88af-c6701cdb10ee	dc59a0e7-7efe-4de8-80a1-576609e8120d	cd7776b9-d0bd-4e1a-a589-beb38d615a93	4	Eirik Frantzen	2013-12-04 00:21:13.738+01	0
66430bd6-ba96-47f9-b519-7fedad7ba1fb	dc59a0e7-7efe-4de8-80a1-576609e8120d	bfb2b69f-112c-4bc7-ad1f-b8ae3ae7aab2	5	Eirik Frantzen	2013-12-04 00:21:54.005+01	0
8e1e0822-9ae4-49bd-a861-ef3a9256c61b	dc59a0e7-7efe-4de8-80a1-576609e8120d	c391e3ea-5364-4362-8684-84311273190f	6	Eirik Frantzen	2013-12-04 00:21:54.007+01	0
e137800e-52d2-4a92-90c9-6d74a590342b	dc59a0e7-7efe-4de8-80a1-576609e8120d	759e160a-aae9-4c57-b473-30db0677cbc0	7	PowerCatch admin	2014-02-24 11:26:04.86+01	0
a722c1ad-63b7-400b-87ce-ee11b7af05af	d24e11e9-3766-4836-b313-d3f3027eeafb	1dd6d754-09dc-4450-b7b4-df0fbd4dee70	1	Eirik Frantzen	2014-01-22 15:52:44.601+01	0
439674e4-c176-458c-86fd-22efd660a423	d24e11e9-3766-4836-b313-d3f3027eeafb	13aef1f5-3f55-45c5-99ff-9248a4382f63	2	Eirik Frantzen	2014-01-22 15:52:44.61+01	0
93dc9c6b-2487-4ce1-8850-613990301763	d24e11e9-3766-4836-b313-d3f3027eeafb	a58330ca-439b-4bac-aef8-00e34a0be43b	3	Eirik Frantzen	2014-01-22 15:52:44.614+01	0
2037b1f5-607d-46b6-821e-2de93cf110ec	d24e11e9-3766-4836-b313-d3f3027eeafb	4c80df83-3d29-436d-b41d-36e65fbdf31f	4	Eirik Frantzen	2014-01-22 15:52:44.616+01	0
d417fa4a-748e-40b9-82e2-c79ce742c69e	d24e11e9-3766-4836-b313-d3f3027eeafb	0951c17e-7129-453e-b17f-1d1d04bd8ada	5	Eirik Frantzen	2014-01-22 15:52:44.618+01	0
b5d230fc-9468-4318-923c-0dd5e28d7da9	f8ad99aa-d0af-4e67-978a-0786029e47df	4453ac02-cb38-4a83-a1bc-55191d911943	1	Eirik Frantzen	2014-01-22 16:12:41.188+01	0
00bab234-f9e1-4feb-80e3-b8521f667600	f8ad99aa-d0af-4e67-978a-0786029e47df	027d1232-383d-4d0b-8eb9-f6be184aec65	2	Eirik Frantzen	2014-01-22 16:12:41.197+01	0
6ccee7e8-e094-41a6-bb32-fc73289f67f0	f8ad99aa-d0af-4e67-978a-0786029e47df	ab80f4ea-fda7-4291-acb3-bfcd128173bf	3	Eirik Frantzen	2014-01-22 16:12:41.199+01	0
56e6d14e-c05b-4cc3-a635-bf1de1e1657a	f8ad99aa-d0af-4e67-978a-0786029e47df	45a370c5-1d19-449b-aaf5-1d1635528416	4	Eirik Frantzen	2014-01-22 16:12:41.2+01	0
d35a85a5-db6d-4496-a4b9-d5e159b3461e	952334af-347d-49d8-a2bf-43849d098639	5f1a7475-6c74-46bd-92d2-6a1c47b8140f	1	Eirik Frantzen	2014-01-23 08:38:20.56+01	0
7aa132ec-d73b-4cfa-ac67-36fd47eee8f6	e691abbb-a386-4e5c-86dd-2488e70ad7b9	4dcf6743-c59d-4ced-bc15-6410833db859	1	Eirik Frantzen	2014-01-23 08:45:43.899+01	0
1dae7d15-c597-44df-a7e5-894c44cd73d2	e691abbb-a386-4e5c-86dd-2488e70ad7b9	fcfd6eb2-b1a4-4e97-82bb-0832e279c968	2	Eirik Frantzen	2014-01-23 08:45:43.902+01	0
b69f9397-d76e-4926-9b8a-eca901e4de48	e691abbb-a386-4e5c-86dd-2488e70ad7b9	5fac5ea1-4c86-4bbb-8b51-5d35956b8895	3	Eirik Frantzen	2014-01-23 08:45:43.904+01	0
bc2dccf0-4d85-43f6-a100-930a205be373	e691abbb-a386-4e5c-86dd-2488e70ad7b9	40644954-b3c8-40ad-90df-66d050b00307	4	Eirik Frantzen	2014-01-23 08:46:38.007+01	0
cda951be-a20a-4a3f-ad16-a3dff6294ecc	f8ad99aa-d0af-4e67-978a-0786029e47df	34c75c60-df48-4de5-aa9c-03e32fbf7c26	5	Eirik Frantzen	2014-01-23 09:15:06.485+01	0
ef0b2bbb-2a34-45e8-9e8e-3c9fb51b9cbc	f8ad99aa-d0af-4e67-978a-0786029e47df	590851fe-b98d-4698-a54f-15e7eccc3a88	6	Eirik Frantzen	2014-01-23 09:15:06.488+01	0
f7ebbcc7-bf20-4fc4-a7a7-b9defb03f59d	23260e4b-5011-4c6d-b451-93eea4eab395	f5f3dec1-18f7-43e2-8e57-9140e01ccc4d	1	Eirik Frantzen	2014-01-23 09:20:18.43+01	0
f68f6ee0-1cc5-4ba9-b766-56c56b6fd99f	23260e4b-5011-4c6d-b451-93eea4eab395	c95289f2-0844-47e2-aa4b-db9c7a606564	2	Eirik Frantzen	2014-01-23 09:20:18.434+01	0
1633e9ad-cce2-423b-8c29-4488093053b8	d7ee8c3b-1b8b-4301-92b2-2a46ce2dda1f	a3a7dd48-1bba-493a-81ef-10da9ec319ea	1	Eirik Frantzen	2014-01-23 09:22:57.731+01	0
f3847f96-1f5b-44a3-9d0e-287e13f7a0e5	8a00261b-42e2-49a3-89b7-ff9efbc31046	e4b9d51a-ba2f-4bd5-b9d7-b1a76d094ad4	1	Eirik Frantzen	2014-01-23 09:25:28.71+01	0
788dfc0c-3195-4c60-bfb5-86fe81c3e2f9	47078b75-dc68-4686-8858-bf6c314549e1	4453ac02-cb38-4a83-a1bc-55191d911943	1	Eirik Frantzen	2014-01-23 11:12:49.923+01	0
cce137cb-3a79-4174-bf55-40632f065daa	47078b75-dc68-4686-8858-bf6c314549e1	9f4cc43a-a153-443c-bad0-aa3a7a763a64	2	Eirik Frantzen	2014-01-23 11:12:49.926+01	0
82271ce6-e8af-4a39-8dc9-9c7de234d7b3	47078b75-dc68-4686-8858-bf6c314549e1	78f0ebb8-1ec1-4504-bd04-aaaff7406da8	3	Eirik Frantzen	2014-01-23 11:12:49.929+01	0
bc6e3938-af3c-45f6-aaae-c6458e73fba9	47078b75-dc68-4686-8858-bf6c314549e1	c9f40f4f-2bbd-44e4-b9e1-b57fb8c28c55	4	Eirik Frantzen	2014-01-23 11:12:49.931+01	0
31774fc8-4b69-4f97-8267-4eb8a3e0bbb3	0699f82f-0215-42d6-8b27-a18ff997e1ac	7740f924-d424-4a8e-874f-6170453c8e6f	1	Eirik Frantzen	2014-01-23 11:18:43.567+01	0
c4ea0073-a102-44d6-86eb-4ac6c7d17d8c	0699f82f-0215-42d6-8b27-a18ff997e1ac	2566d38c-771e-4e0d-9ed0-6f9f70e0d01c	2	Eirik Frantzen	2014-01-23 11:18:43.57+01	0
c67a55ba-29cd-48ff-a761-73e470a2e01b	38aff070-7ba7-48fa-a7d4-afd17153e96c	a3a7dd48-1bba-493a-81ef-10da9ec319ea	1	Eirik Frantzen	2014-01-23 11:21:37.448+01	0
687d3847-9ce6-4342-9eb8-88a0f44d55a8	38aff070-7ba7-48fa-a7d4-afd17153e96c	e4b9d51a-ba2f-4bd5-b9d7-b1a76d094ad4	2	Eirik Frantzen	2014-01-23 11:21:37.45+01	0
ea565167-17bc-4394-85b9-1dfcf7470f8d	c1cee990-2fc3-4ce3-bf44-40eea456d61c	080830de-c44d-41d2-a755-4bf3c2c459df	1	Eirik Frantzen	2014-01-23 11:26:22.941+01	0
72ac5aca-9b52-414b-ac48-c45ec1b5a5bc	c1cee990-2fc3-4ce3-bf44-40eea456d61c	dffb8327-bd67-4641-9de6-1a68e34a3905	2	Eirik Frantzen	2014-01-23 11:26:22.945+01	0
2a0b8b5b-d41f-41bc-bb02-c84917b3beb6	c1cee990-2fc3-4ce3-bf44-40eea456d61c	8abe6200-ab3f-4e30-b364-a4d7bec56ca9	3	Eirik Frantzen	2014-01-23 11:26:22.947+01	0
07dbde03-ea5e-4620-bec9-f76cfafcd59b	c1cee990-2fc3-4ce3-bf44-40eea456d61c	93ce2c62-862c-47d0-a3e7-9326523547cc	4	Eirik Frantzen	2014-01-23 11:26:22.948+01	0
689ae454-a2f8-4d8e-ba24-1b3a4d08e714	cd279ec8-b22b-406c-a329-45b6a001f42c	2c78776f-8ce8-4c45-923a-dfca9be67cc2	1	Eirik Frantzen	2014-01-23 11:31:19.072+01	0
e74a0ae8-6703-412a-97bd-a37eb4230dd9	cd279ec8-b22b-406c-a329-45b6a001f42c	051197b1-842d-44f2-880c-bd6b46a6ae76	2	Eirik Frantzen	2014-01-23 11:31:19.076+01	0
25878b79-157a-4492-a6de-941da8989f41	37c73f0d-59db-4bb9-8f98-08bf38d8d8bf	4453ac02-cb38-4a83-a1bc-55191d911943	1	Eirik Frantzen	2014-01-23 11:34:05.237+01	0
be189bdf-7a2a-44c2-a736-ef6fc7c4b480	37c73f0d-59db-4bb9-8f98-08bf38d8d8bf	9f4cc43a-a153-443c-bad0-aa3a7a763a64	2	Eirik Frantzen	2014-01-23 11:34:05.24+01	0
0516ad47-d19e-40dc-b243-12c9a0edfa23	37c73f0d-59db-4bb9-8f98-08bf38d8d8bf	c9f40f4f-2bbd-44e4-b9e1-b57fb8c28c55	3	Eirik Frantzen	2014-01-23 11:34:05.242+01	0
344544f4-42ba-4de3-8224-f98125a8e3e4	37c73f0d-59db-4bb9-8f98-08bf38d8d8bf	027d1232-383d-4d0b-8eb9-f6be184aec65	4	Eirik Frantzen	2014-01-23 11:34:05.244+01	0
41aa9868-af7d-40b9-809c-e076ceec01ef	37c73f0d-59db-4bb9-8f98-08bf38d8d8bf	8abe6200-ab3f-4e30-b364-a4d7bec56ca9	5	Eirik Frantzen	2014-01-23 11:34:05.246+01	0
42346f44-767c-42df-937b-9162f28e403f	fe97fd37-171a-4847-9298-6fd420183db8	9f4cc43a-a153-443c-bad0-aa3a7a763a64	1	Eirik Frantzen	2014-01-23 11:38:33.935+01	0
d422866d-4f9b-4046-a1dd-d9ca2dd37069	fe97fd37-171a-4847-9298-6fd420183db8	07042c35-0595-4669-8583-e9eeb09ceffe	2	Eirik Frantzen	2014-01-23 11:38:33.939+01	0
36b3f90d-5366-4420-85e6-8ceaaae7a7c8	2bda5f98-9755-4416-a565-08e48c33979d	8c29bfe2-20d3-420c-9bbf-3a9104707d6d	1	Eirik Frantzen	2014-01-23 11:40:55.71+01	0
cbadfdf3-5fe3-422e-a68d-59d2a4b2a615	45e8a418-0cf2-4a58-a608-c6fc79ac9657	4453ac02-cb38-4a83-a1bc-55191d911943	1	Eirik Frantzen	2014-01-23 12:24:23.498+01	0
ae890030-36c5-4152-894d-ed30a5028632	45e8a418-0cf2-4a58-a608-c6fc79ac9657	9f4cc43a-a153-443c-bad0-aa3a7a763a64	2	Eirik Frantzen	2014-01-23 12:24:23.5+01	0
6e42bdd5-1cff-4929-a675-44f3c5cd54d9	45e8a418-0cf2-4a58-a608-c6fc79ac9657	05e30f20-c89e-424c-8e72-93d8f7222f45	3	Eirik Frantzen	2014-01-23 12:24:23.502+01	0
e3aa981f-ddc2-4f11-b79f-4c09164aefa9	affbd02c-61e4-44f6-a519-cc1237d653d2	9f4cc43a-a153-443c-bad0-aa3a7a763a64	1	Eirik Frantzen	2014-01-23 12:29:21.363+01	0
82f9545e-2d97-4de2-a3d7-73799714fdec	affbd02c-61e4-44f6-a519-cc1237d653d2	93ce2c62-862c-47d0-a3e7-9326523547cc	2	Eirik Frantzen	2014-01-23 12:29:21.367+01	0
fa768324-7551-44cd-9bd6-bd0e24806195	7c2c7772-aaa9-415f-9664-5c6b5f2f89ed	4453ac02-cb38-4a83-a1bc-55191d911943	1	Eirik Frantzen	2014-01-23 12:32:35.052+01	0
d1476e44-f4c6-4f4b-a5c0-589d68725474	7c2c7772-aaa9-415f-9664-5c6b5f2f89ed	9f4cc43a-a153-443c-bad0-aa3a7a763a64	2	Eirik Frantzen	2014-01-23 12:32:35.055+01	0
ec9a7d02-ecfa-4ffe-af47-2009d1a8d986	8cf69fda-cfdb-4981-a66e-cbf0e992583d	9f4cc43a-a153-443c-bad0-aa3a7a763a64	2	Eirik Frantzen	2014-01-23 12:34:57.223+01	0
e6789c85-11f2-4e49-83c7-dfe21887e247	8cf69fda-cfdb-4981-a66e-cbf0e992583d	590851fe-b98d-4698-a54f-15e7eccc3a88	3	Eirik Frantzen	2014-01-23 12:34:57.225+01	0
a0ebe4bf-8f21-42da-a340-d19407aae00c	8cf69fda-cfdb-4981-a66e-cbf0e992583d	a3a7dd48-1bba-493a-81ef-10da9ec319ea	4	Eirik Frantzen	2014-01-23 12:34:57.227+01	0
b45ce712-e034-4fd4-8939-8c0e892ad656	8cf69fda-cfdb-4981-a66e-cbf0e992583d	e4b9d51a-ba2f-4bd5-b9d7-b1a76d094ad4	5	Eirik Frantzen	2014-01-23 12:34:57.229+01	0
282f7a3f-8d57-4e51-9118-25be205fab9f	8cf69fda-cfdb-4981-a66e-cbf0e992583d	2c78776f-8ce8-4c45-923a-dfca9be67cc2	6	Eirik Frantzen	2014-01-23 12:34:57.231+01	0
480c934a-dda4-417e-8eb8-50da6e378284	8cf69fda-cfdb-4981-a66e-cbf0e992583d	051197b1-842d-44f2-880c-bd6b46a6ae76	7	Eirik Frantzen	2014-01-23 12:34:57.233+01	0
7bbf8a55-7bb1-4fa5-9a71-37c58d9769f7	9a4479df-b887-46d6-84f2-ebc802a19e3e	4453ac02-cb38-4a83-a1bc-55191d911943	1	Eirik Frantzen	2014-01-23 15:06:24.419+01	0
ede17936-6513-44b9-9e3a-35cdaff71885	9a4479df-b887-46d6-84f2-ebc802a19e3e	9f4cc43a-a153-443c-bad0-aa3a7a763a64	2	Eirik Frantzen	2014-01-23 15:06:24.423+01	0
a903b389-f555-4ce0-8a09-fe1b625f0fe5	9a4479df-b887-46d6-84f2-ebc802a19e3e	ab80f4ea-fda7-4291-acb3-bfcd128173bf	3	Eirik Frantzen	2014-01-23 15:06:24.424+01	0
64a98ea9-1ab5-41a8-9fbd-e298496a5d76	9a4479df-b887-46d6-84f2-ebc802a19e3e	590851fe-b98d-4698-a54f-15e7eccc3a88	4	Eirik Frantzen	2014-01-23 15:06:24.426+01	0
d41c6962-a74b-4ef2-a8c6-7c3e3cfdd8a9	c7ab72ff-2248-45c7-9c6b-1936346cc7d2	9f4cc43a-a153-443c-bad0-aa3a7a763a64	1	Eirik Frantzen	2014-01-23 15:08:54.409+01	0
ab551bd7-ecb8-4a91-818c-52df35128daf	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	45fca5ff-c819-4745-8ffe-668ea1cf852e	3	Eirik Frantzen	2014-01-31 10:47:59.077+01	0
603b8d1a-febc-42f6-91bc-6998f51c8144	8c1026cd-269c-44ba-88a2-25d95d332df8	c30fbbfa-c9ce-4fc2-8380-148a59572f59	1	PowerCatch admin	2014-02-18 15:38:01.48+01	0
fea0428f-f884-429e-8bcf-f13c80c90923	8c1026cd-269c-44ba-88a2-25d95d332df8	d6d21257-30f3-4e6c-9bf4-e2e503ab79f5	2	PowerCatch admin	2014-02-18 15:38:01.519+01	0
d776bc5d-e27c-4fe0-a832-0e0f57a5e8ff	8c1026cd-269c-44ba-88a2-25d95d332df8	c2e2f57f-5cf8-407c-980b-af0ab513a58b	3	PowerCatch admin	2014-02-18 15:38:01.521+01	0
d051fd21-926c-4c06-97f7-74de84cbff1f	8c1026cd-269c-44ba-88a2-25d95d332df8	b1de6368-e72b-4db6-8d7d-9a88b5dae3d0	4	PowerCatch admin	2014-02-18 15:38:01.523+01	0
be3045dd-dc08-41ad-94c0-0e24fb2e4555	8c1026cd-269c-44ba-88a2-25d95d332df8	55254909-80a4-44a3-b5f5-4339413e6b27	5	PowerCatch admin	2014-02-18 15:38:01.524+01	0
43719852-b2d5-47aa-b094-b0ce3c355abf	8c1026cd-269c-44ba-88a2-25d95d332df8	abbcbe8c-d6f3-41da-bca4-810eee92b16f	6	PowerCatch admin	2014-02-18 15:38:01.526+01	0
8c9568a0-b497-404f-abe8-0782433cb2d8	8c1026cd-269c-44ba-88a2-25d95d332df8	d9583663-fe88-4aa8-8fa3-83236959e238	7	PowerCatch admin	2014-02-18 15:38:01.527+01	0
1bbab5a8-14a8-4123-8196-b9ec8bb04d4f	8c1026cd-269c-44ba-88a2-25d95d332df8	daedcc99-3e82-4e31-82e9-478220735fd3	8	PowerCatch admin	2014-02-18 15:38:01.529+01	0
7fdf8e0c-71e3-4d35-8610-278949d2504b	8c1026cd-269c-44ba-88a2-25d95d332df8	1344ca85-aef8-4588-bb68-5bfa3c4831e5	9	PowerCatch admin	2014-02-18 15:38:01.53+01	0
40f4c413-163d-45ed-846f-052136e2655f	53584e38-400d-4905-a563-08e56853f2ec	15aadd9c-611b-44da-9525-c01029a583ea	1	PowerCatch admin	2014-02-18 15:42:27.61+01	0
900b33b0-b68a-46f6-ade8-1208afe1a811	53584e38-400d-4905-a563-08e56853f2ec	4a019e67-69be-4a0a-82f3-5ac65780db35	2	PowerCatch admin	2014-02-18 15:42:27.613+01	0
1f29782a-0b9c-4705-9d5c-a3d18a94e106	53584e38-400d-4905-a563-08e56853f2ec	9306a315-17d8-4187-a367-c7b4cdaf0b26	3	PowerCatch admin	2014-02-18 15:42:27.614+01	0
02d797ac-91c9-447a-b5d1-320ad7ceb3a9	53584e38-400d-4905-a563-08e56853f2ec	71f25906-c204-432c-a38c-be73d09be9da	4	PowerCatch admin	2014-02-18 15:42:27.616+01	0
ce2ffbfd-b059-4d45-9260-188aded34a44	53584e38-400d-4905-a563-08e56853f2ec	2c44e699-173c-4091-9a5c-873e459618a3	5	PowerCatch admin	2014-02-18 15:42:27.618+01	0
59a67ccd-4a97-45e6-a815-bd5fab671203	53584e38-400d-4905-a563-08e56853f2ec	549ab99d-d4a4-4454-a418-deb6d3423f8b	6	PowerCatch admin	2014-02-18 15:42:27.619+01	0
168794c2-8fa2-4f55-8a36-c79d5510c726	53584e38-400d-4905-a563-08e56853f2ec	d11aa057-050d-4673-a5b3-43244be6a0a0	7	PowerCatch admin	2014-02-18 15:42:27.621+01	0
181d302f-c568-4217-b013-3d0e27b418f8	53584e38-400d-4905-a563-08e56853f2ec	7bc3c141-93f0-4fb9-9187-6a1394a1e4fe	9	PowerCatch admin	2014-02-18 15:42:27.624+01	0
897e3502-b4e0-4eab-bd22-dcfd5ad7671f	4eca141c-da35-4935-a05e-8efbae52a929	e921c5b0-7946-45f5-8fb6-3fcc3b947173	1	PowerCatch admin	2014-03-15 19:03:35.489+01	0
57b05531-3c63-4bfd-a986-eb043192a288	6e088fd0-60dc-420d-a23c-2551edd34682	f222070b-0c9c-4721-8f9f-b74d6cf2f243	9	PowerCatch admin	2014-05-12 15:14:19.294+02	0
ddef9370-eeda-48b7-a7c2-a36b916da44f	6e088fd0-60dc-420d-a23c-2551edd34682	51d7ece3-cec1-4444-93c1-cd7d7ecfb5ef	8	PowerCatch admin	2014-05-12 15:14:19.293+02	0
91eeeda1-e8b0-4710-a076-14c052b12267	6e088fd0-60dc-420d-a23c-2551edd34682	84e10dc1-9463-400d-8614-d947ca066e13	7	PowerCatch admin	2014-05-12 15:14:19.292+02	0
b3bc773b-d2dc-4daa-ad17-77eb43299ade	6e088fd0-60dc-420d-a23c-2551edd34682	d6d21257-30f3-4e6c-9bf4-e2e503ab79f5	6	PowerCatch admin	2014-05-12 15:14:19.291+02	0
8ee5f1c4-613b-42b7-a3ad-701f16933b8b	6e088fd0-60dc-420d-a23c-2551edd34682	c30fbbfa-c9ce-4fc2-8380-148a59572f59	5	PowerCatch admin	2014-05-12 15:14:18.504+02	0
897b3bf2-fa67-45cc-a3d1-103f456be06a	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	4e8a31ff-3040-4e14-9d60-9eae17e1b7b3	4	PowerCatch Update Script	2015-01-27 14:58:40.932+01	0
4b309f56-dbf6-4b0a-821b-ea645b3a53b5	f236aef1-f472-4b78-b6b6-1c936dc9a4a0	7bc3c141-93f0-4fb9-9187-6a1394a1e4fe	5	PowerCatch Update Script	2015-01-27 14:58:40.979+01	0
503f8733-59c7-49c8-aa6a-859f25a5a82a	438d2e22-26eb-4022-b7d5-cefd8acd9226	695c39f4-2da4-495f-aa3b-e367be051f26	1	\N	2013-11-19 09:09:55.93+01	0
8fd53afb-72d5-4884-8de5-c637ace07b39	335321c9-58d7-4aba-85fc-f208e963fee1	15aadd9c-611b-44da-9525-c01029a583ea	1	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
16f33f28-adbb-4eba-a352-a4eea23103c1	335321c9-58d7-4aba-85fc-f208e963fee1	4a019e67-69be-4a0a-82f3-5ac65780db35	2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
8ada6864-28e1-4444-b499-211ef3d682f7	335321c9-58d7-4aba-85fc-f208e963fee1	2c44e699-173c-4091-9a5c-873e459618a3	6	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
afa120cf-a97d-45bd-a6b0-8e1522d40be3	335321c9-58d7-4aba-85fc-f208e963fee1	549ab99d-d4a4-4454-a418-deb6d3423f8b	7	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
e84ff71d-d5e5-4ecc-a39d-0957b4883a9a	335321c9-58d7-4aba-85fc-f208e963fee1	250b1d86-34fd-47ff-a9b6-de5aec805e3e	8	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
d5f2de24-80bb-4b1e-823d-ce7798b35e1c	f4b56786-39b2-4c96-baed-e30c297bca0a	d6d21257-30f3-4e6c-9bf4-e2e503ab79f5	1	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
5dd8dd80-4ba7-44bb-8b10-3c2f393656da	f4b56786-39b2-4c96-baed-e30c297bca0a	c2e2f57f-5cf8-407c-980b-af0ab513a58b	2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
c4c06849-59c5-428d-a5a8-9933dc5d1175	1905badf-c9f9-456c-82ca-4d9f9c6791d0	1f5b8feb-b9dc-4d91-876f-7e5ee0e5862c	1	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
e8c0001c-16bb-422b-9a1f-b4f990fc2a90	1905badf-c9f9-456c-82ca-4d9f9c6791d0	4b8658db-9925-4ba9-9de5-363288bd78e6	2	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
6e00b66f-423f-42af-b548-56d42d8e770e	1905badf-c9f9-456c-82ca-4d9f9c6791d0	396b805f-8a76-42f5-8e6d-0a759803bc21	3	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
81921dcf-3ca2-425a-9942-3fa6a6292b86	ee363b7d-5f24-48e1-8fff-689c4f80d651	d0d92b32-de6c-4eab-9940-e7b6c5ea72fa	1	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
574907c8-0c0c-4a4a-b6aa-7a53ca0004a3	335321c9-58d7-4aba-85fc-f208e963fee1	2802bf3b-089c-4657-9d00-c9e98c568503	99	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
9ad4d7c5-b64c-49fa-a8da-a57df15b4e2e	b5ec2348-6f20-42c6-aaa1-c7bd92fb40a1	2802bf3b-089c-4657-9d00-c9e98c568503	99	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
e47d28c2-da9c-4e1c-bf75-c2b7452f3f18	5ee762bb-0abe-45a4-a8fc-861911e3ef96	2802bf3b-089c-4657-9d00-c9e98c568503	99	PowerCatch Update Script	2016-11-01 12:55:51.812+01	0
aa4c9fe5-e50a-f396-b931-784eb0864710	03edfc1f-7663-e593-0151-d7a512cab832	522f1834-772c-9acd-ddc2-1d26624cfadd	1	PowerCatch Update Script	2016-11-01 12:57:05.226+01	0
3a3e2b3a-f2ff-4a2f-9204-5859164d3814	7dbb5114-e884-3645-daee-ee421bbf4a8b	3909dc3d-f9af-4dbc-8601-ee658554b63b	99	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
5c3c800a-734a-4790-adb3-3046f567ba90	7dbb5114-e884-3645-daee-ee421bbf4a8b	e1805c8c-5082-470c-be45-6af0791931c2	99	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
13b8dcb6-4634-4543-19f2-1d34af804c11	7dbb5114-e884-3645-daee-ee421bbf4a8b	2802bf3b-089c-4657-9d00-c9e98c568503	99	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
2fdfe167-666d-f17d-a6bd-6a382fda03c2	7dbb5114-e884-3645-daee-ee421bbf4a8b	15aadd9c-611b-44da-9525-c01029a583ea	1	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
8104f09f-a080-dcc3-f44a-5a2feb891727	7dbb5114-e884-3645-daee-ee421bbf4a8b	4a019e67-69be-4a0a-82f3-5ac65780db35	2	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
ea5786b3-48a4-c28d-5590-52a6ee971703	7dbb5114-e884-3645-daee-ee421bbf4a8b	2c44e699-173c-4091-9a5c-873e459618a3	6	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
d27b109b-e36a-1091-2e16-9d7aadac6536	7dbb5114-e884-3645-daee-ee421bbf4a8b	549ab99d-d4a4-4454-a418-deb6d3423f8b	7	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
62cf7e24-d60a-6533-c2f4-7b61c82d1b7d	7dbb5114-e884-3645-daee-ee421bbf4a8b	250b1d86-34fd-47ff-a9b6-de5aec805e3e	8	PowerCatch Update Script	2016-11-01 12:57:38.46+01	0
\.


--
-- TOC entry 2820 (class 0 OID 0)
-- Dependencies: 208
-- Name: page_number_seq; Type: SEQUENCE SET; Schema: konfigurasjon; Owner: powercatch
--

SELECT pg_catalog.setval('page_number_seq', 93, true);


SET search_path = netbas, pg_catalog;

--
-- TOC entry 2630 (class 0 OID 27381)
-- Dependencies: 209
-- Data for Name: arbeidsbeskrivelse; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY arbeidsbeskrivelse (tid, xml) FROM stdin;
\.


--
-- TOC entry 2631 (class 0 OID 27387)
-- Dependencies: 210
-- Data for Name: arbeidshistorie; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY arbeidshistorie (tid, wid, xml) FROM stdin;
\.


--
-- TOC entry 2632 (class 0 OID 27393)
-- Dependencies: 211
-- Data for Name: arbeidsoppdrag; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY arbeidsoppdrag (tid, issueid, xml, issuekey, received, confirmed, closed, reported, issue_values, closing, status_id) FROM stdin;
\.


--
-- TOC entry 2633 (class 0 OID 27400)
-- Dependencies: 212
-- Data for Name: attr; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY attr (name, value, updateid) FROM stdin;
MEASUREATTRIBS	MÃ¥leattributter	1
ENVIRONMENTATTRIBS	MiljÃ¸attributter	2
EXPORTXML	Eksporter XML	3
IMPORTXML	Importer XML	4
AUTOMATAATTRIBS	Regelstyrte attributter	5
DEFNAME10001	Transf krets	7
DEFNAME10002	Unntak regelstyrt attributter	8
DEFNAME10003	TIL	9
DEFNAME10000	Fra-til skrivbar	15
\.


--
-- TOC entry 2821 (class 0 OID 0)
-- Dependencies: 213
-- Name: cl_id_seq; Type: SEQUENCE SET; Schema: netbas; Owner: powercatch
--

SELECT pg_catalog.setval('cl_id_seq', 7, true);


--
-- TOC entry 2635 (class 0 OID 27406)
-- Dependencies: 214
-- Data for Name: codelist; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY codelist (id, name, xml, html, updateid) FROM stdin;
\.


--
-- TOC entry 2637 (class 0 OID 27416)
-- Dependencies: 216
-- Data for Name: codevd; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY codevd (id, name, xml, html, updateid) FROM stdin;
\.


--
-- TOC entry 2822 (class 0 OID 0)
-- Dependencies: 215
-- Name: cvd_id_seq; Type: SEQUENCE SET; Schema: netbas; Owner: powercatch
--

SELECT pg_catalog.setval('cvd_id_seq', 103, true);


--
-- TOC entry 2638 (class 0 OID 27424)
-- Dependencies: 217
-- Data for Name: delkomponent; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY delkomponent (tid, wid, oid, did, xml) FROM stdin;
\.


--
-- TOC entry 2639 (class 0 OID 27430)
-- Dependencies: 218
-- Data for Name: kontrollpunkt; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY kontrollpunkt (tid, wid, oid, did, id, xml) FROM stdin;
\.


--
-- TOC entry 2640 (class 0 OID 27437)
-- Dependencies: 219
-- Data for Name: object_status; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY object_status (id, status_id, status_name) FROM stdin;
1	1	COMPLETED
2	2	NOT_COMPLETED
3	3	CREATED
4	4	DELETED
5	5	COMPLETED_SENT_TO_NETBAS
6	6	NOT_COMPLETED_SENDT_TO_NETBAS
7	7	XML_UPDATED
8	8	NOT_RELEVANT_FOR_POWERCATCH
\.


--
-- TOC entry 2641 (class 0 OID 27443)
-- Dependencies: 220
-- Data for Name: objektinformasjon; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY objektinformasjon (tid, xml) FROM stdin;
\.


--
-- TOC entry 2642 (class 0 OID 27449)
-- Dependencies: 221
-- Data for Name: sjekkpunkt; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY sjekkpunkt (tid, id, xml) FROM stdin;
\.


--
-- TOC entry 2600 (class 0 OID 27145)
-- Dependencies: 179
-- Data for Name: unique_controlpoints; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY unique_controlpoints (id, xml, updateid) FROM stdin;
\.


--
-- TOC entry 2643 (class 0 OID 27455)
-- Dependencies: 222
-- Data for Name: vedlikeholdsobjekt; Type: TABLE DATA; Schema: netbas; Owner: powercatch
--

COPY vedlikeholdsobjekt (tid, wid, oid, xml, issue_values, closed, status_id, updated) FROM stdin;
\.


SET search_path = prosjekt, pg_catalog;

--
-- TOC entry 2644 (class 0 OID 27461)
-- Dependencies: 223
-- Data for Name: activemq_failures; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY activemq_failures (issue_id, created, id, type, queue, message) FROM stdin;
\.


--
-- TOC entry 2645 (class 0 OID 27468)
-- Dependencies: 224
-- Data for Name: customfield; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY customfield (id, nr, navn, endret_av, endret_dato, slettet, updateid, locale) FROM stdin;
1	\N	PC_SHW_01_DANGER_OF_BASEMENT_SIDESLIP	\N	2013-03-12 10:59:15.444+01	0	1	no_NO
2	\N	PC_SHW_01A_ACTION_FOR_POINT_01	\N	2013-03-12 10:59:15.444+01	0	1	no_NO
5	\N	PC_SHW_03_ALTITUDE	\N	2013-03-13 08:46:42.514+01	0	1	no_NO
26	\N	PC_SHW_13A_ACTION_FOR_POINT_13	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
41	\N	PC_SHW_21_DANGER_FOR_CIVILIANS	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
67	\N	PC_ASSEMBLY_STRAIN_RELIEF	\N	2014-01-21 14:24:52.956+01	0	1	no_NO
85	\N	PC_ASSEMBLY_DISASSEMBLY_SUPPORTING_BAR	\N	2014-01-22 10:14:19.517+01	0	1	no_NO
4	\N	PC_SHW_02A_ACTION_FOR_POINT_02	\N	2013-03-13 08:44:40.092+01	0	1	no_NO
11	\N	PC_SHW_06_INSTALLATION_NOISE_LEVEL	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
12	\N	PC_SHW_06A_ACTION_FOR_POINT_06	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
13	\N	PC_SHW_07_FALLING_TREES	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
14	\N	PC_SHW_07A_ACTION_FOR_POINT_07	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
15	\N	PC_SHW_08_WATER_MOISTURE	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
16	\N	PC_SHW_08A_ACTION_FOR_POINT_08	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
17	\N	PC_SHW_09_PRESENCE_OF_VEGETATION_FUNGUS_ROT	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
18	\N	PC_SHW_09A_ACTION_FOR_POINT_09	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
19	\N	PC_SHW_10_PRESENCE_OF_FAUNA_ANIMALS	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
20	\N	PC_SHW_10A_ACTION_FOR_POINT_10	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
21	\N	PC_SHW_11_WIND	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
22	\N	PC_SHW_11A_ACTION_FOR_POINT_11	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
23	\N	PC_SHW_12_SNOW	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
24	\N	PC_SHW_12A_ACTION_FOR_POINT_12	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
25	\N	PC_SHW_13_FLOODING	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
27	\N	PC_SHW_14_TEMPERATURE	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
28	\N	PC_SHW_14A_ACTION_FOR_POINT_14	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
29	\N	PC_SHW_15_PRESENCE_OF_CORROSIVE_ENVIRONMENT	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
30	\N	PC_SHW_15A_ACTION_FOR_POINT_15	\N	2013-03-13 08:59:07.018+01	0	1	no_NO
31	\N	PC_SHW_16_RISK_OF_POLLUTION	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
32	\N	PC_SHW_16A_ACTION_FOR_POINT_16	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
33	\N	PC_SHW_17_AESTETHICS	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
34	\N	PC_SHW_17A_ACTION_FOR_POINT_17	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
35	\N	PC_SHW_18_ELECTRICAL_AND_MAGNETIC_FIELDS	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
36	\N	PC_SHW_18A_ACTION_FOR_POINT_18	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
37	\N	PC_SHW_19_DELIVERY_RELIABILITY	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
38	\N	PC_SHW_19A_ACTION_FOR_POINT_19	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
39	\N	PC_SHW_20_FIRE_PROTECTION	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
40	\N	PC_SHW_20A_ACTION_FOR_POINT_20	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
42	\N	PC_SHW_21A_ACTION_FOR_POINT_21	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
43	\N	PC_SHW_22_OTHER_RISKS	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
44	\N	PC_SHW_22A_ACTION_FOR_POINT_22	\N	2013-03-13 09:06:32.416+01	0	1	no_NO
46	\N	PC_BASEMENT_POLE	\N	2013-04-09 10:05:36.122+02	0	1	no_NO
45	\N	PC_TRANSPORT	\N	2013-04-03 15:47:08.94+02	0	1	no_NO
47	\N	PC_ROCK_DRILL_USAGE	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
48	\N	PC_POLE_ERECTION	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
49	\N	PC_LIFTING	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
50	\N	PC_IRON_CUTTING	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
51	\N	PC_CONNECTION_LV_CABLE	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
52	\N	PC_CONNECTION_HV_CABLE	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
53	\N	PC_CABLE_LABELLING	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
54	\N	PC_GROUNDING_CONNECTION	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
55	\N	PC_LONG_CARGO	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
56	\N	PC_HEAVY_CARGO	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
57	\N	PC_LIFTING_HOISTING	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
58	\N	PC_BROAD_CARGO	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
59	\N	PC_POLE_ERECTION_MANUAL	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
60	\N	PC_POLE_ERECTION_MACHINE	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
61	\N	PC_BRACING_WIRE_ASSEMBLY	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
62	\N	PC_USE_OF_DRAW_TOOLS	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
63	\N	PC_WINCH	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
64	\N	PC_POLE_CLIMBING	\N	2013-04-09 10:29:12.568+02	0	1	no_NO
65	\N	PC_BASEMENT_BLASTING_WORK	\N	2014-01-21 14:18:17.008+01	0	1	no_NO
66	\N	PC_ASSEMBLY_CABLE_DUCT	\N	2014-01-21 14:21:46.918+01	0	1	no_NO
68	\N	PC_HOIST_CABLE_IN_POLE	\N	2014-01-21 14:31:09.594+01	0	1	no_NO
69	\N	PC_DISMANTLE_CABLE	\N	2014-01-21 14:34:33.905+01	0	1	no_NO
70	\N	PC_CLEANING	\N	2014-01-21 14:37:11.328+01	0	1	no_NO
71	\N	PC_PRESSURE_BRACKET	\N	2014-01-21 14:39:34.071+01	0	1	no_NO
72	\N	PC_CRIMPLE_HEAT	\N	2014-01-21 14:41:20.39+01	0	1	no_NO
73	\N	PC_DIGGING_PLOT_TRANSFORMATOR	\N	2014-01-21 14:49:01.211+01	0	1	no_NO
74	\N	PC_ASSEMBLY_BASEMENT_KIOSK	\N	2014-01-21 14:56:49.063+01	0	1	no_NO
75	\N	PC_DIGGING_DITCH	\N	2014-01-21 21:49:16.902+01	0	1	no_NO
76	\N	PC_ASSEMBLY_CABLE_PIPE	\N	2014-01-22 08:13:00.905+01	0	1	no_NO
77	\N	PC_SWITCH_ATTACHMENT	\N	2014-01-22 08:15:52.024+01	0	1	no_NO
78	\N	PC_SWITCHBOARD_ASSEMBLY	\N	2014-01-22 08:18:19.502+01	0	1	no_NO
79	\N	PC_DISASSEMBLY_OLD_SWITCH	\N	2014-01-22 08:41:48.597+01	0	1	no_NO
80	\N	PC_SWITCH_TRANSPORTATION	\N	2014-01-22 08:48:15.554+01	0	1	no_NO
81	\N	PC_ASSEMBLY_NEW_SWITCH	\N	2014-01-22 09:59:37.188+01	0	1	no_NO
6	\N	PC_SHW_03A_ACTION_FOR_POINT_03	\N	2013-03-13 08:46:42.514+01	0	1	no_NO
7	\N	PC_SHW_04_INSTALLATION_PLACEMENT_MECHANICAL_IMPACT	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
8	\N	PC_SHW_04A_ACTION_FOR_POINT_04	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
9	\N	PC_SHW_05_VIBRATION	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
10	\N	PC_SHW_05A_ACTION_FOR_POINT_05	\N	2013-03-13 08:52:49.839+01	0	1	no_NO
82	\N	PC_CONNECT_DISSCONNECT_HV_CABLE	\N	2014-01-22 10:00:35.803+01	0	1	no_NO
83	\N	PC_ASSEMBLY_BASEMENT_SUBSTATION	\N	2014-01-22 10:06:22.593+01	0	1	no_NO
84	\N	PC_ASSEMBLY_DISASSEMBLY_CABINET	\N	2014-01-22 10:10:27.775+01	0	1	no_NO
86	\N	PC_ASSEMBLY_METER_DIRECTLY_MEASURED	\N	2014-01-22 10:17:42.444+01	0	1	no_NO
87	\N	PC_ASSEMBLY_METER_TRANSFORMATOR_MEASURED	\N	2014-01-22 10:22:06.682+01	0	1	no_NO
88	\N	PC_ASSEMBLY_MEASURING_DEVICE	\N	2014-01-23 09:54:37.692+01	0	1	no_NO
89	\N	PC_GENERIC_SAFETY_ASSESSMENT	\N	2014-03-14 10:00:00+01	0	1	no_NO
3	\N	PC_SHW_02_DANGER_OF_SLIDE	\N	2013-03-13 08:44:40.092+01	0	1	no_NO
\.


--
-- TOC entry 2646 (class 0 OID 27474)
-- Dependencies: 225
-- Data for Name: fc_connection; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY fc_connection (id_issuetype, id_value, sortorder, deleted, updateid, changed_by, changed_date) FROM stdin;
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:47.665+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_FC_SS_REN6015	2	0	1	admin	2015-01-27 14:58:47.673+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_FC_OPERATION_LABEL_ROUTINES	3	0	1	admin	2015-01-27 14:58:47.681+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_FC_DATA_SYSTEM_UPDATE_NOTES	4	0	1	admin	2015-01-27 14:58:47.691+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_FC_CLEANUP	5	0	1	admin	2015-01-27 14:58:47.699+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:47.708+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_ON_CUSHION	2	0	1	admin	2015-01-27 14:58:47.717+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_MUTUAL_DISTANCE	3	0	1	admin	2015-01-27 14:58:47.727+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_BEND	4	0	1	admin	2015-01-27 14:58:47.736+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_LABEL_REGULATIONS	5	0	1	admin	2015-01-27 14:58:47.745+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_PIPE_PLUGGED	6	0	1	admin	2015-01-27 14:58:47.753+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_PLUG_SHORTING	7	0	1	admin	2015-01-27 14:58:47.76+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_CROSSING_CLOSE_LV	8	0	1	admin	2015-01-27 14:58:47.769+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_CABINET_SS_POLE	9	0	1	admin	2015-01-27 14:58:47.776+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_COVER	10	0	1	admin	2015-01-27 14:58:47.785+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CABLE_BAND_MOUNT	11	0	1	admin	2015-01-27 14:58:47.793+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_DATA_SYSTEM_UPDATE_NOTES	12	0	1	admin	2015-01-27 14:58:47.802+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_FC_CLEANUP	13	0	1	admin	2015-01-27 14:58:47.81+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:47.821+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_EXTENSION_VENDOR_DESCRIPTION	2	0	1	admin	2015-01-27 14:58:47.831+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_TERMINATION_VENDOR_DESCRIPTION	3	0	1	admin	2015-01-27 14:58:47.84+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_TERMINATION_DISTANCE	4	0	1	admin	2015-01-27 14:58:47.852+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_CONNECTION_MOMENT	5	0	1	admin	2015-01-27 14:58:47.861+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_SHIELD_GROUND	6	0	1	admin	2015-01-27 14:58:47.87+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_TERMINATION_CLEAN	7	0	1	admin	2015-01-27 14:58:47.878+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_MEASURE_TEST	8	0	1	admin	2015-01-27 14:58:47.888+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CABLE_CUT_TEST	9	0	1	admin	2015-01-27 14:58:47.896+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_FC_CLEANUP	10	0	1	admin	2015-01-27 14:58:47.903+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:47.912+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_EXTENSION_VENDOR_DESCRIPTION	2	0	1	admin	2015-01-27 14:58:47.92+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_TERMINATION_VENDOR_DESCRIPTION	3	0	1	admin	2015-01-27 14:58:47.929+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_TERMINATION_DISTANCE	4	0	1	admin	2015-01-27 14:58:47.939+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_CONNECTION_MOMENT	5	0	1	admin	2015-01-27 14:58:47.95+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_SHIELD_GROUND	6	0	1	admin	2015-01-27 14:58:47.959+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_TERMINATION_CLEAN	7	0	1	admin	2015-01-27 14:58:47.97+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_MEASURE_TEST	8	0	1	admin	2015-01-27 14:58:47.977+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CABLE_CUT_TEST	9	0	1	admin	2015-01-27 14:58:47.987+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_FC_CLEANUP	10	0	1	admin	2015-01-27 14:58:47.995+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.003+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_METER_FUSE_SIZE_INSTALLATION	2	0	1	admin	2015-01-27 14:58:48.011+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_METER_MARK_COLOR	3	0	1	admin	2015-01-27 14:58:48.02+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_METER_AVAILABILITY	4	0	1	admin	2015-01-27 14:58:48.028+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_VOLTAGE_MEASURE	5	0	1	admin	2015-01-27 14:58:48.035+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_METER_CONNECTION_TIGHTEN	6	0	1	admin	2015-01-27 14:58:48.043+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_DATA_SYSTEM_UPDATE_NOTES	7	0	1	admin	2015-01-27 14:58:48.051+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_METER_COMMUNICATION_TEST	8	0	1	admin	2015-01-27 14:58:48.058+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_INSTALLATION_VOLTAGE	9	0	1	admin	2015-01-27 14:58:48.066+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_TRANSFORMATOR_CONSUMPTION_VISIBLE	10	0	1	admin	2015-01-27 14:58:48.076+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_TRANSFORMATOR_DISTANCE	11	0	1	admin	2015-01-27 14:58:48.087+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_METER_TRANSFORMATOR_AVAILABILITY	12	0	1	admin	2015-01-27 14:58:48.097+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_SEAL	13	0	1	admin	2015-01-27 14:58:48.108+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_WATER_BEND	14	0	1	admin	2015-01-27 14:58:48.12+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_POLE_DISTANCE_NAIL	15	0	1	admin	2015-01-27 14:58:48.128+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_PROTECTION	16	0	1	admin	2015-01-27 14:58:48.136+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_GROUND_POLEBASE	17	0	1	admin	2015-01-27 14:58:48.143+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_EX_POLE	18	0	1	admin	2015-01-27 14:58:48.151+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_GROUND_REN4101	19	0	1	admin	2015-01-27 14:58:48.158+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_FOUNDATION_CABINET	20	0	1	admin	2015-01-27 14:58:48.166+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_CABINET_COVER	21	0	1	admin	2015-01-27 14:58:48.174+01
PC_ISSUETYPE_WO_NET	PC_FC_NOT_RELEVANT	1	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CABLE_CONNECTION_MOMENT	22	0	1	admin	2015-01-27 14:58:48.181+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_METER_MOUNT_REN4100	23	0	1	admin	2015-01-27 14:58:48.19+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_FOUNDATION_CABINET_REN4100	24	0	1	admin	2015-01-27 14:58:48.197+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_DATA_SYSTEM_UPDATE_NOTES	25	0	1	admin	2015-01-27 14:58:48.205+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_FC_CLEANUP	26	0	1	admin	2015-01-27 14:58:48.213+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.221+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_FC_CABLE_WATER_BEND	2	0	1	admin	2015-01-27 14:58:48.228+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_FC_CABLE_POLE_DISTANCE_NAIL	3	0	1	admin	2015-01-27 14:58:48.238+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_FC_CABLE_PROTECTION	4	0	1	admin	2015-01-27 14:58:48.248+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_FC_CABLE_GROUND_POLEBASE	5	0	1	admin	2015-01-27 14:58:48.257+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_FC_CLEANUP	6	0	1	admin	2015-01-27 14:58:48.265+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.272+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_DITCH_URBAN	2	0	1	admin	2015-01-27 14:58:48.283+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_DITCH_WILD	3	0	1	admin	2015-01-27 14:58:48.293+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_DITCH_CABLE_PIPE	4	0	1	admin	2015-01-27 14:58:48.302+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_DITCH_AGRICULTURE	5	0	1	admin	2015-01-27 14:58:48.312+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_DITCH_SHALLOW	6	0	1	admin	2015-01-27 14:58:48.32+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_MASS_BACKFILL	7	0	1	admin	2015-01-27 14:58:48.328+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_MASS_FILLING	8	0	1	admin	2015-01-27 14:58:48.337+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_TOP_LEVELING	9	0	1	admin	2015-01-27 14:58:48.346+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_ASPHALT_AREA_MEASURE	10	0	1	admin	2015-01-27 14:58:48.353+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_PRIVATE_AGREEMENT	11	0	1	admin	2015-01-27 14:58:48.361+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_CABLE_GROUND_REN4101	12	0	1	admin	2015-01-27 14:58:48.368+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_CABLE_BEND	13	0	1	admin	2015-01-27 14:58:48.376+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_CABLE_BAND_MOUNT	14	0	1	admin	2015-01-27 14:58:48.384+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_DATA_SYSTEM_UPDATE_NOTES	15	0	1	admin	2015-01-27 14:58:48.394+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_FC_CLEANUP	16	0	1	admin	2015-01-27 14:58:48.402+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.41+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_FC_MEASURE_REN8028	2	0	1	admin	2015-01-27 14:58:48.419+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_FC_MEASURE_INTERNAL_ROUTINE	3	0	1	admin	2015-01-27 14:58:48.428+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_FC_GROUND_RECONNECT	4	0	1	admin	2015-01-27 14:58:48.438+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_FC_MEASURE_VALUE_DOCUMENT	5	0	1	admin	2015-01-27 14:58:48.448+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_FC_GROUND_PLATE_MEASURE_LABEL	6	0	1	admin	2015-01-27 14:58:48.461+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_FC_CLEANUP	7	0	1	admin	2015-01-27 14:58:48.473+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.482+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_SS_MOUNT_VENDOR_DESCRIPTION	2	0	1	admin	2015-01-27 14:58:48.492+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_SS_HORIZONTAL	3	0	1	admin	2015-01-27 14:58:48.502+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_CABLE_NO_OBSTACLES	4	0	1	admin	2015-01-27 14:58:48.511+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_SS_GAS_VOLUME	5	0	1	admin	2015-01-27 14:58:48.52+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_SS_PRESSURE_RELIEF_DIRECTION	6	0	1	admin	2015-01-27 14:58:48.533+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_SS_FUNCTIONAL_TEST	7	0	1	admin	2015-01-27 14:58:48.541+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_SS_DOOR_OPEN	8	0	1	admin	2015-01-27 14:58:48.551+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_CLEANUP	9	0	1	admin	2015-01-27 14:58:48.579+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_FC_DATA_SYSTEM_UPDATE_NOTES	10	0	1	admin	2015-01-27 14:58:48.587+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.596+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_SWITCH_GROUND_REN8011	2	0	1	admin	2015-01-27 14:58:48.604+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_SWITCH_OPERATION_GROUND_REN8011	3	0	1	admin	2015-01-27 14:58:48.613+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_POLE_HEIGHT_OVER_GROUND	4	0	1	admin	2015-01-27 14:58:48.623+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_SWITCH_OPERATION	5	0	1	admin	2015-01-27 14:58:48.633+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_POLE_CLIMBING_STEPS	6	0	1	admin	2015-01-27 14:58:48.641+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_DESCRIPTION_REN2011	7	0	1	admin	2015-01-27 14:58:48.649+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_MECHANICAL_JOINTS_TIGHTEN	8	0	1	admin	2015-01-27 14:58:48.657+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_CONNECTIONS	9	0	1	admin	2015-01-27 14:58:48.669+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_LABEL_ROUTINE	10	0	1	admin	2015-01-27 14:58:48.68+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_SWITCH_LOCK_MOUNT	11	0	1	admin	2015-01-27 14:58:48.691+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_FC_DATA_SYSTEM_UPDATE_NOTES	12	0	1	admin	2015-01-27 14:58:48.703+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.714+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_LINE_SAG	2	0	1	admin	2015-01-27 14:58:48.725+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_LINE_HEIGHT_GROUND	3	0	1	admin	2015-01-27 14:58:48.736+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_LINE_HEIGHT_ROAD	4	0	1	admin	2015-01-27 14:58:48.747+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_INTERMEDIATE_FIXTURE_MOUNT	5	0	1	admin	2015-01-27 14:58:48.759+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_END_FIXTURE_MOUNT	6	0	1	admin	2015-01-27 14:58:48.771+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_CLAMP	7	0	1	admin	2015-01-27 14:58:48.783+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_END_PLUG	8	0	1	admin	2015-01-27 14:58:48.796+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_ROPE_FIXTURE	9	0	1	admin	2015-01-27 14:58:48.808+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_DATA_SYSTEM_UPDATE_NOTES	10	0	1	admin	2015-01-27 14:58:48.823+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_FC_CLEANUP	11	0	1	admin	2015-01-27 14:58:48.837+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.849+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_FC_MATERIAL_DELIVER	2	0	1	admin	2015-01-27 14:58:48.86+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_FC_MATERIAL_DAMAGE	3	0	1	admin	2015-01-27 14:58:48.873+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_FC_MATERIAL_AMOUNT_TYPE	4	0	1	admin	2015-01-27 14:58:48.887+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_FC_MATERIAL_OBSTACLE	5	0	1	admin	2015-01-27 14:58:48.899+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:48.91+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_METER_FUSE_SIZE_INSTALLATION	2	0	1	admin	2015-01-27 14:58:48.921+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_METER_MARK_COLOR	3	0	1	admin	2015-01-27 14:58:48.934+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_METER_AVAILABILITY	4	0	1	admin	2015-01-27 14:58:48.945+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_VOLTAGE_MEASURE	5	0	1	admin	2015-01-27 14:58:48.958+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_METER_CONNECTION_TIGHTEN	6	0	1	admin	2015-01-27 14:58:48.969+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_DATA_SYSTEM_UPDATE_NOTES	7	0	1	admin	2015-01-27 14:58:48.982+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_METER_COMMUNICATION_TEST	8	0	1	admin	2015-01-27 14:58:48.995+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_INSTALLATION_VOLTAGE	9	0	1	admin	2015-01-27 14:58:49.008+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_TRANSFORMATOR_CONSUMPTION_VISIBLE	10	0	1	admin	2015-01-27 14:58:49.019+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_TRANSFORMATOR_DISTANCE	11	0	1	admin	2015-01-27 14:58:49.033+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_METER_TRANSFORMATOR_AVAILABILITY	12	0	1	admin	2015-01-27 14:58:49.043+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_FC_SEAL	13	0	1	admin	2015-01-27 14:58:49.055+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.066+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_SS_CONSUMPTION	2	0	1	admin	2015-01-27 14:58:49.077+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_SS_GROUND_FIX_SUPPORT	3	0	1	admin	2015-01-27 14:58:49.088+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_OIL_LEAK	4	0	1	admin	2015-01-27 14:58:49.099+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_OIL_LEVEL	5	0	1	admin	2015-01-27 14:58:49.11+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_SIGN_VISIBLE	6	0	1	admin	2015-01-27 14:58:49.122+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_FUSE_CORRECT_MOUNT	7	0	1	admin	2015-01-27 14:58:49.133+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_CABLE_CONNECTION_MOMENT	8	0	1	admin	2015-01-27 14:58:49.144+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_CABLE_DISTANCE_MINIMUM	9	0	1	admin	2015-01-27 14:58:49.158+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_THROUGHPUT_WHOLE	10	0	1	admin	2015-01-27 14:58:49.168+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_GROUND_CONNECT	11	0	1	admin	2015-01-27 14:58:49.176+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_DATA_SYSTEM_UPDATE_NOTES	12	0	1	admin	2015-01-27 14:58:49.184+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_OLD_TRANSFORMATOR_STORAGE	13	0	1	admin	2015-01-27 14:58:49.192+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_FC_CLEANUP	14	0	1	admin	2015-01-27 14:58:49.201+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.21+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_POLE_DIGGINGDEPTH	2	0	1	admin	2015-01-27 14:58:49.218+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_POLE_VERTICAL	3	0	1	admin	2015-01-27 14:58:49.227+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_WIRE_MOUNT	4	0	1	admin	2015-01-27 14:58:49.235+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_EARTH_BAND_DIAMETER	5	0	1	admin	2015-01-27 14:58:49.242+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_DATA_SYSTEM_UPDATE_NOTES	6	0	1	admin	2015-01-27 14:58:49.251+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_POLE_HEIGHT_OVER_GROUND	7	0	1	admin	2015-01-27 14:58:49.26+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_POLE_TOP_CAP	8	0	1	admin	2015-01-27 14:58:49.268+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_FC_CLEANUP	9	0	1	admin	2015-01-27 14:58:49.275+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.284+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_GROUND_GLOBAL_REN8011	2	0	1	admin	2015-01-27 14:58:49.292+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_GROUND_REN8011	3	0	1	admin	2015-01-27 14:58:49.3+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_CABLE_DISTANCE	4	0	1	admin	2015-01-27 14:58:49.31+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_CONSTRUCTION_DAMAGE	5	0	1	admin	2015-01-27 14:58:49.321+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_ORAL_AGREEMENT_FINISH	6	0	1	admin	2015-01-27 14:58:49.331+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_LABEL_ROUTINE	7	0	1	admin	2015-01-27 14:58:49.34+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_LOCK_CORRECT_SYSTEM	8	0	1	admin	2015-01-27 14:58:49.349+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_DATA_SYSTEM_UPDATE_NOTES	9	0	1	admin	2015-01-27 14:58:49.357+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_FC_CLEANUP	10	0	1	admin	2015-01-27 14:58:49.365+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.373+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_POLE_TRANSFORMATOR_GROUND_REN8011	2	0	1	admin	2015-01-27 14:58:49.381+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_POLE_STATION_GROUND_REN8011	3	0	1	admin	2015-01-27 14:58:49.389+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_POLE_GROUND_ROUTINES_REN8011	4	0	1	admin	2015-01-27 14:58:49.398+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_CABLE_CONTROL_SS_GROUND	5	0	1	admin	2015-01-27 14:58:49.408+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_CABLE_CONNECTION	6	0	1	admin	2015-01-27 14:58:49.417+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_POLE_CLIMBING_STEPS	7	0	1	admin	2015-01-27 14:58:49.427+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_CONSTRUCTION_DAMAGE	8	0	1	admin	2015-01-27 14:58:49.439+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_FIX_SOLID	9	0	1	admin	2015-01-27 14:58:49.452+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_OIL_LEAK	10	0	1	admin	2015-01-27 14:58:49.462+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_ORAL_AGREEMENT_FINISH	11	0	1	admin	2015-01-27 14:58:49.47+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_LABEL_ROUTINE	12	0	1	admin	2015-01-27 14:58:49.48+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_DATA_SYSTEM_UPDATE_NOTES	13	0	1	admin	2015-01-27 14:58:49.49+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_LOCK_CORRECT_SYSTEM	14	0	1	admin	2015-01-27 14:58:49.498+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_FC_CLEANUP	15	0	1	admin	2015-01-27 14:58:49.506+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.516+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABINET_BORDER	2	0	1	admin	2015-01-27 14:58:49.526+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABINET_DOOR_OPEN	3	0	1	admin	2015-01-27 14:58:49.534+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABINET_HORIZONTAL	4	0	1	admin	2015-01-27 14:58:49.542+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABINET_SNOWMARKER	5	0	1	admin	2015-01-27 14:58:49.55+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_LABEL_ROUTINE	6	0	1	admin	2015-01-27 14:58:49.558+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABINET_FROST_FREE	7	0	1	admin	2015-01-27 14:58:49.566+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABINET_PLACEMENT_FLAMMABLE_WALL	8	0	1	admin	2015-01-27 14:58:49.577+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABINET_STABLE	9	0	1	admin	2015-01-27 14:58:49.585+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_BUS_MOUNT	10	0	1	admin	2015-01-27 14:58:49.594+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_MODULES_MOUNT	11	0	1	admin	2015-01-27 14:58:49.602+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_SWITCH_TEST_NO_VOLTAGE	12	0	1	admin	2015-01-27 14:58:49.61+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CABLE_ADDRESS	13	0	1	admin	2015-01-27 14:58:49.618+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_PHASE_SEQUENCE	14	0	1	admin	2015-01-27 14:58:49.627+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_DATA_SYSTEM_UPDATE_NOTES	15	0	1	admin	2015-01-27 14:58:49.638+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_FC_CLEANUP	16	0	1	admin	2015-01-27 14:58:49.646+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.655+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_GROUND_GLOBAL_REN8011	2	0	1	admin	2015-01-27 14:58:49.664+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_GROUND_REN8011	3	0	1	admin	2015-01-27 14:58:49.676+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_FOUNDATION_REN6028	4	0	1	admin	2015-01-27 14:58:49.686+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_ORAL_AGREEMENT_FINISH	5	0	1	admin	2015-01-27 14:58:49.697+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_DRAIN	6	0	1	admin	2015-01-27 14:58:49.707+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_FOUNDATION_LOCATION	7	0	1	admin	2015-01-27 14:58:49.717+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_FC_CLEANUP	8	0	1	admin	2015-01-27 14:58:49.728+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.741+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_CABLE_CABINET_SHARP_EDGES	2	0	1	admin	2015-01-27 14:58:49.751+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_CABLE_POLE_FIX	3	0	1	admin	2015-01-27 14:58:49.764+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_EXCESS_CABLE_PROTECTED	4	0	1	admin	2015-01-27 14:58:49.774+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_CABLE_SQUEEZE	5	0	1	admin	2015-01-27 14:58:49.786+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_PHASE_VOLTAGE	6	0	1	admin	2015-01-27 14:58:49.831+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_GROUND_FAULT_SWITCH	7	0	1	admin	2015-01-27 14:58:49.842+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_DATA_SYSTEM_UPDATE_NOTES	8	0	1	admin	2015-01-27 14:58:49.855+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_LOCK_POSSIBLE	9	0	1	admin	2015-01-27 14:58:49.868+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_CLEANUP	10	0	1	admin	2015-01-27 14:58:49.882+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:49.894+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_SS_CONSUMPTION	2	0	1	admin	2015-01-27 14:58:49.906+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_SS_GROUND_FIX_SUPPORT	3	0	1	admin	2015-01-27 14:58:49.919+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_OIL_LEAK	4	0	1	admin	2015-01-27 14:58:49.928+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_OIL_LEVEL	5	0	1	admin	2015-01-27 14:58:49.94+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_SIGN_VISIBLE	6	0	1	admin	2015-01-27 14:58:49.952+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_FUSE_CORRECT_MOUNT	7	0	1	admin	2015-01-27 14:58:49.963+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_LOADSWITCH_SET	8	0	1	admin	2015-01-27 14:58:49.974+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_CABLE_CONNECTION_MOMENT	9	0	1	admin	2015-01-27 14:58:49.985+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_THROUGHPUT_WHOLE	10	0	1	admin	2015-01-27 14:58:49.995+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_GROUND_CONNECT	11	0	1	admin	2015-01-27 14:58:50.006+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_DATA_SYSTEM_UPDATE_NOTES	12	0	1	admin	2015-01-27 14:58:50.017+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_FC_CLEANUP	13	0	1	admin	2015-01-27 14:58:50.027+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_NOT_RELEVANT	1	0	1	admin	2015-01-27 14:58:50.038+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_CENTRAL_DAMAGE	2	0	1	admin	2015-01-27 14:58:50.051+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_METER_READING	3	0	1	admin	2015-01-27 14:58:50.065+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_DAMAGE_REGISTER	4	0	1	admin	2015-01-27 14:58:50.077+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_FC_CLEANUP	5	0	1	admin	2015-01-27 14:58:50.089+01
PC_ISSUETYPE_WO_NET	PC_FC_WORK_AS_INSTRUCTED	1	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_FC_AREA_CLEANUP	2	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_FC_CONTRACT_NOT_NEEDED	3	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_FC_CONTRACT_ATTACHED	4	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_FC_NOT_RELEVANT	1	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_FC_SS_REN6015	2	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_FC_OPERATION_LABEL_ROUTINES	3	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_FC_DATA_SYSTEM_UPDATE_NOTES	4	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_FC_CLEANUP	5	0	1	admin	2016-11-01 12:55:51.812+01
\.


--
-- TOC entry 2647 (class 0 OID 27485)
-- Dependencies: 226
-- Data for Name: fc_value; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY fc_value (pc_key, locale, pc_text, deleted, updateid, changed_by, changed_date) FROM stdin;
PC_FC_ASPHALT_AREA_MEASURE	no_NO	Asfaltareal er oppmÃ¥lt	0	1	admin	2015-01-27 14:58:46.461+01
PC_FC_BUS_MOUNT	no_NO	Samleskinneplate er montert og godt festet	0	1	admin	2015-01-27 14:58:46.468+01
PC_FC_CABINET_BORDER	no_NO	Kabelskap montert i grenseskille	0	1	admin	2015-01-27 14:58:46.476+01
PC_FC_CABINET_DOOR_OPEN	no_NO	Kontrollert at dÃ¸rer lar seg lett Ã¥pne	0	1	admin	2015-01-27 14:58:46.484+01
PC_FC_CABINET_FROST_FREE	no_NO	Masser rundt skapet er telefrie	0	1	admin	2015-01-27 14:58:46.492+01
PC_FC_CABINET_HORIZONTAL	no_NO	Skapet er i vater	0	1	admin	2015-01-27 14:58:46.5+01
PC_FC_CABINET_PLACEMENT_FLAMMABLE_WALL	no_NO	Skapet er plassert riktig i forhold til brennbar vegg	0	1	admin	2015-01-27 14:58:46.507+01
PC_FC_CABINET_SNOWMARKER	no_NO	SnÃ¸markÃ¸r er montert	0	1	admin	2015-01-27 14:58:46.515+01
PC_FC_CABINET_STABLE	no_NO	Kontrollert at skapet stÃ¥r rett og stabilt	0	1	admin	2015-01-27 14:58:46.522+01
PC_FC_CABLE_ADDRESS	no_NO	Kabler er merket med adresse	0	1	admin	2015-01-27 14:58:46.53+01
PC_FC_CABLE_BAND_MOUNT	no_NO	KabelbÃ¥nd er montert riktig	0	1	admin	2015-01-27 14:58:46.537+01
PC_FC_CABLE_BEND	no_NO	Alle kabler er kontrollert for skarpe bÃ¸yer	0	1	admin	2015-01-27 14:58:46.545+01
PC_FC_CABLE_CABINET_COVER	no_NO	InnfÃ¸ring i skap er beskyttet med nÃ¸dvendig overdekning	0	1	admin	2015-01-27 14:58:46.553+01
PC_FC_CABLE_CABINET_SHARP_EDGES	no_NO	KabelinnfÃ¸ring i skap er sjekket for skarpe kanter	0	1	admin	2015-01-27 14:58:46.562+01
PC_FC_CABLE_CABINET_SS_POLE	no_NO	InnfÃ¸ring i skap/nettstasjoner og oppfÃ¸ring i mast er sjekket, og ok	0	1	admin	2015-01-27 14:58:46.57+01
PC_FC_CABLE_CONNECTION	no_NO	Alle kabeltilkoblinger er kontrollert	0	1	admin	2015-01-27 14:58:46.578+01
PC_FC_CABLE_CONNECTION_MOMENT	no_NO	Tilkoblinger er foretatt med riktig moment	0	1	admin	2015-01-27 14:58:46.586+01
PC_FC_CABLE_CONTROL_SS_GROUND	no_NO	KabelfÃ¸ringer kontrollert, herunder ogsÃ¥ kabler fra nettstasjon og ned i jorden	0	1	admin	2015-01-27 14:58:46.594+01
PC_FC_CABLE_COVER	no_NO	Overdekning av kabler er ok	0	1	admin	2015-01-27 14:58:46.601+01
PC_FC_CABLE_CROSSING_CLOSE_LV	no_NO	Kryssinger og nÃ¦rfÃ¸ringer med andre svakstrÃ¸mskabler er ok	0	1	admin	2015-01-27 14:58:46.609+01
PC_FC_CABLE_CUT_TEST	no_NO	Kappetest er utfÃ¸rt	0	1	admin	2015-01-27 14:58:46.619+01
PC_FC_CABLE_DISTANCE	no_NO	Alle kabelfÃ¸ringer og avstander er kontrollert	0	1	admin	2015-01-27 14:58:46.628+01
PC_FC_CABLE_DISTANCE_MINIMUM	no_NO	Minimumsavstander for kabelfÃ¸ringer er kontrollert	0	1	admin	2015-01-27 14:58:46.636+01
PC_FC_CABLE_EXTENSION_VENDOR_DESCRIPTION	no_NO	Beskrivelser fra leverandÃ¸r pÃ¥ skjÃ¸t er fulgt	0	1	admin	2015-01-27 14:58:46.644+01
PC_FC_CABLE_FOUNDATION_CABINET	no_NO	Kabel er tilkoblet i grunnmursskap	0	1	admin	2015-01-27 14:58:46.652+01
PC_FC_CABLE_GROUND_POLEBASE	no_NO	Kabel er fÃ¸rt ned i jorden og tildekket ved stolperot	0	1	admin	2015-01-27 14:58:46.66+01
PC_FC_CABLE_GROUND_REN4101	no_NO	Kabel er forlagt i jorden etter gjeldende REN-blad 4101	0	1	admin	2015-01-27 14:58:46.667+01
PC_FC_CABLE_LABEL_REGULATIONS	no_NO	Alle kabler er merket ihht forskrifter	0	1	admin	2015-01-27 14:58:46.675+01
PC_FC_CABLE_MEASURE_TEST	no_NO	Kabel er megget og testet	0	1	admin	2015-01-27 14:58:46.683+01
PC_FC_CABLE_MUTUAL_DISTANCE	no_NO	Kabler er forlagt med riktig avstand innbyrdes	0	1	admin	2015-01-27 14:58:46.691+01
PC_FC_CABLE_NO_OBSTACLES	no_NO	Det er ingen hindringer for innfÃ¸ring av kabler	0	1	admin	2015-01-27 14:58:46.699+01
PC_FC_CABLE_PLUG_SHORTING	no_NO	Alle kabelender som ikke er tilkoblet er tettet og kortsluttet i endene	0	1	admin	2015-01-27 14:58:46.715+01
PC_FC_CABLE_POLE_DISTANCE_NAIL	no_NO	Kabel er festet til mast med avstandsspiker	0	1	admin	2015-01-27 14:58:46.724+01
PC_FC_CABLE_POLE_FIX	no_NO	KabelfÃ¸ring opp i mast er tilstrekkelig festet	0	1	admin	2015-01-27 14:58:46.731+01
PC_FC_CABLE_PROTECTION	no_NO	Kabelbeskyttelse er montert	0	1	admin	2015-01-27 14:58:46.739+01
PC_FC_CABLE_SHIELD_GROUND	no_NO	Skjerm i kabel er jordet	0	1	admin	2015-01-27 14:58:46.747+01
PC_FC_CABLE_SQUEEZE	no_NO	KabelfÃ¸ringer ligger ikke i klem	0	1	admin	2015-01-27 14:58:46.754+01
PC_FC_CABLE_TERMINATION_CLEAN	no_NO	Endeavslutning er rengjort for smuss etter montasje	0	1	admin	2015-01-27 14:58:46.762+01
PC_FC_CABLE_TERMINATION_DISTANCE	no_NO	Avstander pÃ¥ endeavslutning er kontrollmÃ¥lt, og ok	0	1	admin	2015-01-27 14:58:46.77+01
PC_FC_CABLE_TERMINATION_VENDOR_DESCRIPTION	no_NO	Beskrivelser fra leverandÃ¸r pÃ¥ endeavslutning er fulgt	0	1	admin	2015-01-27 14:58:46.778+01
PC_FC_CABLE_WATER_BEND	no_NO	Kabel beskyttet mot vannintregning i enden (vannbÃ¸y)	0	1	admin	2015-01-27 14:58:46.786+01
PC_FC_CENTRAL_DAMAGE	no_NO	Sentral er sjekket for skader	0	1	admin	2015-01-27 14:58:46.794+01
PC_FC_CLAMP	no_NO	Klemmeforbindelser er kontrollert	0	1	admin	2015-01-27 14:58:46.803+01
PC_FC_CLEANUP	no_NO	Opprydding er utfÃ¸rt	0	1	admin	2015-01-27 14:58:46.814+01
PC_FC_CONNECTIONS	no_NO	Alle tilkoblinger er kontrollert	0	1	admin	2015-01-27 14:58:46.826+01
PC_FC_CONSTRUCTION_DAMAGE	no_NO	Byggekonstruksjon er kontrollert for skader	0	1	admin	2015-01-27 14:58:46.836+01
PC_FC_DAMAGE_REGISTER	no_NO	Eventuelle skader er notert	0	1	admin	2015-01-27 14:58:46.845+01
PC_FC_DATA_SYSTEM_UPDATE_NOTES	no_NO	Notert grunnlag for oppdatering av fagsystemer	0	1	admin	2015-01-27 14:58:46.857+01
PC_FC_DESCRIPTION_REN2011	no_NO	Beskrivelser i REN-blad 2011 pkt. 18 er fulgt	0	1	admin	2015-01-27 14:58:46.867+01
PC_FC_DITCH_AGRICULTURE	no_NO	GrÃ¸ft er ihht bestemmelser om grÃ¸ft i jordbruksomrÃ¥der	0	1	admin	2015-01-27 14:58:46.875+01
PC_FC_DITCH_CABLE_PIPE	no_NO	GrÃ¸ft er ihht bestemmelser om grÃ¸ft for stikkledning	0	1	admin	2015-01-27 14:58:46.883+01
PC_FC_DITCH_SHALLOW	no_NO	GrÃ¸ft er ihht bestemmelser om grunne kabelgrÃ¸fter	0	1	admin	2015-01-27 14:58:46.892+01
PC_FC_DITCH_URBAN	no_NO	GrÃ¸ft er ihht bestemmelser om grÃ¸ft for tettbygde strÃ¸k	0	1	admin	2015-01-27 14:58:46.901+01
PC_FC_DITCH_WILD	no_NO	GrÃ¸ft er ihht bestemmelser om grÃ¸ft i utmarksomrÃ¥der	0	1	admin	2015-01-27 14:58:46.909+01
PC_FC_DRAIN	no_NO	Drenering er riktig utfÃ¸rt	0	1	admin	2015-01-27 14:58:46.917+01
PC_FC_EARTH_BAND_DIAMETER	no_NO	Jordbanddiameter er over minstekrav	0	1	admin	2015-01-27 14:58:46.925+01
PC_FC_END_FIXTURE_MOUNT	no_NO	Alle endefester er satt til	0	1	admin	2015-01-27 14:58:46.944+01
PC_FC_END_PLUG	no_NO	Endesmokk er pÃ¥satt	0	1	admin	2015-01-27 14:58:46.952+01
PC_FC_EX_POLE	no_NO	EX er tilkoblet i mast slik at det ikke oppstÃ¥r bevegelse ved tilkoblingsklemme	0	1	admin	2015-01-27 14:58:46.961+01
PC_FC_EXCESS_CABLE_PROTECTED	no_NO	OverflÃ¸dig kabel er beskyttet	0	1	admin	2015-01-27 14:58:46.969+01
PC_FC_FIX_SOLID	no_NO	BÃ¦rejern er godt festet	0	1	admin	2015-01-27 14:58:46.976+01
PC_FC_FOUNDATION_CABINET_REN4100	no_NO	Grunnmursskap er montert ihht gjeldende bestemmelser i REN-blad 4100	0	1	admin	2015-01-27 14:58:46.985+01
PC_FC_FOUNDATION_LOCATION	no_NO	Plassering og hÃ¸yder er ihht beskrivelse	0	1	admin	2015-01-27 14:58:46.993+01
PC_FC_FOUNDATION_REN6028	no_NO	Fundament er ihht beskrivelser i REN-blad 6028	0	1	admin	2015-01-27 14:58:47.001+01
PC_FC_FUSE_CORRECT_MOUNT	no_NO	Det er montert riktige sikringer for denne trafo	0	1	admin	2015-01-27 14:58:47.009+01
PC_FC_GROUND_CONNECT	no_NO	Kontrollert at jording er tilkoblet	0	1	admin	2015-01-27 14:58:47.016+01
PC_FC_GROUND_FAULT_SWITCH	no_NO	Jordfeilbryter er testet	0	1	admin	2015-01-27 14:58:47.026+01
PC_FC_GROUND_RECONNECT	no_NO	Alle frakoblinger av jording er koblet tilbake	0	1	admin	2015-01-27 14:58:47.052+01
PC_FC_INSTALLATION_VOLTAGE	no_NO	Anlegg er spenningsatt	0	1	admin	2015-01-27 14:58:47.069+01
PC_FC_INTERMEDIATE_FIXTURE_MOUNT	no_NO	Alle mellomfester er ferdig montert	0	1	admin	2015-01-27 14:58:47.078+01
PC_FC_LABEL_ROUTINE	no_NO	Merket ihht gjeldende rutiner og beskrivelser	0	1	admin	2015-01-27 14:58:47.087+01
PC_FC_LINE_HEIGHT_GROUND	no_NO	Kontrollert at hÃ¸yde over bakken er ok	0	1	admin	2015-01-27 14:58:47.097+01
PC_FC_LINE_HEIGHT_ROAD	no_NO	Kontrollert at hÃ¸yde over vei er ok	0	1	admin	2015-01-27 14:58:47.104+01
PC_FC_LINE_SAG	no_NO	Kontrollert at pilhÃ¸yde er ok	0	1	admin	2015-01-27 14:58:47.112+01
PC_FC_LOADSWITCH_SET	no_NO	Lastbryter er riktig innstilt	0	1	admin	2015-01-27 14:58:47.12+01
PC_FC_LOCK_CORRECT_SYSTEM	no_NO	Alle lÃ¥ser er kontrollert for riktig system	0	1	admin	2015-01-27 14:58:47.128+01
PC_FC_LOCK_POSSIBLE	no_NO	Forsvarlig lÃ¥sing er mulig	0	1	admin	2015-01-27 14:58:47.136+01
PC_FC_MASS_BACKFILL	no_NO	Omfyllingsmasse er ihht beskrivelser	0	1	admin	2015-01-27 14:58:47.145+01
PC_FC_MASS_FILLING	no_NO	PÃ¥fyllingsmasser er ihht beskrivelser	0	1	admin	2015-01-27 14:58:47.153+01
PC_FC_MATERIAL_AMOUNT_TYPE	no_NO	Kontrollert at det er riktig materiell og mengde	0	1	admin	2015-01-27 14:58:47.161+01
PC_FC_MATERIAL_DAMAGE	no_NO	Materiell er kontrollert for transportskader	0	1	admin	2015-01-27 14:58:47.169+01
PC_FC_MATERIAL_DELIVER	no_NO	Materiell er levert pÃ¥ anvist sted	0	1	admin	2015-01-27 14:58:47.177+01
PC_FC_MATERIAL_OBSTACLE	no_NO	Kontrollert at materiell ikke er til hinder for andre	0	1	admin	2015-01-27 14:58:47.187+01
PC_FC_MEASURE_INTERNAL_ROUTINE	no_NO	MÃ¥linger utfÃ¸rt ihht interne prosedyrer/instrukser	0	1	admin	2015-01-27 14:58:47.195+01
PC_FC_MEASURE_REN8028	no_NO	MÃ¥linger utfÃ¸rt ihht REN-blad 8028	0	1	admin	2015-01-27 14:58:47.203+01
PC_FC_MEASURE_VALUE_DOCUMENT	no_NO	MÃ¥leverdier er notert	0	1	admin	2015-01-27 14:58:47.211+01
PC_FC_MECHANICAL_JOINTS_TIGHTEN	no_NO	Alle mekaniske sammenfÃ¸yninger er trukket til	0	1	admin	2015-01-27 14:58:47.219+01
PC_FC_METER_AVAILABILITY	no_NO	MÃ¥ler har tilfredsstillende tilgjengelighet	0	1	admin	2015-01-27 14:58:47.227+01
PC_FC_METER_COMMUNICATION_TEST	no_NO	Kommunikasjon er testet og fungerer	0	1	admin	2015-01-27 14:58:47.235+01
PC_FC_METER_CONNECTION_TIGHTEN	no_NO	Alle tilkoblinger er ettertrukket	0	1	admin	2015-01-27 14:58:47.243+01
PC_FC_METER_FUSE_SIZE_INSTALLATION	no_NO	SikringsstÃ¸rrelse er sjekket mot anleggsbidrag	0	1	admin	2015-01-27 14:58:47.251+01
PC_FC_METER_MARK_COLOR	no_NO	Merking (fargekoder mÃ¥lerslÃ¸yfer) er sjekket	0	1	admin	2015-01-27 14:58:47.258+01
PC_FC_METER_MOUNT_REN4100	no_NO	MÃ¥ler er montert etter gjeldende REN-blad 4100	0	1	admin	2015-01-27 14:58:47.268+01
PC_FC_METER_READING	no_NO	MÃ¥lerstand er notert	0	1	admin	2015-01-27 14:58:47.277+01
PC_FC_METER_TRANSFORMATOR_AVAILABILITY	no_NO	MÃ¥lertransformatorer er lett tilgjengelig	0	1	admin	2015-01-27 14:58:47.286+01
PC_FC_MODULES_MOUNT	no_NO	Moduler er montert og festet med riktig moment	0	1	admin	2015-01-27 14:58:47.297+01
PC_FC_NOT_RELEVANT	no_NO	Ikke aktuell	0	1	admin	2015-01-27 14:58:47.304+01
PC_FC_OIL_LEAK	no_NO	Kontrollert for lekkasje	0	1	admin	2015-01-27 14:58:47.314+01
PC_FC_OIL_LEVEL	no_NO	OljenivÃ¥ kontrollert	0	1	admin	2015-01-27 14:58:47.322+01
PC_FC_OLD_TRANSFORMATOR_STORAGE	no_NO	Gammel trafo er transportert til lager	0	1	admin	2015-01-27 14:58:47.33+01
PC_FC_OPERATION_LABEL_ROUTINES	no_NO	Driftsmerking er utfÃ¸rt ihht rutiner for intern merking	0	1	admin	2015-01-27 14:58:47.338+01
PC_FC_ORAL_AGREEMENT_FINISH	no_NO	Alle muntlige avtaler med utenforstÃ¥ende er avsluttet	0	1	admin	2015-01-27 14:58:47.346+01
PC_FC_PHASE_SEQUENCE	no_NO	FasefÃ¸lge er testet	0	1	admin	2015-01-27 14:58:47.354+01
PC_FC_PHASE_VOLTAGE	no_NO	Testet at det er spenning pÃ¥ alle faser	0	1	admin	2015-01-27 14:58:47.362+01
PC_FC_PIPE_PLUGGED	no_NO	Alle ledige rÃ¸r er tettet i endene	0	1	admin	2015-01-27 14:58:47.37+01
PC_FC_POLE_CLIMBING_STEPS	no_NO	Klatretrinn er kontrollert	0	1	admin	2015-01-27 14:58:47.378+01
PC_FC_POLE_DIGGINGDEPTH	no_NO	Nedgravingsdybde er kontrollert	0	1	admin	2015-01-27 14:58:47.386+01
PC_FC_POLE_GROUND_ROUTINES_REN8011	no_NO	Jording er mÃ¥lt og dokumentert ihht interne rutiner eller REN-8011	0	1	admin	2015-01-27 14:58:47.394+01
PC_FC_POLE_HEIGHT_OVER_GROUND	no_NO	HÃ¸yde over bakken er kontrollert	0	1	admin	2015-01-27 14:58:47.407+01
PC_FC_POLE_STATION_GROUND_REN8011	no_NO	Jording er utfÃ¸rt ihht REN 8011 pkt. 9.2.2. Mastefotkiosk	0	1	admin	2015-01-27 14:58:47.42+01
PC_FC_POLE_TOP_CAP	no_NO	Topphette er montert	0	1	admin	2015-01-27 14:58:47.428+01
PC_FC_POLE_TRANSFORMATOR_GROUND_REN8011	no_NO	Jording er utfÃ¸rt ihht REN 8011 pkt. 9.3. Mastetrafo	0	1	admin	2015-01-27 14:58:47.437+01
PC_FC_POLE_VERTICAL	no_NO	Kontrollert at mast er i lodd	0	1	admin	2015-01-27 14:58:47.446+01
PC_FC_PRIVATE_AGREEMENT	no_NO	Alle avtaler med private er oppfylt	0	1	admin	2015-01-27 14:58:47.455+01
PC_FC_ROPE_FIXTURE	no_NO	Bardunfester er kontrollert	0	1	admin	2015-01-27 14:58:47.462+01
PC_FC_SEAL	no_NO	Plombering er utfÃ¸rt	0	1	admin	2015-01-27 14:58:47.47+01
PC_FC_SIGN_VISIBLE	no_NO	Merkeskilt er plassert synlig	0	1	admin	2015-01-27 14:58:47.477+01
PC_FC_SS_CONSUMPTION	no_NO	Kontrollert for riktig omsetning	0	1	admin	2015-01-27 14:58:47.485+01
PC_FC_SS_DOOR_OPEN	no_NO	Kontrollert at alle luker, dÃ¸rer og dekkplater lar seg Ã¥pne/fjerne	0	1	admin	2015-01-27 14:58:47.493+01
PC_FC_SS_FUNCTIONAL_TEST	no_NO	Anlegget er funksjonsprÃ¸vd	0	1	admin	2015-01-27 14:58:47.501+01
PC_FC_SS_GAS_VOLUME	no_NO	Kontrollert at anlegget inneholder nÃ¸dvendig gassvolum (SF6)	0	1	admin	2015-01-27 14:58:47.509+01
PC_FC_SS_GROUND_FIX_SUPPORT	no_NO	Kontrollert at underlag, fester og bÃ¦rejern er ok	0	1	admin	2015-01-27 14:58:47.518+01
PC_FC_SS_HORIZONTAL	no_NO	Kontrollert at anlegget er i vater	0	1	admin	2015-01-27 14:58:47.525+01
PC_FC_SS_MOUNT_VENDOR_DESCRIPTION	no_NO	Montert ihht beskrivelse fra leverandÃ¸r	0	1	admin	2015-01-27 14:58:47.536+01
PC_FC_SS_PRESSURE_RELIEF_DIRECTION	no_NO	Kontrollert at trykkavlastninger har riktig retning	0	1	admin	2015-01-27 14:58:47.547+01
PC_FC_SS_REN6015	no_NO	Alle mÃ¥l er kontrollert ihht REN-blad 6015	0	1	admin	2015-01-27 14:58:47.556+01
PC_FC_SWITCH_GROUND_REN8011	no_NO	Jording er utfÃ¸rt ihht beskrivelser i REN 8011 pkt. 6.7 og 8	0	1	admin	2015-01-27 14:58:47.566+01
PC_FC_SWITCH_LOCK_MOUNT	no_NO	BryterlÃ¥s er montert	0	1	admin	2015-01-27 14:58:47.574+01
PC_FC_SWITCH_OPERATION	no_NO	BetjeningshÃ¥ndtak er kontrollert	0	1	admin	2015-01-27 14:58:47.586+01
PC_FC_SWITCH_OPERATION_GROUND_REN8011	no_NO	Jording av betjening er utfÃ¸rt ihht beskrivelse i REN 8011 pkt. 8.5	0	1	admin	2015-01-27 14:58:47.594+01
PC_FC_SWITCH_TEST_NO_VOLTAGE	no_NO	Brytere og sikringsmoduler er testet i spenningslÃ¸s tilstand	0	1	admin	2015-01-27 14:58:47.601+01
PC_FC_THROUGHPUT_WHOLE	no_NO	Kontrollert at gjennomfÃ¸ringer er hele	0	1	admin	2015-01-27 14:58:47.609+01
PC_FC_TOP_LEVELING	no_NO	Toppsjikt er avrettet	0	1	admin	2015-01-27 14:58:47.617+01
PC_FC_TRANSFORMATOR_CONSUMPTION_VISIBLE	no_NO	Merking av omsetningsforhold for strÃ¸mtrafo er synlig	0	1	admin	2015-01-27 14:58:47.625+01
PC_FC_TRANSFORMATOR_DISTANCE	no_NO	Det er tilstrekkelig avstand mellom strÃ¸mtrafoer	0	1	admin	2015-01-27 14:58:47.633+01
PC_FC_VOLTAGE_MEASURE	no_NO	Spenning er mÃ¥lt, og ok	0	1	admin	2015-01-27 14:58:47.641+01
PC_FC_WIRE_MOUNT	no_NO	Barduner/bardunfester montert	0	1	admin	2015-01-27 14:58:47.649+01
PC_FC_GROUND_GLOBAL_REN8011	no_NO	Jording er utfÃ¸rt ihht REN 8011 pkt. 9.1. global jord	0	1	admin	2015-01-27 14:58:47.035+01
PC_FC_GROUND_REN8011	no_NO	Jording er utfÃ¸rt ihht REN 8011 pkt. 9.2. ikke global jord	0	1	admin	2015-01-27 14:58:47.061+01
PC_FC_WORK_AS_INSTRUCTED	no_NO	Arbeidet er utfÃ¸rt etter gjeldende retningslinjer	0	1	admin	2016-11-01 12:55:51.812+01
PC_FC_AREA_CLEANUP	no_NO	Anleggsstedet er ryddet	0	1	admin	2016-11-01 12:55:51.812+01
PC_FC_CONTRACT_NOT_NEEDED	no_NO	Arbeidet krever ikke samsvarserklÃ¦ring	0	1	admin	2016-11-01 12:55:51.812+01
PC_FC_CONTRACT_ATTACHED	no_NO	SamsvarserklÃ¦ring ligger vedlagt	0	1	admin	2016-11-01 12:55:51.812+01
PC_FC_GROUND_PLATE_MEASURE_LABEL	no_NO	Anlegget er fysisk merket med JordplatemÃ¥ling utfÃ¸rt	0	2	admin	2015-01-27 14:58:47.043+01
PC_FC_CABLE_ON_CUSHION	no_NO	Kabler er forlagt pÃ¥ kabelpute	0	2	admin	2015-01-27 14:58:46.707+01
\.


--
-- TOC entry 2672 (class 0 OID 27746)
-- Dependencies: 251
-- Data for Name: jira_subissue; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY jira_subissue (id_issuetype, pc_text, locale, sortorder, deleted, changed_by, changed_date) FROM stdin;
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	Montasje graving av grÃ¸ft for kabel og rÃ¸r	no_NO	1	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	Montasje endeavsl./tilkobling kabel HS	no_NO	2	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	Montasje endeavsl./tilkobling kabel LS	no_NO	3	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	Montasje skift/monter trafo i mast	no_NO	4	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	Montasje reising/bardunering mast HS/LS	no_NO	5	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	Montasje transport av materiell	no_NO	6	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	Montasje fundamentering av nettstasjon	no_NO	7	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	Montasje graving av grÃ¸ft for stikkledning	no_NO	8	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	Montasje jordplatemÃ¥ling	no_NO	10	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	Montasje legging av kabel og rÃ¸r i grÃ¸ft	no_NO	11	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	Montasje HS-bryteranlegg i nettstasjon	no_NO	12	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	Montasje mÃ¥lermontasje/skifting	no_NO	13	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	Montasje ombygging av nettstasjon i mast	no_NO	14	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	Montasje prefab. nettstasjon pÃ¥ bakke	no_NO	15	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	Montasje prefab. nettstasjon i mast	no_NO	16	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	Montasje skift kabelskap	no_NO	17	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	Montasje strekking LS	no_NO	18	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	Montasje tilkobling kunde komplett	no_NO	20	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	Montasje transformator NS bakke	no_NO	21	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	Montasje tilkobling kabel i mast	no_NO	22	0	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	Montasje byggestrÃ¸m	no_NO	24	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	Demontering byggestrÃ¸m	no_NO	25	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	Montasje HS-bryter i mast	no_NO	23	0	admin	2016-11-01 12:55:51.812+01
\.


--
-- TOC entry 2648 (class 0 OID 27495)
-- Dependencies: 227
-- Data for Name: risiko; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY risiko (id, navn, endret_av, endret_dato, slettet, updateid, locale, value) FROM stdin;
1	Ingen	\N	2013-03-11 09:48:53.265+01	0	1	no_NO	pc.global.Risk.v01
2	Lav	\N	2013-03-11 09:49:12.562+01	0	1	no_NO	pc.global.Risk.v02
3	Middels	\N	2013-03-11 09:49:20.559+01	0	1	no_NO	pc.global.Risk.v03
4	HÃ¸y	\N	2013-03-11 09:49:27.763+01	0	1	no_NO	pc.global.Risk.v04
5	None	\N	2014-05-05 15:38:32.292+02	0	1	en_US	pc.global.Risk.v01
6	Low	\N	2014-05-05 15:38:49.102+02	0	1	en_US	pc.global.Risk.v02
7	Medium	\N	2014-05-05 15:38:59.319+02	0	1	en_US	pc.global.Risk.v03
8	High	\N	2014-05-05 15:39:08.047+02	0	1	en_US	pc.global.Risk.v04
\.


--
-- TOC entry 2675 (class 0 OID 27782)
-- Dependencies: 254
-- Data for Name: risks; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY risks (pc_category, pc_description, pc_level, pc_selection, locale, sortorder, deleted, updateid, changed_by, changed_date) FROM stdin;
ren_ris	Skal det utfÃ¸res arbeid med kjemikalier?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res arbeid med kjemikalier?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res arbeid hvor det er stÃ¸y tilstede?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res arbeid hvor det er stÃ¸y tilstede?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res arbeid hvor det er rÃ¸yk, stÃ¸v, gass og damp tilstede?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res arbeid hvor det er rÃ¸yk, stÃ¸v, gass og damp tilstede?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res varmt arbeid eller annet arbeid som kan fremkalle brann/eksplosjon?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res varmt arbeid eller annet arbeid som kan fremkalle brann/eksplosjon?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Vurder trafikk/fremkomst/atkomst	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Vurder trafikk/fremkomst/atkomst	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering med hensyn pÃ¥ fall eller fallende gjenstander?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering med hensyn pÃ¥ fall eller fallende gjenstander?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering av lÃ¸fting av last?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering av lÃ¸fting av last?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er arbeidet tungt og ensformig?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er arbeidet tungt og ensformig?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering av hÃ¥ndtering av spesialavfall?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering av hÃ¥ndtering av spesialavfall?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det tilfredsstillende belysning?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det tilfredsstillende belysning?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Vurder klimatiske/topografiske forhold	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Vurder klimatiske/topografiske forhold	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res arbeid med/nÃ¦r ved roterende maskiner?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det utfÃ¸res arbeid med/nÃ¦r ved roterende maskiner?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det arbeides nÃ¦r/ved farlige omrÃ¥der?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal det arbeides nÃ¦r/ved farlige omrÃ¥der?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering med hensyn pÃ¥ ras eller utgliding av fundament?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Er det utfÃ¸rt vurdering med hensyn pÃ¥ ras eller utgliding av fundament?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal bÃ¦rende og tunge elementer rives eller demonteres?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Skal bÃ¦rende og tunge elementer rives eller demonteres?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Har omrÃ¥det tilstrekkelige kommunikasjonsmuligheter?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Har omrÃ¥det tilstrekkelige kommunikasjonsmuligheter?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Andre risikoelementer som bÃ¸r vurderes?	Normal	Lav	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
ren_ris	Andre risikoelementer som bÃ¸r vurderes?	Middels	\N	no_NO	0	0	0	admin	2016-11-01 12:57:05.226+01
\.


--
-- TOC entry 2649 (class 0 OID 27501)
-- Dependencies: 228
-- Data for Name: sa_action; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY sa_action (id_risk, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by, changed_date) FROM stdin;
PC_SA_RISK_HEATED_WORK	PC_SA_ACTION_PROTECTIVE_CLOTHING	no_NO	VerneklÃ¦r	0	0	1	admin	2015-01-27 14:58:46.183+01
PC_SA_RISK_HEATED_WORK	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	1	admin	2015-01-27 14:58:46.192+01
PC_SA_RISK_HEATED_WORK	PC_SA_ACTION_EYE_PROTECTION	no_NO	Vernebriller	0	0	1	admin	2015-01-27 14:58:46.199+01
PC_SA_RISK_HEATED_WORK	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	1	admin	2015-01-27 14:58:46.208+01
PC_SA_RISK_CURRENT_PASSAGE	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	1	admin	2015-01-27 14:58:46.216+01
PC_SA_RISK_CURRENT_PASSAGE	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	1	admin	2015-01-27 14:58:46.224+01
PC_SA_RISK_CURRENT_PASSAGE	PC_SA_ACTION_PROTECTIVE_CLOTHING	no_NO	VerneklÃ¦r	0	0	1	admin	2015-01-27 14:58:46.232+01
PC_SA_RISK_FALL_FROM_POLE	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	1	admin	2015-01-27 14:58:46.24+01
PC_SA_RISK_FALL_FROM_POLE	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	1	admin	2015-01-27 14:58:46.249+01
PC_SA_RISK_FALL_FROM_POLE	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	1	admin	2015-01-27 14:58:46.257+01
PC_SA_RISK_FALL_FROM_POLE	PC_SA_ACTION_PROTECTIVE_CLOTHING	no_NO	VerneklÃ¦r	0	0	1	admin	2015-01-27 14:58:46.267+01
PC_SA_RISK_LINE_PULL_IF_STRAP_POLE_BREAKAGE	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	1	admin	2015-01-27 14:58:46.276+01
PC_SA_RISK_LINE_PULL_IF_STRAP_POLE_BREAKAGE	PC_SA_ACTION_PROTECTIVE_CLOTHING	no_NO	VerneklÃ¦r	0	0	1	admin	2015-01-27 14:58:46.284+01
PC_SA_RISK_LINE_PULL_IF_STRAP_POLE_BREAKAGE	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	1	admin	2015-01-27 14:58:46.292+01
PC_SA_RISK_LINE_PULL_IF_STRAP_POLE_BREAKAGE	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	1	admin	2015-01-27 14:58:46.3+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	1	admin	2015-01-27 14:58:46.309+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	1	admin	2015-01-27 14:58:46.318+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	1	admin	2015-01-27 14:58:46.325+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_PROTECTIVE_CLOTHING	no_NO	VerneklÃ¦r	0	0	1	admin	2015-01-27 14:58:46.333+01
PC_SA_RISK_FALLING_OBJECTS	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	1	admin	2015-01-27 14:58:46.341+01
PC_SA_RISK_FALLING_OBJECTS	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	1	admin	2015-01-27 14:58:46.35+01
PC_SA_RISK_FALLING_OBJECTS	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	1	admin	2015-01-27 14:58:46.357+01
PC_SA_RISK_FALLING_OBJECTS	PC_SA_ACTION_PROTECTIVE_CLOTHING	no_NO	VerneklÃ¦r	0	0	1	admin	2015-01-27 14:58:46.365+01
PC_SA_RISK_COLLISION	PC_SA_ACTION_ROAD_ALERT	no_NO	Varselskilt/veisperring	0	0	1	admin	2015-01-27 14:58:46.374+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_VISIBILITY_CLOTHES	no_NO	SynlighetsklÃ¦r	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CRUSH_HAZARD	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CUT_INJURY	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CUT_INJURY	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CUT_INJURY	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CUT_INJURY	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CUT_INJURY	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CUT_INJURY	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CUT_INJURY	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_ANTIFIRE_CLOTHES	no_NO	Brannhemmende klÃ¦r	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_FIRE_EXTINGUISHER	no_NO	Brannslukningsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_PLANNING	no_NO	PlanleggingsmÃ¸te	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_ARC	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_VISIBILITY_CLOTHES	no_NO	SynlighetsklÃ¦r	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_SIGN_PLAN	no_NO	Skiltplan	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_CLOTHES_IN_MACHINE	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_PHYSICAL_SECURITY	no_NO	Fysisk sikring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_FALL_PROTECTION	no_NO	Fallsikring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_DITCH_INSPECTION	no_NO	Kontroll av grÃ¸ft	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DITCH_SLIDE	PC_SA_ACTION_DISCONNECTION	no_NO	Utkobling	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_POLE_SLING	no_NO	Stolpeslynge	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_ACTION_FALL_PROTECTION	no_NO	Fallsikring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_ACTION_EXTRA_GUYING	no_NO	Ekstra bardunering	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_KNOCK_CONTROL	no_NO	Bankekontroll	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_POLE_ROT	PC_SA_ACTION_VISUAL_POLE_INSPECTION	no_NO	Visuell kontroll mast	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_SF6_LEAK	PC_SA_ACTION_DUST_MASK	no_NO	StÃ¸vmaske	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_SF6_LEAK	PC_SA_ACTION_PROTECTIVE_MASK	no_NO	Vernemaske	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_SF6_LEAK	PC_SA_ACTION_EYE_PROTECTION	no_NO	Ã˜yevern	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_SF6_LEAK	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_SF6_LEAK	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_SF6_LEAK	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_SF6_LEAK	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_GROUND_SHORTING	no_NO	Jording/kortslutning	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_EVALUATE_GROUNDING	no_NO	Vurdere jordingsanlegget	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_DISCONNECTION	no_NO	Utkobling	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_ON	PC_SA_ACTION_LEADER_FOR_SECURITY	no_NO	Leder for sikkerhet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DUST	PC_SA_ACTION_DUST_MASK	no_NO	StÃ¸vmaske	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DUST	PC_SA_ACTION_PROTECTIVE_MASK	no_NO	Vernemaske	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DUST	PC_SA_ACTION_EYE_PROTECTION	no_NO	Ã˜yevern	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DUST	PC_SA_ACTION_AERATION	no_NO	Lufting	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_DUST	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_NOISE	PC_SA_ACTION_EAR_PROTECTION	no_NO	HÃ¸rselvern	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_NOISE	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_NOISE	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_PHYSICAL_SECURITY	no_NO	Fysisk sikring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_LOAD_CONTROL	no_NO	Kontroll av last	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_VOLTAGE_UNSTABLE	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_EYE_INJURY	PC_SA_ACTION_EYE_PROTECTION	no_NO	Ã˜yevern	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_EYE_INJURY	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_EYE_INJURY	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_EYE_INJURY	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_EYE_INJURY	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_HAND_PROTECTION	no_NO	Hansker	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_HELMET_FACE_SHIELD	no_NO	Hjelm m/visir	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_FOOT_PROTECTION	no_NO	Vernesko/stÃ¸vler	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_PHYSICAL_SECURITY	no_NO	Fysisk sikring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_FALL_PROTECTION	no_NO	Fallsikring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_PLANNING	no_NO	PlanleggingsmÃ¸te	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_TERRAIN_CHALLENGE	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_WEATHER_CHALLENGE	PC_SA_ACTION_FIRST_AID_EQUIPMENT	no_NO	FÃ¸rstehjelpsutstyr	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_WEATHER_CHALLENGE	PC_SA_ACTION_LEADER_FOR_SECURITY	no_NO	Leder for sikkerhet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_WEATHER_CHALLENGE	PC_SA_ACTION_AWAIT_WEATHER	no_NO	Avvente vÃ¦rforhold	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_WEATHER_CHALLENGE	PC_SA_ACTION_COMMUNICATION	no_NO	Samband	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_WEATHER_CHALLENGE	PC_SA_ACTION_TWO_PERSONS	no_NO	To pÃ¥ arbeidsstedet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_WEATHER_CHALLENGE	PC_SA_ACTION_DISCONNECTION	no_NO	Utkobling	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_UNCLEAR_ORGANIZATION	PC_SA_ACTION_LEADER_FOR_SECURITY	no_NO	Leder for sikkerhet	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_UNCLEAR_ORGANIZATION	PC_SA_ACTION_TRAINING	no_NO	OpplÃ¦ring	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_SA_RISK_UNCLEAR_ORGANIZATION	PC_SA_ACTION_PLANNING	no_NO	PlanleggingsmÃ¸te	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
\.


--
-- TOC entry 2650 (class 0 OID 27512)
-- Dependencies: 229
-- Data for Name: sa_connection; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY sa_connection (id_issuetype, id_task, deleted, updateid, changed_by, changed_date) FROM stdin;
SK idriftsettelse	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_FIELD_INSPECTION	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_INSTALLATION_OPERATION	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_CONTROL_CABINET	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_CONTROL_POLE_HV	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_CONTROL_POLE_LV	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_CONTROL_SS_1_YR	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_CONTROL_SS_5_YR	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_METER_REPLACEMENT	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
Driftsoppgave	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2015-01-27 14:58:46.393+01
SK idriftsettelse	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_FIELD_INSPECTION	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_INSTALLATION_OPERATION	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_CONTROL_CABINET	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_CONTROL_POLE_HV	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_CONTROL_POLE_LV	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_CONTROL_SS_1_YR	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_CONTROL_SS_5_YR	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_METER_REPLACEMENT	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
Driftsoppgave	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2015-01-27 14:58:46.402+01
SK idriftsettelse	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_FIELD_INSPECTION	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_INSTALLATION_OPERATION	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_CONTROL_CABINET	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_CONTROL_POLE_HV	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_CONTROL_POLE_LV	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_CONTROL_SS_1_YR	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_CONTROL_SS_5_YR	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_METER_REPLACEMENT	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
Driftsoppgave	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:46.412+01
SK idriftsettelse	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_FIELD_INSPECTION	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_INSTALLATION_OPERATION	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_CONTROL_CABINET	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_CONTROL_POLE_HV	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_CONTROL_POLE_LV	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_CONTROL_SS_1_YR	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_CONTROL_SS_5_YR	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_METER_REPLACEMENT	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
Driftsoppgave	PC_SA_TASK_CRANE_BASKET	0	1	admin	2015-01-27 14:58:46.421+01
SK idriftsettelse	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_FIELD_INSPECTION	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_INSTALLATION_OPERATION	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_CONTROL_CABINET	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_CONTROL_POLE_HV	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_CONTROL_POLE_LV	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_CONTROL_SS_1_YR	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_CONTROL_SS_5_YR	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_METER_REPLACEMENT	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
Driftsoppgave	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2015-01-27 14:58:46.429+01
SK idriftsettelse	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_FIELD_INSPECTION	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_INSTALLATION_OPERATION	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_CONTROL_CABINET	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_CONTROL_POLE_HV	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_CONTROL_POLE_LV	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_CONTROL_SS_1_YR	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_CONTROL_SS_5_YR	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_METER_REPLACEMENT	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
Driftsoppgave	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2015-01-27 14:58:46.437+01
SK idriftsettelse	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_FIELD_INSPECTION	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_HELPER	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_INSTALLATION_OPERATION	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_CONTROL_CABINET	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_CONTROL_POLE_HV	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_CONTROL_POLE_LV	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_CONTROL_SS_1_YR	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_CONTROL_SS_5_YR	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_METER_REPLACEMENT	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
Driftsoppgave	PC_SA_TASK_CONTROL_POLE	0	1	admin	2015-01-27 14:58:46.444+01
PC_ISSUETYPE_SUB_TASK_NET	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_SA_TASK_CRANE_BASKET	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_SUB_TASK_NET	PC_SA_TASK_CONTROL_POLE	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	PC_SA_TASK_CABLE_TERMINATION	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	PC_SA_TASK_LIVE_CABLE_MAST	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	PC_SA_TASK_LINE_STRETCHING	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	PC_SA_TASK_CRANE_BASKET	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	PC_SA_TASK_POLES_BY_ROAD	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	PC_SA_TASK_CONTROL_POLE	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_SA_TASK_CABLE_TERMINATION	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_SA_TASK_LIVE_CABLE_MAST	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_SA_TASK_LINE_STRETCHING	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_SA_TASK_CRANE_BASKET	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_SA_TASK_POLES_BY_ROAD	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_SA_TASK_CONTROL_POLE	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	PC_GENERAL_SJA	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
\.


--
-- TOC entry 2651 (class 0 OID 27522)
-- Dependencies: 230
-- Data for Name: sa_issuetype; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY sa_issuetype (pc_key, deleted, updateid, changed_by, changed_date) FROM stdin;
SK idriftsettelse	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_CABLE_PIPE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_WORK_ORDER_WITH_SAFETY_ASSESSMENT	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_WORK_ORDER_WITHOUT_SAFETY_ASSESSMENT	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_FIELD_INSPECTION	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_HELPER	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_HELPER	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_INSTALLATION_OPERATION	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_CONTROL_CABINET	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_CONTROL_POLE_HV	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_CONTROL_POLE_LV	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_CONTROL_SS_1_YR	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_CONTROL_SS_5_YR	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_GROUND_PLATE_MEASUREMENT	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_OR_ALTERATION_METER	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_ASSEMBLY_MATERIAL_TRANSPORTATION	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_METER_REPLACEMENT	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_FINAL_CHECK_DITCH_CABLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_FINAL_CHECK_CABINET	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_FINAL_CHECK_HV_LINE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_FINAL_CHECK_LV_LINE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_FINAL_CHECK_SS_GROUND	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_FINAL_CHECK_SS_POLE	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_PLAN_ECONOMY_CALCULATIONS	0	1	admin	2015-01-27 14:58:45.928+01
Driftsoppgave	0	1	admin	2015-01-27 14:58:45.928+01
PC_ISSUETYPE_SUB_TASK_NET	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_MOBILE	0	1	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	1	2	admin	2016-11-01 12:55:51.812+01
PC_ISSUETYPE_WO_NET	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
\.


--
-- TOC entry 2652 (class 0 OID 27529)
-- Dependencies: 231
-- Data for Name: sa_risk; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY sa_risk (id_task, pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by, changed_date) FROM stdin;
PC_SA_TASK_CABLE_TERMINATION	PC_SA_RISK_HEATED_WORK	no_NO	Varme arbeider	0	0	1	admin	2015-01-27 14:58:46.018+01
PC_SA_TASK_LIVE_CABLE_MAST	PC_SA_RISK_CURRENT_PASSAGE	no_NO	StrÃ¸mgjennomgang	0	0	1	admin	2015-01-27 14:58:46.027+01
PC_SA_TASK_LIVE_CABLE_MAST	PC_SA_RISK_FALL_FROM_POLE	no_NO	Fall fra stolpe	0	0	1	admin	2015-01-27 14:58:46.036+01
PC_SA_TASK_LIVE_CABLE_MAST	PC_SA_RISK_LINE_PULL_IF_STRAP_POLE_BREAKAGE	no_NO	Napp i linjer hvis taljer/stropper/stolper ryker	0	0	1	admin	2015-01-27 14:58:46.044+01
PC_SA_TASK_LIVE_CABLE_MAST	PC_SA_RISK_FALLING_OBJECTS	no_NO	Fallende gjenstander	0	0	1	admin	2015-01-27 14:58:46.051+01
PC_SA_TASK_LINE_STRETCHING	PC_SA_RISK_FALL_FROM_POLE	no_NO	Fall fra stolpe	0	0	1	admin	2015-01-27 14:58:46.059+01
PC_SA_TASK_LINE_STRETCHING	PC_SA_RISK_LINE_PULL_IF_STRAP_POLE_BREAKAGE	no_NO	Napp i linjer hvis taljer/stropper/stolper ryker	0	0	1	admin	2015-01-27 14:58:46.067+01
PC_SA_TASK_LINE_STRETCHING	PC_SA_RISK_FALLING_OBJECTS	no_NO	Fallende gjenstander	0	0	1	admin	2015-01-27 14:58:46.075+01
PC_SA_TASK_CRANE_BASKET	PC_SA_RISK_FALL_FROM_POLE	no_NO	Fall fra stolpe	0	0	1	admin	2015-01-27 14:58:46.085+01
PC_SA_TASK_CRANE_BASKET	PC_SA_RISK_CRUSH_HAZARD	no_NO	Klemfare	0	0	1	admin	2015-01-27 14:58:46.094+01
PC_SA_TASK_CRANE_BASKET	PC_SA_RISK_FALLING_OBJECTS	no_NO	Fallende gjenstander	0	0	1	admin	2015-01-27 14:58:46.102+01
PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	PC_SA_RISK_LINE_PULL_IF_STRAP_POLE_BREAKAGE	no_NO	Napp i linjer hvis taljer/stropper/stolper ryker	0	0	1	admin	2015-01-27 14:58:46.112+01
PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	PC_SA_RISK_CRUSH_HAZARD	no_NO	Klemfare	0	0	1	admin	2015-01-27 14:58:46.124+01
PC_SA_TASK_POLES_BY_ROAD	PC_SA_RISK_COLLISION	no_NO	PÃ¥kjÃ¸rsel	0	0	1	admin	2015-01-27 14:58:46.135+01
PC_SA_TASK_CONTROL_POLE	PC_SA_RISK_FALL_FROM_POLE	no_NO	Fall fra stolpe	0	0	1	admin	2015-01-27 14:58:46.145+01
PC_SA_TASK_CONTROL_POLE	PC_SA_RISK_CURRENT_PASSAGE	no_NO	StrÃ¸mgjennomgang	0	0	1	admin	2015-01-27 14:58:46.157+01
PC_SA_TASK_CONTROL_POLE	PC_SA_RISK_FALLING_OBJECTS	no_NO	Fallende gjenstander	0	0	1	admin	2015-01-27 14:58:46.166+01
PC_GENERAL_SJA	PC_SA_RISK_CRUSH_HAZARD	no_NO	Klemkader	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_CUT_INJURY	no_NO	Kuttskader	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_ARC	no_NO	Lysbue	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_CLOTHES_IN_MACHINE	no_NO	Maskin fast i klÃ¦r	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_DITCH_SLIDE	no_NO	Ras i grÃ¸ft	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_POLE_ROT	no_NO	RÃ¥te i stolper	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_SF6_LEAK	no_NO	SF6-lekkasje	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_VOLTAGE_ON	no_NO	Skrittspenning, spenning pÃ¥ kabel, strÃ¸mgjennomgang	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_DUST	no_NO	StÃ¸v	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_NOISE	no_NO	StÃ¸y	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_VOLTAGE_UNSTABLE	no_NO	Ustabil last	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_EYE_INJURY	no_NO	Ã˜yeskade	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_TERRAIN_CHALLENGE	no_NO	Terrengutfordringer	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_WEATHER_CHALLENGE	no_NO	VÃ¦rutfordringer	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
PC_GENERAL_SJA	PC_SA_RISK_UNCLEAR_ORGANIZATION	no_NO	Uklar organisering	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
\.


--
-- TOC entry 2653 (class 0 OID 27540)
-- Dependencies: 232
-- Data for Name: sa_task; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY sa_task (pc_key, locale, pc_text, sortorder, deleted, updateid, changed_by, changed_date) FROM stdin;
PC_SA_TASK_CABLE_TERMINATION	no_NO	SkjÃ¸ting av kabel	0	0	1	admin	2015-01-27 14:58:45.948+01
PC_SA_TASK_LIVE_CABLE_MAST	no_NO	Arbeid ved strÃ¸mfÃ¸rende ledninger i stolpe	0	0	1	admin	2015-01-27 14:58:45.956+01
PC_SA_TASK_LINE_STRETCHING	no_NO	Oppstrekk/riving av linjer	0	0	1	admin	2015-01-27 14:58:45.966+01
PC_SA_TASK_CRANE_BASKET	no_NO	Bruk av heisekran/kurv	0	0	1	admin	2015-01-27 14:58:45.975+01
PC_SA_TASK_MOTORIZED_STRETCH_EQUIPMENT	no_NO	Bruk av motorisert strekkeutstyr	0	0	1	admin	2015-01-27 14:58:45.984+01
PC_SA_TASK_POLES_BY_ROAD	no_NO	Arbeid i stolper langs vei	0	0	1	admin	2015-01-27 14:58:45.993+01
PC_SA_TASK_CONTROL_POLE	no_NO	Kontroll stolpe	0	0	1	admin	2015-01-27 14:58:46.001+01
PC_GENERAL_SJA	no_NO	Generell SJA	0	0	2	PowerCatch Update Script 2.3.1	2016-11-01 12:57:31.467+01
\.


--
-- TOC entry 2676 (class 0 OID 27793)
-- Dependencies: 255
-- Data for Name: task_objectdata; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY task_objectdata (pc_task, pc_key, pc_text, locale, sortorder, deleted, updateid, changed_by, changed_date) FROM stdin;
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_POLE_TYPE	Mastetype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_BASEMENT_TYPE	Type fundament:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_POLE_LENGTH	Mastelengde:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_POLE_ERECTION_BRACING_HV_LV	PC_IMPREGNATION_TYPE	Type impregnering pÃ¥ mast:	no_NO	4	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_CABINET_TYPE_MANUFACTURE	Kabelskapstype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_CABINET_NUMBER	Kabelskapsnummer:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_REPLACE_CABINET	PC_CABINET_WIDTH	Kabelskapsbredde:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_CABLE_TERMINAL_TYPE	Type kabelendeavslutning:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_HV	PC_CABLE_JOINT_TYPE	KabelskjÃ¸t-type:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_CABLE_TERMINAL_TYPE	Type kabelendeavslutning:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CABLE_TERMINATION_LV	PC_CABLE_JOINT_TYPE	KabelskjÃ¸t-type:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_POLE_TYPE	Mastetype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_IMPREGNATION_TYPE	Type impregnering pÃ¥ mast:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_CABINET_TYPE_MANUFACTURE	Kabelskapstype:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_CABINET_NUMBER	Kabelskapsnummer:	no_NO	4	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_CABINET_WIDTH	Kabelskapsbredde:	no_NO	5	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_CABLE_TYPE	Kabeltype:	no_NO	6	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_LV_LINE_STRETCHING	PC_CABLE_CROSS_SECTION	Kabeltverrsnitt:	no_NO	7	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_CABLE_TYPE	Kabeltype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_DIGGING_DITCH_FOR_SPUR_CABLE	PC_CABLE_CROSS_SECTION	Kabeltverrsnitt:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_CABLE_TYPE	Kabeltype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CABLE_PIPE_IN_DITCH	PC_CABLE_CROSS_SECTION	Kabeltverrsnitt:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_SUBSTATION_TYPE	Nettstasjonstype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_SUBSTATION_BASEMENT	PC_BASEMENT_TYPE	Type fundament:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SWITCH_TYPE	Brytertype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SWITCH_SERIAL_NUMBER	Bryterens serienummer:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SWITCH_ID	Brytermerke:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_INSTALLATION_SUBSTATION	PC_SWITCH_MANUFACTURE	Bryterfabrikat:	no_NO	4	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SUBSTATION_TYPE	Nettstasjonstype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_INTERNAL_EXTERNAL_CONTROLLED	I/U betjent:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_GROUND	PC_SUBSTATION_NUMBER	Nettstasjonsnummer:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_ASSEMBLED_TRANSFORMER_NUMBER	Nummer pÃ¥ montert trafo:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_TRANSFORMER_TYPE	Trafotype:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_TRANSFORMER_SIZE_KVA	TrafostÃ¸rrelse (kVA):	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_TRANSFORMER_SS_GROUND	PC_SUBSTATION_NUMBER	Nettstasjonsnummer:	no_NO	4	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SUBSTATION_TYPE	Nettstasjonstype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_INTERNAL_EXTERNAL_CONTROLLED	I/U betjent:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_PREFABRICATED_SS_POLE	PC_SUBSTATION_NUMBER	Nettstasjonsnummer:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_ASSEMBLED_TRANSFORMER_NUMBER	Nummer pÃ¥ montert trafo:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_TRANSFORMER_TYPE	Trafotype:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_TRANSFORMER_SIZE_KVA	TrafostÃ¸rrelse (kVA):	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_OR_REPLACEMENT_TRANSFORMER_POLE	PC_SUBSTATION_NUMBER	Nettstasjonsnummer:	no_NO	4	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_ASSEMBLED_TRANSFORMER_NUMBER	Nummer pÃ¥ montert trafo:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_TRANSFORMER_TYPE	Trafotype:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_TRANSFORMER_SIZE_KVA	TrafostÃ¸rrelse (kVA):	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_ALTERATION_SUBSTATION_POLE	PC_SUBSTATION_NUMBER	Nettstasjonsnummer:	no_NO	4	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_POLE_TYPE	Mastetype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_CONNECT_CABLE_IN_POLE	PC_IMPREGNATION_TYPE	Type impregnering pÃ¥ mast:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_POLE_TYPE	Mastetype:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_IMPREGNATION_TYPE	Type impregnering pÃ¥ mast:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_CABINET_TYPE_MANUFACTURE	Kabelskapstype:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_CABINET_NUMBER	Kabelskapsnummer:	no_NO	4	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_CABINET_WIDTH	Kabelskapsbredde:	no_NO	5	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_CABLE_TYPE	Kabeltype:	no_NO	6	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_COMPLETE_SPUR_CABLE_INCL_METER	PC_CABLE_CROSS_SECTION	Kabeltverrsnitt:	no_NO	7	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_METER_NUMBER	MÃ¥lernummer:	no_NO	1	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_METER_READING	MÃ¥lerstand:	no_NO	2	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_DISASSEMBLY_TEMP_POWER_SUPPLY	PC_DISASSEMBLY_DATE	Dato for demontering:	no_NO	3	0	0	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_CENTRAL_MAIN_FUSE_SIZE	SikringsstÃ¸rrelse pÃ¥ montert sentral:	no_NO	1	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_MAIN_FUSE_SIZE	SikringsstÃ¸rrelse hovedsikring:	no_NO	2	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_METER_TRANSFORMER_SIZE	MÃ¥lertrafo-stÃ¸rrelse:	no_NO	3	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_ASSEMBLY_DATE	Montasjedato:	no_NO	4	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_CENTRAL_NUMBER	Sentral-nummer:	no_NO	5	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_METER_NUMBER	MÃ¥lernummer:	no_NO	6	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_METER_READING	MÃ¥lerstand:	no_NO	7	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_CENTRAL_MOUNTING	MontasjemÃ¥te for sentral:	no_NO	8	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_SUBSTATION_NUMBER	Nettstasjonsnummer:	no_NO	9	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_TEMP_POWER_SUPPLY	PC_CABINET_POLE_NUMBER	Skapnummer/stolpenummer:	no_NO	10	0	1	PowerCatch Update Script 2.3.0.4	2016-11-01 12:57:44.566+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SWITCH_TYPE	Brytertype:	no_NO	1	0	2	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SWITCH_SERIAL_NUMBER	Bryterens serienummer:	no_NO	2	0	2	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SWITCH_ID	Brytermerke:	no_NO	3	0	2	admin	2016-11-01 12:57:05.226+01
PC_ISSUETYPE_ASSEMBLY_HV_SWITCH_POLE	PC_SWITCH_MANUFACTURE	Bryterfabrikat:	no_NO	4	0	2	admin	2016-11-01 12:57:05.226+01
\.


--
-- TOC entry 2654 (class 0 OID 27551)
-- Dependencies: 233
-- Data for Name: threelevels; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY threelevels (id, nr, level1, level2, level3, endret_av, endret_dato, slettet, updateid, locale, value) FROM stdin;
1	45	valg 1	valg 1-1	valg 1-1-1	\N	2013-04-03 16:06:05.04+02	0	1	no_NO	pc.cf.Transport.v01
127	89	Klemfare	Stor	Hjelm	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v002
17	50	SkjÃ¦re av jern 1	SkjÃ¦re av jern 1-1	SkjÃ¦re av jern 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.CableMark.v01
7	46	Stolpehull kan ry	Klemskader arm, fot	Verneutstyr, hjelm, sko med stÃ¥lbeskyttelse	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.Foundation.v01
16	49	LÃ¸ft 1	LÃ¸ft 1-1	LÃ¸ft 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.IronCut.v01
15	48	Feste for styringstau kan svikte	Mast faller ned og skader mennesker	Knuter og feste kontrolleres	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.Lift.v01
12	48	Rotende kan skli	Mast faller ned og skader mennesker	Planlegge godt pÃ¥ forhÃ¥nd	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetup.v02
13	48	Reiseutstyr kan svikte	Mast faller ned og skader mennesker	Kontrollere utstyret (mÃ¥ vÃ¦re sertifisert)	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetup.v03
14	48	Styringstau kan ryke	Mast faller ned og skader mennesker	Kontroller tau	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetup.v04
8	47	StÃ¸y	HÃ¸rselskade	HÃ¸rselvern	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.RockDrillingMachine.v01
9	47	Tunge lÃ¸ft	Ryggskade	Flere hender	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.RockDrillingMachine.v02
10	47	InnÃ¥nding av farlige gasser	Skader luftveier	Maske	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.RockDrillingMachine.v03
22	55	Lang last 1	Lang last 1-1	Lang last 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.StretchTool.v01
2	45	valg 2	valg 2-1	valg 2-1-1	\N	2013-04-03 16:06:05.04+02	0	1	no_NO	pc.cf.Transport.v02
3	45	valg 1	valg 1-2	valg 1-2-1	\N	2013-04-03 16:06:05.04+02	0	1	no_NO	pc.cf.Transport.v03
4	45	valg 1	valg 1-2	valg 1-2-2	\N	2013-04-03 16:06:05.04+02	0	1	no_NO	pc.cf.Transport.v04
5	45	valg 2	valg 2-2	valg 2-2-1	\N	2013-04-03 16:06:05.04+02	0	1	no_NO	pc.cf.Transport.v05
6	45	valg 2	valg 2-2	valg 2-2-2	\N	2013-04-03 16:06:05.04+02	0	1	no_NO	pc.cf.Transport.v06
20	53	Kabelmerking 1	Kabelmerking 1-1	Kabelmerking 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.WideLoad.v01
36	64	Mast er iset	Klatresko glipper	Fjerne is fÃ¸r klatring	\N	2014-01-21 13:44:03.67+01	0	1	no_NO	pc.cf.ConnectCableHV.v01
37	64	Barduner kan ryke	Rykk i mast, eller mast faller	Sjekk barduner og fester fÃ¸r klatring	\N	2014-01-21 13:46:13.853+01	0	1	no_NO	pc.cf.ConnectCableHV.v02
35	60	Hydraulikkslanger kan ryke	Mast faller ned og skader mennesker	Bruk verneutstyr, hjelm, sko med stÃ¥lbeskyttelse	\N	2014-01-21 13:41:40.703+01	0	1	no_NO	pc.cf.ConnectCableLV.v01
43	54	Montering av jordspyd	Slagskader ved montering av jordspyd	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-21 14:11:07.603+01	0	1	no_NO	pc.cf.ConnectGrounding.v01
44	54	Lysbue	Brannskader pÃ¥ kropp	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-21 14:11:54.915+01	0	1	no_NO	pc.cf.ConnectGrounding.v02
19	52	Stor belastning pÃ¥ tilkoblingspunkter	Flere tyngre deler kan briste og falle ned	Kabelen festes fÃ¸r tilkobling	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.HeavyLoad.v01
38	52	LÃ¸se ender kan vÃ¦re i spenn og slÃ¥ ut	Kan skade ansikt og Ã¸yne pÃ¥ personell	Bakkemannskap bruker hjelm og annet verneutstyr	\N	2014-01-21 13:55:59.017+01	0	1	no_NO	pc.cf.Lifting.v01
39	57	Innretninger pÃ¥ bryter kan skades	Skade pÃ¥ utstyr som igjen kan skade personell	Sette pÃ¥ tau slik at bryter kan styres	\N	2014-01-21 14:00:50.815+01	0	1	no_NO	pc.cf.Lifting.v02
40	57	Plutselige bevegelser kan skade personell	Slag-/klemskade	Sette stopper slik at stropp ikke glir	\N	2014-01-21 14:01:34.206+01	0	1	no_NO	pc.cf.Lifting.v03
41	57	Heisefester kan ryke	Personskade for bakkemannskap	Respekter faresonen og bruk personlig verneutstyr	\N	2014-01-21 14:02:20.326+01	0	1	no_NO	pc.cf.Lifting.v04
42	57	Heisefester kan ryke	Personskade for bakkemannskap	Bakkemannskap bruker hjelm og annet verneutstyr	\N	2014-01-21 14:02:35.278+01	0	1	no_NO	pc.cf.Lifting.v05
18	51	LÃ¸se ender kan vÃ¦re i spenn og slÃ¥ ut	Kan skade ansikt og Ã¸yne pÃ¥ personell	Bruk verneutstyr, sett fast lÃ¸se ender kontrollert	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.LongLoad.v01
31	64	RÃ¥te i mast	Mast knekker	Bankekontroll og visuell kontroll	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastClimb.v01
32	59	Reiseutstyr kan svikte	Mast faller ned og skader mennesker	Kontrollere utstyret (mÃ¥ vÃ¦re sertifisert)	\N	2014-01-21 13:36:20.418+01	0	1	no_NO	pc.cf.MastClimb.v02
33	59	Styringstau kan ryke	Mast faller ned og skader mennesker	Kontrollere tau	\N	2014-01-21 13:37:14.681+01	0	1	no_NO	pc.cf.MastClimb.v03
11	47	InnÃ¥nding av stÃ¸v	Skader luftveier	Maske	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetup.v01
29	62	StrekkverktÃ¸y 1	StrekkverktÃ¸y 1-1	StrekkverktÃ¸y 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetupMachine.v01
30	63	TrekkverktÃ¸y 1	TrekkverktÃ¸y 1-1	TrekkverktÃ¸y 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetupMachine.v02
25	58	Bred last 1	Bred last 1-1	Bred last 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetupManual.v01
26	59	Rotende kan skli	Mast faller ned og skader mennesker	Planlegge godt pÃ¥ forhÃ¥nd	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetupManual.v02
27	60	Stropper kan ryke	Klemskader, slag	Kontrollere utstyret (mÃ¥ vÃ¦re sertifisert)	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetupManual.v03
28	61	Montasje bardun 1	Montasje bardun 1-1	Montasje bardun 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MastSetupManual.v04
21	54	Ender pÃ¥ kobberwire kan slÃ¥ ut (snurr)	Klemskader, kuttskader, slag, riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.MountRope.v01
24	57	Tau/heiseanordning kan ryke	Faller ned og skader personell	Alt av heiseanordning sjekkes og sikres med tau - 2 barrierer	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.RockDrillingMachine.v04
34	59	Feste for styringstau kan svikte	Mast faller ned og skader mennesker	Kontrollere knuter og feste	\N	2014-01-21 13:39:10.623+01	0	1	no_NO	pc.cf.StrainReliefMount.v01
51	67	VerktÃ¸y kan mistes	Andre pÃ¥ bakken kan skades	Bakkemannskap bruker hjelm og annet verneutstyr	\N	2014-01-21 14:27:11.3+01	0	1	no_NO	pc.cf.StrainReliefMount.v02
23	56	Tung last 1	Tung last 1-1	Tung last 1-1-1	\N	2013-04-09 13:46:19.851+02	0	1	no_NO	pc.cf.WinchTool.v01
194	89	StÃ¸v	Stor	Lufting	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v069
48	66	VerktÃ¸y kan mistes	Andre pÃ¥ bakken kan skades	Bakkemannskap bruker hjelm og annet verneutstyr	\N	2014-01-21 14:23:25.357+01	0	1	no_NO	pc.cf.CableChannelMount.v02
50	67	LÃ¸se deler kan falle ned	Andre pÃ¥ bakken kan skades	LÃ¸se deler oppbevares forsvarlig	\N	2014-01-21 14:25:56.628+01	0	1	no_NO	pc.cf.CableChannelMount.v04
61	70	InnÃ¥nding av kjemikalier	Fare for Ã¥ndedrett	SÃ¸rg for god utlufting og om nÃ¸dvendig vernemaske	\N	2014-01-21 14:37:52.832+01	0	1	no_NO	pc.cf.Cleaning.v01
62	70	Brukte filler kan vÃ¦re brannfarlige	Ved bruk av ild kan filler ta fyr	Legg brukte filler bort slik at Ã¥pen varme ikke kan nÃ¥ dem	\N	2014-01-21 14:38:24.871+01	0	1	no_NO	pc.cf.Cleaning.v02
45	65	Stein spres utover	Andre bygg og anlegg kan skades	Bruke nÃ¸dvendig dekning	\N	2014-01-21 14:19:25.656+01	0	1	no_NO	pc.cf.ConnectGrounding.v03
58	69	Kniver kan glippe	Kuttskader	Bruk skarpe gjenstander med bevegelse fra deg	\N	2014-01-21 14:35:17.12+01	0	1	no_NO	pc.cf.DismantleCable.v01
59	69	JernbÃ¥ndarmering kan vÃ¦re skarp	Kutt- og riftskader	Fjern kontrollert Ã©n del av gangen	\N	2014-01-21 14:35:48.464+01	0	1	no_NO	pc.cf.DismantleCable.v02
60	69	Kappe kan vÃ¦re skarp	Kutt- og riftskader	Fjern deler og legg dem slik at de ikke kan skade noe	\N	2014-01-21 14:36:19.68+01	0	1	no_NO	pc.cf.DismantleCable.v03
78	75	Det finnes andre kabler i jorden	Kabelskader og evt. lysbueskader	UndersÃ¸k alltid om det fins andre kabler i jorden fÃ¸r graving	\N	2014-01-21 22:01:01.191+01	0	1	no_NO	pc.cf.DitchDig.v02
79	75	Ã˜vrig trafikk	Personell og utstyr kan skades	Skiltplaner, skilting og sperring	\N	2014-01-21 22:04:12.594+01	0	1	no_NO	pc.cf.DitchDig.v03
80	75	GrÃ¸ft kan ry igjen	Klemskader for peronell i grÃ¸ften	Bruk verneutstyr og stÃ¸tt av grÃ¸ftevegger om nÃ¸dvendig	\N	2014-01-21 22:11:48.432+01	0	1	no_NO	pc.cf.DitchDig.v04
81	75	Andre kan falle ned i grÃ¸ften	Skade pÃ¥ tredjeperson	God markering/sperring etterhvert som graving pÃ¥gÃ¥r	\N	2014-01-21 22:16:26.538+01	0	1	no_NO	pc.cf.DitchDig.v05
82	75	Steinfliser kan sprute under graving	Kutt- og riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-21 22:20:09.352+01	0	1	no_NO	pc.cf.DitchDig.v06
73	74	Skarpe kanter ved stÃ¥lfundament	Kutt- og riftskader	Bruk hansker og annet verneutstyr	\N	2014-01-21 21:24:24.393+01	0	1	no_NO	pc.cf.FoundationHousingMount.v01
74	74	Stropper ryker ved heising	Klemskader, kuttskader, slag	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-21 21:27:45.681+01	0	1	no_NO	pc.cf.FoundationHousingMount.v02
75	74	Montering av jordspyd	Slagskader ved montering av jordspyd	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-21 21:28:56.192+01	0	1	no_NO	pc.cf.FoundationHousingMount.v03
76	74	Ender pÃ¥ kobberwire kan slÃ¥ ut (snurr)	Kuttskader, riftskader, Ã¸yeskade	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-21 21:32:16.472+01	0	1	no_NO	pc.cf.FoundationHousingMount.v04
65	72	Objekter kan ta fyr	Brann	VÃ¦r foreredt med slukkeutstyr	\N	2014-01-21 14:42:05.917+01	0	1	no_NO	pc.cf.HeatShrink.v01
67	72	Kan pÃ¥fÃ¸re brannskader	Brannskader pÃ¥ kropp	UndersÃ¸k om det finnes kaldt vann i nÃ¦rheten	\N	2014-01-21 14:43:16.252+01	0	1	no_NO	pc.cf.HeatShrink.v03
68	72	Bekledning kan ta fyr	Store brannskader	Ha tilgjengelig kalde omslag	\N	2014-01-21 14:43:57.245+01	0	1	no_NO	pc.cf.HeatShrink.v04
69	72	Propanflaske kan svikte	Brenner pÃ¥ steder hvor det ikke skal brenne	Kontroller propanslange og tilkoblinger	\N	2014-01-21 14:44:27.669+01	0	1	no_NO	pc.cf.HeatShrink.v05
83	76	Trommel kan velte	Skade pÃ¥ tredjeperson, skade pÃ¥ personell	Bruk sertifisert utstyr	\N	2014-01-22 08:13:46.937+01	0	1	no_NO	pc.cf.LayingCablePipe.v01
84	76	Stropper og lÃ¸fteutstyr kan ryke	Skade pÃ¥ utstyr	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 08:14:18.728+01	0	1	no_NO	pc.cf.LayingCablePipe.v02
53	68	Tau/heiseanordning kan ryke	Kabel faller ned og skader personell	Alt av heiseanordning sjekkes, sikre med tau	\N	2014-01-21 14:32:01.69+01	0	1	no_NO	pc.cf.LiftCableMast.v01
54	68	Kabel/endeavslutning kan skades	Ny montasje/skjÃ¸t	Sette stopper slik at stropp ikke glir	\N	2014-01-21 14:32:40.746+01	0	1	no_NO	pc.cf.LiftCableMast.v02
56	68	Ved plutselig vridning kan ende slÃ¥	Slagskader av kabelsko/hylse	Knytt sammen endene, ta av snurr pÃ¥ kabelen	\N	2014-01-21 14:33:48.793+01	0	1	no_NO	pc.cf.LiftCableMast.v04
57	68	Ved plutselig vridning kan ende slÃ¥	Slagskader av kabelsko/hylse	Bakkemannskap bruker hjelm og annet verneutstyr	\N	2014-01-21 14:34:01.729+01	0	1	no_NO	pc.cf.LiftCableMast.v05
70	73	Maskindeler kan ryke	Personell kan skades	Respekter maskinens arbeidssone	\N	2014-01-21 14:49:40.946+01	0	1	no_NO	pc.cf.PrepareGroundTrafo.v01
71	73	Det finnes andre kabler i jorden	Kabelskader og evt. lysbueskader	UndersÃ¸k alltid om det fins andre kabler i jorden fÃ¸r graving	\N	2014-01-21 14:50:09.314+01	0	1	no_NO	pc.cf.PrepareGroundTrafo.v02
72	73	Steinfliser kan sprute under graving	Kutt- og riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-21 14:50:42.794+01	0	1	no_NO	pc.cf.PrepareGroundTrafo.v03
63	71	Hydrauliske slanger kan ryke	Olje kan sprute ukontrollert	Slanger sjekkes kontinuerlig visuelt	\N	2014-01-21 14:40:14.559+01	0	1	no_NO	pc.cf.PressureSleeve.v01
52	67	VerktÃ¸y kan mistes	Andre pÃ¥ bakken kan skades	Sikre verktÃ¸y slik at det henger fast selv om det glipper	\N	2014-01-21 14:27:25.364+01	0	1	no_NO	pc.cf.StrainReliefMount.v03
85	77	Klemskader mellom mast, bolt og bryter	Klemskader	VÃ¦re obs! og holde forsvarlig avstand	\N	2014-01-22 08:17:12.398+01	0	1	no_NO	pc.cf.SwitchFix.v01
86	77	Heiseanordning slakkes fÃ¸r bryter er festet godt	Bryter kan falle ut av festene, rykk i mast	Ikke anordne bryter mellom mast og person	\N	2014-01-22 08:17:44.319+01	0	1	no_NO	pc.cf.SwitchFix.v02
87	77	Heiseanordning slakkes fÃ¸r bryter er festet godt	Bryter kan falle ut av festene, rykk i mast	Sikre bryter med heiseanordning fÃ¸r mutter og bolter settes pÃ¥ plass	\N	2014-01-22 08:17:58.511+01	0	1	no_NO	pc.cf.SwitchFix.v03
88	78	Heisefester kan ryke	Andre pÃ¥ bakken kan skades	Alt av heiseanordning sjekkes og sikres med tau (2 barrierer)	\N	2014-01-22 08:19:08.006+01	0	1	no_NO	pc.cf.SwitchPanelMount.v01
91	78	Mast er iset	Klatresko glipper	Fjerne is fÃ¸r klatring	\N	2014-01-22 08:20:41.453+01	0	1	no_NO	pc.cf.SwitchPanelMount.v02
92	78	RÃ¥te i mast	Mast knekker	Bankekontroll og visuell kontroll	\N	2014-01-22 08:23:03.524+01	0	1	no_NO	pc.cf.SwitchPanelMount.v03
106	84	GrÃ¸ft kan ry igjen	Personell og utstyr kan skades	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:12:07.438+01	0	1	no_NO	pc.cf.AssembleDisassembleCabinet.v02
107	84	Tunge lÃ¸ft	Ryggskader	Riktig lÃ¸fteteknikk	\N	2014-01-22 10:12:42.839+01	0	1	no_NO	pc.cf.AssembleDisassembleCabinet.v03
158	89	Ras i grÃ¸ft	Stor	Arbeidshansker	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v033
109	84	Trafikk	Personell og utstyr kan skades	Skiltplaner, skilting og sperring	\N	2014-01-22 10:13:43.781+01	0	1	no_NO	pc.cf.AssembleDisassembleCabinet.v05
110	85	Skarpe kanter ved stÃ¥lfundament	Klemskader, kuttskader, slag, riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:15:03.277+01	0	1	no_NO	pc.cf.AssembleDisassembleMainstay.v01
111	85	Fallende gjenstander	Faller ned og skader personell	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:15:35.301+01	0	1	no_NO	pc.cf.AssembleDisassembleMainstay.v02
98	81	Heisefester kan ryke	Personell og utstyr kan skades	Bruk sertifisert utstyr	\N	2014-01-22 09:59:57.867+01	0	1	no_NO	pc.cf.AssembleNewSwitch.v01
100	82	StrÃ¸mgjennomgang	Brannskader pÃ¥ kropp	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:01:29.915+01	0	1	no_NO	pc.cf.ConnectDisconnectCableHV.v01
101	82	StrÃ¸mgjennomgang	Brannskader pÃ¥ kropp	Ha tilgjengelig kalde omslag	\N	2014-01-22 10:01:46.363+01	0	1	no_NO	pc.cf.ConnectDisconnectCableHV.v02
102	82	StrÃ¸mgjennomgang	Hjertestans	Planlegge godt pÃ¥ forhÃ¥nd	\N	2014-01-22 10:02:17.746+01	0	1	no_NO	pc.cf.ConnectDisconnectCableHV.v03
94	79	Heisefester kan ryke	Personell og utstyr kan skades	Bruk sertifisert utstyr	\N	2014-01-22 08:42:40.276+01	0	1	no_NO	pc.cf.DisassembleOldSwitch.v01
103	83	GrÃ¸ft kan ry igjen	Klemskader for personell i grÃ¸ften	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:07:10.032+01	0	1	no_NO	pc.cf.FoundationStationMount.v01
104	83	Skarpe kanter ved stÃ¥lfundament	Klemskader, kuttskader, slag, riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:09:31.552+01	0	1	no_NO	pc.cf.FoundationStationMount.v02
96	80	Heisefester kan ryke	Personell og utstyr kan skades	Bruk sertifisert utstyr	\N	2014-01-22 08:49:39.321+01	0	1	no_NO	pc.cf.InOutTransportSwitch.v01
97	80	Legemsdeler kan komme i klem	Klemskader, kuttskader, slag, riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 08:49:39.321+01	0	1	no_NO	pc.cf.InOutTransportSwitch.v02
123	88	StrÃ¸mgjennomgang	Brannskader pÃ¥ kropp	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-23 09:56:35.971+01	0	1	no_NO	pc.cf.MeterConnect.v01
124	88	StrÃ¸mgjennomgang	Brannskader pÃ¥ kropp	Ha tilgjengelig kalde omslag	\N	2014-01-23 09:56:50.78+01	0	1	no_NO	pc.cf.MeterConnect.v02
125	88	StrÃ¸mgjennomgang	Hjertestans	Planlegge godt pÃ¥ forhÃ¥nd	\N	2014-01-23 09:57:14.651+01	0	1	no_NO	pc.cf.MeterConnect.v03
113	86	Miste verktÃ¸y/utstyr mot spenningsfÃ¸rende deler	Brannskader pÃ¥ kropp	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:18:53.372+01	0	1	no_NO	pc.cf.MeterDirectMount.v02
114	86	Fallskade	Personell og utstyr kan skades	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:19:27.788+01	0	1	no_NO	pc.cf.MeterDirectMount.v03
115	86	Feilkobling	Skade pÃ¥ utstyr	Kontroll av koblingsskjema	\N	2014-01-22 10:20:00.171+01	0	1	no_NO	pc.cf.MeterDirectMount.v04
116	87	Ã…pne trafoklemmer	Induksjon av spenning	Kortslutning av trafo	\N	2014-01-22 10:22:50.986+01	0	1	no_NO	pc.cf.MeterTrafoMount.v01
118	87	Miste verktÃ¸y/utstyr mot spenningsfÃ¸rende deler	Brannskader pÃ¥ kropp	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:23:54.689+01	0	1	no_NO	pc.cf.MeterTrafoMount.v03
119	87	Fallskade	Personell og utstyr kan skades	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:24:25.089+01	0	1	no_NO	pc.cf.MeterTrafoMount.v04
120	87	Feilkobling	Skade pÃ¥ utstyr	Kontroll av koblingsskjema	\N	2014-01-22 10:24:55.897+01	0	1	no_NO	pc.cf.MeterTrafoMount.v05
90	78	LÃ¸se deler kan falle ned	Flere tyngre deler kan briste og falle ned	LÃ¸se deler oppbevares forsvarlig	\N	2014-01-22 08:20:13.47+01	0	1	no_NO	pc.cf.SwitchPanelMount.v05
89	78	Klemskader mellom mast, bolt og bryter	Klemskader	VÃ¦re obs! og holde forsvarlig avstand	\N	2014-01-22 08:19:46.902+01	0	1	no_NO	pc.cf.SwitchPanelMount.v06
122	78	VerktÃ¸y kan mistes	Andre pÃ¥ bakken kan skades	Sikre verktÃ¸y slik at det henger fast selv om det glipper	\N	2014-01-23 09:48:34.144+01	0	1	no_NO	pc.cf.SwitchPanelMount.v07
126	89	Klemfare	Stor	Arbeidshansker	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v001
128	89	Klemfare	Stor	Vernesko	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v003
129	89	Klemfare	Stor	SynlighetsklÃ¦r	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v004
130	89	Klemfare	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v005
131	89	Klemfare	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v006
132	89	Klemfare	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v007
133	89	Kuttskader	Stor	Arbeidshansker	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v008
134	89	Kuttskader	Stor	Hjelm	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v009
136	89	Kuttskader	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v011
137	89	Kuttskader	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v012
138	89	Kuttskader	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v013
139	89	Kuttskader	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v014
141	89	Lysbue	Stor	Brannhemmende klÃ¦r	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v016
142	89	Lysbue	Stor	Vernesko	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v017
143	89	Lysbue	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v018
144	89	Lysbue	Stor	Brannslokningsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v019
145	89	Lysbue	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v020
147	89	Lysbue	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v022
148	89	Lysbue	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v023
149	89	Maskin fast i klÃ¦r	Stor	Arbeidshansker	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v024
150	89	Maskin fast i klÃ¦r	Stor	Hjelm	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v025
204	89	Terrengutfordringer	Stor	Fallsikring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v079
152	89	Maskin fast i klÃ¦r	Stor	SynlighetsklÃ¦r	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v027
153	89	Maskin fast i klÃ¦r	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v028
154	89	Maskin fast i klÃ¦r	Stor	Skiltplan	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v029
155	89	Maskin fast i klÃ¦r	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v030
157	89	Maskin fast i klÃ¦r	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v032
159	89	Ras i grÃ¸ft	Stor	Hjelm	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v034
160	89	Ras i grÃ¸ft	Stor	Vernesko	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v035
161	89	Ras i grÃ¸ft	Stor	Fysisk sikring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v036
163	89	Ras i grÃ¸ft	Stor	Fallsikring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v038
164	89	Ras i grÃ¸ft	Stor	Kontroll av grÃ¸ft	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v039
165	89	Ras i grÃ¸ft	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v040
166	89	Ras i grÃ¸ft	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v041
167	89	Ras i grÃ¸ft	Stor	Utkobling	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v042
168	89	RÃ¥te i stolper	Stor	Stolpeslynge	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v043
170	89	RÃ¥te i stolper	Stor	Fallsikring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v045
171	89	RÃ¥te i stolper	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v046
172	89	RÃ¥te i stolper	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v047
173	89	RÃ¥te i stolper	Stor	Ekstra bardunering	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v048
174	89	RÃ¥te i stolper	Stor	Bankekontroll	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v049
176	89	SF6 lekkasje	Stor	StÃ¸vmaske	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v051
177	89	SF6 lekkasje	Stor	Vernemaske	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v052
178	89	SF6 lekkasje	Stor	Ã˜yevern	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v053
179	89	SF6 lekkasje	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v054
180	89	SF6 lekkasje	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v055
181	89	SF6 lekkasje	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v056
182	89	SF6 lekkasje	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v057
184	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v059
185	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v060
186	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v061
187	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	Vurdere jordingsanlegget	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v062
188	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	Utkobling	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v063
190	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	Leder for sikkerhet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v065
191	89	StÃ¸v	Stor	StÃ¸vmaske	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v066
192	89	StÃ¸v	Stor	Vernemaske	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v067
193	89	StÃ¸v	Stor	Ã˜yevern	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v068
195	89	StÃ¸v	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v070
196	89	StÃ¸y	Stor	HÃ¸rselvern	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v071
197	89	StÃ¸y	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v072
198	89	StÃ¸y	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v073
199	89	Terrengutfordringer	Stor	Arbeidshansker	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v074
201	89	Terrengutfordringer	Stor	Vernesko	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v076
202	89	Terrengutfordringer	Stor	Fysisk sikring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v077
203	89	Terrengutfordringer	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v078
205	89	Terrengutfordringer	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v080
206	89	Terrengutfordringer	Stor	PlanleggingsmÃ¸te	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v081
208	89	VÃ¦rutfordring	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v083
209	89	VÃ¦rutfordring	Stor	Leder for sikkerhet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v084
210	89	VÃ¦rutfordring	Stor	Avente vÃ¦rforhold	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v085
211	89	VÃ¦rutfordring	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v086
212	89	VÃ¦rutfordring	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v087
213	89	VÃ¦rutfordring	Stor	Utkobling	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v088
215	89	Uklar organisering	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v090
216	89	Uklar organisering	Stor	PlanleggingsmÃ¸te	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v091
217	89	Ustabil last	Stor	Arbeidshansker	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v092
218	89	Ustabil last	Stor	Hjelm	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v093
219	89	Ustabil last	Stor	Vernesko	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v094
220	89	Ustabil last	Stor	Fysisk sikring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v095
105	84	Skarpe kanter ved stÃ¥lfundament	Klemskader, kuttskader, slag, riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 10:10:55.729+01	0	1	no_NO	pc.cf.AssembleDisassembleCabinet.v01
108	84	Fare for takras/isras	Personell og utstyr kan skades	Visuell kontroll og fjerning av faremoment	\N	2014-01-22 10:13:20.006+01	0	1	no_NO	pc.cf.AssembleDisassembleCabinet.v04
99	81	Legemsdeler kan komme i klem	Klemskader, kuttskader, slag, riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 09:59:57.867+01	0	1	no_NO	pc.cf.AssembleNewSwitch.v02
47	66	LÃ¸se deler kan falle ned	Andre pÃ¥ bakken kan skades	LÃ¸se deler oppbevares forsvarlig	\N	2014-01-21 14:22:57.782+01	0	1	no_NO	pc.cf.CableChannelMount.v01
49	66	VerktÃ¸y kan mistes	Andre pÃ¥ bakken kan skades	Sikre verktÃ¸y slik at det henger fast selv om det glipper	\N	2014-01-21 14:23:38.093+01	0	1	no_NO	pc.cf.CableChannelMount.v03
95	79	Legemsdeler kan komme i klem	Klemskader, kuttskader, slag, riftskader	Bruk nÃ¸dvendig verneutstyr	\N	2014-01-22 08:43:14.988+01	0	1	no_NO	pc.cf.DisassembleOldSwitch.v02
77	75	Maskindeler kan ryke	Personell kan skades	Respekter maskinens arbeidssone	\N	2014-01-21 21:55:44.337+01	0	1	no_NO	pc.cf.DitchDig.v01
46	66	Kabelkanalen kan falle ned	Andre pÃ¥ bakken kan skades	SÃ¸rge for Ã¥ sikre med tau under arbeidet	\N	2014-01-21 14:22:32.285+01	0	1	no_NO	pc.cf.FoundationBlast.v01
66	72	InnÃ¥nding av farlige gasser	Skader i Ã¥ndedrett og Ã¸yne	SÃ¸rg for lufting. Bruk Ã¥ndedrettsvern, ha rent vann i nÃ¦rheten	\N	2014-01-21 14:42:34.749+01	0	1	no_NO	pc.cf.HeatShrink.v02
55	68	Kan fÃ¥ skarpe bÃ¸yer (kank)	Kabelskade og farlig vridning	Ta av all snurr pÃ¥ kabel fÃ¸r heising	\N	2014-01-21 14:33:15.633+01	0	1	no_NO	pc.cf.LiftCableMast.v03
112	86	StrÃ¸mgjennomgang	Hjertestans	Utkobling av strÃ¸m	\N	2014-01-22 10:18:23.7+01	0	1	no_NO	pc.cf.MeterDirectMount.v01
117	87	StrÃ¸mgjennomgang	Hjertestans	Utkobling av strÃ¸m	\N	2014-01-22 10:23:23.449+01	0	1	no_NO	pc.cf.MeterTrafoMount.v02
121	87	LÃ¸se anleggsdeler	Kontakt med spenningsfÃ¸rende deler	Visuell kontroll og fjerning av faremoment	\N	2014-01-22 10:25:31.865+01	0	1	no_NO	pc.cf.MeterTrafoMount.v06
64	71	Brukte filler kan vÃ¦re brannfarlige	Ved bruk av ild kan filler ta fyr	Legg brukte filler bort slik at Ã¥pen varme ikke kan nÃ¥ dem	\N	2014-01-21 14:40:48.686+01	0	1	no_NO	pc.cf.PressureSleeve.v02
93	78	VerktÃ¸y kan mistes	Andre pÃ¥ bakken kan skades	Bakkemannskap bruker hjelm og annet verneutstyr	\N	2014-01-22 08:31:26.258+01	0	1	no_NO	pc.cf.SwitchPanelMount.v04
135	89	Kuttskader	Stor	Vernesko	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v010
140	89	Lysbue	Stor	Arbeidshansker	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v015
146	89	Lysbue	Stor	PlanleggingsmÃ¸te	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v021
151	89	Maskin fast i klÃ¦r	Stor	Vernesko	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v026
156	89	Maskin fast i klÃ¦r	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v031
162	89	Ras i grÃ¸ft	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v037
169	89	RÃ¥te i stolper	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v044
175	89	RÃ¥te i stolper	Stor	Visuell kontroll mast	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v050
183	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	Jording/kortslutning	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v058
189	89	Skrittspenning , spenning pÃ¥ kabel, strÃ¸mgjennomgang	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v064
200	89	Terrengutfordringer	Stor	Hjelm	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v075
207	89	Terrengutfordringer	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v082
214	89	Uklar organisering	Stor	Leder for sikkerhet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v089
221	89	Ustabil last	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v096
222	89	Ustabil last	Stor	Kontroll av last	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v097
223	89	Ustabil last	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v098
224	89	Ustabil last	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v099
225	89	Ã˜yeskade	Stor	Ã˜yevern	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v100
226	89	Ã˜yeskade	Stor	FÃ¸rstehjelpsutstyr	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v101
227	89	Ã˜yeskade	Stor	OpplÃ¦ring	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v102
228	89	Ã˜yeskade	Stor	Samband	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v103
229	89	Ã˜yeskade	Stor	To pÃ¥ arbeidsstedet	\N	2014-03-14 14:00:00+01	0	1	no_NO	pc.cf.SJA.v104
\.


--
-- TOC entry 2655 (class 0 OID 27560)
-- Dependencies: 234
-- Data for Name: tiltak; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY tiltak (id, navn, id_risiko, id_customfield, endret_av, endret_dato, slettet, updateid, locale, value) FROM stdin;
20	Ingen tiltak nÃ¸dvendig	2	4	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.SlideDanger.v02
21	Flytting av anlegg 	3	4	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.SlideDanger.v03
22	Bekyttelse mot ras	3	4	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.SlideDanger.v04
23	Flytting av anlegg 	4	4	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.SlideDanger.v05
24	Bekyttelse mot ras	4	4	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.SlideDanger.v06
109	Filter montert i alle kanaler hvor der tilkommer luft 	3	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v04
110	REN-blad 6020 er benyttet	3	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v05
111	Montert ventilasjonsfilter	4	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v06
112	Filter montert i alle kanaler hvor der tilkommer luft 	4	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v07
113	REN-blad 6020 er benyttet	4	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v08
114	Ingen tiltak	1	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v01
115	Ingen tiltak nÃ¸dvendig	2	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v02
116	Oppsamlingskar for olje montert	3	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v03
117	Anlegget flyttes	3	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v04
118	MiljÃ¸ufarlige stoffer benyttes	3	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v05
119	Oppsamlingskar for olje montert	4	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v06
120	Anlegget flyttes	4	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v07
121	MiljÃ¸ufarlige stoffer benyttes	4	32	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Pollution.v08
152	Flytting av anlegget	3	42	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ThirdPersonDanger.v03
154	Flytting av anlegget	4	42	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ThirdPersonDanger.v05
155	Skjerming av anlegget	4	42	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ThirdPersonDanger.v06
72	All vegetasjon rundt anlegget fjernes	4	18	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FungusDecay.v05
73	Hindre videre vekst rundt anlegget	4	18	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FungusDecay.v06
74	Ingen tiltak	1	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v01
75	Ingen tiltak nÃ¸dvendig	2	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v02
76	Montert fuglebeskyttelse	3	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v03
77	Montert nett mot hakkespett 	3	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v04
78	Beskyttelse mot gnagere	3	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v05
79	Montert fuglebeskyttelse	4	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v06
80	Montert nett mot hakkespett 	4	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v07
81	Beskyttelse mot gnagere	4	20	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FaunaAnimals.v08
82	Ingen tiltak	1	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v01
83	Ingen tiltak nÃ¸dvendig	2	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v02
84	Vurder vindlast i kombinasjon med snÃ¸	3	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v03
85	Egen prosedyre i REN-2007 fulgt 	3	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v04
86	Tiltak vurdert i samarbeid med leverandÃ¸r	3	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v05
129	Riktig farge i forhold til omgivelser valgt. 	4	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v08
156	Ingen tiltak	1	44	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.OtherRisks.v01
25	Ingen tiltak	1	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v01
26	Ingen tiltak nÃ¸dvendig	2	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v02
61	Linjen forsterkes	4	14	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FallingTree.v07
62	Ingen tiltak	1	16	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterMoist.v01
63	Ingen tiltak nÃ¸dvendig	2	16	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterMoist.v02
64	Tiltak vurdert i samarbeid med leverandÃ¸r	3	16	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterMoist.v03
65	Anlegget har hÃ¸yere IP-grad	3	16	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterMoist.v04
66	Tiltak vurdert i samarbeid med leverandÃ¸r	4	16	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterMoist.v05
157	Ingen tiltak nÃ¸dvendig	2	44	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.OtherRisks.v02
158	Noter hvilke i felt for kommentar	3	44	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.OtherRisks.v03
67	Anlegget har hÃ¸yere IP-grad	4	16	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterMoist.v06
68	Ingen tiltak	1	18	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FungusDecay.v01
69	Ingen tiltak nÃ¸dvendig	2	18	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FungusDecay.v02
70	All vegetasjon rundt anlegget fjernes	3	18	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FungusDecay.v03
71	Hindre videre vekst rundt anlegget	3	18	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FungusDecay.v04
15	REN-blad 5012 fulgt	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v15
16	REN-blad 9104 fulgt	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v16
17	Flytting av anlegg	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v17
18	Forsterkning av fundament	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v18
153	Skjerming av anlegget	3	42	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ThirdPersonDanger.v04
19	Ingen tiltak	1	4	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.SlideDanger.v01
145	Brannbeskyttelse	3	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v04
122	Ingen tiltak	1	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v01
123	Ingen tiltak nÃ¸dvendig	2	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v02
124	UnngÃ¥ siluett	3	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v03
125	UngÃ¥ Ã¥ stenge utsikt for naboer	3	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v04
126	Riktig farge i forhold til omgivelser valgt. 	3	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v05
127	UnngÃ¥ siluett	4	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v06
128	UngÃ¥ Ã¥ stenge utsikt for naboer	4	34	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Appearance.v07
146	Brannalarm/melding	3	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v05
147	Avstand til bygg Ã¸kes	4	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v06
148	Brannbeskyttelse	4	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v07
149	Brannalarm/melding	4	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v08
150	Ingen tiltak	1	42	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ThirdPersonDanger.v01
151	Ingen tiltak nÃ¸dvendig	2	42	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ThirdPersonDanger.v02
92	Stor snÃ¸last konferert med leverandÃ¸r	3	24	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Snow.v03
93	Stor snÃ¸last konferert med leverandÃ¸r	4	24	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Snow.v04
87	Vurder vindlast i kombinasjon med snÃ¸	4	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v06
88	Egen prosedyre i REN-2007 fulgt 	4	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v07
94	Ingen tiltak	1	26	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Flood.v01
95	Ingen tiltak nÃ¸dvendig	2	26	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Flood.v02
130	Ingen tiltak	1	36	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ElectroMagnetic.v01
131	Ingen tiltak nÃ¸dvendig	2	36	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ElectroMagnetic.v02
132	Vurder flytting av anlegget 	3	36	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ElectroMagnetic.v03
133	Anlegget flyttes 	4	36	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.ElectroMagnetic.v04
134	Ingen tiltak	1	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v01
135	Ingen tiltak nÃ¸dvendig	2	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v02
136	Etablere alternative forsyningsveger	3	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v03
137	Etablere aggregat kjÃ¸ring 	3	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v04
138	Overspenningsvern montert	3	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v05
139	Etablere alternative forsyningsveger	4	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v06
140	Etablere aggregat kjÃ¸ring 	4	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v07
141	Overspenningsvern montert	4	38	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Deliverability.v08
142	Ingen tiltak	1	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v01
143	Ingen tiltak nÃ¸dvendig	2	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v02
144	Avstand til bygg Ã¸kes	3	40	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FireProtection.v03
50	Tiltak vurdert ihh til REN-6016	3	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v06
51	Trafo stÃ¥r pÃ¥ antivibrasjonsplate	4	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v07
52	Annen lydisolering iverksatt i rommet 	4	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v08
53	Lydfeller montert i ventilasjon	4	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v09
54	Tiltak vurdert ihh til REN-6016	4	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v10
55	Ingen tiltak	1	14	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FallingTree.v01
56	Ingen tiltak nÃ¸dvendig	2	14	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FallingTree.v02
58	Linjen  forsterkes	3	14	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FallingTree.v04
59	Risikoen godtaes	3	14	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FallingTree.v05
60	Skogrydding	4	14	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FallingTree.v06
27	FÃ¥tt garanti fra leverandÃ¸r	3	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v03
28	Sjekket anleggets isolasjonsnivÃ¥	3	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v04
29	Sjekket beskrivelsen for komponenten 	3	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v05
30	FÃ¥tt garanti fra leverandÃ¸r	4	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v06
31	Sjekket anleggets isolasjonsnivÃ¥	4	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v07
32	Sjekket beskrivelsen for komponenten 	4	6	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.WaterDistance.v08
33	Ingen tiltak	1	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v01
34	Ingen tiltak nÃ¸dvendig	2	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v02
35	Beskyttet mot pÃ¥kjÃ¸ring	3	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v03
36	Anlegget er forsterket	3	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v04
37	Ekstra hÃ¸y snÃ¸markÃ¸r er montert	3	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v05
38	Beskyttet mot pÃ¥kjÃ¸ring	4	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v06
39	Anlegget er forsterket	4	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v07
40	Ekstra hÃ¸y snÃ¸markÃ¸r er montert	4	8	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.MechanicInterference.v08
41	Ingen tiltak	1	10	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Vibrations.v01
42	Ingen tiltak nÃ¸dvendig	2	10	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Vibrations.v02
43	Tiltak i samarbeid med leverandÃ¸r	3	10	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Vibrations.v03
44	Tiltak i samarbeid med leverandÃ¸r	4	10	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Vibrations.v04
45	Ingen tiltak	1	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v01
46	Ingen tiltak nÃ¸dvendig	2	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v02
47	Trafo stÃ¥r pÃ¥ antivibrasjonsplate	3	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v03
48	Annen lydisolering iverksatt i rommet 	3	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v04
49	Lydfeller montert i ventilasjon	3	12	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Noise.v05
57	Skogrydding	3	14	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.FallingTree.v03
96	Vurder flytting av anlegget 	3	26	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Flood.v03
97	Godtar risikoen	3	26	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Flood.v04
98	Plassering i samrÃ¥d med leverandÃ¸r	3	26	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Flood.v05
99	Anlegget flyttes 	4	26	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Flood.v06
100	Ingen tiltak	1	28	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Temperatur.v01
101	Ingen tiltak nÃ¸dvendig	2	28	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Temperatur.v02
102	LeverandÃ¸r kontaktet 	3	28	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Temperatur.v03
103	Ventilasjon monteres	3	28	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Temperatur.v04
104	LeverandÃ¸r kontaktet 	4	28	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Temperatur.v05
105	Ventilasjon monteres	4	28	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Temperatur.v06
106	Ingen tiltak	1	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v01
107	Ingen tiltak nÃ¸dvendig	2	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v02
108	Montert ventilasjonsfilter	3	30	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.CorrosiveSubstances.v03
1	Ingen tiltak	1	2	\N	2013-03-12 10:43:18.214+01	0	1	no_NO	pc.cf.FoundationSlip.v01
2	Ingen tiltak nÃ¸dvendig	2	2	\N	2013-03-12 10:43:58.163+01	0	1	no_NO	pc.cf.FoundationSlip.v02
3	Flytting av anlegg	3	2	\N	2013-03-12 10:44:32.989+01	0	1	no_NO	pc.cf.FoundationSlip.v03
4	Forsterkning av fundament	3	2	\N	2013-03-12 10:44:51.414+01	0	1	no_NO	pc.cf.FoundationSlip.v04
5	Garanti fra leverandÃ¸r	3	2	\N	2013-03-12 10:47:25.339+01	0	1	no_NO	pc.cf.FoundationSlip.v05
6	REN-blad 6028 fulgt	3	2	\N	2013-03-12 10:47:25.339+01	0	1	no_NO	pc.cf.FoundationSlip.v06
7	REN-blad 5012 fulgt	3	2	\N	2013-03-12 10:47:25.339+01	0	1	no_NO	pc.cf.FoundationSlip.v07
8	REN-blad 9104 fulgt	3	2	\N	2013-03-12 10:47:25.339+01	0	1	no_NO	pc.cf.FoundationSlip.v08
9	Flytting av anlegg	3	2	\N	2013-03-12 10:47:25.339+01	0	1	no_NO	pc.cf.FoundationSlip.v09
10	Forsterkning av fundament	3	2	\N	2013-03-12 10:47:25.339+01	0	1	no_NO	pc.cf.FoundationSlip.v10
11	Garanti fra leverandÃ¸r	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v11
12	Garanti fra leverandÃ¸r	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v12
13	Garanti fra leverandÃ¸r	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v13
14	REN-blad 6028 fulgt	4	2	\N	2013-03-12 10:55:09.2+01	0	1	no_NO	pc.cf.FoundationSlip.v14
159	Noter hvilke i felt for kommentar	4	44	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.OtherRisks.v04
90	Ingen tiltak	1	24	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Snow.v01
91	Ingen tiltak nÃ¸dvendig	2	24	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Snow.v02
89	Tiltak vurdert i samarbeid med leverandÃ¸r	4	22	\N	2013-03-13 09:57:31.791+01	0	1	no_NO	pc.cf.Wind.v08
\.


--
-- TOC entry 2656 (class 0 OID 27569)
-- Dependencies: 235
-- Data for Name: webservice_failures; Type: TABLE DATA; Schema: prosjekt; Owner: powercatch
--

COPY webservice_failures (issue_id, id, url, query_parameters, message, created, update_existing_project) FROM stdin;
\.


SET search_path = sync, pg_catalog;

--
-- TOC entry 2674 (class 0 OID 27774)
-- Dependencies: 253
-- Data for Name: deviation; Type: TABLE DATA; Schema: sync; Owner: powercatch
--

COPY deviation (id, key, username, sync_date, content, comment) FROM stdin;
\.


--
-- TOC entry 2673 (class 0 OID 27766)
-- Dependencies: 252
-- Data for Name: issue; Type: TABLE DATA; Schema: sync; Owner: powercatch
--

COPY issue (id, key, username, sync_status, sync_date, content, comment, mobilesyncstatus, steps_executed) FROM stdin;
\.


--
-- TOC entry 2677 (class 0 OID 27806)
-- Dependencies: 256
-- Data for Name: issue_backup; Type: TABLE DATA; Schema: sync; Owner: powercatch
--

COPY issue_backup (id, key, username, sync_status, sync_date, content, comment, mobilesyncstatus, steps_executed) FROM stdin;
\.


--
-- TOC entry 2678 (class 0 OID 27812)
-- Dependencies: 257
-- Data for Name: issue_error; Type: TABLE DATA; Schema: sync; Owner: powercatch
--

COPY issue_error (id, key, username, sync_status, sync_date, content, comment, mobilesyncstatus, steps_executed) FROM stdin;
\.


SET search_path = tekla, pg_catalog;

--
-- TOC entry 2657 (class 0 OID 27577)
-- Dependencies: 236
-- Data for Name: action; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY action (id_condclass_id, action_id, actiontype, id_object, id) FROM stdin;
\.


--
-- TOC entry 2823 (class 0 OID 0)
-- Dependencies: 237
-- Name: action_id_seq; Type: SEQUENCE SET; Schema: tekla; Owner: powercatch
--

SELECT pg_catalog.setval('action_id_seq', 6, true);


--
-- TOC entry 2659 (class 0 OID 27582)
-- Dependencies: 238
-- Data for Name: attrvalue; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY attrvalue (field, value, id_object) FROM stdin;
\.


--
-- TOC entry 2660 (class 0 OID 27585)
-- Dependencies: 239
-- Data for Name: condclass; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY condclass (condclass_id, name, description, valuetype, createddate, updateddate, datatype, actiontype, deleted, defaultvalue, unit) FROM stdin;
\.


--
-- TOC entry 2661 (class 0 OID 27594)
-- Dependencies: 240
-- Data for Name: condclassvalues; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY condclassvalues (description, id_condclass_id, code, createddate, updateddate, deleted) FROM stdin;
\.


--
-- TOC entry 2662 (class 0 OID 27600)
-- Dependencies: 241
-- Data for Name: condvalue; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY condvalue (id_condclass_id, value, id_parent_condclass_id, id_object, sortorder, condclassname, id_urgency, comment, id_action, id) FROM stdin;
\.


--
-- TOC entry 2663 (class 0 OID 27606)
-- Dependencies: 242
-- Data for Name: field; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY field (name, visiblename, category, fieldlength, id_table, createddate, updateddate, deleted, id_class) FROM stdin;
\.


--
-- TOC entry 2824 (class 0 OID 0)
-- Dependencies: 244
-- Name: object_id_seq; Type: SEQUENCE SET; Schema: tekla; Owner: powercatch
--

SELECT pg_catalog.setval('object_id_seq', 21, true);


--
-- TOC entry 2825 (class 0 OID 0)
-- Dependencies: 246
-- Name: order_id_seq; Type: SEQUENCE SET; Schema: tekla; Owner: powercatch
--

SELECT pg_catalog.setval('order_id_seq', 7, true);


--
-- TOC entry 2668 (class 0 OID 27630)
-- Dependencies: 247
-- Data for Name: sysdataclass; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY sysdataclass (id, name, id_table, createddate, updateddate, deleted) FROM stdin;
\.


--
-- TOC entry 2669 (class 0 OID 27636)
-- Dependencies: 248
-- Data for Name: sysdatatable; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY sysdatatable (table_id, name, id, typeid, createddate, updateddate, deleted) FROM stdin;
\.


--
-- TOC entry 2826 (class 0 OID 0)
-- Dependencies: 249
-- Name: table_id_seq; Type: SEQUENCE SET; Schema: tekla; Owner: powercatch
--

SELECT pg_catalog.setval('table_id_seq', 125, true);


--
-- TOC entry 2664 (class 0 OID 27612)
-- Dependencies: 243
-- Data for Name: teklaobject; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY teklaobject (object_id, issue_key, id_order, id, id_table, sortorder, locked, comment, id_object, label) FROM stdin;
\.


--
-- TOC entry 2666 (class 0 OID 27620)
-- Dependencies: 245
-- Data for Name: teklaorder; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY teklaorder (id, issue_key, xml_order, order_id, createddate, updateddate, order_type) FROM stdin;
\.


--
-- TOC entry 2671 (class 0 OID 27644)
-- Dependencies: 250
-- Data for Name: urgency; Type: TABLE DATA; Schema: tekla; Owner: powercatch
--

COPY urgency (code, value, createddate, updateddate, deleted) FROM stdin;
\.


SET search_path = equipment, pg_catalog;

--
-- TOC entry 2413 (class 2606 OID 27658)
-- Name: pk_consumption; Type: CONSTRAINT; Schema: equipment; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY consumption
    ADD CONSTRAINT pk_consumption PRIMARY KEY (id);


--
-- TOC entry 2415 (class 2606 OID 27660)
-- Name: pk_consumption_item; Type: CONSTRAINT; Schema: equipment; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY consumption_item
    ADD CONSTRAINT pk_consumption_item PRIMARY KEY (id);


--
-- TOC entry 2417 (class 2606 OID 27662)
-- Name: pk_item; Type: CONSTRAINT; Schema: equipment; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY item
    ADD CONSTRAINT pk_item PRIMARY KEY (id);


--
-- TOC entry 2419 (class 2606 OID 27664)
-- Name: pk_storage; Type: CONSTRAINT; Schema: equipment; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY stock
    ADD CONSTRAINT pk_storage PRIMARY KEY (id);


--
-- TOC entry 2421 (class 2606 OID 27666)
-- Name: pk_template; Type: CONSTRAINT; Schema: equipment; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY template_issue
    ADD CONSTRAINT pk_template PRIMARY KEY (id);


--
-- TOC entry 2423 (class 2606 OID 27668)
-- Name: pk_template_item; Type: CONSTRAINT; Schema: equipment; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY template_issue_item
    ADD CONSTRAINT pk_template_item PRIMARY KEY (id);


SET search_path = infrastruktur, pg_catalog;

--
-- TOC entry 2435 (class 2606 OID 27670)
-- Name: nodetype_pk_plctype; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY nodetype
    ADD CONSTRAINT nodetype_pk_plctype PRIMARY KEY (id);


--
-- TOC entry 2425 (class 2606 OID 27672)
-- Name: pk_anlegg; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY anlegg
    ADD CONSTRAINT pk_anlegg PRIMARY KEY (id);


--
-- TOC entry 2427 (class 2606 OID 27674)
-- Name: pk_bryter; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY bryter
    ADD CONSTRAINT pk_bryter PRIMARY KEY (id);


--
-- TOC entry 2429 (class 2606 OID 27676)
-- Name: pk_bygning; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY bygning
    ADD CONSTRAINT pk_bygning PRIMARY KEY (id);


--
-- TOC entry 2407 (class 2606 OID 27678)
-- Name: pk_kabelskap; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY kabelskap
    ADD CONSTRAINT pk_kabelskap PRIMARY KEY (id);


--
-- TOC entry 2431 (class 2606 OID 27680)
-- Name: pk_linje; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY linje
    ADD CONSTRAINT pk_linje PRIMARY KEY (id);


--
-- TOC entry 2411 (class 2606 OID 27682)
-- Name: pk_mastepunkt; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY mastepunkt
    ADD CONSTRAINT pk_mastepunkt PRIMARY KEY (id);


--
-- TOC entry 2409 (class 2606 OID 27684)
-- Name: pk_nettstasjon_ny; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY nettstasjon
    ADD CONSTRAINT pk_nettstasjon_ny PRIMARY KEY (id);


--
-- TOC entry 2433 (class 2606 OID 27686)
-- Name: pk_node; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY node
    ADD CONSTRAINT pk_node PRIMARY KEY (id);


--
-- TOC entry 2437 (class 2606 OID 27688)
-- Name: pk_omraade; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY omraade
    ADD CONSTRAINT pk_omraade PRIMARY KEY (id);


--
-- TOC entry 2439 (class 2606 OID 27690)
-- Name: pk_plctype; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY plctype
    ADD CONSTRAINT pk_plctype PRIMARY KEY (id);


--
-- TOC entry 2441 (class 2606 OID 27692)
-- Name: pk_trafo; Type: CONSTRAINT; Schema: infrastruktur; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY trafo
    ADD CONSTRAINT pk_trafo PRIMARY KEY (id);


SET search_path = konfigurasjon, pg_catalog;

--
-- TOC entry 2445 (class 2606 OID 27694)
-- Name: id; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY config_user
    ADD CONSTRAINT id PRIMARY KEY (id);


--
-- TOC entry 2447 (class 2606 OID 27696)
-- Name: pk_field; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY field
    ADD CONSTRAINT pk_field PRIMARY KEY (id);


--
-- TOC entry 2449 (class 2606 OID 27698)
-- Name: pk_fieldproperty; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY fieldproperty
    ADD CONSTRAINT pk_fieldproperty PRIMARY KEY (id);


--
-- TOC entry 2451 (class 2606 OID 27700)
-- Name: pk_issuetype; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY issuetype
    ADD CONSTRAINT pk_issuetype PRIMARY KEY (id);


--
-- TOC entry 2453 (class 2606 OID 27702)
-- Name: pk_issuetype_page; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY issuetype_page
    ADD CONSTRAINT pk_issuetype_page PRIMARY KEY (id);


--
-- TOC entry 2455 (class 2606 OID 27704)
-- Name: pk_page; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY page
    ADD CONSTRAINT pk_page PRIMARY KEY (id);


--
-- TOC entry 2457 (class 2606 OID 27706)
-- Name: pk_page_fieldproperty; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY page_fieldproperty
    ADD CONSTRAINT pk_page_fieldproperty PRIMARY KEY (id);


--
-- TOC entry 2443 (class 2606 OID 27708)
-- Name: primary_key; Type: CONSTRAINT; Schema: konfigurasjon; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY config_server_values
    ADD CONSTRAINT primary_key PRIMARY KEY (id);


SET search_path = netbas, pg_catalog;

--
-- TOC entry 2459 (class 2606 OID 27710)
-- Name: arbeidsbeskrivelse_pkey; Type: CONSTRAINT; Schema: netbas; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY arbeidsbeskrivelse
    ADD CONSTRAINT arbeidsbeskrivelse_pkey PRIMARY KEY (tid);


--
-- TOC entry 2461 (class 2606 OID 27712)
-- Name: arbeidsoppdrag_pkey; Type: CONSTRAINT; Schema: netbas; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY arbeidsoppdrag
    ADD CONSTRAINT arbeidsoppdrag_pkey PRIMARY KEY (tid);


--
-- TOC entry 2463 (class 2606 OID 27714)
-- Name: attribute_pkey; Type: CONSTRAINT; Schema: netbas; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY attr
    ADD CONSTRAINT attribute_pkey PRIMARY KEY (name);


--
-- TOC entry 2465 (class 2606 OID 27716)
-- Name: cl_pkey; Type: CONSTRAINT; Schema: netbas; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY codelist
    ADD CONSTRAINT cl_pkey PRIMARY KEY (name);


--
-- TOC entry 2467 (class 2606 OID 27718)
-- Name: cvd_pkey; Type: CONSTRAINT; Schema: netbas; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY codevd
    ADD CONSTRAINT cvd_pkey PRIMARY KEY (name);


--
-- TOC entry 2405 (class 2606 OID 27720)
-- Name: id_primarykey; Type: CONSTRAINT; Schema: netbas; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY unique_controlpoints
    ADD CONSTRAINT id_primarykey PRIMARY KEY (id);


--
-- TOC entry 2469 (class 2606 OID 27722)
-- Name: object_status_pk; Type: CONSTRAINT; Schema: netbas; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY object_status
    ADD CONSTRAINT object_status_pk PRIMARY KEY (id);


SET search_path = prosjekt, pg_catalog;

--
-- TOC entry 2471 (class 2606 OID 27724)
-- Name: PRIMARY_KEY_ID; Type: CONSTRAINT; Schema: prosjekt; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY activemq_failures
    ADD CONSTRAINT "PRIMARY_KEY_ID" PRIMARY KEY (id);


--
-- TOC entry 2481 (class 2606 OID 27726)
-- Name: PRIMARY_KEY_WEBSERVICE_ID; Type: CONSTRAINT; Schema: prosjekt; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY webservice_failures
    ADD CONSTRAINT "PRIMARY_KEY_WEBSERVICE_ID" PRIMARY KEY (id);


--
-- TOC entry 2477 (class 2606 OID 27728)
-- Name: pk_3levels; Type: CONSTRAINT; Schema: prosjekt; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY threelevels
    ADD CONSTRAINT pk_3levels PRIMARY KEY (id);


--
-- TOC entry 2473 (class 2606 OID 27730)
-- Name: pk_customfield; Type: CONSTRAINT; Schema: prosjekt; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY customfield
    ADD CONSTRAINT pk_customfield PRIMARY KEY (id);


--
-- TOC entry 2475 (class 2606 OID 27732)
-- Name: pk_risiko; Type: CONSTRAINT; Schema: prosjekt; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY risiko
    ADD CONSTRAINT pk_risiko PRIMARY KEY (id);


--
-- TOC entry 2479 (class 2606 OID 27734)
-- Name: pk_tiltak; Type: CONSTRAINT; Schema: prosjekt; Owner: powercatch; Tablespace:
--

ALTER TABLE ONLY tiltak
    ADD CONSTRAINT pk_tiltak PRIMARY KEY (id);


SET search_path = infrastruktur, pg_catalog;

--
-- TOC entry 2485 (class 2620 OID 27735)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON anlegg FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2486 (class 2620 OID 27736)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON bryter FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2487 (class 2620 OID 27737)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON bygning FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2482 (class 2620 OID 27738)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON kabelskap FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2488 (class 2620 OID 27739)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON linje FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2484 (class 2620 OID 27740)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON mastepunkt FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2483 (class 2620 OID 27741)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON nettstasjon FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2489 (class 2620 OID 27742)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON node FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2490 (class 2620 OID 27743)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON nodetype FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2491 (class 2620 OID 27744)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON omraade FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2492 (class 2620 OID 27745)
-- Name: modified_stamp; Type: TRIGGER; Schema: infrastruktur; Owner: powercatch
--

CREATE TRIGGER modified_stamp BEFORE INSERT OR UPDATE ON trafo FOR EACH ROW EXECUTE PROCEDURE public.modified_stamp();


--
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 13
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO powercatch;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-11-01 13:02:49

--
-- PostgreSQL database dump complete
--