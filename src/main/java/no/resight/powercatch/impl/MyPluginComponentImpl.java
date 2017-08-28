package no.resight.powercatch.impl;

import com.atlassian.jira.config.properties.ApplicationProperties;
import com.atlassian.plugin.spring.scanner.annotation.imports.ComponentImport;
import no.resight.powercatch.api.MyPluginComponent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

//@ExportAsService ({MyPluginComponent.class})
//@Inject ("myPluginComponent")
@Component
public class MyPluginComponentImpl implements MyPluginComponent
{
    @ComponentImport
    private final ApplicationProperties applicationProperties;

    @Autowired
    public MyPluginComponentImpl(final ApplicationProperties applicationProperties)
    {
        this.applicationProperties = applicationProperties;
    }

    public String getName()
    {
        if(null != applicationProperties)
        {
            return "myComponent:" + applicationProperties.getEncoding();
        }

        return "myComponent";
    }
}