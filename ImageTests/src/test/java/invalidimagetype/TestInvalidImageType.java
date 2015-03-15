package invalidimagetype;

import java.io.InputStream;

import javax.imageio.ImageIO;

import org.apache.sanselan.Sanselan;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class TestInvalidImageType {
    
    @Test
    public void testLoadWithStandardApi() throws Exception {
        ImageIO.read(imageResource());
    }

    @Test
    public void testLoadWithSanselan() throws Exception {
        Sanselan.getBufferedImage(imageResource());
    }

    @Test
    public void testLoadWithJai() throws Exception {
    }

    private InputStream imageResource() {
        return getClass().getResourceAsStream("/Kepler-186f_20x30.0.jpg");
    }
}
