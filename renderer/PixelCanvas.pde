class PixelCanvas {
  int width;
  int height;
  int len;
  Pixel[] px;
  PGraphics g;
  
  final int COLOR_STEP = 40;
  
  PixelCanvas(PImage target) {
    width = target.width;
    height = target.height;
    len = width * height;
    px = new Pixel[len];
    g = createGraphics(width, height, P2D);
    
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
    color newColor;
    g.beginDraw();

    for (int i = 0; i < len; i++) { // 픽셀을 더 촘촘하게 만들 수 있음
      p = px[i];
      p.c = target.pixels[i];
      if ( !(p.x % p.tsize == 0 && p.y % p.tsize == 0) ) continue;
      
      newColor = color(breakColor(hue(p.c), 10), 
                        min(200, breakColor(saturation(p.c), 20)), 
                        max(0, breakColor(brightness(p.c), 40)));
      g.fill(newColor);
      g.noStroke();
      g.rect(p.x, p.y, p.tsize, p.tsize);
    }
    
    g.endDraw();
    image(g, 0, 0);
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
  
  float breakColor(float cl, float step) {
    return constrain(ceil(cl / step) * step, 0, 255);
  }
  
}
