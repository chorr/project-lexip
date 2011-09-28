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
      if (ScreenUtil.PIXEL_MODE == 0 || ScreenUtil.PIXEL_MODE == 2) {
        s = breakColor(saturation(c), 20);
        if (s < 80) s = 0;
        b = brightness(c) > 170 ? 255 : (brightness(c) > 80 ? 100 : 0);
      } else if (ScreenUtil.PIXEL_MODE == 1) { // B & W
        s = 0;
        b = brightness(c) > 130 ? 255 : 0;
      } else if (ScreenUtil.PIXEL_MODE == 3) { // RED
        h = 0;
        s = brightness(c) > 130 ? 0 : 200;
        b = brightness(c) > 130 ? 255 : 220;
      } else if (ScreenUtil.PIXEL_MODE == 4) { // GREEN
        h = 90;
        s = brightness(c) > 130 ? 0 : 190;
        b = brightness(c) > 130 ? 255 : 195;
      } else if (ScreenUtil.PIXEL_MODE == 5) { // BLUE
        h = 176;
        s = brightness(c) > 130 ? 0 : 195;
        b = brightness(c) > 130 ? 255 : 207;
      }
      
      
      newColor = color(h, s, b);
      
      fill(newColor, 210);
    } else {
      fill(c);
    }
    
    noStroke();
    if (ScreenUtil.PIXEL_MODE == 2) {
      stroke(0);
    }
    rect(x, y, tsize, tsize);
  }
  
  float breakColor(float cl, float step) {
    return constrain(ceil(cl / step) * step, 0, 255);
  }

}


