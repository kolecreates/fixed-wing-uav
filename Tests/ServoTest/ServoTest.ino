#include <Servo.h>

Servo servo_1; // servo controller (multiple can exist)

int servo_pin = 3; // PWM pin for servo control
int pos = 0;    // servo starting position
int step_deg = 15;
int max_deg = 180;

void setup() {
  servo_1.attach(servo_pin); // start servo control
}

void loop() {
   servo_1.write(pos);
   pos += step_deg;
   if(pos > max_deg)
   {
    pos = pos - max_deg;
   }
   delay(1000);
}
