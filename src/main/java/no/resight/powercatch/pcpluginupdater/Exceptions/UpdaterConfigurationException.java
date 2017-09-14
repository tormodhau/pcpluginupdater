package no.resight.powercatch.pcpluginupdater.Exceptions;

public class UpdaterConfigurationException extends RuntimeException {
    public UpdaterConfigurationException(String message) {
        super("UPDATER PLUGIN CONFIGURATION EXCEPTION: " + message);
    }
}
