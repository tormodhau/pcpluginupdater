package no.resight.powercatch.pcpluginupdater.startupBeans;

import no.resight.powercatch.pcpluginupdater.configurations.DatabaseUpdateConfiguration;
import no.resight.powercatch.pcpluginupdater.utilities.StringUtil;
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

        if (StringUtil.IsPresent(databaseUpdateConfiguration.getBaseLineVersion())) {
            log.info("---- SETTING BASELINE VERSION TO: " + databaseUpdateConfiguration.getBaseLineVersion() +" ----");
            flyway.setBaselineVersion(MigrationVersion.fromVersion(databaseUpdateConfiguration.getBaseLineVersion()));
            flyway.baseline();
        }

        log.info("---- RUNNING DATABASE MIGRATIONS ----");
        flyway.migrate();
    }

}
