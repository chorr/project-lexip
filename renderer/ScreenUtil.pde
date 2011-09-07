class ScreenUtil {
  //int WIDTH = screen.width; int HEIGHT = screen.height;
  int WIDTH = 800; int HEIGHT = 600;
  
  float getFullScreenRatio(PImage target) {
    float ratio = (float)WIDTH / (float)target.width;
    if (target.height * ratio < HEIGHT) {
      ratio = HEIGHT / target.height;
    }
    return ratio;
  }
  
}
