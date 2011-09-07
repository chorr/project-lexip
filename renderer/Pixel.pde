class Pixel {
  int c;
  int x;
  int y;
  int tsize = 3;
  int colorStep = 30;
  
  Pixel(int c, int x, int y) {
    this.c = c;
    this.x = x;
    this.y = y;
  }
  
  void update(PGraphics g) {
    if (x % tsize == 0 && y % tsize == 0) {
      g.beginDraw();
      g.fill(color(breakColor(red(c)), breakColor(green(c)), breakColor(blue(c))));
      g.noStroke();
      g.rect(x, y, tsize, tsize);
      g.endDraw();
    }
  }
  
  float breakColor(float cl) {
    return constrain(ceil(cl / colorStep) * colorStep, 0, 255);
  }
  
}


