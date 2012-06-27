// ==================================
// Arduano : Arduino chronometer 
// for sport motorcycling
// 
// Developped by Julien Levasseur
//
// Begin on 22 March 2012 from initial
// code by 15 February 2011
// Last modification : 09 June 2012
// ===================================


// IMPORTS //

#include <glcd.h>
#include <glcd_Config.h>
#include <Wire.h>
#include <Time.h>
#include "fonts/SystemFont5x7.h"
#include "fonts/Arial_bold_14.h"
#include <SD.h>
#include <SimpleTimer.h>
#include <EEPROM.h>
#include "EEPROMAnything.h"

// VARIABLES //

long pushedTime = 0;
long currentChrono;
int lap;
long last1Chrono;
long last2Chrono;
long lastLapDiffTime;
long lastLapDiffTimeInMilliSeconds;
long lastLapDiffTimeInSeconds;
long lastLapDiffTimeInMinutes;
String lastLapDiffTimeSymbol;
long currentChronoDisplayInSeconds;
long currentChronoDisplayInMilliseconds;
long currentChronoDisplayInMinutes;
int buttonState;
int previousbuttonState;
int standByButton = HIGH;
int previousStandByButtonState;
//String errormsg;
long bestLap;
long bestLapDisplay;
long bestLapInMilliSeconds;
long bestLapInSeconds;
long bestLapInMinutes;
boolean standByMode = true;
const int buttonPin = 40;
const int standByButtonPin = 41;
SimpleTimer timer;
long time;
long debounce = 200;
String logLine;
String logTest;
int firstEEPROMFreeAddress;

// SETUP //

void setup(){

  // Init the button :
  pinMode(buttonPin, INPUT);
  pinMode(standByButtonPin, INPUT);
  time = 0;
  //SS pin (10 on most Arduino boards, 53 on the Mega) must be left as an output or the SD library functions will not work.
  pinMode(53, OUTPUT);
  
  // Init error variable :
  //errormsg = '';

  // Init the library, non inverted writes blank pixels onto a clear screen :
  GLCD.Init(NON_INVERTED);
  // Clear the screen :
  GLCD.ClearScreen();  
  // Select the Font for display :
  //GLCD.SelectFont(SystemFont5x7);
  GLCD.SelectFont(Arial_bold_14);
  // Clear the screen :
  GLCD.ClearScreen();
  GLCD.ClearScreen();
 
  timer.setInterval(10000, doEachTenSeconds);
 
  // Init the serial link for getting stored crhonos via USB :
  Serial.begin(9600);
  String eepromContent = EEPROM_readAnything(0, logLine);
  Serial.print();
}

// MAIN //

void loop() {

  // Throw exceptions and display here if there :
  displayError();
  // Manage standByMode and define currentChrono  :
  // This permit to currentChrono is equal to 0 at the startup and begin to grow only when button is pushed for the first time
  if (standByMode == false) {
    currentChrono = millis() - pushedTime;
  }
 
 // Check if button is pushed :
 buttonState = digitalRead(buttonPin);
 if (buttonState == LOW && millis() - time > debounce) {
     time = millis();
     buttonPushed();
     previousbuttonState = buttonState;
 }
 
 // Call display function :
 display();
 // Call clearScreenForTenSeconds for clean screen to prevent display bugs :
 clearScreenForTenSeconds();
 
}

