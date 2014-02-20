
PImage instructions, powers,volume,  volumeOff,bckgrnd1, bckgrnd2, textD, textC, textB, textV, decoy, decoyZombie, enemy, enemyDrugged, ninjaDrugged, boss, toughEnemy, plate, toughEnemyDrugged, fastEnemy, spikesLeft, spikesRight, spikesDown, spikesUp, oil, tnt, tntexplode, trigger, triggerclosed, punch, sludge, teeth, teethUsed, powerPunch, turret;
Animation hero, beam;


color SHADOW_COLOR = color(0, 32, 64, 64);//color(64, 84, 32);

float HERO_RADIUS = 22;
color HeroDOT_FILL = color(192, 16, 64);

float ENEMY_RADIUS = 10;

float SPIKES_RADIUS = 45;

float SUIT_WALK_SPEED = 1.5;
float TOUGH_WALK_SPEED = 1;
float FAST_WALK_SPEED = 5;

float PLAYER_WALK_SPEED = 3;
float PLAYER_MASS = 10;
float Z_SCALE = 0.5;
float GRAVITY = 0.3;
float JUMP_STRENGTH = 5;

float FLAP_STRENGTH = 5;
float FLAP_CEILING = 400;
float FLAP_DRAG = 0.9;
float FLAP_SPEED = 3;

int COMBO_TIME = 8;
int NAME_TIME = 120;


int PLAYER_START_HP = 5;

int WORLD_WIDTH = 5;
int WORLD_HEIGHT = 5;
int WORLD_START_X = 2;
int WORLD_START_Y = 2;

int LIFEBAR_W = 50;
int LIFEBAR_H = 4;

PFont font;

ZSorter zSort = new ZSorter();


Screen testScreen;
Screen[][] world;
int world_x;
int world_y;
ParticleList smokeParticles;
ParticleList textParticles;
ArrayList loot_drop;
boolean muted;
boolean paused;
boolean soundPlayed;
boolean gameBeat;
int score;
int credits;
int level;
int stage;
boolean cheated;
boolean won;
boolean hasDecoy;
boolean hasSludge;
boolean hasOil;
boolean hasBite;
boolean useBite;
boolean musicPlaying;
boolean decoyPresent;
boolean at_title, at_instruct, at_pow;
boolean levelBeaten;
boolean power1Chosen, power2Chosen, power3Chosen, power4Chosen, power5Chosen, power6Chosen;
String overlay_text;
Decoy aDecoy;
Sludge aSludge;
Oil  aOil;
Explosive explosive;
Bite bite;
Plate plateX, plateX2;
Beam beamX = null;
Beam beamX2 = null;

int HIGH_SCORE1, HIGH_SCORE2, HIGH_SCORE3;
String high1, high2, high3;
int first, second, third, fourth;

boolean[] keys = new boolean[255];
int KEY_LEFT = 37;
int KEY_RIGHT = 39;
int KEY_UP = 38;
int KEY_DOWN = 40;
int KEY_JUMP = 90; //Z
int KEY_ATTACK = 88; //X
int KEY_SPECIAL = 67; //C
int KEY_SPECIAL2 = 86; //V
int KEY_SPECIAL3 = 66; //B
int KEY_SPECIAL4 = 68; //D
int KEY_KILLALL = 8; //backspace
int KEY_PHATLOOT = 80; 
int KEY_POWER1 = 89; //Y
int KEY_POWER2 = 85; //U
int KEY_POWER3 = 73; //I
int KEY_POWER4 = 79; //O
int KEY_POWER5 = 80; //P
int KEY_POWER6 = 84; //T
int KEY_MUTE = 77; //M
int KEY_RETURN = 13;//RETURN
int KEY_NEXT = 78; //N

Sprite player;

Minim minim;
AudioPlayer ahhh;
AudioPlayer punchSound;
AudioPlayer deathSound;
AudioPlayer hitSound;
AudioPlayer doorSound;
AudioPlayer biteSound;
AudioPlayer knifeSound;
AudioPlayer stompSound;
AudioPlayer bellSound;
AudioPlayer gameOverSound;
AudioPlayer sludgeSound;
AudioPlayer laserSound;
AudioPlayer oilSound;
AudioPlayer explodeSound;
AudioPlayer powerAcqSound;

AudioPlayer bgm;

/// UTILITY //////////////////////////////////////////////////////////////////////////////
void openSound()
{
  minim = new Minim(this);
  ahhh = minim.loadFile("data/ahhh.mp3", 1024);
  punchSound = minim.loadFile("data/punch.wav", 1024);
  doorSound = minim.loadFile("data/door-open-7.wav",1024);
  deathSound = minim.loadFile("data/grunt.wav",1024);
  biteSound = minim.loadFile("data/bite.wav", 1024);
  knifeSound = minim.loadFile("data/slash.wav", 1024);
  stompSound  = minim.loadFile("data/stomp.wav", 1024);
  bellSound = minim.loadFile("data/bell.wav", 1024);
  gameOverSound = minim.loadFile("data/gameover.mp3", 4096);
  sludgeSound = minim.loadFile("data/sludge.wav", 2048);
  laserSound = minim.loadFile("data/beam.wav", 4000);
  oilSound = minim.loadFile("data/oil.wav", 1024);
  explodeSound = minim.loadFile("data/explosion.wav", 1024);
  powerAcqSound = minim.loadFile("data/poweracq.wav", 1024);
  bgm = minim.loadFile("data/DuHast.mp3", 4096);
}
void closeSound()
{
  ahhh.close();
  punchSound.close();
  doorSound.close();
  deathSound.close();
  biteSound.close();
  knifeSound.close();
  stompSound.close();
  bellSound.close();
  gameOverSound.close();
  sludgeSound.close();
  laserSound.close();
  oilSound.close();
  explodeSound.close();
  powerAcqSound.close();
  bgm.close();
  minim.stop();
}


boolean inRadius(PVector a, PVector b, float rad)
{
  return rad*rad > (a.x - b.x)*(a.x - b.x) + (a.y - b.y) * (a.y - b.y) + (a.z - b.z) * (a.z - b.z);
}

boolean inRect(float xT, float yT, int wT, int hT, PVector middle)
{
  return ((middle.x> xT) && (middle.x < xT+wT) && (middle.y > yT) && (middle.y<yT+hT));
}

PVector randomVector(float magn)
{
  float angle = random(TWO_PI);
  return new PVector(cos(angle)*magn, sin(angle)*magn);
}

class ParticleList extends ArrayList
{
  void tick()
  {
    Iterator i = this.iterator();
    for (int i = 0; i< this.size(); i++)
    {
      Particle p = this.get(i);
      p.tick();
      if(p.life <= 0) this.remove(i);
    }
  }
  void draw()
  {
    Iterator i = this.iterator();
    while(i.hasNext())
    {
      Particle p = (Particle) i.next();
      p.draw();
    }
  }
}

abstract class Particle
{
  PVector pos;
  PVector vel;
  PVector accel;
  int life;
  int maxlife;
  Particle(PVector p, PVector v, int lifetime)
  {
    this(p, v, new PVector(0, 0), lifetime);
  }
  Particle(PVector p, PVector v, PVector a, int lifetime)
  {
    accel = new PVector(a.x, a.y);
    pos = new PVector(p.x, p.y);
    vel = new PVector(v.x, v.y);
    life = maxlife = lifetime;
  }
  void tick()
  {
    vel.add(accel);
    pos.add(vel);
    life--;
  }
  abstract void draw();
}

class SmokePoof extends Particle
{
  SmokePoof(PVector p, int bigness)
  {
    super(p, randomVector(random(1)), new PVector(0, -0.05), bigness*2);
  }
  void draw()
  {
    fill(230, 230, 220);
    noStroke();
    ellipse(pos.x, pos.y, life/2, life/2);
  }
}

class TextBlip extends Particle
{
  String myText;
  color myColor;
  int txtSize;
  TextBlip(PVector p, int life, String label)
  {
    super(p, PVector.add(randomVector(0.5), new PVector(0, -2)), new PVector(0, 4.0/life), life);
    myText = label;
    myColor = color(255);
    txtSize = 15;
  }
  TextBlip(PVector p, int life, String label, color c)
  {
    super(p, PVector.add(randomVector(0.5), new PVector(0, -2)), new PVector(0, 4.0/life), life);
    myText = label;
    myColor = c;
    txtSize = 15;
  }
  TextBlip(PVector p, int life, String label, color c, int s)
  {
    super(p, PVector.add(randomVector(0.5), new PVector(0, -2)), new PVector(0, 4.0/life), life);
    myText = label;
    myColor = c;
    txtSize = s;
  }
  void draw()
  {
    textAlign(CENTER, BOTTOM);
    textFont(font, txtSize);
    fill(myColor);
    text(myText, pos.x, pos.y);
  }
}
// CLASSES ////////////////////////////////////////////////////////////////////////////////
class ZSorter implements Comparator
{
  int compare(Object o1, Object o2)
  {
    Sprite c1 = (Sprite) o1;
    Sprite c2 = (Sprite) o2;
    if(c1.pos.z < c2.pos.z) return -1;
    if(c1.pos.z > c2.pos.z) return 1;
    return 0;
  }
}

class BGFeature
{
  float radius;
  color col;
  PVector pos;
  BGFeature(PVector p, float r, color c)
  {
    pos = p;
    radius = r;
    col = c;
  }
  void draw()
  {
    noStroke();
    fill(col);
    ellipse(pos.x, pos.y, radius, radius);
  }
}


