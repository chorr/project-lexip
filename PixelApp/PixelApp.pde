import processing.video.*;
import fullscreen.*;
import imageadjuster.*;

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

void setup() {
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

void draw() {
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
    color c = tmp.pixels[i];
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
    
    PImage img1 = (PImage)ls.get(BF_SIZE-1);  // current
    PImage img2 = (PImage)ls.get(BF_SIZE/2);  // ..
    PImage img3 = (PImage)ls.get(0);          // oldest
    int gap1 = 0;
    int gap2 = 0;
    
    colorMode(RGB, 255);
    for (int x=0; x < res.width; x++) {
      for (int y=0; y < res.height; y++) {
        color c1 = img1.get(x, y);
        color c2 = img2.get(x, y);
        color c3 = img3.get(x, y);
        color cR = color(red(c1), 0, 0);
        color cG = color(0, green(c2), 0);
        color cB = color(0, 0, blue(c3));
        color cNew = blendColor(blendColor(cR, cG, ADD), cB, ADD);
        res.set(x, y, cNew);
        
        gap1 += abs((c1 & 0xFF) - (c2 & 0xFF));
        gap1 += abs(((c1 >> 8) & 0xFF) - ((c2 >> 8) & 0xFF));
        gap1 += abs(((c1 >> 16) & 0xFF) - ((c2 >> 16) & 0xFF));
        gap2 += abs((c1 & 0xFF) - (c3 & 0xFF));
        gap2 += abs(((c1 >> 8) & 0xFF) - ((c3 >> 8) & 0xFF));
        gap2 += abs(((c1 >> 16) & 0xFF) - ((c3 >> 16) & 0xFF));
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

void keyPressed() {
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

void mousePressed() {
  if (MODE != 0 && net.message == "") {
    net.saveImage("pixel", "pic", MODE);
  }
}

void stop() {
  cam.stop();
  super.stop();
}

float breakColor(float cl, float step) {
  return constrain(ceil(cl / step) * step, 0, 255);
}

void showMessage() {
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

