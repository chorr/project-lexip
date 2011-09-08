import hypermedia.video.*;
import java.awt.Rectangle;

OpenCV opencv;


void setup() {
  size( 320, 240 );
  opencv = new OpenCV(this);
  opencv.capture(width, height);
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );
}

void draw() {
  opencv.read();
  
  Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40);
  image(opencv.image(), 0, 0);
  
  noStroke();
  fill(255, 200, 0);
  for (int i = 0; i < faces.length; i++) {
    rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
}

void stop() {
  opencv.stop();
  super.stop();
}
