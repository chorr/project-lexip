import processing.opengl.*;

import processing.video.*;
import FaceDetect.*;

FaceDetect fd;
Capture cam;

int MAX = 10;

int[] x = new int[MAX];
int[] y = new int[MAX];
int[] w = new int[MAX];
int[] h = new int[MAX];
int[][] Faces = new int[MAX][3];

void setup(){
  println(Capture.list());
  size(320,240);
  cam = new Capture(this, 320, 240,Capture.list()[1]);
  fd = new FaceDetect(this);
  fd.start("haarcascade_frontalface_alt.xml", width,height,30);
  stroke(255,200,0);

  noFill();
}

void draw(){
  if (cam.available()) {
    cam.read();
    image(cam,0,0);

    Faces = fd.detect(cam);
    int count = Faces.length;
      //  println(count);
    if (count>0) {
      for (int i = 0;i<count;i++) {
        x[i] = Faces[i][0];
        y[i] = Faces[i][1];
        w[i] = Faces[i][2] *2;
        ellipse(x[i],y[i],w[i],w[i]);
      }
    }
  }
}
