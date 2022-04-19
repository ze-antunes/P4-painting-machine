import processing.pdf.*;
import java.util.Calendar;

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
float z;
float guardaX;
float guardaY;

ArrayList<PVector> points = new ArrayList<PVector>();


void setup () {

  size (1080, 720, P3D);
  colorMode(HSB);
  smooth();

  z = 0;
}

void draw() {
  X = map(mouseX, 0, width, 0, 1);
  Y = map(mouseY, 0, height, 0, 1);
  guardaX = X;
  guardaY = Y;
  if (savePDF) beginRecord(PDF, "data/" + timestamp()+".pdf");

  background(0);

  float x = ax1 * sin(t * fx1 + X) * exp(-dx1 * t) 
    + 
    ax2 * sin(t * fx2 + X) * exp(-dx2 * t);

  float y = ay1 * sin(t * fy1 + Y) * exp(-dy1 * t)
    +
    ay2 * sin(t * fy2 + Y) * exp(-dy2 * t);

  points.add(new PVector(x, y, z));

  translate(width/2, height/2);


  noFill();

  beginShape();
  for (PVector v : points) {
    //v = points.get(points.size()-1);
    //print(points.get(points.size()-1));

    vertex(v.x, v.y);
    vertex(points.get(points.size()-1).x, points.get(points.size()-1).y);
    if (guardaX != mouseX || guardaY != mouseY) {
      stroke(v.z, 255, 255);
      z += 0.1;
      if (z > 255) {
        z = 0;
      }
    } else {
      stroke(0);
    }
  }

  endShape();

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
  if (key=='p' || key=='P') savePDF = true;
  if (key == '1') {
    println("hello");
  stroke(255,255,0);
  }
  
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$td-%1$tm-%1$ty_%1$tH'%1$tM''%1$tS", now);
}
