#include <Servo.h>

Servo servo_1; // servo controller (multiple can exist)

int servo_pin = 3; // PWM pin for servo control

void setup() {
  servo_1.attach(servo_pin); // start servo control
  servo_1.write(90);
}

void loop() {
}