class Screen
{
  int rescue_award = 5;
  ArrayList sprites;
  ArrayList traps;
  ArrayList features;
  boolean cleared;
  boolean killedFriendly;
  Screen()
  {
    cleared = false;
    killedFriendly = false;
    sprites = new ArrayList();
    traps = new ArrayList();
    features = new ArrayList();
    /*for(int i = 0; i < 5; i++)
    {
      features.add(new BGFeature(new PVector(random(width), random(height)), random(40)+40, BG_VARIATION_COLOR_2));
    }
    for(int i = 0; i < 5; i++)
    {
      features.add(new BGFeature(new PVector(random(width), random(height)), random(20)+20, BG_VARIATION_COLOR));
    }*/
  }
  void draw()
  {
    /*for(int i = 0; i < features.size(); i++)
    {
      BGFeature b = (BGFeature) features.get(i);
      b.draw();
    }*/
    for(int i = 0; i < sprites.size(); i++)
    {
      Sprite c = (Sprite) sprites.get(i);
      c.drawShadow();
    }
    for(int i = 0; i<traps.size();i++)
    {
      Trap c = (Trap) traps.get(i); 
        if(explosive != null && explosive.exploded)
          traps.remove(explosive);
        if(c instanceof Plate && c.triggered){
          traps.remove(c);
        }
        if(c instanceof Beam && ((Beam)c).timer < millis())
          traps.remove(c);
        c.draw();
      }
    

    for(int i = 0; i < sprites.size(); i++)
    {
      Sprite c = (Sprite) sprites.get(i);
      c.draw();
      c.drawAttack();
    }
    for(int i = 0; i < sprites.size(); i++)
    {
      Sprite c = (Sprite) sprites.get(i);
      if(c.name_timer > 0) c.drawName();
    }
  }
  void stepPhysics()
  {
    for(int i = 0; i < sprites.size(); i++)
    {
      Sprite c = (Sprite) sprites.get(i);
      c.step();
    }
    for(int i = 0; i < sprites.size(); i++)
    {
      Sprite c = (Sprite) sprites.get(i);
      
      for(int j = i+1; j< sprites.size(); j++)
      {
        Sprite d = (Sprite) sprites.get(j);
        c.resolveCollision(d);
      }
    }
    
    for(int i = 0; i < traps.size(); i++)
    {
      Trap t = (Trap) traps.get(i);      
      for(int j = 0; j< sprites.size(); j++)
      {
        Sprite d = (Sprite) sprites.get(j);
        t.resolveCollision(d);
      }
    }
    
    for(int i = 0; i < sprites.size(); i++)
    {
      Sprite c = (Sprite) sprites.get(i);
      for(int j = 0; j< sprites.size(); j++)
      {
        if(i != j)
        {
          Sprite d = (Sprite) sprites.get(j);
          c.resolveAttack(d);
        }
      }
    }

    {
      boolean hadHostiles = false;
      boolean hadFriendly = false;
      boolean hasHostiles = false;

      int numHostiles = 0;

      for(int i = 0; i < sprites.size(); i++)
      {
        Sprite c = sprites.get(i);
        if(c.hostile) hadHostiles = true;
        else if(!c.inanimate && c!=player) hadFriendly = true;
        if(c.hp <= 0 && c.stun_timer == 0 && c.max_hp > 0 && !c.airborne)
        {
          c.poof(); // may create loot    
          if(c.isDecoy)
            decoyPresent = false;
          if(!(c instanceof Loot))
            deathSound.play();
          console.log("Removing!");
          sprites.remove(i);  
          if(!c.hostile && !c.inanimate) 
          {
            killedFriendly = true;
          }
        }
        else if(c.hostile)  numHostiles++;
      }

      cleared = true;
      for (int i =0; i < sprites.size(); i++)
      {
        if (sprites.get(i).hostile) {
          cleared = false;
          break;
        }
      }
      // if(numHostiles <= 0) cleared = true;
    }
    sprites.addAll(loot_drop);
    loot_drop.clear();

    //sort by Z-value for drawing
    // Collections.sort(sprites, zSort);
  }
}

abstract class Sprite
{
  PVector pos;
  PVector vel;
  PVector desired_vel;
  PVector fidget;
  PVector heading;
  PVector facing;
  float radius;
  float rotation;
  color fill_color;
  color stroke_color;
  int hp;
  int max_hp;
  String name;
  float walk_speed;
  float traction;
  float air_traction;
  boolean airborne;
  int walk_timer;
  int stun_timer;
  float mass;
  int oilTimer;
  boolean isDecoy;
  boolean sludged;
  boolean drugged;
  boolean oiled;
  int trapTimer;

  int combo = -1;
  ArrayList attacks;
  int attack_timer;
  boolean attack_cue;

  boolean hostile;
  boolean inanimate;

  int name_timer;

  void touched(Sprite c)
  {
    if(max_hp > 0)
    {
      if(c.mass > mass && c.pos.z > pos.z && c.vel.z < -12 && stun_timer == 0)
        injure(1, 20);
    } 
  }

  Sprite(float x, float y, float z)
  {
    pos = new PVector(x, y, z);
    radius = z;
    vel = new PVector(0, 0);
    desired_vel = new PVector(0, 0);
    fidget = new PVector(0, 0);
    heading = new PVector(0, 0);
    facing = new PVector(0, -1);
    isDecoy = false;
    sludged = false;
    drugged = false;
    oiled = false;
    walk_speed = 1;
    traction = 1;
    name = "Something";
    airborne = false;
    mass = 1;
    attacks = new ArrayList();
    name_timer = NAME_TIME;
    oilTimer = 0;
    trapTimer = 0;
  }

  void draw(){};
  
  void resolveCollision(Sprite c)
  {
    if(inRadius(pos, c.pos, radius+c.radius))
    {
      touched(c);
      c.touched(this);
      float overlap = (radius+c.radius) - PVector.dist(pos, c.pos);
      float myEject;
      if(mass == 0) myEject = 0; //zero-mass objects have infinite mass
      else if(c.mass == 0) myEject = 1;
      else myEject = 1-mass/(mass + c.mass);
      PVector toThem = PVector.sub(c.pos, pos);
      toThem.normalize();
      pos.add(PVector.mult(toThem, -overlap*myEject));
      c.pos.add(PVector.mult(toThem, overlap*(1-myEject)));
      vel.add(PVector.mult(toThem, -myEject * overlap));
      c.vel.add(PVector.mult(toThem, (1-myEject) * overlap));
    }
  }

  void resolveAttack(Sprite c)
  {
    if(combo > 1)
      combo = 0;
    if(combo > -1)
    {
      Attack a;
      if(useBite && this==player){
        a = bite;
        hasBite = false;
      }
      else
        a = (Attack) attacks.get(combo);
      if(attack_timer >= a.warm_frames && attack_timer < a.warm_frames + a.active_frames)
      {
        PVector attackPos = new PVector(pos.x, pos.y, pos.z);
        attackPos.add(PVector.mult(facing, a.distance));
        if(inRadius(attackPos, c.pos, a.radius + c.radius) && c.stun_timer == 0)
        {
          c.injure(a.damage, a.stun_time);
          if(drugged && c != player){
            addScore(5, 1);
            textParticles.add(new TextBlip(pos, 60, "+"+5, color(20,255,20), 25));
            textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Zombie Fight Bonus!", color(20, 255, 20), 23));
          }
          if(a.name == "zombie bite!" && !(c instanceof Boss)){
            c.drugged = true;
            c.name = c.name + " (Zombified)";
            if(c instanceof Decoy)
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Zombi-ecoy!", color(20, 255, 70), 35));  
            else
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Zombified!", color(20, 255, 20), 35));
          }
          if(c.mass != 0) 
          {
            PVector away = PVector.sub(c.pos, pos);
            away.z = 0;
            away.normalize();
            away.mult(a.knock_away);
            away.z = a.knock_upward;
            away.mult(11/(5+c.mass));
            c.vel = away;
          }
        }
      }
    }
  }

  void injure(int amount, int stun)
  {
    hp -= amount;
    if(hp<0)
      hp = 0;
    stun_timer = stun;
    name_timer = NAME_TIME;
  }

  void poof()
  {
    for(int i = 0; i < 5; i++)
    {
      smokeParticles.add(new SmokePoof(pos, (int)radius + 5));
    }
    int lootValue = 1;
    if(!hostile) lootValue /= 2;
    while(lootValue > 0)
    {
      int value = lootValue/4 + 1;
      int drop_type = (int)random(3);
      PVector location = randomVector(random(radius));
      location.add(pos);
      if(drop_type == 0 || drop_type == 1 || player.hp == player.max_hp || value > player.max_hp) {}
      else if(drop_type == 2) loot_drop.add(new Heart(location.x, location.y, value));
      lootValue -= value;
    }
  }

  void drawShadow()
  {
    pushMatrix();
    translate(pos.x+radius -15, pos.y+radius - 15);
    translate(fidget.x, fidget.y);
    noStroke();
    fill(SHADOW_COLOR);
    ellipse(0, 0, radius-10, radius-10);
    popMatrix();
  }
  
  void drawName()
  {
    textFont(font, 15);
    textAlign(CENTER, BOTTOM);
    fill(0);
    text(name, (int)pos.x+1, (int)(pos.y - Z_SCALE * pos.z - radius - 8 + 1));

    fill(255);
    text(name, (int)pos.x, (int)(pos.y - Z_SCALE * pos.z - radius - 8));

    if(max_hp > 0)
    {
      fill(0);
      noStroke();
      strokeWeight(1);
      rect(pos.x - LIFEBAR_W/2, pos.y - Z_SCALE * pos.z - radius - LIFEBAR_H, LIFEBAR_W, LIFEBAR_H);
      noStroke();
      fill(255, 0, 0);
      rect(pos.x - LIFEBAR_W/2, pos.y - Z_SCALE * pos.z - radius - LIFEBAR_H, map(max(hp, 0), 0, max_hp, 0, LIFEBAR_W), LIFEBAR_H);
    }
  }

  void drawAttack()
  {
    if(combo > 1)
      combo = 0;
    if(combo > -1)
    {
      Attack a;
      if(useBite && this==player)
        a= bite;
      else
        a = (Attack) attacks.get(combo);
      pushMatrix();
      translate(pos.x + radius, pos.y + radius - Z_SCALE * pos.z);
      translate(facing.x * a.distance, facing.y * a.distance);
      a.draw(attack_timer);
      popMatrix();        
    }
  }

