import JMyron.*;

int[] frame = new int[640*480];
JMyron theMov;

void setup() {
  size(640, 480);
  theMov = new JMyron();
  theMov.start(640, 480);
  theMov.findGlobs(0);
}

void draw() {
  background(0);
  theMov.update();
  frame = theMov.image();
  loadPixels();
  for (int i=0; i < width*height; i++) {
    pixels[i] = frame[i];
  }
  updatePixels();
}

void mouseClicked() {
  theMov.settings();
}

public void stop() {
  theMov.stop();
  super.stop();
}
