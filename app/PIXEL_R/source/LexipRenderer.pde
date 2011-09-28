import processing.video.*;
import fullscreen.*;
import hypermedia.video.*;
import java.awt.Rectangle;

Movie mov = null;
Capture cam = null;
OpenCV opencv = null;
PixelCanvas canvas;
FullScreen fs;
int br = 20;
int ct = 40;

void setup() {
  if (ScreenUtil.IS_FULLSCREEN) {
    size(ScreenUtil.FULL_WIDTH, ScreenUtil.FULL_HEIGHT, P2D);
  } else {
    size(ScreenUtil.WIDTH, ScreenUtil.HEIGHT, P2D);
  }
  println(width);
  background(0);
  colorMode(HSB, 255);
  
  if (ScreenUtil.CAPTURE_MODE == 0) initOpenCV();
  if (ScreenUtil.CAPTURE_MODE == 1) initCam();
  if (ScreenUtil.CAPTURE_MODE == 2) initMovie();
  
  fs = new FullScreen(this);
  fs.setResolution(ScreenUtil.FULL_WIDTH, ScreenUtil.FULL_HEIGHT);
  if (ScreenUtil.IS_FULLSCREEN) {
    fs.enter();
  }
}

void draw() {
  if (cam != null) {
    if (cam.available()) {
      cam.read();
      scale(ScreenUtil.getFullScreenRatio(cam));
      canvas.update(cam);
    }
  } else if (mov != null) {
    scale(ScreenUtil.getFullScreenRatio(mov));
    canvas.update(mov);
  } else if (opencv != null) {
    Rectangle[] faces;
    opencv.read();
    opencv.flip(OpenCV.FLIP_HORIZONTAL);
    if (ScreenUtil.PIXEL_MODE == 0) {
      faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40);
    }
    opencv.brightness(br);
    opencv.contrast(ct);
    
    scale(ScreenUtil.getFullScreenRatio(opencv.image()));
    if (ScreenUtil.PIXEL_MODE == 0) {
      canvas.update(opencv.image(), faces);
    } else {
      canvas.update(opencv.image());
    }
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
  } else if ((key == 'f' || key == 'F') && fs != null) {
    fs.enter();
  } else if (key == '1') {
    br = max(br - 1, -128);
    println("brightness = " + br);
  } else if (key == '2') {
    br = min(br + 1, 128);
    println("brightness = " + br);
  } else if (key == '3') {
    ct = max(ct - 1, -128);
    println("contrast = " + ct);
  } else if (key == '4') {
    ct = min(ct + 1, 128);
    println("contrast = " + ct);
  }
}