  void step()
  {
    name_timer --;
    /// PHYSICS
    heading.normalize();
    if(combo > -1 || stun_timer > 0) heading.mult(0);
    stun_timer--;
    if(stun_timer < 0) stun_timer = 0;

    if(pos.z <= radius)
    {
      pos.z = radius;
      airborne = false;
      if(vel.z<0) vel.z= 0;
    }
    else airborne = true;

    float using_traction;
    if(airborne) using_traction = air_traction;
    else using_traction = traction;
    PVector flatvel = new PVector(vel.x, vel.y);
    desired_vel.x = heading.x * walk_speed;
    desired_vel.y = heading.y * walk_speed;
    if(PVector.dist(desired_vel, flatvel) < using_traction)
    {
      flatvel.x = desired_vel.x;
      flatvel.y = desired_vel.y;
    }
    else
    {
      PVector steer = PVector.sub(desired_vel, flatvel);
      steer.normalize();
      steer.mult(using_traction);
      flatvel.add(steer);
    }
    if((heading.x != 0 || heading.y != 0) && !airborne) //if heading's not zero and we're on the ground, update walk anim
    {
      walk_timer++;
      int walk_frame = (int)(walk_timer / (radius / walk_speed))%4;
      if(walk_frame %2 == 0) {
        fidget.x = heading.x; 
        fidget.y = heading.y;
      }
      if(walk_frame == 1) {
        fidget.x = -heading.y; 
        fidget.y = heading.x;
      }
      if(walk_frame == 3) {
        fidget.x = heading.y; 
        fidget.y = -heading.x;
      }
    }
    else
    {
      walk_timer = 0;
      fidget.x = 0;
      fidget.y = 0;
    }
    //}
    vel.x = flatvel.x;
    vel.y = flatvel.y;
    if(airborne) vel.z -= GRAVITY;
    pos.add(vel);

    if(this != player) /// bad practice!
    { 
      if(pos.x < 60) {
          pos.x = 60; 
          vel.x *= -1;
        }
      if(pos.x > width-70) {
          pos.x = width-70; 
          vel.x *= -1;
      }
      if(pos.y > height-55) {
          pos.y = height-55; 
          vel.y *= -1;
      }
      if(pos.y < 65) {
          pos.y = 65; 
          vel.y *= -1;
      }
    }

    if(heading.x != 0 || heading.y != 0)
    {
      facing.x = heading.x;
      facing.y = heading.y;
      facing.normalize();
    }

    ////// ATTACKS
    if(combo == -1 && attack_cue && !attacks.isEmpty())
    {
      combo = 0;
      attack_cue = false;
      attack_timer = 0;
      if(useBite && !hasBite && player.attacks.size()>2){
        useBite = false;
        player.attacks.remove(2);  
      }
    }
   if(combo > 1)
        combo = 0;   
    if(combo > -1)
    {
      Attack a;
      if(useBite && this == player)
        a= bite;
      else
        a= (Attack) attacks.get(combo);
      if(attack_timer == a.warm_frames) 
      {
        //a.sound.setGain(0.1);
        a.sound.play();
        textParticles.add(new TextBlip(new PVector(pos.x, pos.y - radius), 30, a.name, color(192)));
      }
      attack_timer++;
      if(attack_timer >= a.warm_frames + a.active_frames + a.cool_frames)
      {
        if(attack_cue && attacks.size() > combo+1)
        {
          attack_cue = false;
          if(combo<2)
            combo++;
          attack_timer = 0;
        }
        else if(attack_timer >= a.warm_frames + a.active_frames + a.cool_frames + COMBO_TIME)
        {
          combo = -1;
          attack_cue = false;
        }
      }
    }
  }
}

class Hero extends Sprite
{
  Hero(float x, float y)
  {
    super(x, y, HERO_RADIUS);

    walk_speed = PLAYER_WALK_SPEED;
    traction = 1;//PLAYER_WALK_SPEED*4;
    air_traction = 0.05;
    hp = max_hp = PLAYER_START_HP;
    name = "Bruce";
    mass = PLAYER_MASS;
  }
  void draw()
  {
    //fill(255,0,0);
    //text(oilTimer - millis(), pos.x, pos.y -20, 15);
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    //INSERT HERO IMAGE HERE
    if(stun_timer/2 % 2 == 0){
      translate(22.5, 21);
      rotate(rotation);
      hero.display(-22.5, -21,  45, 42);
    }
    popMatrix();
    if(oilTimer < millis()){
      walk_speed = PLAYER_WALK_SPEED;
      oiled = false;
      if(sludged && walk_speed != PLAYER_WALK_SPEED/2)
        walk_speed /= 2;
    }
  }
}

class Enemy extends Sprite
{
  Enemy(float x, float y)
  {
    super(x, y, ENEMY_RADIUS);
    hostile = true;
    fill_color = color(64, 192, 96);
    stroke_color = color(128, 96, 64);
    walk_speed = SUIT_WALK_SPEED;
    traction = 0.5;//PLAYER_WALK_SPEED*4;
    hp = max_hp = 10;
    name = "Suit";
    mass = 1;
    attacks.add(new Knife());
  } 
  
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    if(stun_timer/2 % 2 == 0){
      if(!drugged)image(enemy, -10, -10);
      else image(enemyDrugged,-10,-10);
    }
    popMatrix();
  }
  
  void step()
  {
    Sprite s = null;
    boolean available = false;
    for(int i = 0; i<world[2][2].sprites.size(); i++){
      if(((Sprite)(world[2][2].sprites.get(i))).hostile  && (Sprite)(world[2][2].sprites.get(i)) != this){
        s = (Sprite)world[2][2].sprites.get(i);
        available = true;
      }
    }
    if(!(oilTimer > millis()))
    {
      walk_speed = SUIT_WALK_SPEED;
      if(sludged)
        walk_speed /= 2;
      oiled = false;
      if(!available)
        drugged = false;
      if(!decoyPresent && !drugged)
        heading = PVector.sub(player.pos, pos);
      else if(drugged && available){
        heading = PVector.sub(s.pos,pos);
        if(inRadius(s.pos, pos, s.radius + 20)) attack_cue = true;
      }
      else{
        heading = PVector.sub(aDecoy.pos, pos);
        if(inRadius(aDecoy.pos, pos, player.radius + 20)) attack_cue = true;
      }  
      if(inRadius(player.pos, pos, player.radius + 20)) attack_cue = true;
    }
    heading.z = 0;
    super.step();
  }
}

class ToughEnemy extends Sprite
{
  ToughEnemy(float x, float y)
  {
    super(x, y, 20);
    hostile = true;
    fill_color = color(172, 160, 145);
    stroke_color = color(162, 130, 96);
    walk_speed = TOUGH_WALK_SPEED;
    traction = 0.1;//PLAYER_WALK_SPEED*4;
    hp = max_hp = 40;
    name = "Pro Wrestler";
    mass = 5;
    attacks.add(new Stomp());
  } 
  
    void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    if(stun_timer/2 % 2 == 0) 
    {
      if(!drugged)image(toughEnemy, 0, 0);
      else image(toughEnemyDrugged, 0,0);
    }
    popMatrix();
  }
  void step()
  {
    Sprite s = null;
    boolean available = false;
    for(int i = 0; i<world[2][2].sprites.size(); i++){
      if(((Sprite)(world[2][2].sprites.get(i))).hostile  && (Sprite)(world[2][2].sprites.get(i)) != this){
        s = (Sprite)world[2][2].sprites.get(i);
        available = true;
      }
    }
    if(!(oilTimer > millis()))
    {
      oiled = false;
      walk_speed = TOUGH_WALK_SPEED;
      if(sludged) walk_speed /= 2;
      if(!available)
        drugged = false;
      if(!decoyPresent && !drugged)
        heading = PVector.sub(player.pos, pos);
      else if(drugged && available){
        heading = PVector.sub(s.pos,pos);
        if(inRadius(s.pos, pos, s.radius + 20)) attack_cue = true;
      }
      else{
        heading = PVector.sub(aDecoy.pos, pos);
        if(inRadius(aDecoy.pos, pos, player.radius + 20)) attack_cue = true;
      }
    } 
    heading.z = 0;
    if(inRadius(player.pos, pos, player.radius + 20)) attack_cue = true;
    super.step();
  }
}

class Boss extends Sprite
{
  Boss(float x, float y)
  {
    super(x, y, 45);
    hostile = true;
    fill_color = color(172, 160, 145);
    stroke_color = color(162, 130, 96);
    walk_speed = SUIT_WALK_SPEED;
    traction = 0.1;//PLAYER_WALK_SPEED*4;
    hp = max_hp = 80;
    name = "Gustav (BOSS)";
    mass = 5;
    attacks.add(new Stomp());
  } 
  
    void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    if(stun_timer/2 % 2 == 0) 
    {
      image(boss,-10, -10);
    }
    popMatrix();
  }
  void step()
  {
    Sprite s = null;
    boolean available = false;
    for(int i = 0; i<world[2][2].sprites.size(); i++){
      if(((Sprite)(world[2][2].sprites.get(i))).hostile  && (Sprite)(world[2][2].sprites.get(i)) != this){
        s = (Sprite)world[2][2].sprites.get(i);
        available = true;
      }
    }
    if(!(oilTimer > millis()))
    {
      oiled = false;
      walk_speed = SUIT_WALK_SPEED;
      if(sludged) walk_speed /= 2;
      if(!available)
        drugged = false;
      if(!decoyPresent && !drugged)
        heading = PVector.sub(player.pos, pos);
      else if(drugged && available){
        heading = PVector.sub(s.pos,pos);
        if(inRadius(s.pos, pos, s.radius + 20)) attack_cue = true;
      }
      else{
        heading = PVector.sub(aDecoy.pos, pos);
        if(inRadius(aDecoy.pos, pos, player.radius + 20)) attack_cue = true;
      }
    } 
    heading.z = 0;
    if(inRadius(player.pos, pos, player.radius + 20)) attack_cue = true;
    super.step();
  }
}

