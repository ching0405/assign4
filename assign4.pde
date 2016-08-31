Shoot[] s;

final int GAME_START = 0;
final int GAME_RUN = 1;
final int GAME_END = 2;

PImage enemyImg, fighterImg, treasureImg, hpImg, bg1Img, bg2Img, shootImg;
PImage start1Img, start2Img, end1Img, end2Img;

int numFrames=5;
int currentFrame = 0;
PImage [] flameImg = new PImage[numFrames];

float hpFull, hp, hpDamage, hpAdd, enemy;
float treasureX, treasureY, fighterX, fighterY, enemyX, enemyY;
float enemySpeed, fighterSpeed, shootSpeed, bg1Move, bg2Move;
float enemySpacingX, enemySpacingY;
float[][] x_enemys = new float[3][8];
float[][] y_enemys = new float[3][8];

int shootNum = 0;
int shootCount = 5;
int lastTime = 0;
int gameState;
int enemyArray;

boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;
boolean[] spacePressed = new boolean[shootCount];
boolean[][] remove = new boolean[3][8];
boolean[][] flame = new boolean[3][8];

void setup(){ 
  size(640,480) ;

  enemyImg = loadImage("img/enemy.png");
  fighterImg = loadImage("img/fighter.png");
  treasureImg = loadImage("img/treasure.png");
  hpImg = loadImage("img/hp.png");
  shootImg = loadImage("img/shoot.png");
  bg1Img = loadImage("img/bg1.png");
  bg2Img = loadImage("img/bg2.png");
  start1Img = loadImage("img/start1.png");
  start2Img = loadImage("img/start2.png");
  end1Img = loadImage("img/end1.png");
  end2Img = loadImage("img/end2.png");
  
  //flame img
  for (int i=0; i<numFrames; i++){
    flameImg[i] = loadImage("img/flame" + (i+1) + ".png"); 
  }
      
  //hp 
  hpFull = 194;
  hp = hpFull*2/10;
  hpDamage = hpFull*2/10;
  hpAdd = hpFull/10;  

  //move control
  enemySpeed = 4;
  fighterSpeed = 5;
  shootSpeed = 5;
  bg1Move = 0;
  bg2Move = -640;  

  //subject location
  treasureX = floor(random(600));
  treasureY = floor(random(35,440));
  enemyX = 0;  
  enemyY = floor(random(height - enemyImg.height));
  enemySpacingX = 80;
  enemySpacingY = 40;
  fighterX = width - fighterImg.width;
  fighterY = (height - fighterImg.height)/2; 
          
  gameState = GAME_START;
  enemyArray = 0;
  
  for(int i = 0; i < 3; i++){
    for(int j =0; j < 8; j++){      
      remove[i][j] = true;
      flame[i][j] = false;
    }
  }
  
  s = new Shoot[shootCount];
  for(int i = 0; i < shootCount; i++){
    spacePressed[i] = false;
    s[i] = new Shoot();
  }
}

