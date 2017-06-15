/*
  
 ------------ SENTRY GUN TURRET VERSION 5 CODE 03 -------------
 ------------------  Tobias  Scharfenberg ---------------
 ==============================================================
 
 This is the lastest code as of Dec 29, 2010.
 This is the computer side of the code, and is compatible with version 5_03 of the Arduino code.
 
 For this code to run properly, you must download these libraries from processing.org : controlP5, JMyron, and blobDetection
 
 See the Arduino code for directions on electrical connections. 
 A stationary camera is used in this program.
 
 hold 'r' and click+drag to form a rectangle "fire-restricted" zone
 hold 't' to view "fire-restricted zones"
 to toggle between manual and autonomous modes, click the Manual/Autonomous control.
 
 
 FUTURE IMPROMVEMENTS / TO DO LIST:
 
 -Stereo cameras for finding range
 -Gun-mounted camera for precision aiming in manual mode
 -Better calibration process
 -Remote control via internet site
 -Face/object recognition
 -Voice password recognition
 -"disable plate" that will disable the sentry gun for a random period of time when it is tapped or shot
 -battery power
 -anything else you can imagine; add to the list please
 
 
 Produced by Bob Rudolph. Version 5 , Revision 3. Use this code and modify it freely.
 Comments, bugs, questions? post a comment on code.google.com/p/airsoft-sentry-gun/wiki/General
 
 */

import controlP5.*;
import JMyron.*;
import blobDetection.*;
import processing.serial.*;

int camWidth = 320;                       //   camera width (pixels),   usually 160*n
int camHeight = 240;                      //   camera height (pixels),  usually 120*n
int minBlobArea = 180;                    //   minimum target size (pixels)
public int tolerance = 100;               //   sensitivity to motion
float xMin = 124.0;                   //  0.0      used for calibration. adjust these numbers to work with
float xMax = 87.0;                    //  180.0    your unique setup.
float yMin = 116.0;                   //  180.0
float yMax = 91.0;                    //  0.0

float xRatio;
float yRatio;

Serial arduinoPort;
JMyron theMov;
BlobDetection target;
Blob blob;
Blob biggestBlob;
ControlP5 controlP5;
ControlWindow controlPanel;

int[] Background;
int[] currFrame;
int[] screenPixels;
int targetX = camWidth/2;
int targetY = camHeight/2;
int fire = 0;

public boolean showDifferentPixels = true;
public boolean showTargetBox = true;
public boolean showCameraView = true;
public boolean firingMode = true;             // true = semi,        false = auto
public boolean controlMode = false;           // true = autonomous,  false = manual

int[][] fireRestrictedZones = new int[30][4];
int restrictedZone = 0;


void setup() {
  size(camWidth, camHeight);
  drawControlPanel();
  theMov = new JMyron();
  theMov.start(camWidth, camHeight);
  theMov.findGlobs(0);
  theMov.adaptivity(1.5);
  theMov.update();
  Background = theMov.image();
  currFrame = theMov.image();
  screenPixels = theMov.image();
  target = new BlobDetection(camWidth, camHeight);
  target.setThreshold(0.5);
  target.setPosDiscrimination(true);
  arduinoPort = new Serial(this, Serial.list()[0], 9600);      // start arduino communications
  xRatio = (camWidth / (xMax - xMin));                         // used to allign sights with crosshairs on PC
  yRatio = (camHeight/ (yMax - yMin));                         //

}