class FastEnemy extends Sprite
{
  FastEnemy(float x, float y)
  {
    super(x, y, 22);
    hostile = true;
    fill_color = color(172, 160, 145);
    stroke_color = color(162, 130, 96);
    walk_speed = FAST_WALK_SPEED;
    traction = 0.1;//PLAYER_WALK_SPEED*4;
    hp = max_hp = 8;
    name = "Fast Enemy";
    mass = 1;
    attacks.add(new Slash());
  } 
  
    void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    if(stun_timer/2 % 2 == 0){
      if(!drugged)image(fastEnemy, -10 ,-10);
      else image(ninjaDrugged, -10,-10);
    }
    popMatrix();
  }
  void step()
  {
    Sprite s = null;
    boolean available = false;
    for(int i = 0; i<world[2][2].sprites.size(); i++){
      if(((Sprite)(world[2][2].sprites.get(i))).hostile && (Sprite)(world[2][2].sprites.get(i)) != this){
        s = (Sprite)world[2][2].sprites.get(i);
        available = true;
      }
    }
    if(!(oilTimer > millis()))
    {
      oiled = false;
      walk_speed = FAST_WALK_SPEED;
      if(sludged) walk_speed = SUIT_WALK_SPEED/2;
      if(!available)
        drugged = false;
      if(!decoyPresent && !drugged)
        heading = PVector.sub(player.pos, pos);
      else if(drugged && available){
        heading = PVector.sub(s.pos,pos);
        if(inRadius(s.pos, pos, s.radius + 20)) attack_cue = true;
      }
      else{
        heading = PVector.sub(aDecoy.pos, pos);
        if(inRadius(aDecoy.pos, pos, player.radius + 20)) attack_cue = true;
      } 
    }
    heading.z = 0;
    if(inRadius(player.pos, pos, player.radius + 26)) attack_cue = true;
    super.step();    
  }
}

class Trigger extends Sprite
{
  Trigger(float x, float y)
  {
    super(x, y, 30);

    walk_speed = 0;
    traction = 1;//PLAYER_WALK_SPEED*4;
    air_traction = 0.05;
    hp = max_hp = 10;
    name = "Trigger";
    mass = PLAYER_MASS;
  }
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    translate(22.5, 21);
    rotate(rotation);
    if(hp > 9)
      image(trigger, -22.5, -21);
    else{
      image(triggerclosed, -22.5, -21);
      if(explosive != null && !explosive.triggered){
          explodeSound.play();
          explosive.triggered = true;
      }
    }
    popMatrix();
  }
}
class Decoy extends Sprite
{
  Decoy(float x, float y)
  {
    super(x, y, 30);

    walk_speed = 0;
    traction = 1;//PLAYER_WALK_SPEED*4;
    air_traction = 0.05;
    hp = max_hp = 5;
    name = "Decoy";
    mass = PLAYER_MASS;
    isDecoy = true;
  }
  void draw()
  {
    if(hp<=0)
      decoyPresent = false;
    if(drugged){
      walk_speed = 2;
      hostile = true;
      if(attacks.size() == 0)
        attacks.add(new Punch());
    }
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    if(stun_timer/2 % 2 == 0){
      translate(22.5, 21);
      rotate(rotation);
      if(!drugged)
        image(decoy, -22.5, -21); 
      else{
        image(decoyZombie, -22.5, -21);
      }
    }
    popMatrix();
  }
  void step()
  {
    Sprite s = null;
    boolean available = false;
    for(int i = 0; i<world[2][2].sprites.size(); i++){
      if(((Sprite)(world[2][2].sprites.get(i))).hostile  && (Sprite)(world[2][2].sprites.get(i)) != this){
        s = (Sprite)world[2][2].sprites.get(i);
        available = true;
      }
    }
    if(!available)
      drugged = false;
    if(!decoyPresent && !drugged)
      heading = PVector.sub(player.pos, pos);
    else if(drugged && available){
      heading = PVector.sub(s.pos,pos);
      if(inRadius(s.pos, pos, s.radius + 20)) attack_cue = true;
    }
    else{
      heading = PVector.sub(aDecoy.pos, pos);
      if(inRadius(aDecoy.pos, pos, player.radius + 20)) attack_cue = true;
    }  
    heading.z = 0;
    if(inRadius(player.pos, pos, player.radius + 20)) attack_cue = true;
    super.step();
  }
}

/////// ATTACKS
class Attack
{
  String name;
  float radius;
  float distance;
  float knock_away;
  float knock_upward;
  int damage;
  int warm_frames;
  int active_frames;
  int cool_frames;
  int animation;
  int stun_time;
  static final int SLASH = 0;
  static final int SWEEP = 1;
  static final int BITE = 2;
  static final int ZOMBIE_BITE = 90;
  static final int FIREBALL = 3;
  color anim_color = color(255);
  AudioPlayer sound;  
  void draw(int frame)
  {
    if(frame >= warm_frames && frame < warm_frames + active_frames)
    {
      if(animation == SLASH)
      {
        noFill();
        stroke(anim_color, map(frame, warm_frames, warm_frames+active_frames, 255, 0));
        strokeWeight(2);
        pushMatrix();
        rotate(player.rotation);
        image(punch, -22.5, -21);
        popMatrix();
      }
      else if(animation == BITE)
      {
        noFill();
        float ratio = map(frame, warm_frames, warm_frames+active_frames, 0, 1);
        stroke(anim_color);
        strokeWeight(2);
        line(0, -radius, 0, -radius + 2 * ratio * radius);
        line(-radius * 0.8, -radius * 0.5, -radius * 0.8, (-radius + 2 * ratio * radius) * 0.5);
        line(radius * 0.8, -radius * 0.5, radius * 0.8, (-radius + 2 * ratio * radius) * 0.5);
        line(-radius * 0.4, radius * 0.75, -radius * 0.4, (radius - 2 * ratio * radius) * 0.75);
        line(radius * 0.4, radius * 0.75, radius * 0.4, (radius - 2 * ratio * radius) * 0.75);
      }
      else if(animation == ZOMBIE_BITE)
      {
        noFill();
        float ratio = map(frame, warm_frames, warm_frames+active_frames, 0, 1);
        stroke(color(0,255,0));
        strokeWeight(2);
        line(0, -radius, 0, -radius + 2 * ratio * radius);
        line(-radius * 0.8, -radius * 0.5, -radius * 0.8, (-radius + 2 * ratio * radius) * 0.5);
        line(radius * 0.8, -radius * 0.5, radius * 0.8, (-radius + 2 * ratio * radius) * 0.5);
        line(-radius * 0.4, radius * 0.75, -radius * 0.4, (radius - 2 * ratio * radius) * 0.75);
        line(radius * 0.4, radius * 0.75, radius * 0.4, (radius - 2 * ratio * radius) * 0.75);
      }
      else if(animation == SWEEP)
      {
        fill(anim_color, 
        min(map(frame, warm_frames, warm_frames+active_frames, 510, 0), map(frame, warm_frames, warm_frames+active_frames, 0, 510)));
        noStroke();
        ellipse(0, 0, radius, radius);
      }      
      else
      {
        fill(anim_color);
        noStroke();
        ellipse(0, 0, radius, radius);
      }
    }
  }
}
class Punch extends Attack
{
  Punch()
  {
    name = "punch!";
    radius = 22;
    distance = 30;
    warm_frames = 0;
    active_frames = 6;
    cool_frames = 8;
    animation = SLASH;
    damage = 1;
    knock_away = 2;
    knock_upward = 2;
    stun_time = 6;
    sound = punchSound;
  }
}

class Bite extends Attack
{
  Bite()
  {
    name = "zombie bite!";
    radius = 22;
    distance = 30;
    warm_frames = 0;
    active_frames = 6;
    cool_frames = 8;
    animation = ZOMBIE_BITE;
    damage = 0;
    knock_away = 2;
    knock_upward = 2;
    stun_time = 6;
    sound = biteSound;
  }
}


class Slash extends Attack
{
  Slash()
  {
    name = "slash!";
    radius = 14;
    distance = 15;
    warm_frames = 15;
    active_frames = 8;
    cool_frames = 60;
    animation = BITE;
    damage = 1;
    knock_away = 1;
    knock_upward = 1;
    stun_time = 20;
    sound = knifeSound;
  }
}

class Stomp extends Attack
{
  Stomp()
  {
    name = "stomp!";
    radius = 14;
    distance = 15;
    warm_frames = 4;
    active_frames = 8;
    cool_frames = 60;
    animation = BITE;
    damage = 1;
    knock_away = 7;
    knock_upward = 7;
    stun_time = 20;
    sound = stompSound;
  }
}

class TailSweep extends Attack
{
  TailSweep()
  {
    name = "tail sweep!";
    radius = 43;
    distance = 9;
    warm_frames = 3;
    active_frames = 12;
    cool_frames = 20;
    anim_color = HeroDOT_FILL;
    animation = SWEEP;
    damage = 1;
    knock_away = 4;
    knock_upward = 8;
    stun_time = 30;
    //sound = sweepSound;
  }
}

class Knife extends Attack
{
  Knife()
  {
    name = "knife!";
    radius = 10;
    distance = 8;
    warm_frames = 20;
    active_frames = 6;
    cool_frames = 8;
    animation = BITE;
    damage = 1;
    knock_away = 4;
    knock_upward = 2;
    stun_time = 30;
    sound = knifeSound;
  }
}


