#include <PICxel.h>
#include <EEPROM.h>
#include <string.h>
#include "splash.h"

//#define DEBUG_MODE

#define splash_millisecond_delay 2750

typedef struct snode{
  uint8_t en;
  uint8_t count;
  uint16_t *hue;
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
#define millisecond_delay 

#define SPEED_INCREASE 2
#define STOCK_SPEED 100

#define STARTING_LENGTH 8

PICxel strip(number_of_LEDs, LED_pin, HSV, noalloc);

uint8_t sketch_color_array[number_of_bytes];

uint8_t head[2]={6,1};
uint8_t food[2];
uint8_t dir=RIGHT;
uint8_t lastdir=RIGHT;
uint8_t length=STARTING_LENGTH;
snode grid[30][30];
int lastupdate;
uint8_t lastbuf[2];
static int i,j;

uint32_t difficulty=STOCK_SPEED;

uint16_t snakehue=500;
uint16_t backhue=700;
uint16_t foodhue=214;

int backupdate=0;

const uint8_t snakebrightness=200;
const uint8_t backbrightness=15;

const uint8_t refreshrate=15;

bool timeSave = 0;

int time =0;
int timeDif = 0;

#define buff_size 30
char strtemp[buff_size];
char strtemp2[buff_size];

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
int splash_state = 1;

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

  //EEPROM.clear();

  for(int i=0; i<40;i++)
     EEPROM.write(i, 0);
  }

