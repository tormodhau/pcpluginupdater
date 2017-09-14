package no.resight.powercatch.pcpluginupdater.configurations;

import no.resight.powercatch.pcpluginupdater.constants.Flags;
import no.resight.powercatch.pcpluginupdater.constants.ScriptLocations;
import no.resight.powercatch.pcpluginupdater.constants.SpringProfiles;
import org.flywaydb.core.api.MigrationVersion;
import org.postgresql.ds.PGSimpleDataSource;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Profile(SpringProfiles.NettalliansenTest)
@Component
public class NettalliansenTestConfiguration implements DatabaseUpdateConfiguration {

    public String getBaseLineVersion() {
        return Flags.NO_BASELINE;
    }

    public MigrationVersion getTargetVersion() {
        return MigrationVersion.LATEST;
    }

    public String[] getScriptLocations() {
        return new String[]{ScriptLocations.Common, ScriptLocations.Nettalliansen};
    }

    public DataSource getDataSource() {
        PGSimpleDataSource pgSimpleDataSource = new PGSimpleDataSource();
        pgSimpleDataSource.setServerName("localhost");
        pgSimpleDataSource.setPortNumber(5432);
        pgSimpleDataSource.setDatabaseName("pgtest");
        pgSimpleDataSource.setUser("postgres");
        pgSimpleDataSource.setPassword("postgres123!");
        return pgSimpleDataSource;
    }
}
