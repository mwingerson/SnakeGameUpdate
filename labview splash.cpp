


uint16_t greenColor = 510;
uint16_t constantBack = 1050;
unsigned int w;
uint16_t color_changer;

void splash3(){
  for(w=90; w>0; w--){
    //Clear the display first
    for (i=0;i<30;i++){
      for(j=0; j<30;j++){
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
    if ((Serial.available()!=0)||digitalRead(34)||digitalRead(35)||digitalRead(36)||digitalRead(37))break;
    
 //   Serial.print("w is: ");Serial.println(w);
  }//end of looping through the LabVIEW sine wave
}//END of splash3

void sine_wave(unsigned int startRow){
  if(startRow>60){startRow-=30;}
  if(startRow>30){startRow-=30;}
  int columnSpot;
  for (i=0;i<30;i++){
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
  for(i=0; i<30; i++){
    for(j=20; j<30; j++){
      grid[i][j].hue=&constantBack;
      grid[i][j].sat=255;
      grid[i][j].val=20;
    }
  }
  
  //L
  for(j=21; j<29; j++){
    grid[0][j].hue=&foodhue;
    grid[0][j].sat=255;
    grid[0][j].val=70;
  }
  for(i=1; i<3; i++){
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
  
  for(i=4; i<6; i++){
    grid[i][23].hue=&foodhue;
    grid[i][23].sat=255;
    grid[i][23].val=70;
  }
  
  grid[5][27].hue=&foodhue;
  grid[5][27].sat=255;
  grid[5][27].val=70;
  
  for(j=24; j<29; j++){
    grid[6][j].hue=&foodhue;
    grid[6][j].sat=255;
    grid[6][j].val=70;
  }
  
  //b
  for(j=21; j<28; j++){
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
  
  for(j=26; j<28; j++){
    grid[10][j].hue=&foodhue;
    grid[10][j].sat=255;
    grid[10][j].val=70;
  }
  
  //V
  for(j=21; j<25; j++){
    grid[11][j].hue=&foodhue;
    grid[11][j].sat=255;
    grid[11][j].val=70;
  }
  
  for(j=25; j<28; j++){
    grid[12][j].hue=&foodhue;
    grid[12][j].sat=255;
    grid[12][j].val=70;
  }
  
  grid[13][28].hue=&foodhue;
  grid[13][28].sat=255;
  grid[13][28].val=70;
  
  for(j=25; j<28; j++){
    grid[14][j].hue=&foodhue;
    grid[14][j].sat=255;
    grid[14][j].val=70;
  }
  
  for(j=21; j<25; j++){
    grid[15][j].hue=&foodhue;
    grid[15][j].sat=255;
    grid[15][j].val=70;
  }
  
  //I
  for(j=21; j<29; j++){
    grid[17][j].hue=&foodhue;
    grid[17][j].sat=255;
    grid[17][j].val=70;
  }
  
  //E
  for(j=21; j<29; j++){
    grid[19][j].hue=&foodhue;
    grid[19][j].sat=255;
    grid[19][j].val=70;
  }
  
  for(i=20; i<22; i++){
    grid[i][21].hue=&foodhue;
    grid[i][21].sat=255;
    grid[i][21].val=70;
  }
  
  for(i=20; i<22; i++){
    grid[i][24].hue=&foodhue;
    grid[i][24].sat=255;
    grid[i][24].val=70;
  }
  
  for(i=20; i<22; i++){
    grid[i][28].hue=&foodhue;
    grid[i][28].sat=255;
    grid[i][28].val=70;
  }
  
  //W
  for(j=21; j<25; j++){
    grid[23][j].hue=&foodhue;
    grid[23][j].sat=255;
    grid[23][j].val=70;
  }
  
  for(j=25; j<28; j++){
    grid[24][j].hue=&foodhue;
    grid[24][j].sat=255;
    grid[24][j].val=70;
  }
  
  grid[25][28].hue=&foodhue;
  grid[25][28].sat=255;
  grid[25][28].val=70;
  
  for(j=23; j<28; j++){
    grid[26][j].hue=&foodhue;
    grid[26][j].sat=255;
    grid[26][j].val=70;
  }
  
  grid[27][28].hue=&foodhue;
  grid[27][28].sat=255;
  grid[27][28].val=70;
  
  for(j=25; j<28; j++){
    grid[28][j].hue=&foodhue;
    grid[28][j].sat=255;
    grid[28][j].val=70;
  }
  
  for(j=21; j<25; j++){
    grid[29][j].hue=&foodhue;
    grid[29][j].sat=255;
    grid[29][j].val=70;
  }
}//END of displayLabVIEW
