/*
press 'v' to show/hide visuals
press 'c' to show/hide camera view
press 'b' to set background

*/

import JMyron.*;
import blobDetection.*;
import ddf.minim.*;

int camWidth = 640;
int camHeight = 480;
boolean visuals = false;
boolean showCam = true;

JMyron theMov;
BlobDetection target;
Blob blob;
Blob biggestBlob;
int[] screenPixels;
int[] currFrame;
int[] Background;
int tolerance = 100;
int blobWidth;
int blobHeight;
int biggestBlobArea;
int minBlobArea = 200;

int[] prevX = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int[] prevY = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

int lastX;
int lastY;
int currX;
int currY;



Minim minim;

AudioSnippet s1;
AudioSnippet s2;
AudioSnippet s3;
AudioSnippet s4;
AudioSnippet s5;
AudioSnippet s6;
AudioSnippet s7;
AudioSnippet s8;
AudioSnippet s9;
AudioSnippet s10;
AudioSnippet s11;
AudioSnippet s12;
AudioSnippet s13;
AudioSnippet s14;
AudioSnippet s15;
AudioSnippet s16;
AudioSnippet s17;
AudioSnippet s18;
AudioSnippet s19;
AudioSnippet s20;
AudioSnippet s21;

void setup() {
  size(camWidth, camHeight);
  minim = new Minim(this);
  loadSounds();
  theMov = new JMyron();
  theMov.start(camWidth, camHeight);
  theMov.findGlobs(0);
  theMov.adaptivity(1.5 );
  theMov.update();
  Background = theMov.image();
  currFrame = theMov.image();
  screenPixels = theMov.image();
  target = new BlobDetection(camWidth, camHeight);
  target.setThreshold(0.5);
  target.setPosDiscrimination(true);
  theMov.adapt();
}

void draw() {
  theMov.update();
  Background = theMov.retinaImage();
  currFrame = theMov.image();
  loadPixels();
  for(int i = 0; i < camWidth*camHeight; i++) {
    if(showCam) 
      pixels[i] = currFrame[i];
    if(pixelsDifference(i) > tolerance) {
      screenPixels[i] = color(255,255,255);
      if(visuals) {
        pixels[i] = color(0,255,0);
      }
    }
    else{
      screenPixels[i] = color(0,0,0);
    }
  }
  updatePixels();
  
  biggestBlobArea = 0;
  target.computeBlobs(screenPixels);
  for(int i = 0; i < target.getBlobNb()-1; i++) {
    blob = target.getBlob(i);
    blobWidth = int(blob.w*float(camWidth));
    blobHeight = int(blob.h*float(camHeight));
    if(blobWidth*blobHeight >= biggestBlobArea) {
      biggestBlob = target.getBlob(i);
      biggestBlobArea = int(biggestBlob.w*float(camWidth))*int(biggestBlob.h*float(camHeight));
    }
  }
  if(biggestBlobArea >= minBlobArea) {
    
    if(visuals && showCam){
      stroke(255,50,50);
      strokeWeight(3);
      fill(255,50,50,150);
      rect(int(biggestBlob.xMin*float(camWidth)), int(biggestBlob.yMin*float(camHeight)), int((biggestBlob.xMax-biggestBlob.xMin)*float(camWidth)), int((biggestBlob.yMax-biggestBlob.yMin)*float(camHeight)));
    }
    for(int i = 9; i >= 1; i--) {
      prevX[i] = prevX[i-1];
    }
    if(currX > 0) {
      prevX[0] = 1;
    }else{
      prevX[0] = 0;
    }
    for(int i = 9; i >= 1; i--) {
      prevY[i] = prevY[i-1];
    }
    
    if(currY > 0) {
      prevY[0] = 1;
    }else{
      prevY[0] = 0;
    }
    currX = int(biggestBlob.x*float(camWidth));
    currY = int(biggestBlob.y*float(camHeight));
    if(!showCam) {
      fill(0);
      stroke(0);
      rect(0,0,640,480);
    }    
    stroke(255,50,50);
    strokeWeight(3);
    fill(255,50,50,150);
    ellipse(currX, currY, 50, 50);
  }else{
    for(int i = 9; i >= 1; i--) {
      prevX[i] = prevX[i-1];
    }
    if(currX > 0) {
      prevX[0] = 1;
    }else{
      prevX[0] = 0;
    }
    for(int i = 9; i >= 1; i--) {
      prevY[i] = prevY[i-1];
    }
    
    if(currY > 0) {
      prevY[0] = 1;
    }else{
      prevY[0] = 0;
    }
    currX = 0;
    currY = 0;
  }
  int sumNewX = prevX[0] + prevX[1] + prevX[2] + prevX[3] + prevX[4];
  int sumPrevX = prevX[5] + prevX[6] + prevX[7] + prevX[8] + prevX[9];
  int sumNewY = prevY[0] + prevY[1] + prevY[2] + prevY[3] + prevY[4];
  int sumPrevY = prevY[5] + prevY[6] + prevY[7] + prevY[8] + prevY[9];
  
  
  if(sumNewX == 5 && sumPrevX == 0 && sumNewY == 5 && sumPrevY == 0) {
    // entered screen
    // 2, 3, 4, 6, 11, 14, 15, 16, 19
    int s = int(random(0, 9));
    if(s == 0)
      playSound(2);
    if(s == 1)
      playSound(3);
    if(s == 2)
      playSound(4);
    if(s == 3)
      playSound(6);
    if(s == 4)
      playSound(11);
    if(s == 5)
      playSound(14);
    if(s == 6)
      playSound(15);
    if(s == 7)
      playSound(16);
    if(s == 8)
      playSound(19);
  }
  
  if(sumNewX == 0 && sumPrevX == 5 && sumNewY == 0 && sumPrevY == 5) {
    // departed screen
    // 1, 5, 9, 12, 13, 20
    int s = int(random(0, 6));
    if(s == 0)
      playSound(1);
    if(s == 1)
      playSound(5);
    if(s == 2)
      playSound(9);
    if(s == 3)
      playSound(12);
    if(s == 4)
      playSound(13);
    if(s == 5)
      playSound(20);
  }
 
  print("currX = " + currX);
  println("   currY = " + currY);
}