void loop() {
  char temp_char;
  char str_index = 0;
  uint32_t* word_ptr;
  uint32_t word_temp;

  #if defined DEBUG_MODE
    delay(500);
  #endif

  switch (game_state) {
    //reset state
    case RESET_ST:
      game_state = TITLE_ST;
      //delay(1000);
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

        reset_grid();
        dir= RIGHT;
        lastdir = RIGHT;
        strtemp[0] = 0;
        strcpy(strtemp,"0");
        
          #if defined DEBUG_MODE
            Serial.print("score0: ");
            Serial.print(strtemp);
            Serial.print("|");
          #endif

        itoa(EEPROM.read(0), strtemp2, 10);

          #if defined DEBUG_MODE
            Serial.println(strtemp2); //print highscore
            Serial.print("data_packet0: ");
          #endif

        strcat(strtemp, strtemp2);  //concat control char and score
        get_name_from_EEPROM(0, strtemp2);  //get name

          #if defined DEBUG_MODE
            Serial.println(strtemp);
            Serial.print("name0: ");
            Serial.println(strtemp2);
          #endif

        //concat contron char, score, " " and name
        strcat(strtemp, " ");
        strcat(strtemp, strtemp2);

          #if defined DEBUG_MODE
            Serial.print("Compete data_packet0: ");
          #endif
      
        Serial.println(strtemp);

          #if defined DEBUG_MODE
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

        strcat(strtemp, strtemp2);  //concat control char and score
        get_name_from_EEPROM(1, strtemp2);  //get name

          #if defined DEBUG_MODE
            Serial.println(strtemp);
            Serial.print("name1: ");
            Serial.println(strtemp2);
          #endif

        //concat control char, score, " " and name
        strcat(strtemp, " ");
        strcat(strtemp, strtemp2);

          #if defined DEBUG_MODE
            Serial.print("Compete data_packet1: ");
          #endif
      
        Serial.println(strtemp);

        #if defined DEBUG_MODE
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

        itoa(EEPROM.read(13), strtemp2, 10);

          #if defined DEBUG_MODE
            Serial.println(strtemp2);
            Serial.print("data_packet2: ");
          #endif

        strcat(strtemp, strtemp2);  //concat control char and score
        get_name_from_EEPROM(2, strtemp2);  //get name

          #if defined DEBUG_MODE
            Serial.println(strtemp);
            Serial.print("name2: ");
            Serial.println(strtemp2);
          #endif

        //concat contron char, score, " " and name
        strcat(strtemp, " ");
        strcat(strtemp, strtemp2);

          #if defined DEBUG_MODE
            Serial.print("Compete data_packet2: ");
          #endif
      
        Serial.println(strtemp);
          #if defined DEBUG_MODE
            Serial.println("------------------------\n");
          #endif

        strtemp[0] = 0;
        
        lastupdate=millis();
        backupdate=millis();
        
        game_state = RUN_GAME_ST;

          #if defined DEBUG_MODE
            Serial.println("\n");
          #endif
      }
    break;

    //RUN_GAME_ST
    case RUN_GAME_ST:

      run_game();
    break;

    //game over
    case GAMEOVER_ST:
      death();

      //print end game score
      strcpy(strtemp,"4");
      itoa((length-6)/2, strtemp2, 10);
      strcat(strtemp, strtemp2);
      Serial.println(strtemp);

        #if defined DEBUG_MODE
          Serial.println("In Gameover state");

          Serial.println("Enter game score: ");

          snake_gets(strtemp);
    
          length = atoi(strtemp);

          Serial.print("You entered: ");
          Serial.println(length);

          Serial.println("Enter name: ");
        #endif

      snake_gets_or_btn_press(strtemp);

        delay(1);

        #if defined DEBUG_MODE
          Serial.print("name: ");
          Serial.println(strtemp);

          Serial.print("length: ");
          Serial.println(length);
        #endif

      //horribly inefficient but easy
      //check if new first high score
      if((length-6)/2 > EEPROM.read(0)){

        #if defined DEBUG_MODE
          Serial.println("------------------------");
          Serial.println("replacing score 0");
          Serial.println("------------------------");
        #endif

        //copy 0 and 1 to 1 and 2
        for(int i=25; i>=0; i--)
          EEPROM.write(i+13, EEPROM.read(i));

        EEPROM.write(0, (length-6)/2);

        for(int i=0; strtemp[i]; i++){
          EEPROM.write(i+1, (uint8_t)strtemp[i]);
        }
          EEPROM.write(strlen(strtemp)+1, 0);
      }

      //check if new second high score
      else if((length-6)/2 > EEPROM.read(13)){
        #if defined DEBUG_MODE
          Serial.println("------------------------");
          Serial.println("replacing score 1");
          Serial.println("------------------------");
        #endif

        //copy 1 to 2
        for(int i=25; i>=13; i--){
          EEPROM.write(i+13, EEPROM.read(i));

        }

        EEPROM.write(13, (length-6)/2);

        for(int i=0; strtemp[i]; i++){
          EEPROM.write(i+14, strtemp[i]);
          EEPROM.write(i+15, 0);
        }
      }

      //check if new third high score
      else if((length-6)/2 > EEPROM.read(26)){

        #if defined DEBUG_MODE
          Serial.println("------------------------");
          Serial.println("replacing score 2");
          Serial.println("------------------------");
        #endif

        EEPROM.write(26, (length-6)/2);

        for(int i=0; strtemp[i]; i++){
          EEPROM.write(i+27, strtemp[i]);
          EEPROM.write(i+28, 0);
        }
      }

        #if defined DEBUG_MODE
          else{
            Serial.println("------------------------");
            Serial.println("not replacing a score");
            Serial.println("------------------------");
          }
        #endif


      game_state = RESET_ST;

      reset_grid();

        #if defined DEBUG_MODE
          print_EEPROM();
        #endif
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

//Splash screen which flips between 2 states
void snake_splash_screen(){
  int row, col;
  
  //flip between the tow screensa by calling load bitmap then refreshLeds
  if(millis()-splash_prevTime > splash_millisecond_delay){
    splash_prevTime = millis();
    if(splash_state){
      loadBitmap(splash_state);    
      strip.refreshLEDs();
      splash_state = 0;
    }
        
    else{
      loadBitmap(splash_state); 
      strip.refreshLEDs();
      splash_state=1;
    }            
  }  
  delay(1);
}

//stores the grid into the PICxel library
void splash_store_array(){
  int s = 0;
  
  for(i = 29; i >= 0; i--){ 
    if(i % 2 == 0){ 
        for(j = 29; j >= 0; j--){    
          strip.HSVsetLEDColor(s, *grid[j][i].hue, grid[j][i].sat, grid[j][i].val);
          s++;        
        }
    }

    else{
      for(j = 0; j < 30; j++){     
        strip.HSVsetLEDColor(s, *grid[j][i].hue, grid[j][i].sat, grid[j][i].val);
        s++;
      } 
    }         
  }  
}

//Reads values from the hue and value arrays and then stores them into the grid
//eventually we can change this to use the old store_array instead of splash_store_array
//The difference is caused by the bitmap being upside down and backward
void loadBitmap(int state){
  int row = 0;
  int col = 0;
  int stepper = 0;
  
  //store into array
  for(stepper =0; stepper < (number_of_LEDs); stepper = stepper + 1){
    row = (stepper) / 30;
    col = (stepper) % 30;

    if(state == 1){
      grid[row][col].hue = &splash_main_hue[stepper];
      grid[row][col].val = splash_main_val[stepper];
    }
    else{
      grid[row][col].hue = &splash_btn_hue[stepper];
      grid[row][col].val = splash_btn_val[stepper];
    }
       
    grid[row][col].sat = 255;
  }
  splash_store_array();
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
      difficulty-=SPEED_INCREASE;
      spawn_food();

      //print current score
        strtemp[0] = 0;
        strcpy(strtemp,"3");

        #if defined DEBUG_MODE
          Serial.println("------------------------");
          Serial.print("current_score: ");
          Serial.print(strtemp);
          Serial.print("|");
        #endif

        itoa((length-6)/2, strtemp2, 10);

        #if defined DEBUG_MODE
          Serial.println(strtemp2);
          Serial.print("data_packet: ");
        #endif

        strcat(strtemp, strtemp2);
        Serial.println(strtemp);

          #if defined DEBUG_MODE
            Serial.println("------------------------\n");
          #endif

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
  length=STARTING_LENGTH;
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
  difficulty=STOCK_SPEED;
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

void get_name_from_EEPROM(int num, char* retstr){
  for(int i=0; i<buff_size; i++)
    retstr[i] = 0;

  for(int i=0; i<12; i++){
    retstr[i] = EEPROM.read(i+1+(num*13));
  }
  retstr[strlen(retstr)+1] = 0;
}

void snake_gets(char* retstr){
  char temp_char = 0;
  uint8_t str_index = 0;

  for(int i=0; i<buff_size; i++)
    retstr[i] = 0;

  while(Serial.available())
    temp_char = Serial.read();

  while(Serial.available()==0);
  
  //read in string
  while(Serial.available() > 0){
    if(str_index < 30)
      retstr[str_index++] = Serial.read();;
    
    delay(1);
  }

  //terminate string
  retstr[strlen(retstr)] = 0;  
}

void snake_gets_or_btn_press(char* retstr){
  char temp_char = 0;
  uint8_t str_index = 0;

  for(int i=0; i<buff_size; i++)
    retstr[i] = 0;

  while(Serial.available())
    temp_char = Serial.read();

  //wait for button release
  while(digitalRead(34)||digitalRead(35)||digitalRead(36)||digitalRead(37));

  while((Serial.available()==0)&&(!digitalRead(34))&&(!digitalRead(35))&&(!digitalRead(36))&&(!digitalRead(37))){
    splash3();
  }

  if(digitalRead(34)||digitalRead(35)||digitalRead(36)||digitalRead(37))
    strcpy(retstr, "anonymous");

  
  else{
    retstr[0] = 0;
    str_index = 0;
    //read in string

    delay(1);

    while(Serial.available()){
      temp_char = Serial.read();

      if(str_index < buff_size)
        retstr[str_index++] = temp_char;
    }

    //terminate string
    retstr[strlen(retstr)] = 0;  
    str_index = 0;
  }
}

uint16_t greenColor = 510;
uint16_t constantBack = 1050;
uint16_t color_changer;

void splash3(){
  static uint8_t w;
  for(w=90; w>0; w--){
    //Clear the display first

    for (int i=0;i<30;i++){
      for(int j=0; j<30;j++){
        grid[i][j].count=0;
        color_changer = backupdate;
        grid[i][j].hue=&color_changer;
        grid[i][j].sat=255;
        grid[i][j].val=0;
      }
    }//end of clearing the display
    
    //Then show the LabVIEW portion
      displayLabVIEW();
 
    sine_wave(w);
    store_array();
    strip.refreshLEDs();

    if((Serial.available()!=0)||digitalRead(34)||digitalRead(35)||digitalRead(36)||digitalRead(37))
      break;

    Serial.print(" ");

  }//end of looping through the LabVIEW sine wave
}//END of splash3

void sine_wave(uint8_t startRow){
  if(startRow>60){startRow-=30;}
  if(startRow>30){startRow-=30;}
  int columnSpot;
  for (int i=0;i<30;i++){
      columnSpot = startRow+i-30;
      if(columnSpot<0){
        columnSpot+=30;
      }
      int k = (int)(10*sin((2*3.14159/15)*columnSpot) + 10);
      grid[i][k].hue=&greenColor;
      grid[i][k].sat=255;
      grid[i][k].val=70;
  }
}//END of sine_wave

void displayLabVIEW(){
  //setup a background contrast
  for(int i=0; i<30; i++){
    for(int j=20; j<30; j++){
      grid[i][j].hue=&constantBack;
      grid[i][j].sat=255;
      grid[i][j].val=20;
    }
  }
  
  //L
  for(int j=21; j<29; j++){
    grid[0][j].hue=&foodhue;
    grid[0][j].sat=255;
    grid[0][j].val=70;
  }
  for(int i=1; i<3; i++){
    grid[i][28].hue=&foodhue;
    grid[i][28].sat=255;
    grid[i][28].val=70;
  }
  //a
  grid[3][24].hue=&foodhue;
  grid[3][24].sat=255;
  grid[3][24].val=70;
  
  grid[3][27].hue=&foodhue;
  grid[3][27].sat=255;
  grid[3][27].val=70;
  
  grid[4][26].hue=&foodhue;
  grid[4][26].sat=255;
  grid[4][26].val=70;
  
  grid[4][28].hue=&foodhue;
  grid[4][28].sat=255;
  grid[4][28].val=70;
  
  for(int i=4; i<6; i++){
    grid[i][23].hue=&foodhue;
    grid[i][23].sat=255;
    grid[i][23].val=70;
  }
  
  grid[5][27].hue=&foodhue;
  grid[5][27].sat=255;
  grid[5][27].val=70;
  
  for(int j=24; j<29; j++){
    grid[6][j].hue=&foodhue;
    grid[6][j].sat=255;
    grid[6][j].val=70;
  }
  
  //b
  for(int j=21; j<28; j++){
    grid[8][j].hue=&foodhue;
    grid[8][j].sat=255;
    grid[8][j].val=70;
  }
  
  grid[9][25].hue=&foodhue;
  grid[9][25].sat=255;
  grid[9][25].val=70;
  
  grid[9][28].hue=&foodhue;
  grid[9][28].sat=255;
  grid[9][28].val=70;
  
  for(int j=26; j<28; j++){
    grid[10][j].hue=&foodhue;
    grid[10][j].sat=255;
    grid[10][j].val=70;
  }
  
  //V
  for(int j=21; j<25; j++){
    grid[11][j].hue=&foodhue;
    grid[11][j].sat=255;
    grid[11][j].val=70;
  }
  
  for(int j=25; j<28; j++){
    grid[12][j].hue=&foodhue;
    grid[12][j].sat=255;
    grid[12][j].val=70;
  }
  
  grid[13][28].hue=&foodhue;
  grid[13][28].sat=255;
  grid[13][28].val=70;
  
  for(int j=25; j<28; j++){
    grid[14][j].hue=&foodhue;
    grid[14][j].sat=255;
    grid[14][j].val=70;
  }
  
  for(int j=21; j<25; j++){
    grid[15][j].hue=&foodhue;
    grid[15][j].sat=255;
    grid[15][j].val=70;
  }
  
  //I
  for(int j=21; j<29; j++){
    grid[17][j].hue=&foodhue;
    grid[17][j].sat=255;
    grid[17][j].val=70;
  }
  
  //E
  for(int j=21; j<29; j++){
    grid[19][j].hue=&foodhue;
    grid[19][j].sat=255;
    grid[19][j].val=70;
  }
  
  for(int i=20; i<22; i++){
    grid[i][21].hue=&foodhue;
    grid[i][21].sat=255;
    grid[i][21].val=70;
  }
  
  for(int i=20; i<22; i++){
    grid[i][24].hue=&foodhue;
    grid[i][24].sat=255;
    grid[i][24].val=70;
  }
  
  for(int i=20; i<22; i++){
    grid[i][28].hue=&foodhue;
    grid[i][28].sat=255;
    grid[i][28].val=70;
  }
  
  //W
  for(int j=21; j<25; j++){
    grid[23][j].hue=&foodhue;
    grid[23][j].sat=255;
    grid[23][j].val=70;
  }
  
  for(int j=25; j<28; j++){
    grid[24][j].hue=&foodhue;
    grid[24][j].sat=255;
    grid[24][j].val=70;
  }
  
  grid[25][28].hue=&foodhue;
  grid[25][28].sat=255;
  grid[25][28].val=70;
  
  for(int j=23; j<28; j++){
    grid[26][j].hue=&foodhue;
    grid[26][j].sat=255;
    grid[26][j].val=70;
  }
  
  grid[27][28].hue=&foodhue;
  grid[27][28].sat=255;
  grid[27][28].val=70;
  
  for(int j=25; j<28; j++){
    grid[28][j].hue=&foodhue;
    grid[28][j].sat=255;
    grid[28][j].val=70;
  }
  
  for(int j=21; j<25; j++){
    grid[29][j].hue=&foodhue;
    grid[29][j].sat=255;
    grid[29][j].val=70;
  }
}//END of displayLabVIEW
