import processing.video.*;
import fullscreen.*;
import imageadjuster.*;

Capture cam;
PImage res = new PImage(140, 105, RGB);
ArrayList ls = new ArrayList();
FullScreen fs;
ImageAdjuster adjust;
NetUtil net = new NetUtil();
int br = 50;
int ct = 40;
int MODE = 3;
final static boolean IS_FS = false;
final static int BF_SIZE = 64;

void setup() {
  size(1024, 640);
//  size(1280, 720);
  background(0);
  cam = new Capture(this, 320, 240);
  
  adjust = new ImageAdjuster(this);
  adjust.brightness(0.25f);
  adjust.contrast(1.4f);

  fs = new FullScreen(this);
  if (IS_FS) {
    fs.setResolution(1024, 640);
    fs.enter();
  }
}

void draw() {
//  println("FPS " + frameRate);
  if (!cam.available()) return;
  cam.read();

  // arrange image.
  PImage tmp = new PImage(cam.width, cam.height, ARGB);
  for (int x=0; x<cam.width; x++) {
    for (int y=0; y<cam.height; y++) {
      tmp.set(cam.width - x - 1, y, cam.get(x, y));
    }
  }
  tmp.resize(res.width, res.height);
  adjust.apply(tmp);
  
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
    tmp.pixels[i] = color(cH, cS, cB, cA);
  }
  
  if (MODE == 0) {
    colorMode(RGB, 255);
    for (int x=0; x<tmp.width; x++) {
      for (int y=0; y<tmp.height; y++) {
        color cR = color(red(((PImage)ls.get(BF_SIZE-1)).get(x, y)), 0, 0);
        color cG = color(0, green(((PImage)ls.get(BF_SIZE/2)).get(x, y)), 0);
        color cB = color(0, 0, blue(((PImage)ls.get(0)).get(x, y)));
        color cNew = blendColor(blendColor(cR, cG, ADD), cB, ADD);
        res.set(x, y, cNew);
      }
    }
    image(res, 0, -64, 1024, 768);
//    image(res, 0, -120, 1280, 960);
  } else {
    image(tmp, 0, -64, 1024, 768);
//    image(tmp, 0, -120, 1280, 960);
  }
  
} 

void keyPressed() {
  if ((key == 'f' || key == 'F') && fs != null) {
    fs.enter();
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
  } else if (keyCode == 32) {
    net.saveImage("pixel", "pic");
  }
}

void mousePressed() {
  net.saveImage("pixel", "pic");
}

void stop() {
  cam.stop();
  super.stop();
}

float breakColor(float cl, float step) {
  return constrain(ceil(cl / step) * step, 0, 255);
}

