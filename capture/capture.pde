import processing.video.*;

Capture cam;

void setup() {
  size(320, 240);
  String[] devices = Capture.list();
  println(devices);
  
  cam = new Capture(this, width, height, devices[1]);
}

void draw() {
  if (cam.available()) {
    cam.read();
    image(cam, 0, 0);
  }
  
}
