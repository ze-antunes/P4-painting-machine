int col = 10;
int rows = 5;

import processing.video.*;

// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;

// How different must a pixel be to be a "motion" pixel
float threshold = 50;


void setup() {
  size (1080, 720);

  // Using the default capture device
  video = new Capture(this, width, height);
  video.start();

  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);
}

// New frame available from camera
void captureEvent(Capture video) {
  // Save previous frame for motion detection!!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();  
  video.read();
}

void draw() {
  background(255);

  // You don't need to display it to analyze it!
  pushMatrix();
  translate(width/2, height/2);
  pushMatrix();
  scale(-1, 1);
  translate(- width/2, - height/2);
  //image(video, 0, 0);


  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  // These are the variables we'll need to find the average X and Y
  float sumX = 0;
  float sumY = 0;
  int motionCount = 0; 

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      // What is the current color
      color current = video.pixels[x+y*video.width];

      // What is the previous color
      color previous = prevFrame.pixels[x+y*video.width];

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current);
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous);
      float b2 = blue(previous);

      // Motion for an individual pixel is the difference between the previous color and current color.
      float diff = dist(r1, g1, b1, r2, g2, b2);

      // If it's a motion pixel add up the x's and the y's
      if (diff > threshold) {
        sumX += x;
        sumY += y;
        motionCount++;
      }
    }
  }

  // average location is total location divided by the number of motion pixels.
  float avgX = sumX / motionCount; 
  float avgY = sumY / motionCount; 

  for (int i = 0; i < col; i++) {
    for (int j = 0; j < rows; j++) {
      noFill();
      strokeWeight(1);

      if ( i*width/col <= avgX && avgX <= (i+1)*width/col) {
        if ( j*height/rows <= avgY && avgY <= (j+1)*height/rows) {
          //fill(0, 255, 0);
          fill(0);
          ellipse(i*width/col + ((width/col)/2), j*height/rows + ((height/rows)/2), 20, 20);
          //println( "X =" + i*width/col);
          //println( "Y =" + j*height/rows);
        }
      }

      noFill();
      rect((width/col)*i, (height/rows)*j, width/col, height/rows);
    }
  }

  float lado = (width/col);

  int coluna = 9 -(int)avgX / (int)lado;
  int linha = (int)avgY / (int)lado;
  println("Nº Coluna: " + coluna);
  println("Nº Linha: " + linha);

  popMatrix();
  popMatrix();
}