void draw() {
  if(controlMode) {              // autonomous mode
    autonomousMode();            //
  }
  else if(!controlMode) {        // manual mode
    manualMode();                //
  }

  String strTargetx = "000" + str(targetX);                   // make into 3-digit numbers
  strTargetx = strTargetx.substring(strTargetx.length()-3);
  String strTargety = "000" + str(targetY);
  strTargety = strTargety.substring(strTargety.length()-3);
  String fireSelector = str(0);
  if(firingMode) {
    fireSelector = str(1);
  }
  else{
    fireSelector = str(3);
  }
  println('a' + strTargetx + strTargety  + str(fire) + fireSelector);
  arduinoPort.write('a' + strTargetx + strTargety + str(fire) + fireSelector);   // send to arduino

  if(keyPressed) {
    if(key == 't') {
      for(int col = 0; col <= restrictedZone; col++) {
        noStroke();
        fill(0,255,0,100);
        rect(fireRestrictedZones[col][0], fireRestrictedZones[col][2], fireRestrictedZones[col][1]-fireRestrictedZones[col][0], fireRestrictedZones[col][3]-fireRestrictedZones[col][2]);
      }
    }
  }
}

void autonomousMode() {
  theMov.update();
  Background = theMov.retinaImage();
  currFrame = theMov.image();

  loadPixels();
  for(int i = 0; i < camWidth*camHeight; i++) {
    if(showCameraView) {
      pixels[i] = currFrame[i];
    }
    else{
      pixels[i] = color(0,0,0);
    }        
    if(int(Math.abs(red(currFrame[i])-red(Background[i]))) + int(Math.abs(green(currFrame[i])-green(Background[i]))) + int(Math.abs(blue(currFrame[i])-blue(Background[i]))) > tolerance) {
      screenPixels[i] = color(255,255,255);
      if(showDifferentPixels) {
        pixels[i] = color(0,255,255);
      }
    }
    else{
      screenPixels[i] = color(0,0,0);
    }
  }
  updatePixels();

  int biggestBlobArea = 0;
  target.computeBlobs(screenPixels);
  for(int i = 0; i < target.getBlobNb()-1; i++) {
    blob = target.getBlob(i);
    int blobWidth = int(blob.w*camWidth);
    int blobHeight = int(blob.h*camHeight);
    if(blobWidth*blobHeight >= biggestBlobArea) {
      biggestBlob = target.getBlob(i);
      biggestBlobArea = int(biggestBlob.w*camWidth)*int(biggestBlob.h*camHeight);
    }
  }
  int possibleX = 0;
  int possibleY = 0;

  if(biggestBlobArea >= minBlobArea) {
    possibleX = int(biggestBlob.x * camWidth);
    possibleY = int(biggestBlob.y * camHeight);
  }

  boolean clearOfZones = true;
  for(int col = 0; col <= restrictedZone; col++) {
    if(possibleX > fireRestrictedZones[col][0] && possibleX < fireRestrictedZones[col][1] && possibleY > fireRestrictedZones[col][2] && possibleY < fireRestrictedZones[col][3]) {
      clearOfZones = false;
    }
  }

  if((biggestBlobArea >= minBlobArea) && clearOfZones) {
    fire = 1;
    if(showTargetBox) {
      stroke(255,50,50);
      strokeWeight(3);
      fill(255,50,50,150);
      rect(int(biggestBlob.xMin*camWidth), int(biggestBlob.yMin*camHeight), int((biggestBlob.xMax-biggestBlob.xMin)*camWidth), int((biggestBlob.yMax-biggestBlob.yMin)*camHeight));
    }
    targetX = int((possibleX/xRatio)+xMin);         
    targetY = int(((camHeight-possibleY)/yRatio)+yMin);
  }
  else{
    fire = 0;
  }
}

void manualMode() {
  theMov.update();                              // read camera
    int[] currFrame = theMov.image();             //

    loadPixels();                                 //draw camera view to screen
    for(int i = 0; i < camWidth*camHeight; i++){  //
      pixels[i] = currFrame[i];                   //
    }                                             //
    updatePixels();                               //

    targetX = int((mouseX/xRatio)+xMin);                 // calculate position to go to based on mouse position
    targetY = int(((camHeight-mouseY)/yRatio)+yMin);     //

    if(mousePressed) {
      fire = 1;
      strokeWeight(3);
    }
    else{
      fire = 0;
      strokeWeight(1);
    }
    stroke(255,0,0);                     //draw crosshairs
    noFill();                            // 
    line(mouseX, 0, mouseX, camHeight);  //
    line(0, mouseY, camWidth, mouseY);   //
    ellipse(mouseX, mouseY, 20, 20);     //
    ellipse(mouseX, mouseY, 28, 22);     //
    ellipse(mouseX, mouseY, 36, 24);     //
}

