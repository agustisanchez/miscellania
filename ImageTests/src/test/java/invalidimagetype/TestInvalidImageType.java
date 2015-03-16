package invalidimagetype;

import java.awt.image.BufferedImage;
import java.io.FileOutputStream;
import java.io.InputStream;

import javax.imageio.ImageIO;
import javax.media.jai.JAI;
import javax.media.jai.RenderedOp;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;

import org.apache.sanselan.Sanselan;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import com.sun.media.jai.codec.SeekableStream;

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
        RenderedOp op = JAI.create("stream", SeekableStream.wrapInputStream(imageResource(), true));
        BufferedImage bufferedImage = op.getAsBufferedImage();
        //JAI.create("encode", bufferedImage, new FileOutputStream("/home/sabart/MyImage.jpg"), "JPEG", null);
        
    }

    private InputStream imageResource() {
        return getClass().getResourceAsStream("/Kepler-186f_20x30.0.jpg");
    }
    
    private void showImage(BufferedImage image) throws Exception{
        ImageIcon icon = new ImageIcon(image);
        JLabel label = new JLabel(icon);
        JFrame frame = new JFrame();
        frame.getContentPane().add(label);
        frame.pack();
        frame.setSize(600, 600);
        frame.setVisible(true);
        Thread.currentThread().sleep(10000);
    }
}
