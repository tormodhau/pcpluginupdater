package ut.no.resight.powercatch;

import org.junit.Test;
import no.resight.powercatch.api.MyPluginComponent;
import no.resight.powercatch.impl.MyPluginComponentImpl;

import static org.junit.Assert.assertEquals;

public class MyComponentUnitTest
{
    @Test
    public void testMyName()
    {
        MyPluginComponent component = new MyPluginComponentImpl(null);
        assertEquals("names do not match!", "myComponent",component.getName());
    }
}