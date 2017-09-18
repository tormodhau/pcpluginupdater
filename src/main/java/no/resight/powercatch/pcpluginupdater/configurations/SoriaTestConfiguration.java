package no.resight.powercatch.pcpluginupdater.configurations;

import no.resight.powercatch.pcpluginupdater.constants.ScriptLocations;
import no.resight.powercatch.pcpluginupdater.constants.SpringProfiles;
import org.flywaydb.core.api.MigrationVersion;
import org.postgresql.ds.PGSimpleDataSource;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Profile(SpringProfiles.SoriaTest)
@Component
public class SoriaTestConfiguration implements DatabaseUpdateConfiguration {

    public MigrationVersion getBaseLineVersion() {
        return MigrationVersion.EMPTY;
    }

    public MigrationVersion getTargetVersion() {
        return MigrationVersion.LATEST;
    }

    public String[] getScriptLocations() {
        return new String[]{ScriptLocations.Common, ScriptLocations.Soria};
    }

    public DataSource getDataSource() {
        PGSimpleDataSource pgSimpleDataSource = new PGSimpleDataSource();
        pgSimpleDataSource.setServerName("localhost");
        pgSimpleDataSource.setPortNumber(5432);
        pgSimpleDataSource.setDatabaseName("powercatch");
        pgSimpleDataSource.setUser("postgres");
        pgSimpleDataSource.setPassword("postgres123!");
        return pgSimpleDataSource;
    }
}
