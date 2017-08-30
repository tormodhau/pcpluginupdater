package no.resight.powercatch.pcpluginupdater.startupBeans;

import no.resight.powercatch.pcpluginupdater.configurations.CustomerUpdateConfiguration;
import org.apache.log4j.Logger;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationVersion;
import org.postgresql.ds.PGSimpleDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
public class RunDatabaseMigration {

    private static final Logger log = Logger.getLogger(RunDatabaseMigration.class);


    // TODO THIS SHOULD BE SET THROUGH THE COMMAND LINE
    // IT ALSO HAS TO BE SET PRIOR TO REQUESTING THE BEAN... MOVE TO A TEST, PROBABLY
    // System.setProperty("spring.profiles.active", SpringProfiles.ResightTest);

//    @Autowired
//    public RunDatabaseMigration(CustomerUpdateConfiguration configuration) {
//        log.info("### RUNNING DATABASE MIGRATIONS ###");
//        Flyway flywayConfiguration = configuration.getFlyWayConfiguration();
//        flywayConfiguration.migrate();
//    }


    @Autowired
    public RunDatabaseMigration(CustomerUpdateConfiguration configuration) {
        log.info("### RUNNING DATABASE MIGRATIONS ###");
        Flyway flyway = new Flyway();
//        flyway.setBaselineOnMigrate(true);
        flyway.setBaselineVersion(MigrationVersion.fromVersion("2.5.0")); //The database is already this version. Only versions above this version will be run.
        flyway.setLocations("dbMigrations/common");
        flyway.setDataSource(getDataSource());
        flyway.baseline();
        flyway.migrate();
    }

    /**
     * Generate connection for database migrations
     * More info: https://jdbc.postgresql.org/documentation/81/ds-ds.html
     */
    private DataSource getDataSource() {
        PGSimpleDataSource pgSimpleDataSource = new PGSimpleDataSource();
        pgSimpleDataSource.setServerName("localhost");
        pgSimpleDataSource.setPortNumber(5432);
        pgSimpleDataSource.setDatabaseName("pgtest");
        pgSimpleDataSource.setUser("postgres");
        pgSimpleDataSource.setPassword("postgres123!");
        return pgSimpleDataSource;
    }

}
