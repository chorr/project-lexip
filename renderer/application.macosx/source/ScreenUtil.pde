class ScreenUtil {
  //int WIDTH = screen.width; int HEIGHT = screen.height;
  int WIDTH = 1024; int HEIGHT = 640;
  //int WIDTH = 640; int HEIGHT = 480;
  
  float getFullScreenRatio(PImage target) {
    float ratio = (float)WIDTH / (float)target.width;
    if (target.height * ratio < HEIGHT) {
      ratio = HEIGHT / target.height;
    }
    return ratio;
  }
  
}
