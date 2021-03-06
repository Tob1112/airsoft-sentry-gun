/*

this is an example of rendering the video pixels in a fun way.
pixels are rendered as colored, scaled spots.

 last tested to work in Processing 0090
 
 JTNIMOY
 
*/

import JMyron.*;

JMyron m;//a camera object
 
void setup(){
  size(320,240);
  m = new JMyron();//make a new instance of the object
  m.start(width,height);//start a capture at 320x240
  m.findGlobs(0);//disable the intelligence to speed up frame rate
  println("Myron " + m.version());
  rectMode(CENTER);
  noStroke();
}

void draw(){
  background(255);
  m.update();//update the camera view
  int[] img = m.image(); //get the normal image of the camera
  float r,g,b;
  for(int y=0;y<height;y+=16){ //loop through all the pixels
    for(int x=0;x<width;x+=16){ //loop through all the pixels
      float av = (red(img[y*width+x])+green(img[y*width+x])+blue(img[y*width+x]))/3.0;
      fill(red(img[y*width+x]),green(img[y*width+x]),blue(img[y*width+x]));
      pushMatrix();
      translate(x,y);
      ellipse(0,0,(255-av)/8.0,(255-av)/8.0);
      popMatrix();
    }
  }
}

void mousePressed(){
  m.settings();//click the window to get the settings
}

public void stop(){
  m.stop();//stop the object
  super.stop();
}

