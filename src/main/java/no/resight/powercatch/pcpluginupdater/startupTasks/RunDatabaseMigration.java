package no.resight.powercatch.pcpluginupdater.startupTasks;

import org.apache.log4j.Logger;
import org.flywaydb.core.Flyway;
import org.postgresql.ds.PGSimpleDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
public class RunDatabaseMigration {

    private static final Logger log = Logger.getLogger(RunDatabaseMigration.class);


    @Autowired
    public RunDatabaseMigration(Flyway flyway) {
        log.info("************** RUNNING DATABASE MIGRATIONS ****************");

//        Flyway flyway = new Flyway();
        flyway.setBaselineVersionAsString("123Version");
        flyway.setBaselineOnMigrate(true);
        flyway.setLocations("path/To/Migrations/Folder");
        flyway.setDataSource(getDataSource());
        flyway.migrate();
    }

    private DataSource getDataSource() {
        // https://jdbc.postgresql.org/documentation/81/ds-ds.html
        PGSimpleDataSource pgSimpleDataSource = new PGSimpleDataSource();
        pgSimpleDataSource.setServerName("SERVER NAME");
        pgSimpleDataSource.setDatabaseName("DATABASE NAME");
        pgSimpleDataSource.setPortNumber(80808080);
        pgSimpleDataSource.setUser("USERNAME");
        pgSimpleDataSource.setPassword("PASSWORD");
        return pgSimpleDataSource;
    }

}
