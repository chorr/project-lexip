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
int br = 20;
int ct = 40;

public void setup() {
  if (ScreenUtil.IS_FULLSCREEN) {
    size(ScreenUtil.FULL_WIDTH, ScreenUtil.FULL_HEIGHT, P2D);
  } else {
    size(ScreenUtil.WIDTH, ScreenUtil.HEIGHT, P2D);
  }
  println(width);
  background(0);
  colorMode(HSB, 255);
  
  if (ScreenUtil.CAPTURE_MODE == 0) initOpenCV();
  if (ScreenUtil.CAPTURE_MODE == 1) initCam();
  if (ScreenUtil.CAPTURE_MODE == 2) initMovie();
  
  fs = new FullScreen(this);
  fs.setResolution(ScreenUtil.FULL_WIDTH, ScreenUtil.FULL_HEIGHT);
  if (ScreenUtil.IS_FULLSCREEN) {
    fs.enter();
  }
}

public void draw() {
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
    Rectangle[] faces;
    opencv.read();
    opencv.flip(OpenCV.FLIP_HORIZONTAL);
    if (ScreenUtil.PIXEL_MODE == 0) {
      faces = opencv.detect( 1.2f, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40);
    }
    opencv.brightness(br);
    opencv.contrast(ct);
    
    scale(ScreenUtil.getFullScreenRatio(opencv.image()));
    if (ScreenUtil.PIXEL_MODE == 0) {
      canvas.update(opencv.image(), faces);
    } else {
      canvas.update(opencv.image());
    }
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
  } else if (key == '1') {
    br = max(br - 1, -128);
    println("brightness = " + br);
  } else if (key == '2') {
    br = min(br + 1, 128);
    println("brightness = " + br);
  } else if (key == '3') {
    ct = max(ct - 1, -128);
    println("contrast = " + ct);
  } else if (key == '4') {
    ct = min(ct + 1, 128);
    println("contrast = " + ct);
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
      if (ScreenUtil.PIXEL_MODE == 0) {
        s = breakColor(saturation(c), 20);
        if (s < 80) s = 0;
        b = brightness(c) > 170 ? 255 : (brightness(c) > 80 ? 100 : 0);
      } else if (ScreenUtil.PIXEL_MODE == 1) {
        s = 0;
        b = brightness(c) > 130 ? 255 : 0;
      }
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
  PImage block1, block2;
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    block1 = loadImage("block1.png");
    block2 = loadImage("block2.png");
    
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
    Rectangle f;
    float ratio;
    
    lg.image(target, 0, 0);
    lg.beginDraw();
    lg.imageMode(CENTER);
    for (int i = 0, l = faces.length; i < l; i++) {
      f = faces[i];
      ratio = (float)f.width / 100.0f;
      lg.image( block1, f.x + f.width / 2, f.y - (f.height), f.width, block1.height * ratio );
    }
    lg.endDraw();
    this.update(lg);
  }
  
  public PGraphics getGraphics() {
    return g;
  }
    
}
static class ScreenUtil {
  final static int PIXEL_MODE = 0;
  final static int CAPTURE_MODE = 0;
  final static boolean IS_FULLSCREEN = true;

  final static int WIDTH = 1024; final static int HEIGHT = 640;
  //final static int WIDTH = 640; final static int HEIGHT = 480;
  final static int FULL_WIDTH = 1024;
  final static int FULL_HEIGHT = 640;
  
  public static float getFullScreenRatio(PImage target) {
    int w = WIDTH, h = HEIGHT;
    if (IS_FULLSCREEN) {
      w = FULL_WIDTH;
      h = FULL_HEIGHT;
    }
    float ratio = (float)w / (float)target.width;
    if (target.height * ratio < h) {
      ratio = h / target.height;
    }
    return ratio;
  }
  
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "LexipRenderer" });
  }
}
