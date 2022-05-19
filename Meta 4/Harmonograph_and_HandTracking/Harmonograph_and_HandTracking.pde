//LIBRARIES
import processing.pdf.*;
import processing.sound.*;
import processing.video.*;
import processing.javafx.*;
import java.util.Calendar;
import java.net.HttpURLConnection;
import java.net.URL;
import java.lang.Thread;
import java.io.DataOutputStream;
import java.io.OutputStreamWriter;

import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;

//GLOBAL VARIABLES
boolean savePDF = false;

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

DeepVision vision = new DeepVision(this);
SSDMobileNetwork network;
ResultList<ObjectDetectionResult> detections;

int lastTimeCheck;
int timeIntervalFlag = 60000; // 60 seconds or 1 minute because we are working with millis
boolean timerSet = false;

float r, g, b;

void setup () {
  size (1080, 720, P3D);
  colorMode(RGB);
  smooth();

  // Frequencies
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  in.start();
  fft.input(in);

  // Creating network
  network = vision.createHandDetector();

  // Loading model
  network.setup();
  network.setConfidenceThreshold(0.5);

  // List of caremas avalable
  String[] cameras = Capture.list();

  video = new Capture(this, width, height, cameras[0]);
  video.start();

  // Last millisecond recorded
  lastTimeCheck = millis();
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {

  pushMatrix();
  translate(width/2, height/2);
  pushMatrix();
  scale(-1, 1);
  translate(- width/2, - height/2);
  image(video, 0, 0);
  popMatrix();
  popMatrix();

  background(255);
  video.loadPixels();

  // Hand Detection
  detections = network.run(video);

  // If there's only one hand detected
  // the X and Y variables will become the x and y coordinates for the detection
  if (detections.size() == 1) {
    for (ObjectDetectionResult detection : detections) {
      X = detection.getX();
      Y = detection.getY();
    }
  }

  if (savePDF) beginRecord(PDF, "data/" + FileName);

  // Analyzing the frequencies
  float z = 0;
  fft.analyze(spectrum);
  for (int i = 0; i < bands; i++) {
    z = spectrum[i]*height*100;
  }

  // Harmonograph math expression
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

  //Clean the elements from the ArrayList
  points.clear();

  //Resetting the variables to use in the Harmonograph expression
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
