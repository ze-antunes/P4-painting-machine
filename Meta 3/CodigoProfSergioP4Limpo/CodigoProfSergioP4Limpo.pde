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

FFT fft;
AudioIn in;
int bands = 512;
float[] spectrum = new float[bands];

Capture video;
color trackColor = color (255, 0, 0);
float threshold = 750000;

void setup () {
  size (1080, 720, P3D);
  colorMode(RGB);
  smooth();

  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);

  in.start();

  fft.input(in);

  video = new Capture(this, width, height);
  video.start();
  trackColor = color(255, 0, 0);
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
  background(255);
  fill(0);
  text("frameRate:"+frameRate, width/2, 30, 0);
  video.loadPixels();

  X = map(mouseX, 0, width, 0, 1);
  Y = map(mouseY, 0, height, 0, 1);
  guardaX = X;
  guardaY = Y;

  pushMatrix();
  scale(-1, 1);
  translate(- width/2, - height/2);
  //image(video, 0, 0);

  float avgX = 0;
  float avgY = 0;

  int count = 0;
  ArrayList <PVector> arr = new ArrayList <PVector>();
  for (int i = 0; i < video.width; i+=1 ) {
    for (int j = 0; j < video.height; j+=1 ) {
      int loc = i + j * video.width;
      //float r1 = x >> 24 & 0xFF;
      float r = video.pixels[loc] >> 16 & 0xFF;
      float g = video.pixels[loc] >> 8 & 0xFF;
      float b = video.pixels[loc] & 0xFF;

      float dist = distSq(r, g, b, red(trackColor), green(trackColor), blue(trackColor)); 

      if (dist < sq(threshold)) {
        arr.add(new PVector (i, j, 1));
      } else {
        arr.add(new PVector (i, j, 0));
      }
    }
  }
  
  float averageX = 0, averageY = 0, c = 0;
  for (PVector v : arr) {
    if (v.z == 1) {
      averageX = averageX + v.x;
      averageY = averageY + v.y;
      c++;
    }

    if (c > 0) averageX = averageX / c;
    if (c > 0) averageY = averageY / c;
  }

  fill(0, 255, 0);
  ellipse (0, 0, 40, 40);

  if (count > 0) { 
    avgX = avgX / count;
    avgY = avgY / count;
    fill(trackColor);
    stroke(0);
  }
  popMatrix();

  if (savePDF) beginRecord(PDF, "data/" + FileName);
  if (saveSVG) beginRaw(SVG, "data/" + FileName);

  float z = 0;

  fft.analyze(spectrum);

  for (int i = 0; i < bands; i++) {
    z = spectrum[i]*height*100;
  } 
  
  float x = ax1 * sin(t * fx1 + X) * exp(-dx1 * X) + ax2 * sin(t * fx2 + X) * exp(-dx2 * X);
  float y = ay1 * sin(t * fy1+ Y) * exp(-dy1 * Y) + ay2 * sin(t * fy2 + Y) * exp(-dy2 * Y);

  //float x = ax1 * sin(t * fx1 + X) * exp(-dx1 * t) + ax2 * sin(t * fx2 + X) * exp(-dx2 * t);
  //float y = ay1 * sin(t * fy1+ Y) * exp(-dy1 * t) + ay2 * sin(t * fy2 + Y) * exp(-dy2 * t);

  points.add(new PVector(x, y, z));
  translate(width/2, height/2);
  noFill();

  beginShape();
  for (PVector v : points) {
    if (v.z >= 1) {
      strokeWeight(v.z);
    } else {
      strokeWeight(1);
    }
    stroke(0, 0, 0);
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
      println("Falhou conec????o");
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
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$td-%1$tm-%1$ty_%1$tH'%1$tM''%1$tS", now);
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
