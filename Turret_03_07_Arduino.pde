/*
----------------TURRET VERSION 3 CODE V07---------------
========================================================
Tobias Scharfenberg
 
 For upload onto arduino board
 
 This version of the code is not autonomous. The user views the webcam image and uses the mouse to aim and fire.
 
 Compatible with Processing Code "Turret_03_07".
 
ATTACHMENT INSTRUCTIONS:
 attach x-axis standard servo to digital I/O pin 5
 attach y-axis standard servo to digital I/O pin 6
 attach normally open firing relay to digital I/O pin 7

*/

#include <Servo.h>

Servo pan;                            // x axis servo
Servo tilt;                           // y axis servo
int xPosition = 75;
int yPosition = 80;
int fire = 0;                         // if 1, fire; else, don't fire
char buff[]= "00000000000";           // store incoming serial bytes
int serialCounter = 0;                // how many frames scince last serial byte was available
int serialTimeout = 10000;            // max number of frames without incoming serial before going back to idle mode

void setup(){
  pan.attach(5);
  tilt.attach(6);
  pinMode(13, OUTPUT);                // serial status LED
  pinMode(7, OUTPUT);                 // firing transistor/relay
  Serial.begin(19200);
}

void loop() {   
  if (Serial.available()>0) {
    serialCounter = 0;

    for (int i=0; i<10; i++) {     
      buff[i]=buff[i+1];            // move each serial buffer byte down one space
    }
    buff[10]=Serial.read();         // add new serial byte to end of buffer

    if (buff[10]=='X' && buff[6] == 'F') {   // check for indicators
      xPosition = (100*(int(buff[7])-48)) + (10*(int(buff[8])-48)) + (int(buff[9])-48);  // previous values are coords
    }
    if (buff[10]=='Y' && buff[6] == 'X') {
      yPosition = (100*(int(buff[7])-48)) + (10*(int(buff[8])-48)) + (int(buff[9])-48);
    }
    if (buff[10]=='F' && buff[8] == 'Y') {
      fire = int(buff[9]) - 48;
    }

    pan.write(xPosition);                // send instructions to servos
    tilt.write(yPosition);

    if(fire == 1) {
      digitalWrite(7, HIGH);             // firing relay
    }
    else{
      digitalWrite(7, LOW);
    }

  }
  else{
    serialCounter++;                     // timeout check (safety feature)

    if(serialCounter > serialTimeout) {  // go into idle mode after serial counter timeout
      pan.write(75);
      tilt.write(150);
      digitalWrite(7, LOW);
      serialCounter = serialTimeout+1;

    }
    else{                               // if just a momentary pause:
      pan.write(xPosition);             // continue with previous actions
      tilt.write(yPosition);
      if(fire == 1) {
        digitalWrite(7, HIGH);
      }
      else{
        digitalWrite(7, LOW);
      }
    }
  }
}



