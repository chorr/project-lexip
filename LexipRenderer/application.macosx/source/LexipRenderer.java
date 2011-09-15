import processing.core.*; 
import processing.xml.*; 

import processing.video.*; 
import fullscreen.*; 
import hypermedia.video.*; 
import java.awt.Rectangle; 

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

public class LexipRenderer extends PApplet {






Movie mov = null;
Capture cam = null;
OpenCV opencv = null;
PixelCanvas canvas;
FullScreen fs;

final int CAPTURE_MODE = 0;
final boolean IS_FULLSCREEN = true;

public void setup() {
  size(ScreenUtil.WIDTH, ScreenUtil.HEIGHT, P2D);
  background(0);
  colorMode(HSB, 255);
  
  if (CAPTURE_MODE == 0) initOpenCV();
  if (CAPTURE_MODE == 1) initCam();
  if (CAPTURE_MODE == 2) initMovie();
  
  fs = new FullScreen(this);
  fs.setResolution(ScreenUtil.FULL_WIDTH, ScreenUtil.FULL_HEIGHT);
  if (IS_FULLSCREEN == true) {
    fs.enter();
  }
}

public void draw() {
  //background(255);
  if (cam != null) {
    if (cam.available()) {
      cam.read();
      scale(ScreenUtil.getFullScreenRatio(cam));
      canvas.update(cam);
    }
  } else if (mov != null) {
    scale(ScreenUtil.getFullScreenRatio(mov));
    canvas.update(mov);
  } else if (opencv != null) {
    opencv.read();
    opencv.flip(OpenCV.FLIP_HORIZONTAL);
    Rectangle[] faces = opencv.detect( 1.2f, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40);
    opencv.brightness(20);
    opencv.contrast(40);
    
    scale(ScreenUtil.getFullScreenRatio(opencv.image()));
    //canvas.update(opencv.image(), faces);
    canvas.update(opencv.image());
  }
}

public void initOpenCV() {
  opencv = new OpenCV(this);
  opencv.capture(320, 240);
  opencv.cascade(OpenCV.CASCADE_FRONTALFACE_ALT);
  canvas = new PixelCanvas(opencv.image());
}

public void initCam() {
  cam = new Capture(this, 320, 240, Capture.list()[1]);
  canvas = new PixelCanvas(cam);
}

public void initMovie() {
  mov = new Movie(this, "station.mov");
  mov.loop();
  mov.read();
  canvas = new PixelCanvas(mov);
}

public void movieEvent(Movie m) {
  m.read();
}

public void stop() {
  if (opencv != null) {
    opencv.stop();
  }
  super.stop();
}

public void keyPressed() {
  if (keyCode == 38) {
    for (int i = 0; i < canvas.len; i++) 
      canvas.px[i].tsize = min(canvas.px[i].tsize + 1, 10);
  } else if (keyCode == 40) {
    for (int i = 0; i < canvas.len; i++) 
      canvas.px[i].tsize = max(canvas.px[i].tsize - 1, 1);
  } else if (key == 'b' || key == 'B') {
    for (int i = 0; i < canvas.len; i++) 
      canvas.px[i].isBreak = !canvas.px[i].isBreak;
  } else if (key == 'r' || key == 'R') {
    for (int i = 0; i < canvas.len; i++) {
      canvas.px[i].isBreak = !canvas.px[i].isBreak;
      canvas.px[i].tsize = canvas.px[i].isBreak ? 3 : 1;
    }
  } else if ((key == 'f' || key == 'F') && fs != null) {
    fs.enter();
  }
}
class Pixel {
  int c, x, y;
  int tsize = 3;
  boolean isBreak = true;
  
  Pixel(int c, int x, int y) {
    this.c = c;
    this.x = x;
    this.y = y;
  }
  
  public void update(int c) {
    int newColor;
    float h, s, b;
    
    this.c = c;
    if ( !(x % tsize == 0 && y % tsize == 0) ) return;
    
    if (isBreak) {
      h = hue(c);
      s = breakColor(saturation(c), 20);
      if (s < 80) s = 0;
      b = brightness(c) > 170 ? 255 : (brightness(c) > 80 ? 100 : 0);
      newColor = color(h, s, b);
      fill(newColor, 210);
    } else {
      fill(c);
    }
    
    noStroke();
    rect(x, y, tsize, tsize);
  }
  
  public float breakColor(float cl, float step) {
    return constrain(ceil(cl / step) * step, 0, 255);
  }

}


class PixelCanvas {
  int width;
  int height;
  int len;
  Pixel[] px;
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    
    int idx = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        px[idx] = new Pixel(color(100), x, y);
        idx++;
      }
    }
  }
  
  public void update(PImage target) {
    Pixel p;
    for (int i = 0; i < len; i++) {
      p = px[i];
      p.update(target.pixels[i]);
    }
  }
  
  public void update(PImage target, Rectangle[] faces) {
    PGraphics lg = createGraphics(target.width, target.height, P2D);
    lg.image(target, 0, 0);
    lg.beginDraw();

    lg.strokeWeight(4);
    lg.fill(255);
    lg.ellipseMode(CENTER);
    for (int i = 0, l = faces.length; i < l; i++) {
      lg.ellipse( faces[i].x - 30, faces[i].y - 20, faces[i].width * 1.7f, faces[i].width * 1.0f );
    }
    
    lg.endDraw();
    this.update(lg);
  }
  
  public PGraphics getGraphics() {
    return g;
  }
    
}
static class ScreenUtil {
  final static int WIDTH = 1024; final static int HEIGHT = 640;
  //final static int WIDTH = 640; final static int HEIGHT = 480;
  
  final static int FULL_WIDTH = 1024;
  final static int FULL_HEIGHT = 640;
  
  public static float getFullScreenRatio(PImage target) {
    float ratio = (float)WIDTH / (float)target.width;
    if (target.height * ratio < HEIGHT) {
      ratio = HEIGHT / target.height;
    }
    return ratio;
  }
  
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "LexipRenderer" });
  }
}
