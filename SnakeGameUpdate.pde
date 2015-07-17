#include <PICxel.h>
#include <EEPROM.h>
#include <string.h>
#include "splash.h"

//#define DEBUG_MODE
#define splash_millisecond_delay 3000
typedef struct snode{
  uint8_t en;
  uint8_t count;
  int *hue;
  uint8_t sat;
  uint8_t val;
  struct snode* tailptr;
}SNODE;

#define UP 0        //yellow, 34
#define LEFT 1      //blue, 35
#define DOWN 2      //green, 36
#define RIGHT 3     //brown, 37

#define RESET_ST 0
#define TITLE_ST 1
#define RUN_GAME_ST 2
#define GAMEOVER_ST 3

#define number_of_LEDs 900
#define number_of_bytes 3600
#define LED_pin 3
#define millisecond_delay 1

PICxel strip(number_of_LEDs, LED_pin, HSV, noalloc);

uint8_t sketch_color_array[number_of_bytes];

uint8_t head[2]={6,1};
uint8_t food[2];
uint8_t dir=RIGHT;
uint8_t lastdir=RIGHT;
uint8_t length=6;
snode grid[30][30];
int lastupdate;
uint8_t lastbuf[2];
static int i,j;
uint16_t difficulty=500;
int snakehue=500;

int backhue=700;

int foodhue=214;

int backupdate=0;

const uint8_t snakebrightness=200;
const uint8_t backbrightness=15;

const uint8_t refreshrate=15;

int time =0;
int timeDif = 0;

char strtemp[30];
char strtemp2[30];

uint32_t EEPROM_temp[4];

#define CHANGE_HEAP_SIZE(size) __asm__ volatile ("\t.globl _min_heap_size\n\t.equ _min_heap_size, " #size "\n")

CHANGE_HEAP_SIZE(0x0);

extern __attribute__((section("linker_defined"))) char _heap;
extern __attribute__((section("linker_defined"))) char _min_heap_size;

snode* snake_ptr;
uint8_t changed_flag = 0;
uint8_t update_flag = 0;
uint8_t game_state = RESET_ST;

int splash_prevTime = 0;
int splash_state = 0;

void setup() {
  //start the serial monitor to show the high score when the game ends
  Serial.begin(115200);

  #if defined DEBUG_MODE
    Serial.println("Microcontroller Starting up");
  #endif

  strip.setArrayPointer(sketch_color_array);

  randomSeed(analogRead(A3));
  
  strip.begin();
  reset_grid(); 

//  for(int i=0; i<512;i++)
    //EEPROM.write(i, 0);

}

