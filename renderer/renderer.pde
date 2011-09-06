import processing.video.*;

Movie mov;
PixelCanvas canvas;

void setup() {
  size(ScreenUtil.WIDTH, ScreenUtil.HEIGHT, P2D);
  background(255);

  mov = new Movie(this, "station.mov");
  mov.loop();
  mov.read();
  
  canvas = new PixelCanvas(mov);
}

void draw() {
  background(255);
  scale(ScreenUtil.getFullScreenRatio(mov));
  canvas.update(mov);
}

void renderCanvas() {
  //image(mov, 0, 0);
}

void movieEvent(Movie m) {
  m.read();
  renderCanvas();
}