void draw() { 
  switch (gameState){
    case GAME_START:
      image(start2Img, 0, 0);    
      if (mouseX > 210 && mouseX < 450 && mouseY > 370 && mouseY < 410){
        if (mousePressed){
          gameState = GAME_RUN;
        }else{
          image(start1Img, 0, 0);
        }
      }  
      break;
      
    case GAME_RUN:
      //background
      bg1Move += 1;
      if(bg1Move == width){
        bg1Move *= -1;
      }
      image(bg1Img,bg1Move,0);      
      bg2Move += 1;
      if(bg2Move == width){
        bg2Move *= -1;
      }
      image(bg2Img,bg2Move,0);  

      //shoot
      for(int i = 0; i < shootCount; i++){
        if (!spacePressed[i]) {
          s[i].start(fighterX+fighterImg.width/3, fighterY+fighterImg.height/4,i);
        }
        if (spacePressed[i]) {
            s[i].display();
            s[i].move();
        }
      }

      //fighter
      image(fighterImg, fighterX, fighterY);  
      if (upPressed) {
        fighterY -= fighterSpeed;
      }
      if (downPressed) {
        fighterY += fighterSpeed;
      }
      if (leftPressed) {
        fighterX -= fighterSpeed;
      }
      if (rightPressed) {
        fighterX += fighterSpeed;
      }           
        
      //fighter boundary detection  
      fighterX = (fighterX > width - fighterImg.width) ? width - fighterImg.width : fighterX;
      fighterX = (fighterX < 0) ? 0 : fighterX;
      fighterY = (fighterY > height - fighterImg.height) ? height - fighterImg.height : fighterY;
      fighterY = (fighterY < 0) ? 0 : fighterY;

      //treasure
      image(treasureImg, treasureX, treasureY);
      if(fighterX+fighterImg.width >= treasureX && fighterX <= treasureX+treasureImg.width && fighterY+fighterImg.height >= treasureY && fighterY <= treasureY+treasureImg.height){
        hp += hpAdd;
        treasureX = floor(random(600));
        treasureY = floor(random(35,440));
        hp = (hp > hpFull) ? hpFull : hp;       
      }      
      
      //enemy      
      enemyX += enemySpeed;
      enemyX %= width + 4*enemySpacingX;       
      if(enemyX == 0){
        enemyY = floor(random(height - enemyImg.height));        
        enemyArray++;
        currentFrame = 0;
        for(int i = 0; i < 3; i++){
          for(int j =0; j<8; j++){      
            remove[i][j] = true;
            flame[i][j] = false;
          }
        }
      }

      switch (enemyArray){      
        case 0:            
        for(int i = 0; i < 5; i++){
          if (remove[enemyArray][i]){
            x_enemys[enemyArray][i] = enemyX - i*enemySpacingX;
            y_enemys[enemyArray][i] = enemyY;
            image(enemyImg, x_enemys[enemyArray][i], y_enemys[enemyArray][i]);  
            crush(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);  
            boom(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
          }              
          Flame(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
        }   
        break; 
        
        case 1:                   
        //boundary detection      
        enemyY = (enemyY > (height - enemyImg.height) - 4*enemySpacingY) ? floor(random((height - enemyImg.height) - 4*enemySpacingY)) : enemyY; 
        for(int i = 0; i < 5; i++){
          if (remove[enemyArray][i]){         
            x_enemys[enemyArray][i] = enemyX - i*enemySpacingX;
            y_enemys[enemyArray][i] = enemyY + i*enemySpacingY;
            image(enemyImg, x_enemys[enemyArray][i], y_enemys[enemyArray][i]);  
            crush(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
            boom(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
          }              
          Flame(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
        }       
        break;          
        
        case 2:                  
        //boundary detection
        if(enemyY > (height - enemyImg.height) - 2*enemySpacingY || enemyY < 2*enemySpacingY){
          enemyY = floor(random(2*enemySpacingY, (height - enemyImg.height) - 2*enemySpacingY));
        }

        for(int i = 0; i < 8; i++){
          int j = i % 4;
          j = ( i % 4 > 2) ? 1 : j;
          if (remove[enemyArray][i]){         
            if (i > 4){
              x_enemys[enemyArray][i] = enemyX + (i-8)*enemySpacingX;
              y_enemys[enemyArray][i] = enemyY - j*enemySpacingY;
              image(enemyImg, x_enemys[enemyArray][i], y_enemys[enemyArray][i]); 
              crush(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
              boom(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
            }else{
              x_enemys[enemyArray][i] = enemyX - i*enemySpacingX;
              y_enemys[enemyArray][i] = enemyY + j*enemySpacingY;
              image(enemyImg, x_enemys[enemyArray][i], y_enemys[enemyArray][i]);  
              crush(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
              boom(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
            }         
          }
            Flame(x_enemys[enemyArray][i], y_enemys[enemyArray][i], i, enemyArray);
        }
        break;
      }                 

      enemyArray = (enemyArray > 2) ? 0 : enemyArray;
      
      //hp
      fill(255,0,0); 
      rect(13,3,hp,17);  
      noStroke();      
      image(hpImg,0,0);
      if(hp < 1){
        gameState = GAME_END;
      }     
      break;
      
    case GAME_END:
      image(end2Img, 0, 0);    
      if (mouseX > 210 && mouseX < 435 && mouseY > 304 && mouseY < 350){
        if (mousePressed){                         
          //default value
          treasureX = floor(random(600));
          treasureY = floor(random(35,440));
          enemyX = 0;  
          enemyY = floor(random(height - enemyImg.height));
          fighterX = width - fighterImg.width;
          fighterY = (height - fighterImg.height)/2;              
          hp = hpFull*2/10;
          enemyArray = 0;
          for(int i = 0; i < 3; i++){
            for(int j =0; j<8; j++){      
              remove[i][j] = true;
              flame[i][j] = false;
            }
          }           
          gameState = GAME_RUN;
        }else{
          image(end1Img, 0, 0);
        }
      }
      break;
  } 
}

class Shoot {
  float shootX;
  float shootY;
  int speed = 7;  
  int sNum; 

  void start(float x,float y,int s){
    shootX = x;
    shootY = y;
    sNum = s;
  }  
  
  void move() {
    shootX -= speed; 
    if (shootX < 0) { 
      spacePressed[sNum] = false;
    } 
  }
  
  void display() {
    image(shootImg, shootX, shootY);
  }
}
  

void keyPressed(){
  if (key == CODED) { // detect special keys 
    switch (keyCode) {
      case UP:
        upPressed = true;
        break;
      case DOWN:
        downPressed = true;
        break;
      case LEFT:
        leftPressed = true;
        break;
      case RIGHT:
        rightPressed = true;
        break;
    }
  }
  if (key == ' ') {
    spacePressed[shootNum] = true;
    shootNum++;           
    if(shootNum > (shootCount -1)){
      shootNum = 0;
    }
  } 
}

void keyReleased(){
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        upPressed = false;
        break;
      case DOWN:
        downPressed = false;
        break;
      case LEFT:
        leftPressed = false;
        break;
      case RIGHT:
        rightPressed = false;
        break;
    }   
  }
}

void crush(float x, float y, int i, int a){
  if(fighterX + fighterImg.width >= x && fighterX <= x + enemyImg.width && fighterY + fighterImg.height >= y && fighterY <= y+enemyImg.height){
    remove[a][i] = false;
    hp -= hpDamage; 
    flame[a][i] = true;
  } 
}

void boom(float x, float y, int i, int a){
  for(int j = 0; j < shootCount; j++){
    if(s[j].shootX + shootImg.width >= x && s[j].shootX <= x + enemyImg.width && s[j].shootY + shootImg.height >= y && s[j].shootY <= y + enemyImg.height){ 
    remove[a][i] = false;
    flame[a][i] = true;  
    }
  }
}

void Flame(float x, float y, int i, int a){
  if(flame[a][i]){ 
    if(millis()-lastTime > 100){
      currentFrame++;
      lastTime = millis();
      if(currentFrame > (numFrames -1)){
        flame[a][i] = false;
        currentFrame = 0;
      }      
    }
  image(flameImg[currentFrame], x, y);            
  } 
}
