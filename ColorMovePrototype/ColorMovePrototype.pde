import processing.video.*;

Capture cam;
PImage i_r = new PImage(320, 240, RGB);
PImage i_g = new PImage(320, 240, RGB);
PImage i_b = new PImage(320, 240, RGB);
PImage res = new PImage(320, 240, RGB);
ArrayList ls = new ArrayList();

void setup() {
  size(640, 480);
  frameRate(24);
  cam = new Capture(this, 320, 240);
}


void draw() {
  if (cam.available() == true) {
    cam.read();
    
    PImage tmp = new PImage(320, 240, RGB);
    for (int i=0; i<cam.pixels.length; i++) tmp.pixels[i] = cam.pixels[i];
    ls.add(tmp);
    
    if (ls.size() > 24) {
      ls.remove(0);
    } else {
      return;
    }

    for (int x=0; x<320; x++) {
      for (int y=0; y<240; y++) {
        color c3 = ((PImage)ls.get(0)).get(x, y);
        color c2 = ((PImage)ls.get(12)).get(x, y);
        color c1 = ((PImage)ls.get(23)).get(x, y);

        i_r.set(x, y, color(red(c1), 0, 0));
        i_g.set(x, y, color(0, green(c2), 0));
        i_b.set(x, y, color(0, 0, blue(c3)));

        res.set(x, y, blendColor(i_r.get(x, y), i_b.get(x, y), ADD));
        res.set(x, y, blendColor(res.get(x, y), i_g.get(x, y), ADD));
      }
    }

    //image(i_r, 0, 0);
    image(cam, 0, 0);
    image(i_g, 320, 0);
    image(i_b, 0, 240);
    image(res, 320, 240);
  }
} 

