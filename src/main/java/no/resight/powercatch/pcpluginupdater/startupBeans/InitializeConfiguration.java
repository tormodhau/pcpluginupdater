package no.resight.powercatch.pcpluginupdater.startupBeans;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.stereotype.Component;

/**
 * By inheriting BeanFactoryPostProcessor, this class will get initialized prior to all other Spring Beans.
 */
@Component
public class InitializeConfiguration implements BeanFactoryPostProcessor {

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {

        System.out.println("<<<<<<<<<<<<<<<< postProcessBeanFactory >>>>>>>>>>>>>>>>");

        ConfigurableEnvironment env = beanFactory.getBean(ConfigurableEnvironment.class);

//        String springProfile = new PropertiesReaderImpl().getActiveSpringProfile();

        //env.setActiveProfiles("na-test");
        //System.setProperty("spring.profiles.active", "na-test");


    }

    /**
     * Setting a Spring profile makes Spring look for Beans with the @Profile("some-profile")
     */
//    private void setSpringActiveProfile() {
//        String springProfile = new PropertiesReaderImpl().getActiveSpringProfile();
//        System.setProperty("spring.profiles.active", springProfile);
//
//        log.error("----- USING SPRING PROFILE: "+ springProfile + "-----");
//    }

}
