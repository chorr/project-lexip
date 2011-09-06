import processing.video.*;

Movie mov;
PixelCanvas canvas;

void setup() {
  size(ScreenUtil.WIDTH, ScreenUtil.HEIGHT, P2D);
  background(255);
println(ARGS_PRESENT);
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
  scale(ScreenUtil.getFullScreenRatio(mov));
  canvas.update(mov);
}

void movieEvent(Movie m) {
  m.read();
}

