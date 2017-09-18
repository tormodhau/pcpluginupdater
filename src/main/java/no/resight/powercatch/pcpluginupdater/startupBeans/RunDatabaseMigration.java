package no.resight.powercatch.pcpluginupdater.startupBeans;

import no.resight.powercatch.pcpluginupdater.configurations.DatabaseUpdateConfiguration;
import org.apache.log4j.Logger;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationVersion;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class RunDatabaseMigration {

    private static final Logger log = Logger.getLogger(RunDatabaseMigration.class);

    @Autowired
    public RunDatabaseMigration(DatabaseUpdateConfiguration databaseUpdateConfiguration, Environment environment) {
        Flyway flyway = new Flyway();
        flyway.setLocations(databaseUpdateConfiguration.getScriptLocations());
        flyway.setDataSource(databaseUpdateConfiguration.getDataSource());
        flyway.setBaselineOnMigrate(true); //If no explicit baseline is set, a schema_version table will be created for empty databases
        flyway.setTarget(databaseUpdateConfiguration.getTargetVersion());

        if (shouldBaseline(databaseUpdateConfiguration)) {
            setAndRunBaseline(databaseUpdateConfiguration, flyway);
        }

        log.info("---- RUNNING DATABASE MIGRATIONS ----");
        flyway.migrate();
    }

    private Boolean shouldBaseline(DatabaseUpdateConfiguration databaseUpdateConfiguration) {
        return databaseUpdateConfiguration.getBaseLineVersion() != MigrationVersion.EMPTY;
    }

    private void setAndRunBaseline(DatabaseUpdateConfiguration databaseUpdateConfiguration, Flyway flyway) {
        log.info("---- SETTING BASELINE VERSION TO: " + databaseUpdateConfiguration.getBaseLineVersion() +" ----");
        flyway.setBaselineVersion(databaseUpdateConfiguration.getBaseLineVersion());
        flyway.baseline();
    }

}