void drawControlPanel() {
  controlP5 = new ControlP5(this);

  // make control panel window
  controlPanel = controlP5.addControlWindow("Control Panel",500,100,400,200);
  controlPanel.hideCoordinates();

  // make slider to control tolerance
  Controller toleranceSlider = controlP5.addSlider("tolerance",0,200,35,30,285,20);
  toleranceSlider.setWindow(controlPanel);

  // make button to open camera settings
  controlP5.addBang("viewCameraSettings",35,80,50,25);
  controlP5.controller("viewCameraSettings").setWindow(controlPanel);
  controlP5.controller("viewCameraSettings").setLabel("Settings"); 

  // make button to set background image
  controlP5.addBang("setBackground",115,80,50,25);
  controlP5.controller("setBackground").setWindow(controlPanel);
  controlP5.controller("setBackground").setLabel("Background");

  // make toggle to show/hide different(blue) pixels
  controlP5.addToggle("showDifferentPixels",true,195,80,70,25).setMode(ControlP5.SWITCH);
  controlP5.controller("showDifferentPixels").setWindow(controlPanel);
  controlP5.controller("showDifferentPixels").setLabel("Show Diff Pixels");

  // make toggle to show/hide target box
  controlP5.addToggle("showTargetBox",true,295,80,70,25).setMode(ControlP5.SWITCH);
  controlP5.controller("showTargetBox").setWindow(controlPanel);
  controlP5.controller("showTargetBox").setLabel("Show Target Box");

  // make toggle to select manual/auto mode
  controlP5.addToggle("controlMode",false,35,140,130,25).setMode(ControlP5.SWITCH);
  controlP5.controller("controlMode").setWindow(controlPanel);
  controlP5.controller("controlMode").setLabel("Autonomous    Manual");


  // make toggle to show/hide camera view
  controlP5.addToggle("showCameraView",true,295,140,70,25).setMode(ControlP5.SWITCH);
  controlP5.controller("showCameraView").setWindow(controlPanel);
  controlP5.controller("showCameraView").setLabel("Show Cam View");

  // make toggle to select firing mode
  controlP5.addToggle("firingMode",true,195,140,70,25).setMode(ControlP5.SWITCH);
  controlP5.controller("firingMode").setWindow(controlPanel);
  controlP5.controller("firingMode").setLabel("Semi    Auto");


  frame.setTitle("Camera View"); 
}

void mousePressed() {
  if(keyPressed && key == 'r') {
    print("constraints:" + mouseX + ", " + mouseY);
    fireRestrictedZones[restrictedZone][0] = mouseX;
    fireRestrictedZones[restrictedZone][2] = mouseY;
  }
}

void mouseReleased() {
  if(keyPressed && key == 'r') {
    println(" ... " + mouseX + ", " + mouseY);
    fireRestrictedZones[restrictedZone][1] = mouseX;
    fireRestrictedZones[restrictedZone][3] = mouseY;
    if(fireRestrictedZones[restrictedZone][1]>fireRestrictedZones[restrictedZone][0] && fireRestrictedZones[restrictedZone][1]>fireRestrictedZones[restrictedZone][2]) {
      restrictedZone++;
    }
  } 
}

public void viewCameraSettings() {
  theMov.settings();
}

public void setBackground() {
  theMov.adapt();
}

public void stop() {
  arduinoPort.write("z0000000");
  theMov.stop();
  super.stop();
}





