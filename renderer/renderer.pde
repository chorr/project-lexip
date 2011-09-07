import processing.video.*;
//import fullscreen.*;

Movie mov = null;
Capture cam = null;
PixelCanvas canvas;
ScreenUtil scr = new ScreenUtil();
//FullScreen fs;

void setup() {
  size(scr.WIDTH, scr.HEIGHT, P2D);
  background(255);
  //initCam();
  initMovie();
  
  /*fs = new FullScreen(this);
  fs.setResolution(1024, 640);
  fs.enter();*/
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
  renderCanvas();
}

void renderCanvas() {
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
  }
}

void movieEvent(Movie m) {
  m.read();
}

