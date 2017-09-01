package no.resight.powercatch.pcpluginupdater.utilities;

import com.atlassian.jira.exception.NotFoundException;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.util.Optional;
import java.util.Properties;

@Component
public class PropertiesReaderImpl implements PropertiesReader {
    private static final Logger log = Logger.getLogger(PropertiesReaderImpl.class);

    @Override
    public String getActiveSpringProfile() {
        return Optional.ofNullable(getRuntimeProperties().getProperty("springProfile"))
                .orElseThrow(() -> new NotFoundException("Unable to read property 'springProfile' from runtime properties"));
    }

    private Properties getRuntimeProperties() {
        return Optional.ofNullable(readFile("runtime.properties"))
                    .orElseThrow(() -> new NotFoundException("Unable to read file 'runtime properties'"));
    }

    private Properties readFile(String fileName) {
        Properties prop = new Properties();
        InputStream inputStream = null;
        try {
            inputStream = getClass().getClassLoader().getResourceAsStream(fileName);
            if (inputStream != null) {
                prop.load(inputStream);
            }
        } catch (IOException ex) {
            log.error("Error reading properties file "+fileName+"'", ex);
            ex.printStackTrace();
        } finally {
            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (IOException e) {
                    log.error("Error reading properties file "+fileName+"'", e);
                    e.printStackTrace();
                }
            }
        }
        return prop;
    }

}