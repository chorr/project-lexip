class PixelCanvas {
  int width;
  int height;
  int len;
  Pixel[] px;
  PImage block1;
  ArrayList ls = new ArrayList();
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    block1 = loadImage("block1.png");
    
    int idx = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        px[idx] = new Pixel(color(100), x, y);
        idx++;
      }
    }
  }
  
  void update(PImage target) {
    Pixel p;
    PImage tmp = new PImage(ScreenUtil.WIDTH, ScreenUtil.HEIGHT);
    int i = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        p = px[i];
        if (x % p.tsize == 0 && y % p.tsize == 0) {
          p.update(target.pixels[i]);
        }
        i++;
      }
    }
    
    if (ScreenUtil.PIXEL_MODE == 6) {  // trinity
      loadPixels();
      for (i=0; i < pixels.length; i++) tmp.pixels[i] = pixels[i];
      ls.add(tmp);
      if (ls.size() > 13) {
        ls.remove(0);
      } else {
        return;
      }
      
      colorMode(RGB);
      for (i=0; i < pixels.length; i++) {
        color hR = color(red(((PImage)ls.get(12)).pixels[i]), 0, 0);
        color hG = color(0, green(((PImage)ls.get(6)).pixels[i]), 0);
        color hB = color(0, 0, blue(((PImage)ls.get(0)).pixels[i]));
        pixels[i] = blendColor(blendColor(hR, hG, LIGHTEST), hB, LIGHTEST);
      }
      colorMode(HSB, 255);
      updatePixels();
    }
    
  }
  
  void update(PImage target, Rectangle[] faces) {
    PGraphics lg = createGraphics(target.width, target.height, P2D);
    Rectangle f;
    float ratio;
    
    lg.image(target, 0, 0);
    lg.beginDraw();
    lg.imageMode(CENTER);
    for (int i = 0, l = faces.length; i < l; i++) {
      f = faces[i];
      ratio = (float)f.width / 100.0;
      lg.image( block1, f.x + f.width / 2, f.y - (f.height), f.width, block1.height * ratio );
    }
    lg.endDraw();
    this.update(lg);
  }
  
  PGraphics getGraphics() {
    return g;
  }
    
}