void loop() {
    char temp_char;
    char str_index = 0;
    uint32_t* word_ptr;
    uint32_t word_temp;

    //delay(500);

  switch (game_state) {
    //reset state
    case RESET_ST:
      game_state = TITLE_ST;
    break;

    //run title screen
    case TITLE_ST:   
      snake_splash_screen();
      #if defined DEBUG_MODE
        Serial.println("title screen case");
      #endif

      //check for button press to start game and exit title screen
      if(digitalRead(34)||digitalRead(35)||digitalRead(36)||digitalRead(37)){

        //send highscores
        //send first high score

        #if defined DEBUG_MODE
          Serial.println("\n------------------------");
          Serial.println("Printing first score");
        #endif

        strtemp[0] = 0;
        strcpy(strtemp,"0");
        
        #if defined DEBUG_MODE
          Serial.print("score0: ");
          Serial.print(strtemp);
          Serial.print("|");
        #endif

        itoa(EEPROM.read(0), strtemp2, 10);

        #if defined DEBUG_MODE
          Serial.println(strtemp2);
          Serial.print("data_packet0: ");
        #endif

        strcat(strtemp, strtemp2);
        Serial.println(strtemp);

        //clear string
        strtemp2[0] = 0;
        //read 12 bytes from EEPROM and make into a string
        for(int i=0; i<12; i++){
          strtemp2[i] = EEPROM.read(i+1);
          strtemp2[i+1] = 0;
        }

        Serial.print(strtemp2);

        #if defined DEBUG_MODE
          Serial.print("\nname0: ");
          Serial.println(strtemp2);

          Serial.println("------------------------");
          Serial.println("Printing second score");
        #endif

        strtemp[0] = 0;
        //send second high score
        strcpy(strtemp,"1");

        #if defined DEBUG_MODE
          Serial.print("score1: ");
          Serial.print(strtemp);
          Serial.print("|");
        #endif

        itoa(EEPROM.read(13), strtemp2, 10);

        #if defined DEBUG_MODE
          Serial.println(strtemp2);
          Serial.print("data_packet1: ");
        #endif

        strcat(strtemp, strtemp2);
        Serial.print(strtemp);

        //clear string
        strtemp2[0] = 0;
        //read 12 bytes from EEPROM and make into a string
        for(int i=0; i<12; i++){
          strtemp2[i] = EEPROM.read(i+13);
          strtemp2[i+1] = 0;
        }

        Serial.println(strtemp2);

        #if defined DEBUG_MODE
          Serial.print("\nname1: ");
          Serial.println(strtemp2);

          Serial.println("------------------------");
          Serial.println("Printing third score");
        #endif

        //send third high score
        strtemp[0] = 0;
        strcpy(strtemp,"2");

          #if defined DEBUG_MODE
            Serial.print("score2: ");
            Serial.print(strtemp);
            Serial.print("|");
          #endif
        
        itoa(EEPROM.read(26), strtemp2, 10);

        #if defined DEBUG_MODE
          Serial.println(strtemp2);
          Serial.print("data_packet2: ");
        #endif
        strcat(strtemp, strtemp2);
        Serial.println(strtemp);

        //clear string
        strtemp2[0] = 0;
        //read 12 bytes from EEPROM and make into a string
        for(int i=0; i<12; i++){
          strtemp2[i] = EEPROM.read(i+26);
          strtemp2[i+1] = 0;
        }

        Serial.println(strtemp2);

        #if defined DEBUG_MODE
          Serial.print("\nname2: ");
          Serial.println(strtemp2);
          Serial.println("------------------------\n");
        #endif

        strtemp[0] = 0;
        
        lastupdate=millis();
        backupdate=millis();
        
        game_state = RUN_GAME_ST;
      }
    break;

    //RUN_GAME_ST
    case RUN_GAME_ST:

      #if defined DEBUG_MODE
        Serial.println("Running Game");
      #endif

      run_game();

      Serial.println(length);
    break;

    //game over
    case GAMEOVER_ST:
        death();
      #if defined DEBUG_MODE
        Serial.println("In Gameover state");

        Serial.println("Enter game score: ");

        while(Serial.available())
          temp_char = Serial.read();

        while(Serial.available()==0);
        
        //read in string
        while(Serial.available() > 0){
          temp_char = Serial.read();
          if(str_index < sizeof(strtemp))
            strtemp[str_index++] = temp_char;
        }
        //terminate string
        strtemp[str_index+1] = 0;      

        length = atoi(strtemp);

        Serial.print("You entered: ");
        Serial.println(length);

        Serial.println("Enter name: ");
      #endif

      //clear the strtemp
      strtemp[0] = 0;

      while(Serial.available())
        temp_char = Serial.read();

      //wait until button press or string is recieved
      while((Serial.available()==0)&&(!digitalRead(34))&&(!digitalRead(35))&&(!digitalRead(36))&&(!digitalRead(37)));

      //read in string
      str_index = 0;
      while(Serial.available() > 0){
        temp_char = Serial.read();
        if(str_index < 30)
          strtemp[str_index++] = temp_char;

        delay(1); //needed for some unknown reason!!!!!
      }

      //terminate string
      strtemp[str_index+1] = 0;      


      #if defined DEBUG_MODE
        Serial.print("name: ");
        Serial.println(strtemp);
      #endif

      if(strtemp[0] == 0)
        strcpy(strtemp, "anonymous");

      //horribly inefficient but easy
      //check if new first high score
      if(length > EEPROM.read(0)){


      #if defined DEBUG_MODE
        Serial.println("------------------------");
        Serial.println("replacing score 0");
        Serial.println("------------------------");
      #endif

        //copy 0 and 1 to 1 and 2
        for(int i=25; i>=0; i--)
          EEPROM.write(i+13, EEPROM.read(i));

        EEPROM.write(0, length);

        for(int i=0; strtemp[i]; i++){
          EEPROM.write(i+1, (uint8_t)strtemp[i]);
          EEPROM.write(i+2, 0);
        }
      }

      //check if new second high score
      else if(length > EEPROM.read(13)){

      #if defined DEBUG_MODE
        Serial.println("------------------------");
        Serial.println("replacing score 1");
        Serial.println("------------------------");
      #endif

        //copy 1 to 2
        for(int i=25; i>=13; i--)
          EEPROM.write(i+13, EEPROM.read(i));

        EEPROM.write(13, length);

        for(int i=0; strtemp[i]; i++){
          EEPROM.write(i+13, strtemp[i]);
          EEPROM.write(i+13, 0);
        }
      }

      //check if new third high score
      else if(length > EEPROM.read(26)){

      #if defined DEBUG_MODE
        Serial.println("------------------------");
        Serial.println("replacing score 2");
        Serial.println("------------------------");
      #endif

        EEPROM.write(26, length);

        for(int i=0; strtemp[i]; i++){
          EEPROM.write(i+26, strtemp[i]);
          EEPROM.write(i+26, 0);
        }
      }


      #if defined DEBUG_MODE
        else{
          Serial.println("------------------------");
          Serial.println("not replacing a score");
          Serial.println("------------------------");
        }
      #endif

      reset_grid();

      //print end game score
      strcpy(strtemp,"4");
      itoa(length, strtemp2, 10);
      strcat(strtemp, strtemp2);
      Serial.println(strtemp);

      game_state = RESET_ST;

    break;

    //error case
    default:
      for(int i=0; i<number_of_LEDs; i++)
        strip.HSVsetLEDColor(i, 0, 255, 255);
      break;
  }
}


