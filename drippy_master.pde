/*
 Memo Akten | www.memo.tv | 2008
 
 SPACE - clear screen
C - change screen clearing mode (CLEAR, FADE, ACCUMULATE)
B - branching mode (NO BRANCHING, SCARY, DRIPPY)
M - mouse mode ON/OFF (follows mouse or not)
S - toggle travel speed between FAST / SLOW
N - randomize number of branches
1 - 6 - Choose a preset of all above parameters and other numbers
1 - Bacteria
2 - Scary Branches
3 - Drippy Branches
4 - Lone Sperm
5 - Drippy Paint (use mouse to draw on canvas)
6 - Scary Paint (use mouse to draw on canvas)

Built with Processing

*/

/************************************* CONSTANTS ****************************************/
int CLEAR_MODE   = 0;
int CLEAR_NONE   = CLEAR_MODE++;
int CLEAR_CLEAR  = CLEAR_MODE++;
int CLEAR_FADE   = CLEAR_MODE++;
//char[][] ClearStates = ["Clear:None", "Clear: Clear", "Clear:Fade"]


int BRANCH_MODE   = 0;
int BRANCH_NONE   = BRANCH_MODE++;
int BRANCH_BRANCH = BRANCH_MODE++;
int BRANCH_DRIP   = BRANCH_MODE++;

int BGCOLOR = 255;
int MAX_CIRCLE_SIZE = 15;


/************************************* VARS ****************************************/
boolean bMouseMode = false;
float fHeadSpeed = 2;
float fNoiseSpeed = 1;
int iClearMode   = CLEAR_CLEAR;
int iBranchMode   = BRANCH_BRANCH;

int numBranches;
int numCircles;
BRANCH[] branches;
VECTORFIELD VectorField = new VECTORFIELD(2, 0.5, 1, 1);

/************************************* SETUP ****************************************/
void setup() {
  size(1280, 720);
  stroke(0);
  smooth();
  frameRate(60);
  Preset('2');
}

void Init(int nb, int nc) {
  numBranches = nb;
  numCircles = nc;
  branches = new BRANCH[numBranches];
  for(int i=0; i<numBranches; i++) branches[i] = new BRANCH(); 
  background(BGCOLOR);
}

void Preset(char c) {
  switch(c) {
  case '1':
    Init(100, 10);
    bMouseMode = false;
    fHeadSpeed = 5;
    fNoiseSpeed = 1;
    iClearMode = CLEAR_FADE;
    iBranchMode = BRANCH_NONE;
    break;

  case '2':
    Init(2, 500);
    bMouseMode = false;
    fHeadSpeed = 2;
    fNoiseSpeed = .1;
    iClearMode = CLEAR_NONE;
    iBranchMode = BRANCH_BRANCH;
    break;

  case '3':
    Init(2, 500);
    bMouseMode = false;
    fHeadSpeed = 2;
    fNoiseSpeed = 1;
    iClearMode = CLEAR_NONE;
    iBranchMode = BRANCH_DRIP;
    break;
  case '4':
    Init(1, 1000);
    bMouseMode = false;
    fHeadSpeed = 2;
    fNoiseSpeed = 1;
    iClearMode = CLEAR_CLEAR;
    iBranchMode = BRANCH_BRANCH;
    break;
  case '5':
    Init(1, 500);
    bMouseMode = true;
    fHeadSpeed = 2;
    fNoiseSpeed = 1;
    iClearMode = CLEAR_NONE;
    iBranchMode = BRANCH_DRIP;
    break;
  case '6':
    Init(1, 500);
    bMouseMode = true;
    fHeadSpeed = 2;
    fNoiseSpeed = 1;
    iClearMode = CLEAR_NONE;
    iBranchMode = BRANCH_BRANCH;
    break;
  }
}


/************************************* DRAW ****************************************/
void draw() {
  if(iClearMode == CLEAR_CLEAR ) {
    background(BGCOLOR);
  } 
  else if (iClearMode == CLEAR_FADE) {
      int branchLength = 1;
      if(frameCount % branchLength == 0) {    // if its time to clear frame, then clear frame
        fill(BGCOLOR, 5);
        rect(-1, -1, width+2, height+2);
      }
  } 

  for(int i=0; i<numBranches; i++) branches[i].draw();
}

/************************************* INPUT ****************************************/
void keyPressed() {
  switch(key) {
    
  case 'c':  // clear  mode   
    iClearMode = (++iClearMode) % CLEAR_MODE;  
    break;
  case 'b': // branch mode
    iBranchMode = (++iBranchMode) % BRANCH_MODE;
    println(iBranchMode);
    break;
  case 'm': //mouse mode
    bMouseMode = !bMouseMode;
    Init(1, 1000);
    break;
  case 's': 
    fHeadSpeed = 7 - fHeadSpeed;
    break;
  case 'n':
    float nb = random(1, 150);
    float nc = 1000/nb; 
    println("Branches: " + nb + " Circles: " + nc);
    Init((int)nb, int(nc));
    break;
  case '0':
  case '1':
  case '2':
  case '3':
  case '4':
  case '5':
  case '6':
  case '7':
  case '8':
  case '9':
    Preset(key); 
    break;
    
  case ' ': 
    background(BGCOLOR);
    break;
  }
}
/*
void mouseMoved() {
 float fAngle = VectorField(mouseX, mouseY, 0);
 println("Value: " + fAngle + " Angle: " + fAngle * 360 + " min: " + fNoiseMin + " max: " + fNoiseMax);
 }
 */
