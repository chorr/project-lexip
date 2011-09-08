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
  
  void update(PImage target) {
    Pixel p;
    g.beginDraw();

    for (int i = 0; i < len; i++) { // 픽셀을 더 촘촘하게 만들 수 있음
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
  
  PGraphics getGraphics() {
    return g;
  }
  
  float breakColor(float cl) {
    return constrain(ceil(cl / COLOR_STEP) * COLOR_STEP, 0, 255);
  }
  
}