void run_game(){
  //Buttons connected to 34 (yellow UP) - 35 (blue LEFT) - 36 (green DOWN) - 37 (brown RIGHT)
  //check up
  if(digitalRead(34)){
    if (digitalRead(35)&&digitalRead(36)&&digitalRead(37)){
      reset_grid();
    }
    if(lastdir!=UP)
      dir=DOWN;
  }
  
  //check left
  else if(digitalRead(35)){
    if(lastdir!=RIGHT)
      dir=LEFT;
  }
  
  //check down
  else if(digitalRead(36)){
    if(lastdir!=DOWN)
      dir=UP;
  }

  //check right
  else if(digitalRead(37)){
    if(lastdir!=LEFT)
      dir=RIGHT;
  }
  
  if (millis()-lastupdate>=difficulty){//Update every [difficulty] ms
    lastupdate=millis();
    //moved to changed_flag if statement
    //update();
    
    lastdir=dir;
    snakehue+=5;
    if (snakehue>=1535){
      snakehue=0;
    }

    //background has changed so set flag
    update_flag=1;
    changed_flag = 1;
  }

  //update background color at a certain rate
  if (millis()-backupdate>=refreshrate){
    backupdate=millis();
    backhue+=2;
    if (backhue>=1535){
      backhue=0;
    }

    //background has changed so set flag
    changed_flag = 1;
  }
  
  //only update the array and refresh LEDs if the state has changed
  if(changed_flag == 1){
    if (update_flag){update();update_flag=0;}
    store_array();
    strip.refreshLEDs();
    //clear flag
    changed_flag = 0;
  }
}


void snake_splash_screen(){
    int row, col;
  if(millis()-splash_prevTime > splash_millisecond_delay){
    splash_prevTime = millis();
        if(splash_state){
              //Serial.println("ENTERED SPLASH LOOP");
              loadBitmap(splash_state);    
              //splash_store_array();
              strip.refreshLEDs();
              splash_state = 0;
        }
        else{
              //Serial.println("ENTERED SPLASH LOOP2");
              loadBitmap(splash_state); 
              // Serial.println("check1");   
              //splash_store_array();
              //Serial.println("check2");   
              strip.refreshLEDs();
              splash_state=1;
        }            
  }  
    //Serial.println("Exit_splash");
  delay(1);
}

