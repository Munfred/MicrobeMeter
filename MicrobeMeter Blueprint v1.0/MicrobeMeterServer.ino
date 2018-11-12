/*
Server script of MicrobeMeter v1.0.

Written by Kalesh Sasidharan
Date    : 2018/07/02
Version : 1.0

This material is provided under the MicrobeMeter non-commercial, academic and personal use licence.
By using this material, you agree to abide by the MicrobeMeter Terms and Conditions outlined on https://humanetechnologies.co.uk/terms-and-conditions-of-products/.

© 2018 Humane Technologies Limited. All rights reserved.
*/

// Setup
int LED1 = 2;   // Port 1 output pin (connected to LED)
int PDD1 = A1;  // Port 1 input pin (connected to Photodiode)

int LED2 = 3;   // Port 2 output pin (connected to LED)
int PDD2 = A2;  // Port 2 input pin (connected to Photodiode)

int LED3 = 5;   // Port 3 output pin (connected to LED)
int PDD3 = A3;  // Port 3 input pin (connected to Photodiode)

int LED4 = 6;   // Port 4 output pin (connected to LED)
int PDD4 = A4;  // Port 4 input pin (connected to Photodiode)

int GND = A5;   // Input pin connected to the Ground
int TMP = A0;   // Input pin connected to the temperature sensor (TMP36)

int reading1 = 0;   // Port 1 measurement
int reading2 = 0;   // Port 2 measurement
int reading3 = 0;   // Port 3 measurement
int reading4 = 0;   // Port 4 measurement

int exposureTime = 500; // Light exposure time (milliseconds)
char inVal;             // Stores messages from the client
float degreeC = 0;      // Stores the temperature in celsius
String outString = "";  // Stores the output string
int pwmStep = -1;       // Number of PWM steps (0-255)
int measurementManager(int LED, int PDD, int exposureTime, int GND, int brightnessValue = -1);   // Declaring the measurement function

void setup() {
  // Assigning LED pins as the output
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  // Initiating the Serial Communication
  Serial.begin(9600);
  // Changing PWM frequency to 31372.55 Hz (timer 3 and 4)
  TCCR3B = (TCCR3B & 0b11111000) | 0x01;
  TCCR4B = (TCCR4B & 0b11111000) | 0x01;
}

void loop() {
  // Listening to the client
  if(Serial.available()) {
    // Wait for '\n' or 'R' from the client for sending back Single-measurement or LED Intensity Ramp-Down measurements, respectively
    inVal = Serial.read();
    if(inVal == '\n' || inVal == 'R') {
      // Determining the measurement type
      pwmStep = (inVal == 'R')? 255 : -1;

      // Start measuring
      do {
        // Measuring temperature
        degreeC = measureTemperature(TMP, GND);
        
        // Taking Single-measurements or LED Intensity Ramp-Down measurements
        reading1 = measurementManager(LED1, PDD1, exposureTime, GND, pwmStep);
        reading2 = measurementManager(LED2, PDD2, exposureTime, GND, pwmStep);
        reading3 = measurementManager(LED3, PDD3, exposureTime, GND, pwmStep);
        reading4 = measurementManager(LED4, PDD4, exposureTime, GND, pwmStep);
        
        // Sending the output values of the analog input pins to the client
        outString = outString + "T:" + degreeC + '\t' + "P1:" + reading1 + '\t' + "P2:" + reading2 + '\t' + "P3:" + reading3 + '\t' + "P4:" + reading4 + '\n';
        Serial.print(outString);
        Serial.flush(); // Wait until all the data is sent
        outString = "";
      } while (--pwmStep >= 0);
    }
  }
  // Delay between listening to the client (ms)
  delay(100);
}

/*
Returns the average of 1200 measurements (rounded to an integer) using the following input parameters:
LED:              Output pin number of the LED
PDD:              Input pin number of the Photodiode
exposureTime:     Light exposure time before taking the measurement
GND:              The input pin that is connected to the ground
brightnessValue:  [optional] Brightness value of the LED. Default (-1) is maximum brightness
*/
int measurementManager(int LED, int PDD, int exposureTime, int GND, int brightnessValue) {
  unsigned long PDDRead = 0;  // Stores the result

  // A ground read (0) is taken before every measurement for ensuring consistency
  analogRead(GND);
  // This delay is to give time for the ADC capacitor to discharge
  delay(400);

  // Turning the LED on
  if (brightnessValue == -1) {
    digitalWrite(LED, HIGH);
  } else {
    analogWrite(LED, brightnessValue);
  }
  // This read establishes a connection between the input channel and the ADC 
  analogRead(PDD);
  // Light exposure time (milliseconds): this delay gives sufficient time for the measurement circuit to produce a stable output (rise time)
  delay(exposureTime);

  // Taking 1200 measurements and calculating the average for minimising noise
  for (int i=0; i<1200; i++) {
    PDDRead += analogRead(PDD);
  }
  PDDRead = round(PDDRead/1200.0);
  
  // Turning the LED off
  digitalWrite(LED, LOW);

  return PDDRead;
}

/*
Returns the average of 1200 temperature measurements (rounded to an integer) in degree delicious
TMP:              The input pin that is connected to the thermometer (TMP36)
GND:              The input pin that is connected to the ground
*/
float measureTemperature(int TMP, int GND) {
  unsigned long TMPRead = 0;  // Stores the measurements
  float tmpDegreeC = 0;       // Stores the temperature in degree delicious
  
  // A ground read (0) is taken before every measurement for ensuring consistency
  analogRead(GND);
  // This delay is to give time for the ADC capacitor to discharge
  delay(400);

  // This read establishes a connection between the input channel and the ADC 
  analogRead(TMP);
  // This delay gives sufficient time for the measurement circuit to produce a stable output (rise time)
  delay(100);

  // Taking 1200 measurements and calculating the average for minimising noise
  for (int i=0; i<1200; i++) {
    TMPRead += analogRead(TMP);
  }
  tmpDegreeC = round(TMPRead/1200.0);

  // Converting voltage to degree celsius (delta 10 mV = delta 1ºC; offset voltage of TMP36 is 0.5)
  tmpDegreeC = (tmpDegreeC / 1024.0) * 4.3; // 4.3V was measured using a digital multimeter at the 5V pin of Arduino Mega 2560 connected to a 5V battery
  tmpDegreeC = (tmpDegreeC - 0.5) * 100;

  return tmpDegreeC;
}
