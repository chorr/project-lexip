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

final int CAPTURE_MODE = 0;
final boolean IS_FULLSCREEN = false;

void setup() {
  size(scr.WIDTH, scr.HEIGHT, P2D);
  background(0);
  colorMode(HSB, 255);
  
  if (CAPTURE_MODE == 0) initOpenCV();
  if (CAPTURE_MODE == 1) initCam();
  if (CAPTURE_MODE == 2) initMovie();
  
  if (IS_FULLSCREEN == true) {
    fs = new FullScreen(this);
    fs.setResolution(1024, 640);
    fs.enter();
  }
}

void draw() {
  //background(255);
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
    //canvas.update(opencv.image(), faces);
    canvas.update(opencv.image());
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

void movieEvent(Movie m) {
  m.read();
}

void stop() {
  if (opencv != null) {
    opencv.stop();
  }
  super.stop();
}

void keyPressed() {
  if (keyCode == 38) {
    for (int i = 0; i < canvas.len; i++) 
      canvas.px[i].tsize = min(canvas.px[i].tsize + 1, 10);
  } else if (keyCode == 40) {
    for (int i = 0; i < canvas.len; i++) 
      canvas.px[i].tsize = max(canvas.px[i].tsize - 1, 1);
  } else if (key == 'b' || key == 'B') {
    for (int i = 0; i < canvas.len; i++) 
      canvas.px[i].isBreak = !canvas.px[i].isBreak;
  } else if (key == 'r' || key == 'R') {
    for (int i = 0; i < canvas.len; i++) {
      canvas.px[i].isBreak = !canvas.px[i].isBreak;
      canvas.px[i].tsize = canvas.px[i].isBreak ? 3 : 1;
    }
  }
}
