#include <Servo.h>

Servo ESC;
const int MAX_THROTTLE = 180;
const int MIN_THROTTLE = 0;
const int ESC_CONTROL_PIN = 3;
const int MIN_PULSE_WIDTH_MS = 1000;
const int MAX_PULSE_WIDTH_MS = 2000;

void setup() {
  ESC.attach(ESC_CONTROL_PIN, MIN_PULSE_WIDTH_MS, MAX_PULSE_WIDTH_MS);
  
  //Perform Throttle Range Calibration
  ESC.write(MAX_THROTTLE);
  delay(5000);
  ESC.write(MIN_THROTTLE);
}

void loop() {
  
}