class Loot extends Sprite
{
  int shiny_timer;
  color base_color;
  Loot(float x, float y, int value)
  {
    super(x, y, 3 + value);
    vel = randomVector(0.5);
    vel.z = 5+random(8);
    stroke_color = color(192, 172, 60);
    fill_color = base_color = color(255, 245, 64);
    shiny_timer = 0;
    walk_speed = 3;
    traction = 0.05;//PLAYER_WALK_SPEED*4;
    air_traction = 0.02;
    hp = max_hp = value;
    name = "Loot";
    mass = 0.2;
    inanimate = true;
  }
  
    void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    translate(fidget.x, fidget.y);
    translate(0, -Z_SCALE * pos.z);
    strokeWeight(2);
    fill(fill_color);
    stroke(stroke_color);
    if(stun_timer/2 % 2 == 0) ellipse(0, 0, 10, 10);
    popMatrix();
  }
  
  void injure(int amount, int stun)
  {
  }
  void touched(Sprite c)
  {
    if(c == player) hp = 0;
  }
  void poof()
  {
  }
  void drawName()
  {
  }
  void step()
  {
    if(world[world_x][world_y].cleared) vel.add(PVector.mult(PVector.sub(player.pos, pos), 0.0012));
    super.step();
    shiny_timer += (int)random(3);
    if(shiny_timer > 60) shiny_timer = 0;
    if(shiny_timer < 6) fill_color = color(255);
    else fill_color = base_color;
  }
}
class Heart extends Loot
{
  Heart(float x, float y, int value)
  {
    super(x, y, value);
    fill_color = base_color = color(255, 160, 192);
    stroke_color = color(255, 32, 32);
  }
  void poof()
  {
    //heartSound.play();
    player.hp = min(player.hp + max_hp, player.max_hp);
    player.name_timer = NAME_TIME;
    textParticles.add(new TextBlip(pos, 60, "+"+max_hp, base_color));
  }
}

abstract class Trap
{
  int damage;
  int tWidth;
  int tHeight;
  PVector pos;
  PVector facing;
  PVector middle;
  int orientation;
  int pointAmt;
  int knock_back;
  boolean triggered;
  
  Trap(float x, float y, float z, PVector fac, int orient){   
    pos = new PVector(x, y, z);
    facing = fac;
    orientation = orient;
    triggered = false;
  }

  void resolveCollision(Sprite c)
  {
    if(triggered)
    {
        PVector attackPos = new PVector(pos.x, pos.y);
        attackPos.add(PVector.mult(facing,20));
        if(inRadius(middle, c.pos, pos.z + c.radius))
        {
          c.injure(damage, 0);
          if(c.mass != 0) 
          {
            PVector away = PVector.sub(c.pos, pos);
            away.z = 0;
            away.normalize();
            away.mult(3);
            away.z = 2;
            away.mult(knock_back/(4+c.mass));
            c.vel = away;
          }
          if(!(c instanceof Loot))
          {
            if(c.hp>-5){
              textParticles.add(new TextBlip(pos, 60, "+"+pointAmt, color(255,255,255), 25));
              if(!c.oiled){
                addScore(pointAmt, 1);
                textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Spiked!", color(255, 0, 20), 35));
              }
              else{
                addScore(15, 2);
                textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Oil Spiked!", color(255, 0, 35)));
              }
            }
          } 
        } 
    }
  }
  abstract void draw();
}

class Oil extends Trap
{
  Oil(float x, float y, PVector fac, int orient)
  {
    super(x,y, 35, fac, orient);
    pointAmt = 0;
    damage = 0;
    tWidth = 69;
    tHeight = 56;
    knock_back = 0;
    triggered = true;
    middle = new PVector(pos.x+35, pos.y + 28);
  }
  
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(radians(orientation));
    image(oil, 0, 0, tWidth, tHeight);  
    popMatrix();
  }
  void resolveCollision(Sprite c)
  {
    if(!c.oiled)
    {
        PVector attackPos = new PVector(pos.x, pos.y);
        attackPos.add(PVector.mult(facing,20));
        if(inRadius(middle, c.pos, pos.z + c.radius))
        {
          oilSound.play();
          c.oiled = true;
          c.oilTimer = millis()+1000;
          c.injure(damage, 0);
          c.walk_speed += 5;
          if(c.mass != 0) 
          {
            PVector away = PVector.sub(c.pos, pos);
            away.z = 0;
            away.normalize();
            away.mult(3);
            away.z = 2;
            away.mult(knock_back/(4+c.mass));
            c.vel = away;
          }
          if(!(c instanceof Loot))
          {
            if(c.hp>-5){
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Oil slicked!", color(255, 255, 255),25));
            }
          }  
      }
    }
  }
  
}

class Beam extends Trap
{
  int timer;
  Beam(float x, float y, PVector fac, int orient)
  {
    super(x,y, 35, fac, orient);
    timer = 9999999;
    pointAmt = 10;
    damage = 10;
    tWidth = 44;
    tHeight = 393;
    knock_back = 5;
    triggered = false;
  }
  
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(radians(orientation));
    image(turret, -16,-35,30,30);
    if(triggered){
      beam.display(-22.5, -21, 44, 393);
    }
    popMatrix();
  }
  void resolveCollision(Sprite c)
  {
    if(triggered){
      PVector attackPos = new PVector(pos.x, pos.y);
      attackPos.add(PVector.mult(facing,20));
      if(inRect(pos.x, pos.y, tWidth, tHeight, new PVector(c.pos.x+c.radius, c.pos.y+c.radius)))
      {
        c.injure(damage, 0);
        if(c.mass != 0) 
        {
          PVector away = PVector.sub(c.pos, pos);
          away.z = 0;
          away.normalize();
          away.mult(3);
          away.z = 2;
          away.mult(knock_back/(4+c.mass));
          c.vel = away;
        }
        if(!(c instanceof Loot))
        {
          if(c.hp>-5){
            if(!c.oiled && !c.sludged){
              textParticles.add(new TextBlip(pos, 60, "+"+pointAmt, color(255,255,255), 25));
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Laser beamed!", color(255, 255, 255),25));
              addScore(pointAmt, 1);
            }
            else if(c.oiled && !c.sludged){
              addScore(20,3);
              textParticles.add(new TextBlip(pos, 60, "+"+20, color(255,0,20), 25));
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Oil beamed!", color(255, 0, 20), 35));
            }
            else if(c.sludged && !c.oiled){
              addScore(25,4);
              textParticles.add(new TextBlip(pos, 60, "+"+25, color(255,0,20), 25));
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Sludge beamed!", color(255, 0, 20), 35));
            }
            else{
              addScore(30,5);
              textParticles.add(new TextBlip(pos, 60, "+"+30, color(255,0,20), 25));
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Sloil beamed!", color(255, 15, 255), 40));
            }
          }
        }  
    }
    }
  } 
}

class Plate extends Trap
{
  Beam corrBeam;
  Plate(float x, float y, PVector fac, int orient, Beam corr)
  {
    super(x,y, 30, fac, orient);
    corrBeam = corr;
    pointAmt = 0;
    damage = 0;
    tWidth = 61;
    tHeight = 51;
    knock_back = 0;
    triggered = false;
    middle = new PVector(pos.x+30, pos.y + 25);
  }
  
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(radians(orientation));
    image(plate, 0, 0, tWidth, tHeight);  
    popMatrix();
  }
  void resolveCollision(Sprite c)
  {
    if(!triggered)
    {
        Object obj = c;
        if(obj instanceof Hero){
          if(inRadius(middle, c.pos, pos.z + c.radius))
          {
           laserSound.play();
           triggered = true;
           corrBeam.triggered = true;
           corrBeam.timer = millis() + 900;
          }
        }
    }
  }
}

class Sludge extends Trap
{
  Sludge(float x, float y, PVector fac, int orient)
  {
    super(x,y, 35, fac, orient);
    pointAmt = 5;
    damage = 0;
    tWidth = 69;
    tHeight = 56;
    knock_back = 0;
    triggered = true;
    middle = new PVector(pos.x+35, pos.y + 28);
  }
  
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(radians(orientation));
    image(sludge, 0, 0, tWidth, tHeight);  
    popMatrix();
  }
  void resolveCollision(Sprite c)
  {
    if(triggered && !c.sludged)
    {
        PVector attackPos = new PVector(pos.x, pos.y);
        attackPos.add(PVector.mult(facing,20));
        if(inRadius(middle, c.pos, pos.z + c.radius))
        {
          sludgeSound.play();
          c.injure(damage, 0);
          c.walk_speed /= 2;
          c.sludged = true;
          c.name = c.name + " (Sludged)";
          if(c.mass != 0) 
          {
            PVector away = PVector.sub(c.pos, pos);
            away.z = 0;
            away.normalize();
            away.mult(3);
            away.z = 2;
            away.mult(knock_back/(4+c.mass));
            c.vel = away;
          }
          if(!(c instanceof Loot))
          {
            addScore(5, 1);
            if(c.hp>-5){
              textParticles.add(new TextBlip(pos, 60, "+"+pointAmt, color(255,255,255),25));
              textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Sludged!", color(255, 255, 255), 30));
            }
          }  
      }
    }
  }
}

