class Pixel {
  int c;
  int x;
  int y;
  int tsize = 5;
  
  Pixel(int c, int x, int y) {
    this.c = c;
    this.x = x;
    this.y = y;
  }
  
  void update(PGraphics g) {
    if (x % tsize == 0 && y % tsize == 0) {
      g.beginDraw();
      g.fill(c);
      g.rect(x, y, tsize, tsize);
      g.endDraw();
    }
  }
  
}


