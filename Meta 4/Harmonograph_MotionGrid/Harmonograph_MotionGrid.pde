//LIBRARIES
import processing.pdf.*;
import processing.svg.*;
import processing.sound.*;
import processing.video.*;
import java.util.Calendar;
import java.net.HttpURLConnection;
import java.net.URL;
import java.lang.Thread;
import java.io.DataOutputStream;
import java.io.OutputStreamWriter;

//GLOBAL VARIAVELS
boolean savePDF = false;
boolean saveSVG = false;

float ax1 = 150;
float ax2 = 150;
float ay1 = 150;
float ay2 = 150;
float fx1 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
float fx2 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
float fy1 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
float fy2 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
float px1 = random(TWO_PI);
float px2 = random(TWO_PI);
float py1 = random(TWO_PI);
float py2 = random(TWO_PI);
float dx1 = random(0.005) + random(0.005);
float dx2 = random(0.005) + random(0.005);  
float dy1 = random(0.005) + random(0.005);
float dy2 = random(0.005) + random(0.005);
float t = 0.0;
float X;
float Y;

ArrayList<PVector> points = new ArrayList<PVector>();
String FileName;

FFT fft;
AudioIn in;
int bands = 512;
float[] spectrum = new float[bands];

Capture video;

int lastTimeCheck;
int timeIntervalFlag = 60000; // 60 seconds or 1 minute because we are working with millis
boolean timerSet = false;

float r, g, b;

PImage prevFrame;
float threshold = 50;
int col = 10;
int rows = 5;

void setup () {
  size (1080, 720, P3D);
  colorMode(RGB);
  smooth();

  // Frequencies
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  in.start();
  fft.input(in);

  // List of caremas avalable
  String[] cameras = Capture.list();
  //println(cameras[0]);

  video = new Capture(this, width, height, cameras[0]);
  video.start();

  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);

  lastTimeCheck = millis();
}

void captureEvent(Capture video) {
  video.read();
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();
}

void draw() {


  // You don't need to display it to analyze it!
  pushMatrix();
  translate(width/2, height/2);
  pushMatrix();
  scale(-1, 1);
  translate(- width/2, - height/2);
  image(video, 0, 0);

  background(255);

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

      // Compare colors (previous vs. current)
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

  float lado = (width/col);
  int coluna = (int)avgX / (int)lado;
  int linha = (int)avgY / (int)lado;
  println("Nº Coluna: " + coluna);
  println("Nº Linha: " + linha);

  X = coluna + ((width/col)/2);
  Y = linha + + ((height/rows)/2);

  popMatrix();
  popMatrix();

  //X = map(mouseX, 0, width, 0, 1);
  //Y = map(mouseY, 0, height, 0, 1);

  if (savePDF) beginRecord(PDF, "data/" + FileName);
  if (saveSVG) beginRaw(SVG, "data/" + FileName);

  //Analyzing the frequencies
  float z = 0;
  fft.analyze(spectrum);
  for (int i = 0; i < bands; i++) {
    z = spectrum[i]*height*100;
  }

  //Harmonograph math expression
  float x = ax1 * sin(t * fx1 + X) * exp(-dx1 * X) + ax2 * sin(t * fx2 + X) * exp(-dx2 * X);
  float y = ay1 * sin(t * fy1+ Y) * exp(-dy1 * Y) + ay2 * sin(t * fy2 + Y) * exp(-dy2 * Y);

  //Adding elements to the ArrayList
  points.add(new PVector(x, y, z));
  translate(width/2, height/2);
  noFill();

  //Drawing the shape
  beginShape();
  for (PVector v : points) {
    if (v.z >= 1) {
      strokeWeight(v.z);
    } else {
      strokeWeight(1);
    }
    stroke(r, g, b);
    vertex(v.x, v.y);
  }
  endShape();

  t = t + 0.05;

  if (savePDF) {
    savePDF = false;
    saveSVG = false;
    dispose();
    endRecord();
  }

  // After 1 minute, if there's no interaction from users
  // the program will print the drawing generated
  if ( millis() > lastTimeCheck + timeIntervalFlag ) {
    timerSet = true;
    lastTimeCheck = millis();
    FileName = timestamp()+".pdf";
    generatePDF(FileName);

    printJS();
  }


//  fill(0);
//  text("frameRate:"+frameRate, width/2, 30, 0);
//  text("frameRate:"+ lastTimeCheck, width/2, 50, 0);
}

void generatePDF (String name) {
  println ("generating:", name);
  PGraphics pdf = createGraphics (width, height, PDF, "data/" + name);

  pdf.beginDraw();
  pdf.translate(pdf.width/2, pdf.height/2);

  pdf.stroke(0);
  pdf.fill(0);

  for (int i=0; i<points.size()-1; i++) {
    PVector v = points.get(i);
    PVector v2 = points.get(i+1);
    pdf.strokeWeight(v.z);
    pdf.stroke(0, 0, 0);
    pdf.line(v.x, v.y, v2.x, v2.y);
  }
  pdf.dispose();
  pdf.endDraw();
}

void keyPressed() {
  if (key == ' ' || key == 32) {
    FileName = timestamp()+".pdf";
    generatePDF(FileName);

    printJS();
  }

  if (key == '1') {
  }
}

// Time stamp to use in Filename
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$td-%1$tm-%1$ty_%1$tH'%1$tM''%1$tS", now);
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

// Request to localhost => endpoint /print
void printJS() {
  try {
    Thread.sleep(100);
  } 
  catch(Exception e) {
  }

  try {
    String printer ="EPSON BX300F Series";
    String scale = "fit";

    URL url = new URL("http://localhost:3000/print?name=" + FileName + "&printer=" + printer.replace(" ", "%20") + "&scale=" + scale);

    println("Funciona");
    HttpURLConnection con = (HttpURLConnection) url.openConnection();
    con.setRequestMethod("GET");

    con.setReadTimeout(10);
    con.connect();
    con.getResponseCode();
    con.disconnect();
  }

  catch(Exception e) {
    println("Falhou conecção");
  }

  points.clear();

  ax1 = 150;
  ax2 = 150;
  ay1 = 150;
  ay2 = 150;
  fx1 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
  fx2 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
  fy1 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
  fy2 = int(5 * random(1) * random(1)) + 1 + 0.01 * randomGaussian();
  px1 = random(TWO_PI);
  px2 = random(TWO_PI);
  py1 = random(TWO_PI);
  py2 = random(TWO_PI);
  dx1 = random(0.005) + random(0.005);
  dx2 = random(0.005) + random(0.005);  
  dy1 = random(0.005) + random(0.005);
  dy2 = random(0.005) + random(0.005);
  t = 0.0;
}
