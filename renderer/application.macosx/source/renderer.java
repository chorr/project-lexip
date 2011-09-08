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

public class renderer extends PApplet {






Movie mov = null;
Capture cam = null;
OpenCV opencv = null;
PixelCanvas canvas;
ScreenUtil scr = new ScreenUtil();
FullScreen fs;

final boolean IS_FULLSCREEN = true;

public void setup() {
  size(scr.WIDTH, scr.HEIGHT, P2D);
  background(0);
  frameRate(18);
  
  initOpenCV();
  //initCam();
  //initMovie();
  
  if (IS_FULLSCREEN == true) {
    fs = new FullScreen(this);
    fs.setResolution(1024, 640);
    fs.enter();
    noCursor();
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

public void draw() {
  background(255);
  if (cam != null) {
    if (cam.available()) {
      cam.read();
      scale(scr.getFullScreenRatio(cam));
      canvas.update(cam);
    }
  } else if (mov != null) {
    scale(scr.getFullScreenRatio(mov));
    canvas.update(mov);
  } else if (opencv != null) {
    opencv.read();
    opencv.flip(OpenCV.FLIP_HORIZONTAL);
    Rectangle[] faces = opencv.detect( 1.2f, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40);
    opencv.brightness(20);
    opencv.contrast(40);
    
    scale(scr.getFullScreenRatio(opencv.image()));
    canvas.update(opencv.image(), faces);
  }
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
class Pixel {
  int c, x, y;
  int tsize = 3;
  
  Pixel(int c, int x, int y) {
    this.c = c;
    this.x = x;
    this.y = y;
  }
  
}


class PixelCanvas {
  int width;
  int height;
  int len;
  Pixel[] px;
  PGraphics g;
  
  final int COLOR_STEP = 40;
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    g = createGraphics(width, height, P2D);
    
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
    g.beginDraw();

    for (int i = 0; i < len; i++) { // \ud53d\uc140\uc744 \ub354 \ucd18\ucd18\ud558\uac8c \ub9cc\ub4e4 \uc218 \uc788\uc74c
      p = px[i];
      p.c = target.pixels[i];
      if ( !(p.x % p.tsize == 0 && p.y % p.tsize == 0) ) continue;
      
      g.fill(color(breakColor(red(p.c)), breakColor(green(p.c)), breakColor(blue(p.c))));
      g.noStroke();
      g.rect(p.x, p.y, p.tsize, p.tsize);
    }
    
    g.endDraw();
    image(g, 0, 0);
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
  
  public float breakColor(float cl) {
    return constrain(ceil(cl / COLOR_STEP) * COLOR_STEP, 0, 255);
  }
  
}
class ScreenUtil {
  int WIDTH = 1024; int HEIGHT = 640;
  //int WIDTH = 640; int HEIGHT = 480;
  
  public float getFullScreenRatio(PImage target) {
    float ratio = (float)WIDTH / (float)target.width;
    if (target.height * ratio < HEIGHT) {
      ratio = HEIGHT / target.height;
    }
    return ratio;
  }
  
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "renderer" });
  }
}
