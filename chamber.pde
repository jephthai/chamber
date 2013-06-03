import java.util.Collections;
import javax.swing.*;

float SCALE = 1;
float WALLSTROKE = 0.003;
float RUNOUT = 0; //1;
Point bulletP = new Point(1.4486668 - 0.025, 0, "Bullet");
Point caseP = new Point(0,0,"Case");

boolean showHandles = true;

class Handle {
  ArrayList<Point> points = new ArrayList<Point>();
  float diam = 0.04;
  float y;
  
  public Handle(float elev) {
    this.y = elev;
  }
  
  void add(Point p) {
    points.add(p);
  }
  
  boolean hover() {
    PVector p1 = new PVector(mouseX, mouseY);
    PVector p2 = new PVector(screenX(points.get(0).x, y), screenY(points.get(0).x, y));
    p1.sub(p2);
    return p1.mag() < (diam / 2.0 * SCALE);
  }
  
  void move(float amount) {
    for(Point p : points) {
      p.x -= amount;
    }
  }

  void draw() {
    fill(128,hover() ? 255 : 192,128);
    stroke(0);
    ellipse(points.get(0).x,y,diam,diam);
    line(points.get(0).x-diam*0.2, y, points.get(0).x+diam*0.2, y);
  }
}

class Point {
  float x, y;
  String name;

  public Point(float x, float y, String name) {
    this.x = x;
    this.y = y;
    this.name = name;
  }
}

class Spec {
  public ArrayList<Point> points = new ArrayList<Point>();
  float maxx = 0;
  float maxy = 0;
  String name;
  color col = color(64, 64, 64, 64);

  public Spec(String name) {
    this.name = name;
  }

  public void add(Point p) {
    points.add(p);
    if (p.x > maxx) maxx = p.x;
    if (p.y > maxy) maxy = p.y;
  }

  void exaggerate(float factor) {
    for(Point p : points) p.y -= factor;
  }

  float length() {
    return maxx;
  }

  float width() {
    return maxy;
  }

  void wall(Point p1, Point p2) {
    strokeWeight(WALLSTROKE);
    stroke(0);
    line(p1.x, p1.y/2.0, p2.x, p2.y/2.0);
    line(p1.x, -p1.y/2.0, p2.x, -p2.y/2.0);
  }

  void section(Point p) {
    stroke(0, 0, 255, 64);
    strokeWeight(0.007);
    line(p.x, p.y/2.0, p.x, -p.y/2.0);

    pushMatrix();
    translate(p.x, 0.8 * width());
    rotate(PI/2.0);
    scale(1 / SCALE);
    fill(0, 128, 0);
    textSize(16);
    textAlign(LEFT, CENTER);
    text(p.name, 0, 0);
    popMatrix();
  }

  void heading() {
    pushMatrix();
    translate(length() / 2.0, -width());
    scale(1 / SCALE);
    textAlign(CENTER, CENTER);
    fill(0, 128, 0);
    textSize(32);
    text(name, 0, 0);
    popMatrix();
  }

  void draw(boolean sections) {
    stroke(0, 0, 255);
    if (sections) section(points.get(0));
    heading();    
    for (int x = 0; x < points.size() - 1; x++) {
      Point p1 = points.get(x);
      Point p2 = points.get(x+1);
      if (sections) section(p2);
      wall(p1, p2);
    }
  }

  void poly() {
    strokeWeight(WALLSTROKE);
    stroke(0);
    fill(col);
    beginShape();
    for (Point p : points) vertex(p.x, -p.y/2.0);
    Collections.reverse(points);
    for (Point p : points) vertex(p.x, p.y/2.0);
    Collections.reverse(points);
    vertex(points.get(0).x, -points.get(0).y/2.0);    
    endShape();
    textAlign(CENTER, CENTER);
    fill(0);
    pushMatrix();
    translate(length() / 3.0, 0);
    scale(1/SCALE);
    textSize(32);
    fill(0, 0, 0, 96);
    text(name, 0, 0);
    popMatrix();
  }  

