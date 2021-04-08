#include <SoftwareSerial.h>
#include <Servo.h>

// BT TX connected to digital 6
// BT RX connected to digital 7
SoftwareSerial BT(6, 7);
Servo servo_right_wing;

enum ServoEnum {
  THROTTLE = 0,
  LEFT_WING,
  RIGHT_WING,
  RUDDER,
  FLAPS
};

struct PayloadStruct {
  ServoEnum servo;
  unsigned int pos;
};

PayloadStruct payload;

void setup() {
  BT.begin(9600);
  servo_right_wing.attach(3);

}

String payload_string = "";

void loop() {
  while(BT.available()){
    char c = BT.read();
    if(c == '\n'){
      payload.servo = static_cast<ServoEnum>(payload_string.charAt(0) - '0');
      payload.pos = payload_string.substring(1).toInt();
      if(payload.servo == RIGHT_WING){
        servo_right_wing.write(payload.pos);
      }
      payload_string = "";
    }else{
      payload_string.concat(c);
    }
  }
}
