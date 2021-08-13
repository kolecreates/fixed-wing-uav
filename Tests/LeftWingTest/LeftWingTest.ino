#include <Servo.h>
Servo servo_left_wing;
Servo servo_right_wing;


void setup() {
   servo_left_wing.attach(9);
   servo_right_wing.attach(6);
   delay(1000);
   servo_left_wing.write(120);
   servo_right_wing.write(120);
   delay(1000);
   servo_left_wing.write(70);
   servo_right_wing.write(70);
   delay(1000);
   servo_left_wing.write(90);
   servo_right_wing.write(90);
}

void loop() {
  // put your main code here, to run repeatedly:

}
