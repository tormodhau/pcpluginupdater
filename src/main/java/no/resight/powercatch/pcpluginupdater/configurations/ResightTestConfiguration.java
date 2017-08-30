package no.resight.powercatch.pcpluginupdater.configurations;


import org.apache.log4j.Logger;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationVersion;
import org.postgresql.ds.PGSimpleDataSource;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

//@Profile(SpringProfiles.ResightTest)
@Component
public class ResightTestConfiguration implements CustomerUpdateConfiguration {

    private static final Logger log = Logger.getLogger(ResightTestConfiguration.class);

    /**
     * Get predefined migration behaviour and configuration
     */
    public Flyway getFlyWayConfiguration() {

        log.info("******* FETCHING RESIGHT TEST CONFIGURATION *******");

        Flyway flyway = new Flyway();
        flyway.setBaselineOnMigrate(true);
        flyway.setBaselineVersion(MigrationVersion.fromVersion("2.3.0"));
        flyway.setLocations("dbMigrations/common");
        flyway.setDataSource(getDataSource());

        return flyway;
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


    /*
    * flyway.driver=org.postgresql.Driver
flyway.url=jdbc:postgresql://localhost:5432/flywaydemo
flyway.user=flywaydemo
flyway.password=flywaydemo
flyway.locations=filesystem:src/main/resources/flyway/migrations
    * */
}
