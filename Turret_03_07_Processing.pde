/*
----------------TURRET VERSION 3 CODE V07---------------
 ========================================================
 Tobias Scharfenberg
 
 This version of the code is not autonomous. The user views the webcam image and uses the mouse to aim and fire.
 Calibration: see instructions below.
 
 Compatible with Arduino code "Turret_03_07".
 
 
 TODO:
 Add autonomy using background subtraction method - Need to feed this image back into JMyron for blob processing. how?  hijack() command?
 Get OpenCV and Processing.Video compatible webcam and program for it
 Add recording of Predator's laugh from Predator movie
 
 
 DEFAULT HOME POSITIONS:
 position     X-coord   Y-coord
 ----------------------------------
 center       75        80
 lower left   20        40
 lower right  130       40
 upper left   20        120
 upper right  130       120
 
 
 ATTACHMENT INSTRUCTIONS:
 attach x-axis standard servo to digital I/O pin 5
 attach y-axis standard servo to digital I/O pin 6
 attach normally open firing relay to digital I/O pin 7
 
 
 CALIBRATION:
 use mouse crosshairs to aim the gun at a point that is on the left edge of the video viewscreen. Press g.
 use mouse crosshairs to aim the gun at a point that is on the right edge of the video viewscreen. Press h.
 use mouse crosshairs to aim the gun at a point that is on the top edge of the video viewscreen. Press y.
 use mouse crosshairs to aim the gun at a point that is on the bottom edge of the video viewscreen. Press b.
 
 */

import JMyron.*;
import processing.serial.*;
Serial arduinoPort;
JMyron m;

//import ddf.minim.*;                 // If you want to play a recording of a machine gun when firing, then
//Minim minim;                        //  get a .wav file of a machine gun, name it machinegun.wav, and put
//AudioSnippet machineGun;            //  it into the sketch folder. Then uncomment all the sound lines.

int Targetx = 75;
int Targety = 80;
int fire;
float xMin = 40;                      // used for calibration. For a permanent calibration (lasts after stopping
float xMax = 120;                     //  the program) change these 4 floats to your calibrations.
float yMin = 40;                      //
float yMax = 120;                     //

String strTargetx;                    // used for serial sending
String strTargety;                    //
String strFire;                       //

float windowWidth = 320;
float windowHeight = 240;
float xRatio;
float yRatio;

void setup(){
  size(320,240);
  arduinoPort = new Serial(this, Serial.list()[2], 19200);      // start arduino communications

  m = new JMyron();                                             // start JMyron
  m.start(320,240);
  m.findGlobs(0);  
  m.update();      
  int[] img = m.image();
  loadPixels();         
  for(int i=0;i<320*240;i++){
    pixels[i] = img[i];      
  }                          
  updatePixels();            

  //  minim = new Minim(this);
  //  machineGun = minim.loadSnippet("machinegun.wav");
  //  machineGun.loop(1);

  xRatio = (windowWidth / (xMax - xMin));                        // used to allign sights with crosshairs on PC
  yRatio = (windowHeight/ (yMax - yMin));

}

void draw(){
  m.update();                              // draw new frame to screen
  int[] img = m.image();
  loadPixels();
  for(int i=0;i<320*240;i++){
    pixels[i] = img[i];
  }
  updatePixels();

  Targetx = int((mouseX/xRatio)+xMin);                 // calculate position to go to based on mouse position
  Targety = int(((240-mouseY)/yRatio)+yMin);
  strTargetx = "000" + str(Targetx);                   // make into 3-digit numbers
  strTargetx = strTargetx.substring(strTargetx.length()-3);
  strTargety = "000" + str(Targety);
  strTargety = strTargety.substring(strTargety.length()-3);
  println(strTargetx + "X      " + strTargety + "Y      " + str(fire) + 'F');
  arduinoPort.write(strTargetx + 'X' + strTargety + 'Y' + str(fire) + 'F');   // send to arduino in form: ###X###Y#F

  stroke(255,0,0);                     //draw crosshairs
  noFill();
  line(mouseX, 0, mouseX, 240);
  line(0, mouseY, 320, mouseY);
  ellipse(mouseX, mouseY, 20, 20);
  ellipse(mouseX, mouseY, 28, 22);
  ellipse(mouseX, mouseY, 36, 24);

  if(fire == 1) {
    fill(255, 0, 0);
    rect(300, 220, 20, 20);
//    machineGun.play();
//    machineGun.loop();
  }
//  else{
//    machineGun.pause();
//  }  
}

void mousePressed(){
  fire = 1;                 // fire if mouse is clicked
}
void mouseReleased(){
  fire = 0;                 // stop firing if mouse is released
}

void keyPressed(){
  if(key == 's'){
    m.settings();          // press 's' to change camera settings
  }
  if(key == ' '){
    fire = 1;              // fire if space bar is pressed
  }
  if(key == 'g'){          // the next four keys are for calibration. see instructions at top
    xMin = float(Targetx);
    xRatio = (windowWidth / (xMax - xMin));    // calculate new ratios
    yRatio = (windowHeight/ (yMax - yMin));    //
  }
  if(key == 'h'){
    xMax = float(Targetx);
    xRatio = (windowWidth / (xMax - xMin));
    yRatio = (windowHeight/ (yMax - yMin));
  }
  if(key == 'y'){
    yMax = float(Targety);
    xRatio = (windowWidth / (xMax - xMin));
    yRatio = (windowHeight/ (yMax - yMin));
  }
  if(key == 'b'){
    yMin = float(Targety);
    xRatio = (windowWidth / (xMax - xMin));
    yRatio = (windowHeight/ (yMax - yMin));
  }    
}

void keyReleased(){
  if(key == ' '){           // stop firing if space bar is released
    fire = 0;
  }
}

void stop(){
  m.stop();
//  machineGun.close();
//  minim.stop();
  super.stop();
}