/************************************* BRANCH ****************************************/
class BRANCH {
  int curCircle = 0;
  CIRCLE[] circles = new CIRCLE[numCircles];
  float x, y, oldX, oldY;
  float vx, vy;
  float seed;

  BRANCH() {
    init();
  }

  void init() {
    oldX = x = random(0, width);
    oldY = y = random(0, height);
    vx = vy = 0;
    seed = random(10);
    for(int i=0; i<numCircles; i++) {
      circles[i] = new CIRCLE(0, 0, 0);
    }
  }

  void draw() {
    strokeWeight(1);
    if(bMouseMode) {
      if(mousePressed) {
        x = mouseX;
        y = mouseY;
        AddCircle(x, y);
      }
    } 
    else {
      if(x<0 || x >= width || y<0 || y>= height) init();
      if(x<0) x+=width;
      else if(x>width) x-=width;

      if(y<0) y+=height;
      else if(y>height) y-=height;


      float fAngle = VectorField.force(x,y, 0, 1, 1) * PI * 2;
      x += cos(fAngle) * fHeadSpeed;
      y += sin(fAngle) * fHeadSpeed;
      AddCircle(x, y);
    }

    for(int i=0; i<numCircles; i++) {
      if(circles[i].r>0.001) {
        circles[i].draw();
      }
    }

    oldX = x;
    oldY = y;
  }

  void AddCircle(float x, float y) {
    circles[curCircle].init(x, y, random(MAX_CIRCLE_SIZE));
    curCircle++;
    if(curCircle>=numCircles) curCircle = 0;
  }
}


/************************************* CIRCLE ****************************************/
class CIRCLE {
  float x, y, r;
  float rs;
  float rs2;
  float a;
  float fNoiseSpeed;
  int c;

  CIRCLE(float tx, float ty, float t_r) {
    init(tx, ty, t_r);
  }

  void init(float tx, float ty, float t_rx) {
    x = tx; 
    y = ty; 
    r = t_rx;
    a = 255;
    rs = random(0.7, 0.98);
    rs2 = sqrt(rs);
    fNoiseSpeed = random(0.5, 10);
    //   c = int(255 * VectorField(x, y, 0, 1, 1));
  }

  void draw() {
    r *= rs;
    a *= rs2;
    c = int(150 * VectorField.force(x, y, 0, 1, 1));
    stroke(c * a/255.0, a);
    fill(255, a);
    if(iBranchMode == BRANCH_DRIP) {
      y += 0.4 * sqrt(sqrt(sqrt(r)));
      x += random(-1, 1) * 0.5;
    } 
    else if(iBranchMode == BRANCH_BRANCH) {
      float fAngle = VectorField.force(x,y, 10, fNoiseSpeed, fNoiseSpeed) * PI * 2;
      x += cos(fAngle);
      y += sin(fAngle);

    }
    strokeWeight(1);
    ellipse(x, y, r, r);
  }
}

/************************************* VECTORFIELD ****************************************/
class VECTORFIELD {
  private float fNoiseMin, fNoiseMax;    // used for scaling values to white and black
  private float fScaleMult, fSpeedMult;
  private int iOctaves;
  private float fFallOff;
  
  VECTORFIELD(int to, float tf, float ts1, float ts2) {
    init( to, tf, ts1, ts2);
  }

  void init(int to, float tf, float ts1, float ts2) {
    float w = 500, h = 500;
    iOctaves = to;
    fFallOff = tf;
    fScaleMult = 0.01 * ts1;      // some good default values
    fSpeedMult = 0.0005 * ts2;
    fNoiseMin = 1;
    fNoiseMax = 0;
    noiseDetail(iOctaves, fFallOff);

    for(int x=0; x<w; x++) {
      for(int y=0; y<h; y++) {
        float c = noise(x * fScaleMult, y * fScaleMult);
        fNoiseMin = min(c, fNoiseMin);
        fNoiseMax = max(c, fNoiseMax);
      }
    }
  }

  float force(float x, float y, float z, float fScaleMultExtra, float fSpeedMultExtra) {
    float f = fScaleMult * fScaleMultExtra;
    float f2 = fSpeedMult * fSpeedMultExtra;
    noiseDetail(iOctaves, fFallOff);
    float c = map( noise(x*f, y*f, z + f2 * millis()), fNoiseMin, fNoiseMax, -0.2, 1.2);
    c = max(min(c, 1), 0);
    return c;
  }

}
