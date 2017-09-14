package no.resight.powercatch.pcpluginupdater.startupBeans;

import no.resight.powercatch.pcpluginupdater.Exceptions.UpdaterConfigurationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.platform.runner.JUnitPlatform;
import org.junit.runner.RunWith;
import org.springframework.core.env.ConfigurableEnvironment;

import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;

@RunWith(JUnitPlatform.class)
class VerifyConfigurationOnStartupTest {

    private ConfigurableEnvironment environment;
    private VerifyConfigurationOnStartup verifyConfigurationOnStartup;

    @BeforeEach
    void setUp() {
        environment = mock(ConfigurableEnvironment.class);
        verifyConfigurationOnStartup = spy(VerifyConfigurationOnStartup.class);
    }

    @ParameterizedTest
    @MethodSource(names = "failingSpringProfilesSource")
    void SpringActiveProfile_whenNoneIsSet_shouldFail(String profile) {
        String[] profiles = new String[]{profile};

        doReturn(profiles).when(environment).getActiveProfiles();

        assertThrows(UpdaterConfigurationException.class, () -> {
            verifyConfigurationOnStartup.AssertThatSpringProfileIsSet(environment);
        });
    }

    @Test
    void SpringActiveProfile_whenReturnsEmptyArray_shouldFail () {
        String[] profiles = new String[]{};

        doReturn(profiles).when(environment).getActiveProfiles();

        assertThrows(UpdaterConfigurationException.class, () -> {
            verifyConfigurationOnStartup.AssertThatSpringProfileIsSet(environment);
        });
    }

    @Test
    void SpringActiveProfile_whenValueIsSet_shouldPass () {
        String[] profiles = new String[]{"profile1"};

        doReturn(profiles).when(environment).getActiveProfiles();

        verifyConfigurationOnStartup.AssertThatSpringProfileIsSet(environment);

        // No exception is pass
    }

    @Test
    void SpringActiveProfile_whenMultipleValuesAreSet_shouldPass () {
        String[] profiles = new String[]{"profile1", "profile2"};

        doReturn(profiles).when(environment).getActiveProfiles();

        verifyConfigurationOnStartup.AssertThatSpringProfileIsSet(environment);

        // No exception is pass
    }

    private static Stream<String> failingSpringProfilesSource() {
        return Stream.of(null, "");
    }

}