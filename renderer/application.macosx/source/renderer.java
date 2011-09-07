import processing.core.*; 
import processing.xml.*; 

import processing.video.*; 
import fullscreen.*; 

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
PixelCanvas canvas;
ScreenUtil scr = new ScreenUtil();
FullScreen fs;

public void setup() {
  size(scr.WIDTH, scr.HEIGHT, P2D);
  background(255);
  initCam();
  //initMovie();
  
  fs = new FullScreen(this);
  fs.setResolution(1024, 640);
  fs.enter();
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
  renderCanvas();
}

public void renderCanvas() {
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
  }
}

public void movieEvent(Movie m) {
  m.read();
}

class Pixel {
  int c;
  int x;
  int y;
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
  
  final int COLOR_STEP = 30;
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    g = createGraphics(width, height, P2D);
    
    int idx = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        px[idx] = new Pixel(target.pixels[idx], x, y);
        idx++;
      }
    }
  }
  
  public void update(PImage target) {
    Pixel p;
    g.beginDraw();

    for (int i = 0; i < len; i++) {
      p = px[i];
      p.c = target.pixels[i];
      if (p.x % p.tsize == 0 && p.y % p.tsize == 0) {
        g.fill(color(breakColor(red(p.c)), breakColor(green(p.c)), breakColor(blue(p.c))));
        g.noStroke();
        g.rect(p.x, p.y, p.tsize, p.tsize);
      }
    }
    
    g.endDraw();
    image(g, 0, 0);
  }
  
  public PGraphics getGraphics() {
    return g;
  }
  
  public float breakColor(float cl) {
    return constrain(ceil(cl / COLOR_STEP) * COLOR_STEP, 0, 255);
  }
  
}
class ScreenUtil {
  //int WIDTH = screen.width; int HEIGHT = screen.height;
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