class Spikes extends Trap
{
  Spikes(float x, float y, PVector fac, int orient)
  {
    super(x,y, SPIKES_RADIUS, fac, orient);
    pointAmt = 5;
    damage = 5;
    if(orient == 0 || orient == 180){
      tWidth = 71;
      tHeight = 84;
    }
    else{
      tWidth = 84;
      tHeight = 71;
    }
    knock_back = 11;
    triggered = false;
    middle = new PVector(pos.x+tWidth/2, pos.y + tHeight/2);
  }
  
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    switch(orientation){
      case 0:
        image(spikesLeft, 0, 0, tWidth, tHeight); break;
      case 90:
        image(spikesUp, 0, 0, tWidth, tHeight); break;
      case 180:
        image(spikesRight, 0, 0, tWidth, tHeight); break;
      case 270:
        image(spikesDown, 0, 0, tWidth, tHeight);
    }  
    popMatrix();
  }
  void resolveCollision(Sprite c)
  {
    if(!triggered && c.trapTimer < millis() && inRadius(middle, c.pos, pos.z + c.radius)){
      c.trapTimer = millis()+1000;
      triggered = true;
    }
    if(triggered)
    {
        triggered = false;
        PVector attackPos = new PVector(pos.x, pos.y);
        attackPos.add(PVector.mult(facing,20));
        if(inRadius(middle, c.pos, pos.z + c.radius))
        {
          ahhh.play();
          c.injure(damage, 0);
          if(c.mass != 0) 
          {
            PVector away = PVector.sub(c.pos, pos);
            away.z = 0;
            away.normalize();
            away.mult(3);
            away.z = 2;
            away.mult(knock_back/(8+c.mass));
            c.vel = away;
          }
          if(!(c instanceof Loot))
          {
              if(!c.oiled){
                textParticles.add(new TextBlip(pos, 60, "+"+pointAmt, color(255,255,255), 25));
                textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Spiked!", color(255, 255, 255), 35));
                addScore(pointAmt, 1);
              }
              else{
                textParticles.add(new TextBlip(pos, 60, "+"+(pointAmt+15), color(255,0,20), 25));
                textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Oil Spiked!", color(255, 0, 20), 35));
                addScore(pointAmt+15, 2);
              }
            
          }  
      }
    }
  }
}

class Explosive extends Trap
{
  boolean exploded;
  Explosive(float x, float y, PVector fac, int orient)
  {
    super(x,y, 100, fac, orient);
    pointAmt = 0;
    damage = 0;
    tWidth = 50;
    tHeight = 33;
    knock_back = 0;
    triggered = false;
    exploded = false;
    middle = new PVector(pos.x+25, pos.y + 15);
  }
  
  void draw()
  {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(radians(orientation));
    if(!triggered)
      image(tnt, 0, 0, tWidth, tHeight);
    else{
      image(tntexplode, 0, 0);
      damage = 15;
      tWidth = 100;
      tHeight = 100;
      knock_back = 20;
      pointAmt = 10;
      exploded = true;
    }
    popMatrix();
  }
  void resolveCollision(Sprite c)
  {
      PVector attackPos = new PVector(pos.x, pos.y);
      attackPos.add(PVector.mult(facing,20));
      if(inRadius(middle, c.pos, pos.z + c.radius) && triggered)
      {
        if(c instanceof Decoy){
          if(c.hp>-5){
                textParticles.add(new TextBlip(pos, 60, "+"+pointAmt + 10, color(0,0,0)));
                textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Decoysploded!", color(255, 0, 20), 35));
                addScore(pointAmt+10,3);
          }
        }
        if(c.sludged)
        {
          textParticles.add(new TextBlip(pos, 60, "+"+pointAmt+ 5, color(0,0,0)));
          textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Sludgeploded!", color(255, 0, 20), 35));
          addScore(pointAmt+10,2);
        }
        c.injure(20, 0);
        if(c.mass != 0) 
        {
          PVector away = PVector.sub(c.pos, pos);
          away.z = 0;
          away.normalize();
          away.mult(3);
          away.z = 2;
          away.mult(knock_back/(4+c.mass));
          c.vel = away;
        }
        if(!(c instanceof Loot))
        {
          textParticles.add(new TextBlip(pos, 60, "+"+pointAmt, color(0,0,0)));
          textParticles.add(new TextBlip(new PVector(width/2, height/2), 120, "Exploded!", color(255, 255, 255), 30));
          addScore(pointAmt,1);
        }
     }  
  }
  
}

void doControls()
{
  player.heading.x = 0;
  player.heading.y = 0;
  
  if(keys[KEY_UP])
    player.heading.y += -1;
  if(keys[KEY_DOWN])
    player.heading.y += 1;
  if(keys[KEY_LEFT])
    player.heading.x += -1;
  if(keys[KEY_RIGHT])
    player.heading.x += 1;
  
  if(!(player.heading.x ==0 && player.heading.y == 0)){
        if(player.heading.x == 1){
          if(player.heading.y == 0)
            player.rotation = (float)(3*PI/2);
          else if(player.heading.y == 1)
            player.rotation = (float)(7*PI/4);
          else
            player.rotation = (float)(5*PI/4);
        }
        else if(player.heading.x == 0){
          if(player.heading.y == 1)
            player.rotation = 0;
          else
            player.rotation = (float)(PI);
        }
        else if(player.heading.x == -1){
          if(player.heading.y == -1)
            player.rotation = (float)(3*PI/4);
          else if(player.heading.y == 0)
            player.rotation = (float)(PI/2);
          else
            player.rotation = (float)(PI/4);
        }
  }
  if(levelBeaten){
   if(keys[KEY_POWER1]  && !power1Chosen) {
     if(credits>=1){
       credits-=1;;
       power1Chosen = true;
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Power acquired!", color(255, 0, 120), 25));
       ((Attack)player.attacks.get(0)).knock_away += 1.5;
       ((Attack)player.attacks.get(1)).knock_away += 1.5;
       powerAcqSound.play();  
     }
     else
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Not enough credits!", color(255, 0, 120), 25));
   }
   else if (keys[KEY_POWER2]  && !power2Chosen && !hasSludge){
     if(credits>=2){
       credits-=2;
       power2Chosen = true;
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Power acquired!", color(255, 0, 120), 25));
       hasSludge = true;
       powerAcqSound.play();
     }
     else
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Not enough credits!", color(255, 0, 120), 25));
   }
   else if (keys[KEY_POWER3]  && !power3Chosen && !hasBite){
     if(credits>=12){
       credits-=12;
       power3Chosen = true;
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Power acquired!", color(255, 0, 120), 25));
       hasBite = true;
       bite = new Bite();
       player.attacks.add(bite);
       powerAcqSound.play();
     }
     else
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Not enough credits!", color(255, 0, 120), 25));
   }
   else if (keys[KEY_POWER4]  && !power4Chosen && !hasDecoy){
     if(credits>=5){
       credits-=5;
       power4Chosen = true;
       hasDecoy = true;
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Power acquired!", color(255, 0, 120), 25));
       powerAcqSound.play(); 
     }
     else
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Not enough credits!", color(255, 0, 120), 25));
   }
   else if (keys[KEY_POWER5]  && !power5Chosen && !hasOil){
     if(credits>=4){
       credits-=4;
       power5Chosen = true;
       hasOil = true;
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Power acquired!", color(255, 0, 120), 25));
       powerAcqSound.play(); 
     }
     else
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Not enough credits!", color(255, 0, 120), 25));
   }
   else if (keys[KEY_POWER6]  && !power6Chosen){
     if(credits>=10){
       credits-=10;
       power6Chosen = true;
       player.max_hp += 2;
       player.hp = player.max_hp;
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Health acquired!", color(255, 0, 120), 25));
       powerAcqSound.play(); 
     }
     else
       textParticles.add(new TextBlip(new PVector(width/2, height/2 - 150), 120, "Not enough credits!", color(255, 0, 120), 25));
   }
  }
  
  player.heading.normalize();

}

void addScore(int amt, int cred)
{
  score+= amt;
  credits+= cred;
}

