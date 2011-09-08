import processing.video.*;
import fullscreen.*;
import hypermedia.video.*;
import java.awt.Rectangle;

Movie mov = null;
Capture cam = null;
OpenCV opencv = null;
PixelCanvas canvas;
ScreenUtil scr = new ScreenUtil();
FullScreen fs;

final boolean IS_FULLSCREEN = false;

void setup() {
  size(scr.WIDTH, scr.HEIGHT, P2D);
  background(0);
  colorMode(HSB, 255);
  
  initOpenCV();
  //initCam();
  //initMovie();
  
  if (IS_FULLSCREEN == true) {
    fs = new FullScreen(this);
    fs.setResolution(1024, 640);
    fs.enter();
  }
}

void initOpenCV() {
  opencv = new OpenCV(this);
  opencv.capture(320, 240);
  opencv.cascade(OpenCV.CASCADE_FRONTALFACE_ALT);
  canvas = new PixelCanvas(opencv.image());
}

void initCam() {
  cam = new Capture(this, 320, 240, Capture.list()[1]);
  canvas = new PixelCanvas(cam);
}

void initMovie() {
  mov = new Movie(this, "station.mov");
  mov.loop();
  mov.read();
  canvas = new PixelCanvas(mov);
}

void draw() {
  background(255);
  if (cam != null) {
    if (cam.available()) {
      cam.read();
      scale(scr.getFullScreenRatio(cam));
      canvas.update(cam);
    }
  } else if (mov != null) {
    scale(scr.getFullScreenRatio(mov));
    canvas.update(mov);
  } else if (opencv != null) {
    opencv.read();
    opencv.flip(OpenCV.FLIP_HORIZONTAL);
    Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40);
    opencv.brightness(20);
    opencv.contrast(40);
    
    scale(scr.getFullScreenRatio(opencv.image()));
    canvas.update(opencv.image(), faces);
  }
}

void movieEvent(Movie m) {
  m.read();
}

void stop() {
  if (opencv != null) {
    opencv.stop();
  }
  super.stop();
}
