class Pixel {
  int c, x, y;
  int tsize = 3;
  boolean isBreak = true;
  
  Pixel(int c, int x, int y) {
    this.c = c;
    this.x = x;
    this.y = y;
  }
  
  void update(int c) {
    color newColor;
    float h, s, b;
    
    this.c = c;
    if ( !(x % tsize == 0 && y % tsize == 0) ) return;
    
    if (isBreak) {
      h = hue(c);
      if (ScreenUtil.PIXEL_MODE == 0) {
        s = breakColor(saturation(c), 20);
        if (s < 80) s = 0;
        b = brightness(c) > 170 ? 255 : (brightness(c) > 80 ? 100 : 0);
      } else if (ScreenUtil.PIXEL_MODE == 1) {
        s = 0;
        b = brightness(c) > 130 ? 255 : 0;
      }
      newColor = color(h, s, b);
      fill(newColor, 210);
    } else {
      fill(c);
    }
    
    noStroke();
    rect(x, y, tsize, tsize);
  }
  
  float breakColor(float cl, float step) {
    return constrain(ceil(cl / step) * step, 0, 255);
  }

}


