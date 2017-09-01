package no.resight.powercatch.pcpluginupdater.startupBeans;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class LogEnvironmentOnStartup {

    private static final Logger log = Logger.getLogger(LogEnvironmentOnStartup.class);

    @Autowired
    public LogEnvironmentOnStartup(Environment environment) {
        System.out.println("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SPRING PROFILE " + System.getProperty("spring.profiles.active") + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }
}