void zonePlayer()
{
  boolean zoned = false;
  if(player.pos.x < 60)
  {
    player.pos.x = 60;
  }
  if(player.pos.y < 65)
  {
    if(player.pos.x>130 && player.pos.x<170 && levelBeaten)
      nextWorld();
     else
       player.pos.y = 65;
  }
  
  if(player.pos.x > width-70)
  {
    player.pos.x = width-70;
  }
  if(player.pos.y > height-55)
  {
    player.pos.y = height-55;
  }

  if(zoned)
  {
    for(int i = 0; i < world[world_x][world_y].sprites.size(); i++)
    {
      Sprite c = (Sprite) world[world_x][world_y].sprites.get(i);
      if(c != player) 
      {
        c.hp = c.max_hp;
        c.name_timer = NAME_TIME;
      }
    }
      textParticles.clear();
      smokeParticles.clear();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////

void initializeWorld()
{
  musicPlaying = false;
  gameOverSound.pause();
  bgm.loop();
  bellSound.play();
  player = new Hero(width/2, height/2);
  smokeParticles = new ParticleList();
  textParticles = new ParticleList();
  loot_drop = new ArrayList();
  score = 0;
  credits = 0;
  decoyPresent = false;
  hasDecoy = false;
  hasOil = false;
  hasSludge = false;
  hasBite = false;
  soundPlayed = false;
  level = 1;
  stage = 1;
  cheated = false;
  power1Chosen = power2Chosen = power3Chosen = power4Chosen = power5Chosen = power6Chosen = false;
  won = false;
  overlay_text = "";
  world = new Screen[WORLD_WIDTH][WORLD_HEIGHT];
  for(int wx = 0; wx < WORLD_WIDTH; wx++) for(int wy = 0; wy < WORLD_HEIGHT; wy++)
  {
    world[wx][wy] = new Screen();
    world[wx][wy].sprites.add(player);
  }

  world_x = WORLD_START_X;
  world_y = WORLD_START_Y;

  testScreen = world[world_x][world_y];

  player.attacks.add(new Punch());
  player.attacks.add(new Punch()); 
  
  //You can add test enemies here
  for(int i = 0; i < 1; i++){
    world[2][2].sprites.add(new Enemy(random(width), random(height)));
    world[2][2].traps.add(new Spikes(640, 200, new PVector(-1,0), 0));
  }
}

void nextWorld()
{
  bellSound.play();
  explosive = null;
  soundPlayed = false;
  smokeParticles = new ParticleList();
  textParticles = new ParticleList();
  loot_drop = new ArrayList();
  decoyPresent = false;
  player.name = "Hero";
  stage++;
  levelBeaten = false;
  cheated = false;
  won = false;
  power1Chosen = power2Chosen = power3Chosen = power4Chosen = power5Chosen = power6Chosen = false;
  overlay_text = "";
  world = new Screen[WORLD_WIDTH][WORLD_HEIGHT];
  player.walk_speed = PLAYER_WALK_SPEED;
  player.sludged = false;
  for(int wx = 0; wx < WORLD_WIDTH; wx++) for(int wy = 0; wy < WORLD_HEIGHT; wy++)
  {
    world[wx][wy] = new Screen();
    world[wx][wy].sprites.add(player);
  }

  world_x = WORLD_START_X;
  world_y = WORLD_START_Y;

  testScreen = world[world_x][world_y];
  
  //You can add levels here
  switch(stage){
    case 11:
      gameBeat = true;
       break;  
    case 10:
      world[2][2].sprites.add(new Boss(width/2, height/2));
      world[2][2].traps.add(new Spikes(640, 200, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(640, 200 +100, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(640, 200 -100, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(263, 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(263 + (100), 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(263 + (100*2), 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(263 + (100*3), 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(15, 90, new PVector(-1,0), 180));
      world[2][2].traps.add(new Spikes(15, 90 + 100, new PVector(-1,0), 180));
      world[2][2].traps.add(new Spikes(15, 90 + (100*2), new PVector(-1,0), 180));
      world[2][2].traps.add(new Spikes(80, 400, new PVector(-1,0), 90));
      world[2][2].traps.add(new Spikes(80 + 100, 400, new PVector(-1,0), 90));
      world[2][2].traps.add(new Spikes(80 + (100*2), 400, new PVector(-1,0), 90));
      world[2][2].traps.add(new Spikes(565, 400, new PVector(-1,0), 90));
      player.oilTimer -= 1001;
      world[2][2].traps.add(new Oil(204,175, new PVector(0,0),0));
      world[2][2].traps.add(new Oil(483,152, new PVector(0,0),0));
      world[2][2].traps.add(new Oil(480,301, new PVector(0,0),0));
      world[2][2].traps.add(new Oil(207,331, new PVector(0,0),0));
      world[2][2].sprites.add(new ToughEnemy(150, 150));
      world[2][2].sprites.add(new ToughEnemy(350, 150));
      break;
    case 9:
      world[2][2].traps.add(new Spikes(640, 200, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(640, 200 +100, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(640, 200 -100, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(263, 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(263 + (100), 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(263 + (100*2), 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(263 + (100*3), 15, new PVector(-1,0), 270));
      world[2][2].traps.add(new Spikes(15, 90, new PVector(-1,0), 180));
      world[2][2].traps.add(new Spikes(15, 90 + 100, new PVector(-1,0), 180));
      world[2][2].traps.add(new Spikes(15, 90 + (100*2), new PVector(-1,0), 180));
      world[2][2].traps.add(new Spikes(80, 400, new PVector(-1,0), 90));
      world[2][2].traps.add(new Spikes(80 + 100, 400, new PVector(-1,0), 90));
      world[2][2].traps.add(new Spikes(80 + (100*2), 400, new PVector(-1,0), 90));
      world[2][2].traps.add(new Spikes(565, 400, new PVector(-1,0), 90));
      world[2][2].sprites.add(new FastEnemy(100,100));
      world[2][2].sprites.add(new FastEnemy(150,100));
      world[2][2].sprites.add(new FastEnemy(200,100));
      world[2][2].sprites.add(new FastEnemy(250,100));
      break;
    case 8:
      world[2][2].sprites.add(new FastEnemy(100,150));
      world[2][2].sprites.add(new Enemy(150,100));
      world[2][2].sprites.add(new Enemy(400,100));
      world[2][2].sprites.add(new Enemy(500,100));
      explosive = new Explosive(width/2, height/2, new PVector(0, 0), 0 );
      world[2][2].traps.add(explosive);
      world[2][2].sprites.add(new Trigger(300, 250));
      beamX = new Beam(580, 70, new PVector(-1,0), 0);
      world[2][2].traps.add(beamX);
      plateX = new Plate(560,70, new PVector(0,0),0, beamX);
      world[2][2].traps.add(plateX);
      beamX2 = new Beam(100, 70, new PVector(-1,0), 0);
      world[2][2].traps.add(beamX2);
      plateX2 = new Plate(70,300, new PVector(0,0),0, beamX2);
      world[2][2].traps.add(plateX2);
      break;  
    case 7:
      world[2][2].sprites.add(new FastEnemy(100,100));
      world[2][2].sprites.add(new FastEnemy(300,100));
      world[2][2].sprites.add(new FastEnemy(500,100));
      world[2][2].sprites.add(new Enemy(250,100));
      world[2][2].sprites.add(new Enemy(300,100));
      player.oilTimer -= 1001;
      world[2][2].traps.add(new Oil(400,70, new PVector(0,0),0));
      world[2][2].traps.add(new Oil(400,370, new PVector(0,0),0));
      beamX = new Beam(231, 70, new PVector(-1,0), 0);
      world[2][2].traps.add(beamX);
      plateX = new Plate(90,70, new PVector(0,0),0, beamX);
      world[2][2].traps.add(plateX);
      beamX2 = new Beam(400, 70, new PVector(-1,0), 0);
      world[2][2].traps.add(beamX2);
      plateX2 = new Plate(300,70, new PVector(0,0),0, beamX2);
      world[2][2].traps.add(plateX2);
      world[2][2].traps.add(new Spikes(640, 200, new PVector(-1,0),0));
      break;
    case 6:
      explosive = new Explosive(425, height/2, new PVector(0, 0), 0 );
      world[2][2].traps.add(explosive);
      world[2][2].sprites.add(new Trigger(181, 250));
      beamX = new Beam(181, 70, new PVector(-1,0), 0);
      world[2][2].traps.add(beamX);
      plateX = new Plate(560,70, new PVector(0,0),0, beamX);
      world[2][2].traps.add(plateX);
      world[2][2].sprites.add(new ToughEnemy(250, 150));
      break;
    case 5:
      world[2][2].sprites.add(new Enemy(100,100));
      world[2][2].sprites.add(new Enemy(400,100));
      world[2][2].sprites.add(new Enemy(500,100));
      world[2][2].sprites.add(new Enemy(250,100));
      explosive = new Explosive(width/2 + 100, height/2, new PVector(0, 0), 0 );
      world[2][2].traps.add(explosive);
      world[2][2].sprites.add(new Trigger(80, 150));
      world[2][2].traps.add(new Spikes(640, 200, new PVector(-1,0),0));
      break;
    case 4:
      world[2][2].sprites.add(new FastEnemy(200,100));
      world[2][2].sprites.add(new Enemy(300,100));
      world[2][2].sprites.add(new Enemy(500, 100));
      beamX = new Beam(271, 70, new PVector(-1,0),0);
      world[2][2].traps.add(beamX);
      plateX = new Plate(90,70, new PVector(0,0),0, beamX);
      world[2][2].traps.add(plateX);
      world[2][2].traps.add(new Spikes(263 + (100*3), 15, new PVector(-1,0), 270));
      break;  
    case 3:
      world[2][2].sprites.add(new Enemy(150,100));
      world[2][2].sprites.add(new Enemy(400,100));
      world[2][2].traps.add(new Spikes(640, 200+84, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(640, 200-84, new PVector(-1,0), 0));
      world[2][2].traps.add(new Spikes(15, 90, new PVector(-1,0), 180));  
    case 2:
      world[2][2].sprites.add(new Enemy(450,150));
      world[2][2].traps.add(new Spikes(15, 90 + (100*2), new PVector(-1,0), 180));
    default:
      world[2][2].traps.add(new Spikes(640, 200, new PVector(-1,0), 0));
      world[2][2].sprites.add(new Enemy(100, 100));
  }
  
  //Reset player position to be near the door
  player.pos.x = 470;
  player.pos.y = 420;
}

void setup()
{
  at_title = true;
  at_instruct = false;
  at_pow = false;
  size(720, 480,P2D);

  frameRate(60);

  gameBeat = false;
  
  HIGH_SCORE1 = 590;
  HIGH_SCORE2 = 420;
  HIGH_SCORE3 = 300;

  //INSERT LEVEL IMAGES HERE
  bckgrnd1 = loadImage("data/levelTemplateDoorClosed.png");
  bckgrnd2 = loadImage("data/levelTemplateDoorOpen.png");
  //INSERT TRAP IMAGES HERE
  spikesLeft = loadImage("data/spikesLeft.png");
  spikesRight = loadImage("data/spikesRight.png");
  spikesUp = loadImage("data/spikesUp.png");
  spikesDown = loadImage("data/spikesDown.png");
  tnt = loadImage("data/tnt.png");
  tntexplode = loadImage("data/explosion.png");
  trigger = loadImage("data/trigger.png");
  triggerclosed = loadImage("data/triggerclosed.png");
  sludge = loadImage("data/sludge.png");
  teeth = loadImage("data/teeth.png");
  teethUsed = loadImage("data/teethUsed.png");
  oil = loadImage("data/oil.png");
  plate = loadImage("data/plate.png");
  turret = loadImage("data/turret.png");
  //INSERT HERO IMAGE HERE
  hero = new Animation("data/Boxer2(", 15);
  beam = new Animation("data/beam(", 7);
  decoy = loadImage("data/decoy.png");
  decoyZombie = loadImage("data/decoyZombie.png");
  //INSERT ENEMY IMAGES HERE
  boss = loadImage("data/boss.png");
  enemy = loadImage("data/suit.png");
  enemyDrugged = loadImage("data/suitZombie.png");
  toughEnemy = loadImage("data/ToughGuy.png");
  toughEnemyDrugged = loadImage("data/ToughGuyZombie.png");
  fastEnemy = loadImage("data/ninja.png");
  ninjaDrugged=  loadImage("data/ninjaZombie.png");
  boss = loadImage("data/boss.png");
  //INSERT ATTACK IMAGES HERE
  punch = loadImage("data/glove.png");
  powerPunch = loadImage("data/powerPunch.png");
  //INSERT MISCELLEANOUS IMAGES HERE
  textC = loadImage("data/textC.png");
  textV = loadImage("data/textV.png");
  textB = loadImage("data/textB.png");
  textD = loadImage("data/textD.png");
  volume = loadImage("data/volume.png");
  volumeOff = loadImage("data/volumeOff.png");
  powers = loadImage("data/powers.png");
  instructions = loadImage("data/instructions.png");
  
  font = loadFont("Rockwell-CondensedBold-32.vlw");
  openSound();
  //bgm.setGain(-10);


}
void draw()
{
  if(gameBeat){
    if(!musicPlaying){
      bgm.pause();
      gameOverSound.loop();
      musicPlaying = true;
    }
    background(color(0,0,0));
    textSize(35);
    text("Congratulations! Your score is " + score + "!\n\nPress SPACE twice to play again.\n\nLEADERBOARD\n\n1. " + high1 + " - "  + first + "\n2. "+ high2 + " - "  + second + "\n3. "+ high3 + " - " + third , width/2, 70);
    if(score>HIGH_SCORE1){
      high1 = "You";
      high2 = "Ben";
      high3 = "Jon";
      first = score;
      second = HIGH_SCORE1;
      third = HIGH_SCORE2;
    }
    else if(score> HIGH_SCORE2){
      high1 = "Ben";
      high2 = "You";
      high3 = "Jon";
      first = HIGH_SCORE1;
      second = score;
      third = HIGH_SCORE2;
    }
    else if(score> HIGH_SCORE3){
      high1 = "Ben";
      high2 = "Jon";
      high3 = "You";
      first = HIGH_SCORE1;
      second = HIGH_SCORE2;
      third = score;
    }
    else{
      high1 = "Ben";
      high2 = "Jon";
      high3 = "Chris";
      first = HIGH_SCORE1;
      second = HIGH_SCORE2;
      third = HIGH_SCORE3;
    }
  }
  else if(!at_title && !at_instruct && !at_pow)
  {
    if(player.hp <=0)
    {
      overlay_text = "GAME OVER\npress SPACE to try again";
    }
    else doControls();
    if(!levelBeaten){
      background(bckgrnd1);
    }
    else{
      background(bckgrnd2);
      if(!soundPlayed){
        doorSound.play();
        soundPlayed = true;
    }
    }
    if(!muted)
      image(volume, 680, 20, 30,30);
    else
      image(volumeOff, 680,20,30,30);
    
    ellipseMode(RADIUS);  
      
    if(!paused) world[world_x][world_y].stepPhysics();
    zonePlayer();
    world[world_x][world_y].draw();
  
    smokeParticles.draw();
    if(!paused) smokeParticles.tick();
    textParticles.draw();
    if(!paused) textParticles.tick();
    //drawMap(width-158, 8, 150, 100);
    fill(255);
    textAlign(LEFT, TOP);
    textSize(18);
    text("Credits: "+credits+"\nScore: "+score+"\nStage: "+stage+"\nHP: "+player.hp+"/"+player.max_hp, 8, 8);
    //won = true;
    levelBeaten = true;
    boolean kobolds = true;
    boolean massacre = true;
    /*for(int x = 0; x < WORLD_WIDTH; x++)  for(int y = 0; y < WORLD_HEIGHT; y++)
    {*/
      if(world[2][2].cleared == false) levelBeaten = false;
      if(world[2][2].killedFriendly == true) kobolds = false;
      if(world[2][2].sprites.isEmpty() == false) massacre = false;
    //}
    if(levelBeaten)
    {
      overlay_text = "Level Cleared!\n";
      textSize(20);
      overlay_text += "\nPower Store\n\n T for Health Boost(10 Credits)\nY for Power Punch(15 Credits)\nU for Sludge(2 Credits)\nI for Zombie Bite(12 Credits)\nO for Decoy(5 Credits)\nP for Oil(4 Credits)\nThen go through the door to go to the next level.";
    }
    
    textAlign(CENTER, TOP);
    text(overlay_text, width/2, height/3 - 100);
      if(hasDecoy){
        image(decoy, 70, 440, 30,35);
        image(textC, 85, 440, 20, 20);
    }
    if(hasSludge){
      image(sludge, 110, 440, 30,35);
      image(textV, 125, 440, 20, 20);
    }
    if(hasOil){
      player.oilTimer -= 1001;
      image(oil, 190, 440, 30,35);
      image(textD, 205, 440, 20, 20);
    }
    if(hasBite){
      image(teeth, 150, 445, 35, 20);
      if(useBite)
        image(teethUsed, 150, 445, 35, 20);
      image(textB, 165, 440, 20, 20);
    }
    if(((Attack)(player.attacks.get(0))).knock_away == 3.5)
      image(powerPunch, 30, 440, 40, 32);
  }
  else
  {
    if(at_title){
      background(color(219,115,13));
      textFont(font, 15);
      textAlign(CENTER, TOP);
      text("PUTREFIED PUGILIST REVENGE\n\nYou are the once renowned (and now dead) heavy-weight championship runner-up Bruce Punchalot.\nYou have risen from the depths of the Earth so that you may exact revenge on the corrupt National\n Boxing Federation who rigged the championship match, robbing you of your title and causing you to \ncommit suicide as a result. Your mission is to kill everyone. There is a problem however. Your arms \nare weak and rotten and are thus not capable of doing much damage. As such you should try \nand use the dangerous environment of the NBF Headquarters to your advantage.\n Press SPACE to begin.", width/2, height/3);
    }
    else if(at_instruct)
      background(instructions);
    else if(at_pow)
      background(powers);
  }
}

void stop()
{
  closeSound();
  super.stop();
}

void togglePause()
{
  paused = !paused;
  //if(paused) bgm.mute();
  //else bgm.unmute();
}
/////////////// INPUT HANDLING CODE
//input processing goes here:

void keyPressed()
{
  if(!keys[keyCode]) 
  {
    keys[keyCode] = true;
    down(keyCode);
  }
}
void keyReleased()
{
  if(keys[keyCode])
  {
    keys[keyCode] = false;
    up(keyCode);
  }
}
void down(int theKey)
{
  if(!at_title && !at_pow && !at_instruct)
  {
  if(theKey == 32 && (player.hp <= 0 || won))
  {
    initializeWorld(); // temporary game over

  }
  else if(theKey == 32) togglePause();

  
  if(!paused)
  {
  //println(theKey + " down");  

  if(theKey == KEY_JUMP && player.combo == -1 && player.stun_timer == 0)
  {
    if(!player.airborne) player.vel.z = JUMP_STRENGTH;
  }
  if(theKey == KEY_SPECIAL)
 {
   if(hasDecoy){
     aDecoy = new Decoy(player.pos.x+(50*player.facing.x), player.pos.y+(50*player.facing.y));
     world[2][2].sprites.add(aDecoy);
     decoyPresent = true;
     hasDecoy = false;
   }
 }
  if(theKey == KEY_SPECIAL2)
 {
   if(hasSludge){
     aSludge = new Sludge(player.pos.x+(80*(player.facing.x - player.facing.x*2)), player.pos.y+(80*(player.facing.y - 2*player.facing.y)), new PVector(0,0),0);
     world[2][2].traps.add(aSludge);
     hasSludge = false;
   }
 }
 
 if(theKey == KEY_SPECIAL3)
 {
   if(hasBite){
     useBite = true;
   }
 }
 if(theKey == KEY_SPECIAL4)
 {
   if(hasOil){
     aOil = new Oil(player.pos.x+(90*(player.facing.x - player.facing.x*2)), player.pos.y+(90*(player.facing.y - 2*player.facing.y)), new PVector(0,0),0);
     world[2][2].traps.add(aOil);
     hasOil = false;
   }
 }
 if(theKey == 32)
   if(gameBeat){
     gameBeat = false;
     initializeWorld();
   }
 if(theKey == KEY_MUTE){
   if(!muted){
     muted = true;
     ahhh.mute();
     biteSound.mute();
     powerAcqSound.mute();
     punchSound.mute();
     laserSound.mute();
     bellSound.mute();
     knifeSound.mute();
     stompSound.mute();
     oilSound.mute();
     gameOverSound.mute();
     sludgeSound.mute();
     explodeSound.mute();
     bgm.mute();
     deathSound.mute();
     doorSound.mute();
   }
   else{
     muted = false;
     punchSound.unmute();
     bgm.unmute();
     deathSound.unmute();
     doorSound.unmute();
   }
 }
  if(theKey == KEY_ATTACK) player.attack_cue = true;
  if(theKey == KEY_PHATLOOT) {
    console.log("CHEATER!");
    cheated = true; 
    hasDecoy = hasSludge = hasOil = hasBite = true;
    bite = new Bite();
    player.attacks.add(bite);
  }
  if(theKey == KEY_KILLALL) 
  {
    cheated = true;
    int sz = world[world_x][world_y].sprites.size();
    for(int i = 0; i < sz; i++)
    {
      Sprite c = (Sprite) world[world_x][world_y].sprites.get(i);
      if(c.hostile) c.hp = 0;
    }
  }
  }
  }
  else
  {
    if(theKey == 32 && !at_pow) 
    {
      at_title = false;
      at_instruct = true;
      //initializeWorld();
    }
    if(theKey == KEY_NEXT && at_instruct)
    {
      at_instruct = false;
      at_pow = true;
    }
    if(theKey == 32 && at_pow)
    {
      at_pow = false;
      initializeWorld();
    }
  }
}
void up(int theKey)
{
  //println(theKey + " up");
}

// Class for animating a sequence of GIFs

class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  
  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, 4) + ").png";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos, int w, int h) {
    frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos, w, h);
  }
  
  int getWidth() {
    return images[0].width;
  }
}