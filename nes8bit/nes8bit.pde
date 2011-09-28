//HendersonSix 2011
//Nes Colour Palette Test with Video Input

import processing.video.*;
String[] palette;  //string array to load the palette.txt file
PVector[] colors = new PVector[256];  //256 colors in the palette file
float d;  //variable to store the distance between the NES color and the sampled color
Capture video;
int res=6;  //sets the increment value in the for loops
float mindist = 256;  //set minimum dist to maximum
color nes;  //the color eventually drawn to the screen
void setup(){
  size(480, 360);
  video = new Capture(this, width, height);
  palette = loadStrings("NesPalette.txt");  //text file with RGB values
    //divide each line from the .txt file into R, G, and B values
  for(int i=0; i<palette.length; i++){
    String[] cols = split(palette[i], ',');
    if(cols.length == 3){
      colors[i] = new PVector(int(cols[0]), int(cols[1]), int(cols[2]));
    }
  }
  noStroke();
}
void draw(){
  if(video.available()){
    video.read();
    //loop through the video input
    for(int x=0; x<video.width; x+=res){
      for(int y=0; y<video.height; y+=res){
        color currColor = video.get(x, y);
        //isolate the R, G, and B channels
        int rval = (currColor >> 16) & 0xFF;
        int gval = (currColor >> 8) & 0xFF;
        int bval = currColor & 0xFF;
        //store them in a pvector
        PVector curr = new PVector(rval, gval, bval);
        mindist = 256;  //reset minimum distance variable to maximum
        //get the distance between the current sampled color and the nes color palette using the brute force method
        for(int i=0; i<palette.length; i++){
          d = colors[i].dist(curr);
          if(d < mindist){
            mindist = d;  //if there is a new lowest distance, set mindist accordingly
            nes = color(colors[i].x, colors[i].y, colors[i].z);
            fill(nes);  //fill rect with the color from the nes palette
            rect(x, y, res, res);
          }
        }
      }
    }
  }
}
void keyPressed(){
  if(key==32){
    save(frameCount+".jpg");
    println("saved! "+frameCount);
  }
}

