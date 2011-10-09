import processing.core.*; 
import processing.xml.*; 

import processing.video.*; 
import fullscreen.*; 
import imageadjuster.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class PixelApp extends PApplet {





Capture cam;
PImage res = new PImage(140, 105, ARGB);
ArrayList ls = new ArrayList();
SoftFullScreen sfs;
ImageAdjuster adjust;
NetUtil net = new NetUtil();
PFont font;
boolean is_disp = false;
int textTimer = -1;

int MODE = 2;
final static boolean IS_FS = false;
final static int BF_SIZE = 64;

public void setup() {
  size(1024, 640);
//  size(1280, 720);  // for iMac
  background(0);
  noCursor();
  cam = new Capture(this, 320, 240);
  
  adjust = new ImageAdjuster(this);
  adjust.brightness(0.2f);
  adjust.contrast(1.4f);

  sfs = new SoftFullScreen(this);
  if (IS_FS) sfs.enter();
  
  font = loadFont("Helvetica-64.vlw");
  textFont(font, 64);
  textAlign(CENTER);
}

public void draw() {
  if (!cam.available()) return;
  cam.read();

  // arrange image.
  PImage tmp = new PImage(cam.width, cam.height, ARGB);
  for (int x=0; x<cam.width; x++) {
    for (int y=0; y<cam.height; y++) {
      tmp.set(cam.width - x - 1, y, cam.get(x, y));
    }
  }
  adjust.apply(tmp);
  tmp.resize(res.width, res.height);
  
  // image queue.
  ls.add(tmp);
  if (ls.size() > BF_SIZE) {
    ls.remove(0);
  } else {
    return;
  }
  
  colorMode(HSB, 255);
  for (int i=0; i<tmp.pixels.length; i++) {
    int c = tmp.pixels[i];
    float cH = hue(c);
    float cS = saturation(c);
    float cB = brightness(c);
    float cA = 255;
    if (MODE == 0) {
      cS = breakColor(saturation(c), 20);
      if (cS < 80) cS = 0;
      cB = brightness(c) > 170 ? 255 : (brightness(c) > 80 ? 100 : 0);
    } else if (MODE == 1) {
      cH = 0;
      cS = brightness(c) > 130 ? 0 : 200;
      cB = brightness(c) > 130 ? 255 : 220;
      cA = 190;
    } else if (MODE == 2) {
      cH = 90;
      cS = brightness(c) > 130 ? 0 : 190;
      cB = brightness(c) > 130 ? 255 : 195;
      cA = 190;
    } else if (MODE == 3) {
      cH = 176;
      cS = brightness(c) > 130 ? 0 : 195;
      cB = brightness(c) > 130 ? 255 : 207;
      cA = 190;
    }
    res.pixels[i] = color(cH, cS, cB, cA);
  }
  res.updatePixels();
  
  if (MODE == 0) {
    colorMode(RGB, 255);
    for (int x=0; x < res.width; x++) {
      for (int y=0; y < res.height; y++) {
        int cR = color(red(((PImage)ls.get(BF_SIZE-1)).get(x, y)), 0, 0);
        int cG = color(0, green(((PImage)ls.get(BF_SIZE/2)).get(x, y)), 0);
        int cB = color(0, 0, blue(((PImage)ls.get(0)).get(x, y)));
        int cNew = blendColor(blendColor(cR, cG, ADD), cB, ADD);
        res.set(x, y, cNew);
      }
    }
    image(res, 0, -64, 1024, 768);
//    image(res, 0, -120, 1280, 960);  // for iMac.
  } else {
    image(res, 0, -64, 1024, 768);
  }
  
  if (is_disp) {
    image(tmp, 0, 0);
  }
  
  if (net.message != "") {
    showMessage();
  }
} 

public void keyPressed() {
  if ((key == 'f' || key == 'F') && sfs != null) {
    sfs.enter();
  } else if (key == 'd' || key == 'D') {
    is_disp = !is_disp;
  } else if (key == '1') {
    adjust.brightness(-0.01f);
  } else if (key == '2') {
    adjust.brightness(0.01f);
  } else if (key == '3') {
    adjust.contrast(0.95f);
  } else if (key == '4') {
    adjust.contrast(1.05f);
  } else if (key == 'a' || key == 'A') {
    MODE = 0;
  } else if (key == 'r' || key == 'R') {
    MODE = 1;
  } else if (key == 'g' || key == 'G') {
    MODE = 2;
  } else if (key == 'b' || key == 'B') {
    MODE = 3;
  } else if (keyCode == 32 && MODE != 0 && net.message == "") {
    net.saveImage("pixel", "pic", MODE);
  }
}

public void mousePressed() {
  if (MODE != 0 && net.message == "") {
    net.saveImage("pixel", "pic", MODE);
  }
}

public void stop() {
  cam.stop();
  super.stop();
}

public float breakColor(float cl, float step) {
  return constrain(ceil(cl / step) * step, 0, 255);
}

public void showMessage() {
  noStroke();
  fill(0, 180);
  rect(0, height / 2 - 110, width, 180);
  fill(255);
  text(net.message, width / 2, height / 2);
  if (textTimer == -1) {
    textTimer = 130;
  } else if (textTimer == 0) {
    net.message = "";
    textTimer = -1;
  } else {
    textTimer--;
  }
}
class NetUtil 
{
  final static String url = "http://pixel.chorr.net/";
  public String message = "";
  
  public NetUtil() {}
  
  public void saveImage(String title, String folder, int mode) {
    println("-- SAVING PNG START");
    save("tmp.png");
    postData(title+"-"+year()+nf(month(),2)+nf(day(),2)+"-"+nf(hour(),2)+nf(minute(),2)+nf(second(),2)+"-"+frameCount%100,
      "png",
      folder,
      loadBytes("tmp.png"), 
      mode);
    println("-- SAVING PNG STOP");
  }
  
  public void postData(String title, String ext, String folder, byte[] bytes, int mode) {
    try{
      URL u = new URL(url+"saveFile.php?title="+title+"&ext="+ext+"&folder="+folder+"&mode="+mode);
      URLConnection c = u.openConnection();
      // post multipart data
   
      c.setDoOutput(true);
      c.setDoInput(true);
      c.setUseCaches(false);
   
      // set request headers
      c.setRequestProperty("Content-Type", "multipart/form-data; boundary=AXi93A");
   
      // open a stream which can write to the url
      DataOutputStream dstream = new DataOutputStream(c.getOutputStream());
   
      // write content to the server, begin with the tag that says a content element is comming
      dstream.writeBytes("--AXi93A\r\n");
   
      // discribe the content
      dstream.writeBytes("Content-Disposition: form-data; name=\"data\"; filename=\"whatever\" \r\nContent-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n");
      dstream.write(bytes,0,bytes.length);
   
      // close the multipart form request
      dstream.writeBytes("\r\n--AXi93A--\r\n\r\n");
      dstream.flush();
      dstream.close();
   
      // read the output from the URL
      try{
        BufferedReader in = new BufferedReader(new InputStreamReader(c.getInputStream()));
        String sIn = in.readLine();
        boolean b = true;
        while(sIn!=null){
          if(sIn!=null){
            System.out.println(sIn);
            this.message = sIn;
          }
          sIn = in.readLine();
        }
      }
      catch(Exception e){
        e.printStackTrace();
      }
    }
   
    catch(Exception e){ 
      e.printStackTrace();
    }
  }

}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "PixelApp" });
  }
}
