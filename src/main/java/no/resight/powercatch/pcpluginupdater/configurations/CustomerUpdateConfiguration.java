package no.resight.powercatch.pcpluginupdater.configurations;

import org.flywaydb.core.Flyway;

public interface CustomerUpdateConfiguration {
    Flyway getFlyWayConfiguration();
}
