/*
 Processing code that changes LED based on the wind speed and Tempature in Albuquerque
 Last Update 3/6/17
*/

import processing.serial.*;
import java.awt.Rectangle;
import java.util.regex.Pattern;
import java.util.ArrayList;
import java.util.Iterator;

int frame_rate = 60; //FPS

//************************Teensies, networking**********************************************************
float gamma = 1.7;
int numPorts=0;  // the number of serial ports in use
int maxPorts=2; // maximum number of serial ports
PImage secondCanvas; //Our canvas, to draw to 
Serial[] ledSerial = new Serial[maxPorts];     // each port's actual Serial port
Rectangle[] ledArea = new Rectangle[maxPorts]; // the area of the movie each port gets, in % (0-100)
boolean[] ledLayout = new boolean[maxPorts];   // layout of rows, true = even is left->right
PImage[] ledImage = new PImage[maxPorts];      // image sent to each port
int[] gammatable = new int[256];
int errorCount=0;
//************************************************************************************************
//**********************Variables that control the functionality of the LED Strip*****************
int STRIPLENGTH = 237;
int STRIPNUM = 16; 

// Constants
int Y_AXIS = 1;
int X_AXIS = 2;
color b1, b2, c1, c2;
color gold,blue,red,purple;

int x_rect_pos = 0;


int maxImages = 601; // Total # of images
int imageIndex = 0; // Initial image to be displayed is the first
boolean isPlaying = true;

// Declaring an array of images.
PImage[] images = new PImage[maxImages];
//****************************************************************************************************
//***********************Variables for Weather Animation**********************************************
String server = ("http://api.wunderground.com/api/a30fcf18ad5fcace/conditions/q/NM/Albuquerque.xml");
String testserver = ("http://api.wunderground.com/api/a30fcf18ad5fcace/conditions/q/IL/Chicago.xml");
XML xml;

byte firstrun = 0;
byte errcount = 0;

int speed = 0;
int currenttime;
int oldtime;
int isWeather = 1;
int limit = 10000;

float windColor;
float tempColor;
float n = 0;
float c = 3;
float start = 0;

String windSpeed;
String tempature;

ArrayList<PVector> points = new ArrayList<PVector>();
//***************************************************************************************************
//***************************************************************************************************
void setup() {
  //size(STRIPLENGTH, STRIPNUM); so dumb varables cant be passed in here. 
  size(237,16);
  frameRate(frame_rate);
  colorMode(HSB, 360, 255, 255);
 

  // teensy housekeeping
  t_setup();

  // Define colors
  gold = color(50,255,255);
  blue = color(225,225,225);
  red = color(0,255,255);
  purple = color(280, 255, 255);
 
  
  // Loading the images into the array
  // Don't forget to put the JPG files in the data folder!
  for (int i = 0; i < images.length; i ++ ) {
    images[i] = loadImage( "brecht_animation/brecht_quote_final" + i + ".jpg" ); 
  }
  //frameRate(20);
 
//Weather Application Code
oldtime = millis();

}
//******************************************************************************************************
//******************************************************************************************************
void draw() {
 
  background(0);
  translate(width / 50, height / 2);
  
  /*get values for weather */
  getWeather();
 
 /*display animation based on weather values*/
  animateWeather();
  
  if(n > limit)
  {
    n = 0;
    start = 0;
  }

  // Only cycle if isPlaying is true
  if (isPlaying == true) 
  {
    // increment image index by one each cycle
    // use modulo " % "to return to 0 once the end of the array is reached
    imageIndex = (imageIndex + 1) % images.length;
  }

  //push to teensies
  t_draw();
}

