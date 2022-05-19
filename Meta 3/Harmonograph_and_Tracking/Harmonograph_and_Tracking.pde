import processing.pdf.*;
import processing.svg.*;
import processing.sound.*;
import processing.video.*;
import java.util.Calendar;
import java.net.HttpURLConnection;
import java.net.URL;
import java.lang.Thread;
import java.io.DataOutputStream;


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
float guardaX;
float guardaY;

ArrayList<PVector> points = new ArrayList<PVector>();
String FileName;

//AudioIn input;
//Amplitude analyzer;
FFT fft;
AudioIn in;
int bands = 512;
float[] spectrum = new float[bands];

Capture video;
color trackColor = color (0, 0, 0);
float threshold = 25;

void setup () {

  size (1080, 720, P3D);
  colorMode(RGB);
  smooth();


  //input = new AudioIn(this, 0);
  //input.start();
  //analyzer = new Amplitude(this);
  //analyzer.input(input);

  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);

  // start the Audio Input
  in.start();

  // patch the AudioIn
  fft.input(in);

  video = new Capture(this, width, height);
  video.start();
  trackColor = color(255, 0, 0);
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
  //background(255);
  fill(0);
  text("frameRate:"+frameRate, width/2, 30, 0);
  video.loadPixels();

  X = map(mouseX, 0, width, 0, 1);
  Y = map(mouseY, 0, height, 0, 1);
  guardaX = X;
  guardaY = Y;

  //if (frameCount%100 == 0) {

  pushMatrix();
  scale(-1, 1);
  translate(- width/2, - height/2);
  //image(video, 0, 0);

  threshold = 25;

  float avgX = 0;
  float avgY = 0;

  int count = 0;
  ArrayList <PVector> arr = new ArrayList <PVector>();
  // Begin loop to walk through every pixel
  for (int i = 0; i < video.width; i+=5 ) {
    for (int j = 0; j < video.height; j+=5 ) {
      int loc = i + j * video.width;
      //float r1 = x >> 24 & 0xFF;
      float r = video.pixels[loc] >> 16 & 0xFF;
      float g = video.pixels[loc] >> 8 & 0xFF;
      float b = video.pixels[loc] & 0xFF;

      float dist = distSq(r, g, b, red(trackColor), green(trackColor), blue(trackColor)); 
      if (dist < sq(threshold)) {
        arr.add(new PVector(avgX, avgY));
        avgX += i;
        avgY += j;
        count++;
      }

      //int g = x >> 8 & 0xFF;
      //int b = x & 0xFF;
      // What is current color
      /*color currentColor = video.pixels[loc];
       float r1 = red(currentColor);
       float g1 = green(currentColor);
       float b1 = blue(currentColor);
       float r2 = red(trackColor);
       float g2 = green(trackColor);
       float b2 = blue(trackColor);
       
       float d = distSq(r1, g1, b1, r2, g2, b2); 
       
       if (d < threshold*threshold) {
       stroke(255);
       strokeWeight(1);
       point(i, j);
       avgX += i;
       avgY += j;
       count++;
       }*/
    }
  }

  if (count > 0) { 
    avgX = avgX / count;
    avgY = avgY / count;
    // Draw a circle at the tracked pixel
    fill(trackColor);
    //strokeWeight(4.0);
    stroke(0);
    if (locX != -1 && locY != -1) {
      ellipse(locX, locY, 24, 24);
    }
  }
  popMatrix();
  //}

  if (savePDF) beginRecord(PDF, "data/" + FileName);
  if (saveSVG) beginRaw(SVG, "data/" + FileName);


  //float vol = analyzer.analyze();
  //float[] z = vol*50;
  //println(z);

  float z = 0;

  fft.analyze(spectrum);

  for (int i = 0; i < bands; i++) {
    // The result of the FFT is normalized
    // draw the line for frequency band i scaling it up by 5 to get more amplitude.
    z = spectrum[i]*height*50;
  } 

  float x = ax1 * sin(X * fx1 + X) * exp(-dx1 * X) + ax2 * sin(t * fx2 + X) * exp(-dx2 * X);
  float y = ay1 * sin(Y * fy1+ Y) * exp(-dy1 * Y) + ay2 * sin(t * fy2 + Y) * exp(-dy2 * Y);

  points.add(new PVector(x, y, z));
  translate(width/2, height/2);
  noFill();

  beginShape();
  for (PVector v : points) {
    strokeWeight(v.z);
    stroke(0, 0, 0);
    vertex(v.x, v.y);
  }
  endShape();

  t = t + 0.05;

  if (savePDF) {
    savePDF = false;
    saveSVG = false;
    //endRecord();
    dispose();
    // endRaw();
    //  endDraw();
    endRecord();
  }
}


void keyPressed() {
  //if (key=='s' || key=='S') {
  //  //saveFrame("data/" + timestamp() + ".png");
  //  FileName = timestamp()+".svg";
  //  saveSVG = true;

  //  try {
  //    Thread.sleep(100);
  //  } 
  //  catch(Exception e) {
  //  }

  //  try {
  //    URL url = new URL("http://localhost:3000/print?name=" + FileName);

  //    println("Funciona");
  //    HttpURLConnection con = (HttpURLConnection) url.openConnection();
  //    con.setRequestMethod("GET");
  //    con.setReadTimeout(10);
  //    con.connect();
  //    con.getResponseCode();
  //    con.disconnect();
  //  }

  //  catch(Exception e) {
  //    println("Falhou conecção");
  //  }
  //}

  if (key=='p' || key=='P') {
    FileName = timestamp()+".pdf";
    savePDF = true;

    generatePDF(FileName);

    try {
      Thread.sleep(100);
    } 
    catch(Exception e) {
    }

    try {
      URL url = new URL("http://localhost:3000/print?name=" + FileName);

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
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$td-%1$tm-%1$ty_%1$tH'%1$tM''%1$tS", now);
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
float locX = -1, locY = -1;
void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  locX= mouseX;
  locY = mouseY;
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
}

void generatePDF (String name) {
  //println ("generating:", millis());
  PGraphics pdf = createGraphics (width, height, PDF, "data/" + name);

  pdf.beginDraw();
  pdf.translate(pdf.width/2, pdf.height/2);
  // pdf.background(255,0,0);

  pdf.stroke(0);
  pdf.fill(0);

  for (int i=0; i<points.size()-1; i++) {
    PVector v = points.get(i);
    PVector v2 = points.get(i+1);
    pdf.strokeWeight(v.z);
    pdf.stroke(0, 0, 0);
    pdf.line(v.x, v.y, v2.x, v2.y);
    // pdf.beginShape();
    // pdf.vertex(v.x, v.y);
    // pdf.strokeWeight(v.z);
    // println ("v.z", v.z);
    // pdf.ellipse(v.x, v.y, v.z, v.z);
    // pdf.endShape();
  }
  pdf.dispose();
  pdf.endDraw();
}