void splash_store_array(){
  
  uint16_t s = 0;
  
    for(i = 29; i >= 0; i--){ 
    
      if(i % 2 == 0){ //is even
         for(j = 29; j >= 0; j--){
         strip.HSVsetLEDColor(s, *grid[j][i].hue, grid[j][i].sat, grid[j][i].val);
         s ++;        
       }
      }
      else{
        for(j = 0; j < 30; j++){       
         strip.HSVsetLEDColor(s, *grid[j][i].hue, grid[j][i].sat, grid[j][i].val);
         s ++;
       } 
      }         
      }  
}

void loadBitmap(uint16_t* bitmap){
  
  for(i =0; i < (number_of_LEDs * 3); i = i + 3){
          
    int row = (i / 3) / 30;
    int col = (i / 3) % 30;
    *grid[row][col].hue =bitmap[i];
    //Serial.println(bitmap[i],DEC);
    //MainArray[row][col].hue = bitmap[i];
    grid[row][col].sat = 255;
    grid[row][col].val = bitmap[i+2];
          
  }
  
  splash_store_array();
  strip.refreshLEDs();
}

//Updates the 2D snake grid array in memory
void update(){
  lastbuf= {head[0], head[1]};
  switch (dir){
    case UP:
      //if (head[1]==0){reset_grid(); return;}  //if the head runs into the ceiling, you die
      if (head[1]==0){ game_state = GAMEOVER_ST; return;}  //if the head runs into the ceiling, you die
      else head[1]--;
      break;
    case DOWN:
      if (head[1]==29){ game_state = GAMEOVER_ST; return;}  //if the head runs into the floor, you die
      else head[1]++;
      break;
    case RIGHT:
      if(head[0]==29){ game_state = GAMEOVER_ST; return;}  //if the head runs into the right wall, you die
      else head[0]++;
      break;
    case LEFT:
      if(head[0]==0){ game_state = GAMEOVER_ST; return;}  //if the head runs into the left wall, you die
      else head[0]--;
      break;
  }
    snake_ptr=&grid[head[0]][head[1]];
    if (snake_ptr->en==1){game_state = GAMEOVER_ST; return;}//Ran into self!
    if (snake_ptr->en==2){//FOOD!
      length+=2;
      difficulty-=3;
      spawn_food();
    }
    snake_ptr->en=1;
    snake_ptr->count=1;
    snake_ptr->hue=&snakehue;
    snake_ptr->sat=255;
    snake_ptr->val=snakebrightness;
    snake_ptr->tailptr= &grid[lastbuf[0]][lastbuf[1]];
    while(snake_ptr->tailptr){
      if (snake_ptr->tailptr->count<length){//Next segment count is less than length, it lives
        //Serial.println(snake_ptr->count, DEC);
        snake_ptr->tailptr->count++;//Decrement tailptr count
      }
      else{//Next segment count is length so it dies
      //Serial.println("Killed");
        snake_ptr->tailptr->en=0;
        snake_ptr->tailptr->count=0;
        snake_ptr->tailptr->hue=&backhue;
        snake_ptr->tailptr->sat=255;
        snake_ptr->tailptr->val=backbrightness;
        snake_ptr->tailptr=NULL;//Remove tailptr of current segment
        break;
      }
      snake_ptr=snake_ptr->tailptr;
    }
}

//Stores the 2D snake array into the strip library's memory
void store_array(){
 int s = 0;
    for(i = 29; i >= 0 ; i--){
      if(i % 2 == 0){ //is even
       for(j = 0; j < 30; j++){
         strip.HSVsetLEDColor(s, (*grid[i][j].hue + grid[i][j].count*5)%1535, grid[i][j].sat, grid[i][j].val);
         s++;
       }
      }
      else{
       for(j = 29; j >= 0; j--){
         strip.HSVsetLEDColor(s, (*grid[i][j].hue + grid[i][j].count*5)%1535, grid[i][j].sat, grid[i][j].val);
         s++;
       } 
      }
    }
}

