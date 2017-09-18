package no.resight.powercatch.pcpluginupdater.startupBeans;

import no.resight.powercatch.pcpluginupdater.exceptions.UpdaterConfigurationException;
import no.resight.powercatch.pcpluginupdater.constants.SpringProfiles;
import no.resight.powercatch.pcpluginupdater.utilities.StringUtil;
import org.apache.log4j.Logger;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Objects;

/**
 * Use this component to verify that required configuration is present on the target instance.
 * By BeanFactoryPostProcessor, this class will get initialized prior to all other Spring Beans.
 */
@Component
public class VerifyConfigurationOnStartup implements BeanFactoryPostProcessor {

    private static final Logger log = Logger.getLogger(VerifyConfigurationOnStartup.class);

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        log.debug("<<<<<<< VERIFYING UPDATE CONFIGURATION >>>>>>>");
        ConfigurableEnvironment env = beanFactory.getBean(ConfigurableEnvironment.class);

        AssertThatSpringProfileIsSet(env);
    }

    void AssertThatSpringProfileIsSet(ConfigurableEnvironment env) {
        String[] profiles = env.getActiveProfiles();
        if (profiles == null || profiles.length == 0) {
            throw new UpdaterConfigurationException("No Spring profiles found. Please set the environment variable 'spring_profiles_active' to an existing customer Spring profile.");
        }

        Boolean oneOrMoreProfilesAreInvalid = Arrays.stream(profiles).filter(StringUtil::IsNullOrEmpty).count() > 0;
        if (oneOrMoreProfilesAreInvalid) {
            throw new UpdaterConfigurationException("One or more Spring profiles was null or empty. Please set the environment variable 'spring_profiles_active' to an existing customer Spring profile.");
        }

        Boolean defaultIsTheOnlyActiveProfile = profiles.length == 1 && Objects.equals(profiles[0], SpringProfiles.Default);
        if (defaultIsTheOnlyActiveProfile) {
            throw new UpdaterConfigurationException("Only the default spring profile was found, but a customer profile is required. Please set the environment variable 'spring_profiles_active' to a customer Spring profile.");
        }

        log.debug("USING SPRING PROFILES: " + Arrays.toString(profiles));
    }

}
