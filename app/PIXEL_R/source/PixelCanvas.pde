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
  
  void update(PImage target) {
    Pixel p;
    for (int i = 0; i < len; i++) {
      p = px[i];
      p.update(target.pixels[i]);
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
