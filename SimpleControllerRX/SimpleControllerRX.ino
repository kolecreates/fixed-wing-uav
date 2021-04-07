#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <Servo.h>

RF24 radio(A1, A0); //CE pin, CSN pin
const byte radio_address[6] = "00001";

Servo servo_left_wing;
Servo servo_right_wing;
Servo servo_rudder;
Servo servo_flaps;

enum ServoEnum {
  LEFT_WING = 0,
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
  
   servo_left_wing.attach(9);
   servo_right_wing.attach(6);
   servo_rudder.attach(5);
   servo_flaps.attach(3);

   servo_left_wing.write(90);
   servo_right_wing.write(90);
   servo_rudder.write(90);
   servo_flaps.write(90);

   radio.begin();
   radio.setAutoAck(false);
   radio.setPayloadSize(sizeof(payload));
   radio.setDataRate(RF24_250KBPS);
   radio.openReadingPipe(0, radio_address);
   radio.startListening();
}

void loop() {
  if(radio.available()){
    radio.read(&payload, sizeof(payload));
    if(payload.servo == LEFT_WING){
      servo_left_wing.write(payload.pos);
    }else if(payload.servo == RIGHT_WING){
      servo_right_wing.write(payload.pos);
    }else if(payload.servo == RUDDER){
      servo_rudder.write(payload.pos);
    }else if(payload.servo == FLAPS){
      servo_flaps.write(payload.pos);
    }
  }
}
