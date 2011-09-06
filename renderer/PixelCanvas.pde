class PixelCanvas {
  int width;
  int height;
  int len;
  Pixel[] px;
  PGraphics g;
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    g = createGraphics(width, height, P2D);
    g.noSmooth();
    
    int idx = 0;
    for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
        px[idx] = new Pixel(target.pixels[idx], x, y);
        idx++;
      }
    }
  }
  
  void update(PImage target) {
    for (int i = 0; i < len; i++) {
      px[i].c = target.pixels[i];
      px[i].update(g);
    }
    image(g, 0, 0);
  }
  
  PGraphics getGraphics() {
    return g;
  }
  
}
