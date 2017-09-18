package no.resight.powercatch.pcpluginupdater.exceptions;

public class UpdaterConfigurationException extends RuntimeException {
    public UpdaterConfigurationException(String message) {
        super("UPDATER PLUGIN CONFIGURATION EXCEPTION: " + message);
    }
}