  void ipoly() {
    stroke(0);
    strokeWeight(WALLSTROKE);
    fill(col);
    beginShape();
    for (Point p : points) vertex(p.x, -p.y/2.0);
    vertex(points.get(0).x, -points.get(0).y/2.0);
    endShape();
    beginShape();
    for (Point p : points) vertex(p.x, p.y/2.0);
    vertex(points.get(0).x, points.get(0).y/2.0);
    endShape();
  }
  
  void isections() {
    float lastX = -1;
    stroke(0,0,0,64);
    for(Point p : points) {
      if(p.x - lastX > 0.01) {
        line(p.x, p.y/2, p.x, points.get(0).y/2);
        line(p.x, -p.y/2, p.x, -points.get(0).y/2);
        lastX = p.x;
      }
    }
  }
}

Spec bullet;
Spec chamber;
Spec cartridge;
ArrayList<Handle> handles;
Handle currentHandle;

void mousePressed() {
  currentHandle = null;
  coords();
  for(Handle h : handles) {
    if(h.hover()) {
      currentHandle = h;
    }
  }
  popMatrix();
}

void keyTyped() {
  if(key == 's') {
    JFileChooser fc = new JFileChooser();
    if(fc.showSaveDialog(this) == JFileChooser.APPROVE_OPTION) {
      showHandles = false;
      draw();
      showHandles = true;
      saveFrame(fc.getSelectedFile().getPath());
    }
  }
}

void mouseReleased() {
  if(currentHandle != null) currentHandle = null;
}

void setup() {
  size(1600, 800);
  frame.setResizable(true);
  smooth();
  cartridge = new Spec("308 Winchester");
  cartridge.add(new Point(0, 0.409, ""));
  cartridge.add(new Point(0.015, 0.473, "Head"));
  cartridge.add(new Point(0.054, 0.473, ""));
  cartridge.add(new Point(0.054, 0.409, ""));
  cartridge.add(new Point(0.109, 0.409, "Rim"));
  cartridge.add(new Point(0.14, 0.473, "")); 
  cartridge.add(new Point(1.5598, 0.454, "Shoulder"));
  cartridge.add(new Point(1.7116, 0.3435, "Neck"));
  cartridge.add(new Point(2.015, 0.3435, "Mouth"));
  cartridge.add(new Point(2.015, 0.308, ""));

  chamber = new Spec("");
  chamber.add(new Point(0, 1, ""));
  chamber.add(new Point(0, 0.4738, ""));
  chamber.add(new Point(0.2, 0.4714, ""));
  chamber.add(new Point(1.5542, 0.4551, ""));
  chamber.add(new Point(1.7039, 0.3462, ""));
  chamber.add(new Point(2.025, 0.3462, ""));
  chamber.add(new Point(2.0488, 0.310, ""));
  chamber.add(new Point(2.1388, 0.310, ""));
  chamber.add(new Point(2.3025, 0.308, ""));
  chamber.add(new Point(2.3025, 0.299, ""));
  chamber.add(new Point(3, 0.299, ""));
  chamber.add(new Point(3, 1, ""));

  bullet = new Spec("190 VLD");
  bullet.add(new Point(0, 0.23, ""));
  bullet.add(new Point(0.015, 0.26, ""));
  bullet.add(new Point(0.176, 0.308, ""));
  bullet.add(new Point(0.646, 0.308, ""));
  bullet.add(new Point(1.000, 0.236, ""));
  bullet.add(new Point(1.195, 0.175, ""));
  bullet.add(new Point(1.386, 0.073, ""));

  cartridge.exaggerate(0.015);
  bullet.exaggerate(0.00);
  chamber.exaggerate(0);

  cartridge.col = color(192, 255, 192, 128);
  bullet.col    = color(255, 192, 192, 128);
  chamber.col   = color(192, 192, 255, 128);

  handles = new ArrayList<Handle>();
  Handle landH = new Handle(-chamber.width()/2.0);
  landH.add(chamber.points.get(8));
  landH.add(chamber.points.get(9));
  handles.add(landH);  
  
  Handle freeboreH = new Handle(-chamber.width()/2.0);
  freeboreH.add(chamber.points.get(7));
  handles.add(freeboreH);
  
  Handle bulletH = new Handle(0);
  bulletH.add(bulletP);
  handles.add(bulletH);

  Handle caseH = new Handle(0);
  caseH.add(caseP);
  handles.add(caseH);
  
  Handle shoulderH = new Handle(-cartridge.points.get(6).y/2.0 + 0.03);
  shoulderH.add(cartridge.points.get(6));
  shoulderH.add(cartridge.points.get(7));
  handles.add(shoulderH);
  
  Handle casemouthH = new Handle(-cartridge.points.get(8).y/2.0 + 0.03);
  casemouthH.add(cartridge.points.get(8));
  casemouthH.add(cartridge.points.get(9));
  handles.add(casemouthH);
  
  Handle mouthH = new Handle(-chamber.width()/2.0);
  mouthH.add(chamber.points.get(5));
  mouthH.add(chamber.points.get(6));
  handles.add(mouthH);
  
  Handle chamberShoulderH = new Handle(-chamber.width()/2.0);
  chamberShoulderH.add(chamber.points.get(3));
  chamberShoulderH.add(chamber.points.get(4));
  handles.add(chamberShoulderH);
}

