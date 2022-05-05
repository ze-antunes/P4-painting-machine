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

PVector C1, C2;

AudioIn input;
Amplitude analyzer;

Capture video;
color trackColor;
float threshold = 25;

void setup () {

  size (1080, 720, P3D);
  colorMode(RGB);
  smooth();


  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);

  video = new Capture(this, width, height);
  video.start();
  trackColor = color(255, 0, 0);
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
  X = map(mouseX, 0, width, 0, 1);
  Y = map(mouseY, 0, height, 0, 1);
  guardaX = X;
  guardaY = Y;

  if (savePDF) beginRecord(PDF, "data/" + FileName);
  if (saveSVG) beginRaw(SVG, "data/" + FileName);

  background(255);
  video.loadPixels();

  float vol = analyzer.analyze();
  float z = vol*50;
  //println(z);

  float x = ax1 * sin(t * fx1 + X) * exp(-dx1 * t) + ax2 * sin(t * fx2 + X) * exp(-dx2 * t);
  float y = ay1 * sin(t * fy1+ Y) * exp(-dy1 * t) + ay2 * sin(t * fy2 + Y) * exp(-dy2 * t);

  points.add(new PVector(x, y, z));
  translate(width/2, height/2);
  noFill();

  //beginShape();
  for (PVector v : points) {
    //strokeWeight(v.z);
    //stroke(0, 0, 0);
    //vertex(v.x, v.y);
    println(v.x + " -- " + (v.get()));
    C1 = new PVector(v.x, v.y);
    C2 = new PVector(v.x-1, v.y-1);
    bresenhamAlg(C1, C2, color(255, 255, 0));
  }
  //endShape();

  t = t + 0.05;

  //if (frameCount%100 == 0) {

  pushMatrix();
  scale(-1, 1);
  translate(- width/2, - height/2);
  image(video, 0, 0);

  threshold = 25;

  float avgX = 0;
  float avgY = 0;

  int count = 0;

  // Begin loop to walk through every pixel
  for (int i = 0; i < video.width; i++ ) {
    for (int j = 0; j < video.height; j++ ) {
      int loc = i + j * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
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
      }
    }
  }

  if (count > 0) { 
    avgX = avgX / count;
    avgY = avgY / count;
    // Draw a circle at the tracked pixel
    fill(trackColor);
    //strokeWeight(4.0);
    stroke(0);
    ellipse(avgX, avgY, 24, 24);
  }
  popMatrix();
  //}

  if (savePDF) {
    savePDF = false;
    endRecord();
  }

  if (saveSVG) {
    saveSVG = false;
    endRaw();
  }
}


void keyPressed() {
  if (key=='s' || key=='S') {
    saveFrame("data/" + timestamp() + ".png");
    FileName = timestamp()+".svg";
    saveSVG = true;

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

  if (key=='p' || key=='P') {
    FileName = timestamp()+".pdf";
    savePDF = true;

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

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
}

void bresenhamAlg(PVector C1, PVector C2, color a) {
  stroke(a);
  float m_new = 2 * (C2.y - C1.y);
  float slope_error_new = m_new - (C2.x - C1.x);

  for (float x = C1.x, y = C1.y; x <= C2.x; x++)
  {
    println("(" +x + "," + y + ")\n");

    // Add slope to increment angle formed
    slope_error_new += m_new;

    // Slope error reached limit, time to
    // increment y and update slope error.
    if (slope_error_new >= 0)
    {
      y++;
      slope_error_new -= 2 * (C2.x - C1.x);
    }
  }
}
