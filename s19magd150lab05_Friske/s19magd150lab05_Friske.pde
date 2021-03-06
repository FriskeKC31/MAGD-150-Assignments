Time time;
Information info;
PVector mouse;
ArrayList<Color> colors;
ArrayList<String> names;
boolean cButtonHoldsColor = true;

CircleButton cButton;
RectButton rButton;

float timeElapsed = 0;
float guessTime = 3.0;
double score = 0;

void setup()
{
  time = new Time();
  frameRate(60);
  size(768, 768);
  FillMapping();
  SetInfomation();
  score = 0;
}

void FillMapping()
{
  colors = new ArrayList<Color>();
  names = new ArrayList<String>();
  put("Red", new Color(255, 0, 0));
  put("Green", new Color(0, 255, 0));
  put("Blue", new Color(0, 0, 255));
  put("Teal", new Color(0, 255, 255));
  put("Yellow", new Color(255, 192, 0));
  put("Orange", new Color(255, 92, 0));
  put("Turquoise", new Color(0, 255, 128));
  put("Purple", new Color(192, 0, 255));
  put("Brown", new Color(92, 32, 0));
}

void put(String s, Color c)
{
  names.add(s);
  colors.add(c);
}

void SetInfomation()
{
  String name = "Dimension #" +  (char)int(random(65, 91));
  for(int i= 0; i < 3; i++)
    name += int(random(0, 9));
    
  int cIndex = 0;
  int nIndex = 0;
  while(cIndex == nIndex)
  {
    cIndex = int(random(0, colors.size()));
    nIndex = int(random(0, names.size()));
  }
  
  boolean nC = true;
  if(int(random(0, 2)) == 0)
    nC = false;
    
  info = new Information(name, cIndex, nIndex, nC); 
  
  cButtonHoldsColor = true;
  if(int(random(0, 2)) == 0)
    cButtonHoldsColor = false;
    
  Color c = colors.get(cIndex);
  Color overC = new Color(c.r / 2, c.g / 2, c.b / 2);
  Color n = colors.get(nIndex);
  Color overN = new Color(n.r / 2, n.g / 2, n.b / 2);
  PVector cPos = new PVector(width/2, height/2);
  PVector rPos = new PVector(width/2, height/2);
  while(PVector.dist(cPos, rPos) < 128)
  {
    cPos = new PVector(width/2 + int(random(-128, 128)), height/2 + int(random(-128, 128)));
    rPos = new PVector(width/2 + int(random(-128, 128)), height/2 + int(random(-128, 128)));
  }
  if(cButtonHoldsColor)
  {
    cButton = new CircleButton(cPos, 96, names.get(cIndex), c, overC);
    rButton = new RectButton(rPos, new PVector(128, 64), names.get(nIndex), n, overN);
  }
  else
  {
    cButton = new CircleButton(cPos, 96, names.get(nIndex), n, overN);
    rButton = new RectButton(rPos, new PVector(128, 64), names.get(cIndex), c, overC);
  }
}

void draw()
{
  background(0);
  Color nCol = colors.get(info.nIndex);
  noStroke();
  fill(nCol.r, nCol.g, nCol.b, 32);
  rectMode(CORNER);
  rect(0, 0, width, height);
  mouse = new PVector(mouseX, mouseY);
  
  time.Update();
  timeElapsed += time.deltaTime;
  if(timeElapsed > guessTime)
  {
        println("FAIL");
        exit();
  }
  
  DrawInfomation();
  
  fill(255);
  textSize(32);
  text("SCORE: " + score, width/2, height - 32);
}

void DrawInfomation()
{
  Color col = colors.get(info.cIndex);
  String cName = names.get(info.nIndex);
  float percent = constrain(timeElapsed / guessTime, 0, 1);
  
  noStroke();
  fill(col.r / 4, col.g / 4, col.b / 4);
  arc(width/2, height/2, width * 2f, height * 2f, -HALF_PI, (2 * PI * percent)-HALF_PI);
  
  fill(255);
  textSize(24);
  textAlign(CENTER);
  text(info.dName + " : " + ((info.namedColor) ? "NAME" : "COLOR"), width/2, 128);
  
  textSize(64);
  fill(col.r, col.g, col.b);
  text(cName, width/2, 96);
  
  cButton.Draw();
  rButton.Draw();
}

