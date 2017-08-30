package no.resight.powercatch.pcpluginupdater.utilities;

public class StringUtil {

    public static Boolean IsNullOrEmpty(String value) {
        return value == null || value.trim().equals("");
    }

    public static Boolean IsPresent(String value) {
        return !IsNullOrEmpty(value);
    }

}
