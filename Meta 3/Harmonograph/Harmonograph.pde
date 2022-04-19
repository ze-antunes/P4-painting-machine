import processing.pdf.*;
import processing.sound.*;
import java.util.Calendar;
import java.net.HttpURLConnection;
import java.net.URL;
import java.lang.Thread;
import java.io.DataOutputStream;
import processing.sound.*;


boolean savePDF = false;

float ax1 = 150;//width * 0.9 * (random(1) + random(1));
float ax2 = 150;//width * 0.9 * (random(1) + random(1));
float ay1 = 150;//height * 0.9 * (random(1) + random(1));
float ay2 = 150;//height * 0.9 * (random(1) + random(1));
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

AudioIn input;
Amplitude analyzer;

void setup () {

  size (1080, 720, P3D);
  colorMode(HSB);
  smooth();

  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);
}

void draw() {
  X = map(mouseX, 0, width, 0, 1);
  Y = map(mouseY, 0, height, 0, 1);
  guardaX = X;
  guardaY = Y;

  if (savePDF) beginRecord(PDF, "data/" + FileName);

  background(255);

  float vol = analyzer.analyze();
  float z = vol*100;
  //println(z);

  float x = ax1 * sin(t * fx1 + X) * exp(-dx1 * t) + ax2 * sin(t * fx2 + X) * exp(-dx2 * t);
  float y = ay1 * sin(t * fy1+ Y) * exp(-dy1 * t) + ay2 * sin(t * fy2 + Y) * exp(-dy2 * t);

  stroke(255);  
  points.add(new PVector(x, y, z));
  translate(width/2, height/2);
  noFill();

  //beginShape();
  for (PVector v : points) {
    //strokeWeight(v.z);
    int vert = (int) v.z;
    int shapeVert = (int) map( vert, 1, 10, 1, 10);
    println(shapeVert);

    drawShape(v.x, v.y, shapeVert, v.z);

    vertex(v.x, v.y);

    //if (guardaX != mouseX || guardaY != mouseY) {
    //  stroke(v.x, 255, 255);
    //  z += 0.1;
    //  if (z > 255) {
    //    z = 0;
    //  }
    //} else {
    //  stroke(0);
    //}
    stroke(0);
  }
  //endShape();

  t = t + 0.05;

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


void keyPressed() {
  if (key=='s' || key=='S') {
    saveFrame("data/" + timestamp() + ".png");
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

void drawShape(float x, float y, int vertices, float raio) {

  if (vertices == 0) {
    pushMatrix();
    beginShape();
    vertex(x, y);
    endShape();
    popMatrix();
  } else {
    pushMatrix();
    translate(x, y);

    beginShape(TRIANGLE_STRIP);

    for (int i = 0; i <= vertices; i++) {
      float angle = TWO_PI / vertices;
      float a = sin(i * angle) * (raio);
      float b = cos(i * angle) * (raio);

      vertex(a, b);
      vertex(a, b);
    }

    endShape();
    popMatrix();
  }
}
