static class ScreenUtil {
  final static int WIDTH = 640;
  final static int HEIGHT = 480;

  static float getFullScreenRatio(PImage target) {
    float ratio = (float)WIDTH / (float)target.width;
    if (target.height * ratio < HEIGHT) {
      ratio = HEIGHT / target.height;
    }
    return ratio;
  }
  
}