void mousePressed()
{
  if(cButtonHoldsColor)
  {
    if(cButton.MouseOver())
    {
      if(info.namedColor)
        Fail();
      else
        Correct();
    }
    if(rButton.MouseOver())
    {
      if(info.namedColor)
        Correct();
      else
        Fail();
    }
  }
  else
  {
    if(rButton.MouseOver())
    {
      if(info.namedColor)
        Fail();
      else
        Correct();
    }
    if(cButton.MouseOver())
    {
      if(info.namedColor)
        Correct();
      else
        Fail();
    }
  }
}

void Fail()
{
  println("FAIL : " + score);
  exit();
}

void Correct()
{
    int add = int(500 / guessTime);
    add -= int(50 * timeElapsed);
    score += add;
    guessTime *= 0.95;
    guessTime = constrain(guessTime, 1, 3);
    timeElapsed = 0;
    SetInfomation();
    println("CORRECT : " + score);
}

public class Information
{
  public String dName;
  public int cIndex;
  public int nIndex;
  public boolean namedColor = false;
  
  public Information(String name, int c, int cName, boolean nC)
  {
    dName = name;
    cIndex = c;
    nIndex = cName;
    namedColor = nC;
  }
}

public class Time
{
  int lastTime = 0;
  int delta = 0;
  public float deltaTime = 0;

  public Time()
  {
  }

  public void Update()
  {
    delta = millis() - lastTime;
    lastTime = millis();  
    deltaTime = (delta / 1000.0);
  }
}

public class RectButton
{
  public PVector pos;
  public PVector size;
  public String text;
  public Color bCol;
  public Color overCol;
  
  public RectButton()
  {
    pos = new PVector(0, 0);
    size = new PVector(96, 32);
  }
  
  public RectButton(PVector p, PVector s, String t, Color c, Color over)
  {
    pos = p;
    size = s;
    text = t;
    bCol = c;
    overCol = over;
  }
  
  public boolean MouseOver()
  {
    return (abs(mouse.x - pos.x) <= (size.x / 2) && abs(mouse.y - pos.y) <= (size.y / 2));
  }

  public void Draw()
  {
    Color col = (MouseOver()) ? overCol : bCol;
    
    stroke(0);
    strokeWeight(4);
    fill(col.r, col.g, col.b);
    rectMode(CENTER);
    rect(pos.x, pos.y, size.x, size.y);
    
    fill(0);
    textSize(size.y / 2);
    textAlign(CENTER);
    text(text, pos.x, pos.y + (size.y / 8));
  }
}

public class CircleButton
{
  public PVector pos;
  public float size;
  public String text;
  public Color bCol;
  public Color overCol;
  
  public CircleButton()
  {
    pos = new PVector(0, 0);
    size = 16;
    text = "Button";
    bCol = new Color(255);
  }
  
  public CircleButton(PVector p, float s, String t, Color c, Color over)
  {
    pos = p;
    size = s;
    text = t;
    bCol = c;
    overCol = over;
  }
  
  public boolean MouseOver()
  {
    return (PVector.dist(mouse, pos) <= (size / 2));
  }
  
  public void Draw()
  {
    Color col = (MouseOver()) ? overCol : bCol;
    
    stroke(0);
    strokeWeight(4);
    fill(col.r, col.g, col.b);
    ellipse(pos.x, pos.y, size, size);
    
    fill(0);
    textSize(size / 4);
    textAlign(CENTER);
    text(text, pos.x, pos.y + (size / 16));
  }
}

public class Color
{
  public int r;
  public int g;
  public int b;
  
  public Color()
  {
    r = 0; g = 0; b= 0;
  }
  
  public Color(int n)
  {
    r = n; g = n; b = n;
  }
  
  public Color(int Nr, int Ng, int Nb)
  {
    r = Nr; g = Ng; b = Nb;
  }
}
