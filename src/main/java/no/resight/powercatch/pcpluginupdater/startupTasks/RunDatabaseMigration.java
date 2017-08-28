package no.resight.powercatch.pcpluginupdater.startupTasks;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class RunDatabaseMigration {

    private static final Logger log = Logger.getLogger(RunDatabaseMigration.class);

    private final Environment environment;

    @Autowired
    public RunDatabaseMigration(Environment environment) {
        this.environment = environment;
        log.info("************** RUNNING DATABASE MIGRATIONS ****************");
    }

}