void loadSounds() {
  s1 = minim.loadSnippet("Sounds/your business is appreciated.wav");
  s2 = minim.loadSnippet("Sounds/who's there.wav");
  s3 = minim.loadSnippet("Sounds/there you are.wav");
  s4 = minim.loadSnippet("Sounds/there you are(2).wav");
  s5 = minim.loadSnippet("Sounds/target lost.wav");
  s6 = minim.loadSnippet("Sounds/target aquired.wav");
  s7 = minim.loadSnippet("Sounds/sleep mode activated.wav");
  s8 = minim.loadSnippet("Sounds/sentry mode activated.wav");
  s9 = minim.loadSnippet("Sounds/no hard feelings.wav");
  s10 = minim.loadSnippet("Sounds/is anyone there.wav");
  s11 = minim.loadSnippet("Sounds/i see you.wav");
  s12 = minim.loadSnippet("Sounds/i dont hate you.wav");
  s13 = minim.loadSnippet("Sounds/i dont blame you.wav");
  s14 = minim.loadSnippet("Sounds/hey its me.wav");
  s15 = minim.loadSnippet("Sounds/hello.wav");
  s16 = minim.loadSnippet("Sounds/gotcha.wav");
  s17 = minim.loadSnippet("Sounds/dispensing product.wav");
  s18 = minim.loadSnippet("Sounds/deploying.wav");
  s19 = minim.loadSnippet("Sounds/could you come over here.wav");
  s20 = minim.loadSnippet("Sounds/are you still there.wav");
  s21 = minim.loadSnippet("Sounds/activated.wav");
}

void playSound(int sound) {
  if(sound == 1) {
    s1.rewind();
    s1.play();
  }
  if(sound == 2) {
    s2.rewind();
    s2.play();
  }
  if(sound == 3) {
    s3.rewind();
    s3.play();
  }
  if(sound == 4) {
    s4.rewind();
    s4.play();
  }
  if(sound == 5) {
    s5.rewind();
    s5.play();
  }
  if(sound == 6) {
    s6.rewind();
    s6.play();
  }
  if(sound == 7) {
    s7.rewind();
    s7.play();
  }
  if(sound == 8) {
    s8.rewind();
    s8.play();
  }
  if(sound == 9) {
    s9.rewind();
    s9.play();
  }
  if(sound == 10) {
    s10.rewind();
    s10.play();
  }
  if(sound == 11) {
    s11.rewind();
    s11.play();
  }
  if(sound == 12) {
    s12.rewind();
    s12.play();
  }
  if(sound == 13) {
    s13.rewind();
    s13.play();
  }
  if(sound == 14) {
    s14.rewind();
    s14.play();
  }
  if(sound == 15) {
    s15.rewind();
    s15.play();
  }
  if(sound == 16) {
    s16.rewind();
    s16.play();
  }
  if(sound == 17) {
    s17.rewind();
    s17.play();
  }
  if(sound == 18) {
    s18.rewind();
    s18.play();
  }
  if(sound == 19) {
    s19.rewind();
    s19.play();
  }
  if(sound == 20) {
    s20.rewind();
    s20.play();
  }
  if(sound == 21) {
    s21.rewind();
    s21.play();
  }
}

int pixelsDifference(int index) {
  return int(Math.abs(red(currFrame[index])-red(Background[index]))) + int(Math.abs(green(currFrame[index])-green(Background[index]))) + int(Math.abs(blue(currFrame[index])-blue(Background[index])));
}

void keyReleased() {
  if(key == 'v')
    visuals = !visuals;
  if(key == 'b')
    theMov.adapt();
  if(key == 'c')
    showCam = !showCam;
}

public void stop() {
  s1.close();
  s2.close();
  s3.close();
  s4.close();
  s5.close();
  s7.close();
  s6.close();
  s8.close();
  s9.close();
  s10.close();
  s11.close();
  s12.close();
  s13.close();
  s14.close();
  s15.close();
  s16.close();
  s17.close();
  s18.close();
  s19.close();
  s20.close();
  s21.close();
  
  minim.stop();
  theMov.stop();
  super.stop();
}