void coords() {
  pushMatrix();
  translate(width/2, height/2);
  scale(SCALE);
  translate(-chamber.length() / 2.0, 0);
}

void draw() {
  SCALE = width / (chamber.length() / 0.9);

  background(255, 255, 224);
  stroke(0);
  strokeWeight(0.007);

  coords();

  if(currentHandle != null) {
    currentHandle.move(-(mouseX - pmouseX) / SCALE);
  }

  noStroke();
  fill(0,0,0,48);
  rect(0,-chamber.width()/2.0, chamber.length(), chamber.width());
  stroke(0,0,0,32);
  line(0,0,chamber.length(),0);
  chamber.ipoly();
  chamber.isections();

  //if(mousePressed) bulletP.x = ((mouseX - 0.05*width) / SCALE); // - bullet.length()/2.0;
  if(bulletP.x < 0) bulletP.x = 0;
  if(bulletP.x > cartridge.length()) bulletP.x = cartridge.length();
  pushMatrix();
  translate(bulletP.x + bullet.length()/3.0, 0); 
  rotate(radians(RUNOUT));
  translate(-bullet.length()/3.0, 0);
  bullet.poly();
  popMatrix();

  pushMatrix();
  translate(caseP.x, caseP.y);
  cartridge.poly();
  popMatrix();

  // Show handles for dragging items in the display
  if(showHandles) {
    for(Handle h : handles) {
      h.draw();
    }
  }
  
  popMatrix();
  textAlign(CENTER, BOTTOM);
  textSize(24);
  fill(255, 128, 0, 255);
  text("Chamber v0.9, Rifle Simulator\nhttp://github.com/jephthai/chamber/", width/2, height/2.0 - chamber.width()*0.5*SCALE - 20);
  
  fill(0);
  float coal = -caseP.x + bulletP.x + bullet.length();
  float cbto = -caseP.x + bulletP.x + bullet.points.get(3).x;
  float land = chamber.points.get(9).x;
  float jump = land - cbto;
  float shou = cartridge.points.get(7).x;
  textSize(13);
  textAlign(CENTER, TOP);
  String display = String.format("COAL: %.3f\nCBTO: %.3f\nJump: %.3f\nBase: %.3f", 
    coal, cbto, jump, bulletP.x);
  text(display, 0.33 * width, height/2.0 + chamber.width()*0.5*SCALE + 20);
  display = String.format("Lands: %.3f\nMouth: %.3f\nShoulder: %.3f\nRunout: %.0f deg", 
    land, cartridge.length(), shou, RUNOUT);
  text(display, 0.66 * width, height/2.0 + chamber.width()*0.5*SCALE + 20);
}