void store_blank(){
  int s = 0;
    for(i = 29; i >= 0 ; i--){
      if(i % 2 == 0){ //is even
       for(j = 0; j < 30; j++){
         strip.HSVsetLEDColor(s, 0, 0, 0);
         s++;
       }
      }
      else{
       for(j = 29; j >= 0; j--){
         strip.HSVsetLEDColor(s, 0, 0, 0);
         s++;
       } 
      }
    }
}

void death(){
  store_blank();
  strip.refreshLEDs();
  delay(50);
  store_array();
  strip.refreshLEDs();
  delay(250);
  store_blank();
  strip.refreshLEDs();
  delay(50);
  store_array();
  strip.refreshLEDs();
  delay(200);
  store_blank();
  strip.refreshLEDs();
  delay(50);
  store_array();
  strip.refreshLEDs();
  delay(150);
  store_blank();
  strip.refreshLEDs();
  delay(50);
  store_array();
  strip.refreshLEDs();
  delay(100);
  store_blank();
  strip.refreshLEDs();
  delay(50);
  store_array();
  strip.refreshLEDs();
  delay(50);
  store_blank();
  strip.refreshLEDs();
  delay(50);
  store_array();
  strip.refreshLEDs();
  delay(30);
  store_blank();
  strip.refreshLEDs();
  delay(30);
  store_array();
  strip.refreshLEDs();
  delay(20);
  store_blank();
  strip.refreshLEDs();
  delay(500);
}
//Randomly spawns an apple on the 2D grid
void spawn_food(){
  //food={10,1};
  food={random(30),random(30)};
  while (grid[food[0]][food[1]].en!=0){
    food={random(30),random(30)};
  }
  grid[food[0]][food[1]].en=2;
  grid[food[0]][food[1]].count=0;
  grid[food[0]][food[1]].hue=&foodhue;
  grid[food[0]][food[1]].sat=255;
  grid[food[0]][food[1]].val=snakebrightness;
}

//Resets the grid, snake is at top left, all else are reset to blank
void reset_grid(){
  for (i=0;i<30;i++){
    for(j=0; j<30;j++){
      grid[i][j].en=0;
      grid[i][j].count=0;
      grid[i][j].hue=&backhue;
      grid[i][j].sat=255;
      grid[i][j].val=backbrightness;
      grid[i][j].tailptr=NULL;
    }
  }

  dir= RIGHT;
  head={6,1};
  length=6;
  for (i=6; i>=1; i--){
    snake_ptr=&grid[i][1];
    snake_ptr->en=1;
    snake_ptr->sat=255;
    snake_ptr->val=snakebrightness;
    snake_ptr->hue=&snakehue;
    snake_ptr->count=7-i;
    snake_ptr->tailptr=&grid[i-1][1];
    snake_ptr=snake_ptr->tailptr;
  }  
  spawn_food();
  difficulty=165;
}

void print_EEPROM(){
  Serial.println("\n------------------------");
  Serial.println("reading EEPROM");

  for(int i=0; i<40; i++){
    Serial.print(i);
    Serial.print(": ");
    Serial.print(EEPROM.read(i));
    Serial.print("    ");
    Serial.println((char)EEPROM.read(i));
  }

  Serial.println("------------------------");
}

void loadBitmap(int state){
  
  int row = 0;
  int col = 0;
  int stepper = 0;
  
  for(stepper =0; stepper < (number_of_LEDs); stepper = stepper + 1){
    row = (stepper) / 30;
    col = (stepper) % 30;
    if(state == 1){
      *grid[row][col].hue =splash_main_hue[stepper];
      grid[row][col].val = splash_main_val[stepper];
    }
    else{
      *grid[row][col].hue =splash_btn_hue[stepper];
      grid[row][col].val = splash_btn_val[stepper];
    }
       
    //Serial.println(*grid[row][col].hue);
    grid[row][col].sat = 255;      
  }
  splash_store_array();
}
