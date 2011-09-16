static class ScreenUtil {
  final static int PIXEL_MODE = 1;
  final static int CAPTURE_MODE = 0;
  final static boolean IS_FULLSCREEN = true;

  final static int WIDTH = 1024; final static int HEIGHT = 640;
  //final static int WIDTH = 640; final static int HEIGHT = 480;
  final static int FULL_WIDTH = 1024;
  final static int FULL_HEIGHT = 640;
  
  static float getFullScreenRatio(PImage target) {
    int w = WIDTH, h = HEIGHT;
    if (IS_FULLSCREEN) {
      w = FULL_WIDTH;
      h = FULL_HEIGHT;
    }
    float ratio = (float)w / (float)target.width;
    if (target.height * ratio < h) {
      ratio = h / target.height;
    }
    return ratio;
  }
  
}
