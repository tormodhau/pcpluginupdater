package no.resight.powercatch.pcpluginupdater.configurations;

import javax.sql.DataSource;

public interface DatabaseUpdateConfiguration {

    /**
     * On first execution, only scripts with higher versions than the baseline version will be ran.
     * This parameter is only required on the initial migration for existing databases, and increasing it on a database
     * that already has a baseline version set will fail.
     * If unset, all migrations will be ran.
     */
    String getBaseLineVersion();

    /**
     * List of paths in which the SQL migration scripts to be ran is placed.
     */
    String[] getScriptLocations();

    /**
     * Database configuration object used to connect to some database instance
     * For postgres connections:
     *      more info       - https://jdbc.postgresql.org/documentation/81/ds-ds.html
     *      serverName      - Name of the server that the database is located at. If the migration is being ran local machine, this can simply be set to 'localhost'
     *      portNumber      - Port number of the postgres instance. The default port for postgres is 5432.
     *      databaseName    - Name of the database to run migrations towards, such as "powercatch".
     *      user            - User name fora a postgres administrative user. This user must be allowed to create tables etc., and not only read from the database.
     *      password        - Administrative user account password.
     */
    DataSource getDataSource();

}