//**************Weather Animation***********************************************************************
//******************************************************************************************************
void animateWeather()
{
  
  rotate(n * 0.3);
  
  for (int i = 0; i < 10000; i++) 
  {
   
    float a = i * radians(137.1);
    float r = c * sqrt(i);
    float x = r * cos(a);
    float y = r * sin(a);
    float hu = i+start;//sin(start + i * 0.5);
    hu = i/3.0 % 255;
    
   if(isWeather == 1)
   {   
     
      if(windColor < 5 && tempColor < 50)
      {
         if(i < 200)
         {
           fill(purple);
         }
        else
          fill(blue); 
      }
      
      if(windColor < 5 && tempColor > 50)
       {
         if(i < 200)
         {
           fill(purple);
         }
        else
          fill(red); 
      }
        
      if(windColor >= 5 && tempColor >= 50)
      {
          if(i < 200)
         {
           fill(gold);
         }
        else
          fill(red);
      }
      
      if(windColor >= 5 && tempColor < 50)
      {
          if(i < 200)
         {
           fill(gold);
         }
        else
          fill(blue);
      }
      
   }
    else 
    fill(hu, 255,255);
    noStroke();
    ellipse(x, y, 4, 4);
  }
  n += 5;
  start += 5;  
}
//*******************************************************************************
//*returns the current wind speed in ABQ as a string ****************************/
void getWeather()
{
/*Weather Application Code*/

  if(firstrun == 0)
  {
    firstrun = 1;
  }
  else
  {
    currenttime = millis();
    if(firstrun == 1 || currenttime - oldtime >= 300000)
    {
     try{
          oldtime = currenttime;
          firstrun = 2;
          
          //Load the XML document
          xml = loadXML(server);
          
          //Get the wind speed 
          XML myval = xml.getChild("current_observation/wind_mph");
          println("Current Wind Speed in ABQ is : " + myval.getContent());
          
          windSpeed = myval.getContent();
          

          windColor = float(windSpeed); // turn windSpeed into a float
          
          XML tempval = xml.getChild("current_observation/temp_f");
          tempature = tempval.getContent();
          tempColor = float(tempature);
          println("Current Tempature in ABQ is : " + tempval.getContent());
          
          isWeather = 1;       
       }
        catch(Exception e)
        {
          print("No Internet");
          isWeather = 0;
          //noLoop();
          errcount ++;
            if (errcount<4)
            {
               firstrun = 0;
            }
         }
    }
  }
 
}
//***********************************************************************
//**********EXTRA CODE FOR FUTURE IDEAS***********************************
void animateTempature()
{
  rotate(n * 0.3);
  for (int i = 0; i < n; i++) 
  {
    float a = i * radians(137.1);
    float r = c * sqrt(i);
    float x = r * cos(a);
    float y = r * sin(a);
    float hu = i+start;//sin(start + i * 0.5);
    hu = i/3.0 % 255;
    
    
    
   if(isWeather == 1)
   {   
      if(tempColor <= 50)
      {
        //fill(180+windColor,180+windColor,200+windColor);
        fill(blue); //Blue
       
      }
      else if(tempColor > 50)
      {
         //fill(150,50,225);
         fill(red); //Red
      }
      else
       fill(hu, 255, 255);
   }
    else 
    fill(hu, 255, 255);
    noStroke();
    ellipse(x, y, 4, 4);
  }

  n += 5;
  start += 5;  
}

void animateWind()
{
  rotate(n * 0.3);
  for (int i = 0; i < n; i++) 
  {
   
    float a = i * radians(137.1);
    float r = c * sqrt(i);
    float x = r * cos(a);
    float y = r * sin(a);
    float hu = i+start;//sin(start + i * 0.5);
    hu = i/3.0 % 255;
    
   if(isWeather == 1)
   {   
     
      if(windColor < 5)
      {
        //fill(180+windColor,180+windColor,200+windColor);
        fill(purple); //Purple
       
      }
      else if(windColor > 5)
      {
         //fill(150,50,225);
         fill(gold); //Gold
      }
      else
       fill(hu, 255, 255);
   }
    else 
    fill(hu, 255, 255);
    noStroke();
    ellipse(x, y, 4, 4);
   
  }
  
  n += 5;
  start += 5;
  
}
*********************************************************************/