void buttonPushed() {
	
  // Clear the screen :
  GLCD.ClearScreen();
  GLCD.ClearScreen();
  // Clear screen each ten seconds
  timer.run();
  // If Arduano is in standby mode, toggle it to running mode :
  if (standByMode = true) {
    standByMode = false;	
  }

  // Construct the log to ba saved :
  logLine = String(lap) + ";" + String(currentChronoDisplayInMinutes) + "'" +
            String(currentChronoDisplayInSeconds) + "''" +
            String(currentChronoDisplayInMilliseconds) + ";" + 
            String(lastLapDiffTimeSymbol) +
            String(lastLapDiffTimeInMinutes) + "'" + 
            String(lastLapDiffTimeInSeconds) + "'" + 
            String(lastLapDiffTimeInMilliSeconds) + ";\n";
  //writeToSD(logLine);
  writeToEEPROM(logLine);
  Serial.print(logLine);

  last2Chrono = last1Chrono;
  last1Chrono = currentChrono;
  // Check if currentChrono is lower than bestLap, if then, set the new bestLap :
  if (lap <= 1) {
    bestLap = currentChrono;
  }
  if (currentChrono < bestLap) {
    bestLap = currentChrono;
  }
  pushedTime = millis();
  lap++;
  // If lap is lower than 2, don't calculate the difference with the 2 last laps and set bestLap to 0 :
  if (lap < 2) {
    bestLap = 0;
    lastLapDiffTime = 0;
  }
  // If lap is greater than or equal to 3, calculate the difference with the 2 last laps :
  if (lap >= 3) {
    lastLapDiffTime = last1Chrono - last2Chrono;
  }
}

long calculateChronoInMilliseconds(long currentChrono) {

  currentChronoDisplayInMilliseconds = currentChrono % 1000;
  return currentChronoDisplayInMilliseconds;
}

long calculateChronoInSeconds(long currentChrono) {
 
 currentChronoDisplayInSeconds = ( currentChrono / 1000L ) % 60;
 return currentChronoDisplayInSeconds;
}

long calculateChronoInMinutes(long currentChrono) {
 
  currentChronoDisplayInMinutes = ( currentChrono / 1000L ) / 60;
  return currentChronoDisplayInMinutes;
}

long calculateBestLapInMilliSeconds(long bestLap) {
 
  bestLapInMilliSeconds = bestLap % 1000;
  return bestLapInMilliSeconds;
}

long calculateBestLapInSeconds(long bestLap) {
 
  bestLapInSeconds = ( bestLap / 1000L ) % 60;
  return bestLapInSeconds;
}

long calculateBestLapInMinutes(long bestLap) {
  
  bestLapInMinutes = ( bestLap / 1000L ) / 60;
  return bestLapInMinutes;
}

// Functions for lastLapDiffTime calculation :
long calculateLastLapDiffTimeInMilliseconds(long lastLapDiffTime) {

  lastLapDiffTimeInMilliSeconds = lastLapDiffTime % 1000;
  if (lastLapDiffTimeInMilliSeconds < 0) {
    lastLapDiffTimeInMilliSeconds = lastLapDiffTimeInMilliSeconds / -1;
  }
  return lastLapDiffTimeInMilliSeconds;
}

long calculateLastLapDiffTimeInSeconds(long lastLapDiffTime) {
 
 lastLapDiffTimeInSeconds = ( lastLapDiffTime / 1000L ) % 60;
 if (lastLapDiffTimeInSeconds < 0) {
    lastLapDiffTimeInSeconds = lastLapDiffTimeInSeconds / -1;
  }
 return lastLapDiffTimeInSeconds;
}

long calculateLastLapDiffTimeInMinutes(long lastLapDiffTime) {
 
  lastLapDiffTimeInMinutes = ( lastLapDiffTime / 1000L ) / 60;
  if (lastLapDiffTimeInMinutes < 0) {
    lastLapDiffTimeInMinutes = lastLapDiffTimeInMinutes / -1;
  }
  return lastLapDiffTimeInMinutes;
}

String lastLapDiffTimeSymbolDetermination(long lastLapDiffTime) {
	
	if (lastLapDiffTime < 0) {
		lastLapDiffTimeSymbol = "-";
	} else {
		lastLapDiffTimeSymbol = "+";
	}
	return lastLapDiffTimeSymbol;
}
// END OF : lastLapDiffTime calculation

void displayError() {

  GLCD.CursorTo(3,3);
 // GLCD.Puts(errormsg);

}

