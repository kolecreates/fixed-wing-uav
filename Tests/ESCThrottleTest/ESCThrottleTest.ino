#include <Servo.h>

Servo ESC;
const int MAX_THROTTLE = 180;
const int MIN_THROTTLE = 0;
const int ESC_CONTROL_PIN = 3;
const int MIN_PULSE_WIDTH_MS = 1000;
const int MAX_PULSE_WIDTH_MS = 2000;
const int THROTTLE_STEP = 45;
int throttle = MIN_THROTTLE;
void setup() {
  ESC.attach(ESC_CONTROL_PIN, MIN_PULSE_WIDTH_MS, MAX_PULSE_WIDTH_MS);
  ESC.write(MIN_THROTTLE);
  delay(1000);
}

void loop() {
  throttle += THROTTLE_STEP;
  if(throttle > MAX_THROTTLE){
    throttle = MIN_THROTTLE;
  }

  ESC.write(throttle);

  delay(3000);
}
