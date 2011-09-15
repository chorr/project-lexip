class PixelCanvas {
  int width;
  int height;
  int len;
  Pixel[] px;
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    
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
    lg.image(target, 0, 0);
    lg.beginDraw();

    lg.strokeWeight(4);
    lg.fill(255);
    lg.ellipseMode(CENTER);
    for (int i = 0, l = faces.length; i < l; i++) {
      lg.ellipse( faces[i].x - 30, faces[i].y - 20, faces[i].width * 1.7, faces[i].width * 1.0 );
    }
    
    lg.endDraw();
    this.update(lg);
  }
  
  PGraphics getGraphics() {
    return g;
  }
    
}