void display() {
  
  // For info : Usage of CursorTo : CursorTo(Column,Line);

  //calculateChronoForDisplay(currentChrono);
  calculateChronoInMilliseconds(currentChrono);
  calculateChronoInSeconds(currentChrono);
  calculateChronoInMinutes(currentChrono);
  calculateBestLapInMilliSeconds(bestLap);
  calculateBestLapInSeconds(bestLap);
  calculateBestLapInMinutes(bestLap);
  lastLapDiffTimeSymbolDetermination(lastLapDiffTime);
  calculateLastLapDiffTimeInMilliseconds(lastLapDiffTime);
  calculateLastLapDiffTimeInSeconds(lastLapDiffTime);
  calculateLastLapDiffTimeInMinutes(lastLapDiffTime);

  // Display currentChrono :
  GLCD.CursorTo(2,0);
  GLCD.print(currentChronoDisplayInMinutes);
  GLCD.CursorTo(4,0);
  GLCD.Puts(" '");
  GLCD.CursorTo(5,0);
  // Prevent the double diplay when seconds passed from 59 to 0->9 :
  if (currentChronoDisplayInSeconds < 10) {
    GLCD.Puts("0");
    GLCD.CursorTo(6,0);
    GLCD.print(currentChronoDisplayInSeconds);
  } else {
    GLCD.print(currentChronoDisplayInSeconds);
  }
  GLCD.CursorTo(7,0);
  GLCD.Puts(" ''");
  GLCD.CursorTo(8,0);
  GLCD.print(currentChronoDisplayInMilliseconds);
  //GLCD.Puts(chronoDisplay);
  // END OF -> Display currentChrono :
  
  // Display bestLap  :
  GLCD.CursorTo(0,2);
  GLCD.print(bestLapInMinutes);
  GLCD.CursorTo(1,2);
  GLCD.Puts("'");
  GLCD.CursorTo(2,2);
  GLCD.print(bestLapInSeconds);
  GLCD.CursorTo(4,2);
  GLCD.Puts("''");
  GLCD.CursorTo(5,2);
  GLCD.print(bestLapInMilliSeconds);
  // END OF -> Display bestLap
  
  // Display Difference between two last laps :
  GLCD.CursorTo(4,3);
  // If lap is lower than 1 don't display the lastLapDiffTimeSymbol :
  if (lap > 1) {
    GLCD.print(lastLapDiffTimeSymbol);
  }
  GLCD.CursorTo(5,3);
  GLCD.print(lastLapDiffTimeInMinutes);
  GLCD.Puts("'");
  GLCD.CursorTo(7,3);
  GLCD.print(lastLapDiffTimeInSeconds);
  GLCD.Puts("''");
  GLCD.CursorTo(9,3);
  GLCD.print(lastLapDiffTimeInMilliSeconds);
  // END OF -> Display lastLapDiffTime
  
  
  // Display Lap number :
  GLCD.CursorTo(0,3);
  GLCD.Puts("[");
  GLCD.print(lap);
  GLCD.Puts("]");

}

/*
// This function is used to write the logs of chrono in SD card :
void writeToSD(String stringLog) {
  
  // Open file for writing :
  string filename = "race.log";
  file = SD.open(filename, FILE_WRITE);
  if (file) {
    file.println(stringLog); 
  } else {
    errormsg = 'SDERR';
  }
  // Close the file :
  //file.close();
}
*/
// NEED TO BE TESTED (NO MORE SD SHIELD TO TEST - USE AS YOUR OWN RISKS !!!!
// This function is used to write the logs of chrono in SD card :
/*void writeToSD(String stringLog) {
  
  // Open file for writing :
  int i = 1;
  string filename = "session" + i + ".log";
  if (!SD.exists(filename)) {
    file = SD.open(filename, FILE_WRITE);
      if (file) {
        file.println(stringLog); 
      } else {
        errormsg = 'SDERR';
      }
  } else {
  i++;
  }
}*/

void writeToEEPROM(String stringLog) {
  EEPROM_writeAnything(0, stringLog);
}


// This function exist for cleaning the screen every 10s to prevent display bugs :
void doEachTenSeconds() {
  GLCD.ClearScreen();
}

void clearScreenForTenSeconds() {
 if (lastLapDiffTimeInSeconds == 10) {
   GLCD.ClearScreen();
 } else if (lastLapDiffTimeInSeconds == 10) {
   GLCD.ClearScreen();
 } else if (currentChronoDisplayInSeconds == 10) {
   GLCD.ClearScreen();
 } else if (currentChronoDisplayInMinutes == 10) {
   GLCD.ClearScreen();
 }
}
