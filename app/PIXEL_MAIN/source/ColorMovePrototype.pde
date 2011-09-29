import hypermedia.video.*;
import fullscreen.*;

OpenCV cam;
PImage res = new PImage(140, 105, RGB);
ArrayList ls = new ArrayList();
FullScreen fs;
int br = 20;
int ct = 40;
int MODE = 3;
final static boolean IS_FS = true;

void setup() {
  size(1024, 640);
  background(0);
  cam = new OpenCV(this);
  cam.capture(320, 240);
  fs = new FullScreen(this);
  fs.setResolution(1024, 640);
  if (IS_FS) {
    fs.enter();
  }
}

void draw() {
  println("FPS " + frameRate);

  cam.read();
  cam.flip(OpenCV.FLIP_HORIZONTAL);
  cam.brightness(br);
  cam.contrast(ct);

  PImage tmp = new PImage(cam.width, cam.height, ARGB);
  tmp.set(0, 0, cam.image());
  tmp.resize(res.width, res.height);
  ls.add(tmp);
  
  if (ls.size() > 24) {
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
        color cR = color(red(((PImage)ls.get(23)).get(x, y)), 0, 0);
        color cG = color(0, green(((PImage)ls.get(13)).get(x, y)), 0);
        color cB = color(0, 0, blue(((PImage)ls.get(0)).get(x, y)));
        color cNew = blendColor(blendColor(cR, cG, ADD), cB, ADD);
        res.set(x, y, cNew);
      }
    }
    image(res, 0, -64, 1024, 768);
  } else {
    image(tmp, 0, -64, 1024, 768);
  }
  
} 

void keyPressed() {
  if ((key == 'f' || key == 'F') && fs != null) {
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
  } else if (key == 'a' || key == 'A') {
    MODE = 0;
  } else if (key == 'r' || key == 'R') {
    MODE = 1;
  } else if (key == 'g' || key == 'G') {
    MODE = 2;
  } else if (key == 'b' || key == 'B') {
    MODE = 3;
  }
}

void stop() {
  cam.stop();
  super.stop();
}

float breakColor(float cl, float step) {
  return constrain(ceil(cl / step) * step, 0, 255);
}

