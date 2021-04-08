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
Servo servo_throttle;

const int SERVO_MAX = 180;
const int SERVO_MIN = 0;
const int ESC_MIN_PULSE_WIDTH_MS = 1000;
const int ESC_MAX_PULSE_WIDTH_MS = 2000;

enum ServoEnum {
  THROTTLE = 0,
  LEFT_WING,
  RIGHT_WING,
  RUDDER,
  FLAPS,
  PING
};

struct PayloadStruct {
  ServoEnum servo;
  unsigned int pos;
};

PayloadStruct payload;

const unsigned int MS_BEFORE_SIGNAL_DISCONNECT_SHUTOFF = 5000;
unsigned long lastPayloadTime = 0;

void setup() {

   servo_throttle.attach(10, ESC_MIN_PULSE_WIDTH_MS, ESC_MAX_PULSE_WIDTH_MS);
   servo_left_wing.attach(9);
   servo_right_wing.attach(6);
   servo_rudder.attach(5);
   servo_flaps.attach(3);

   servo_throttle.write(SERVO_MIN);

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
    lastPayloadTime = millis();
    if(payload.servo == THROTTLE){
      servo_throttle.write(payload.pos);
    }else if(payload.servo == LEFT_WING){
      servo_left_wing.write(payload.pos);
    }else if(payload.servo == RIGHT_WING){
      servo_right_wing.write(payload.pos);
    }else if(payload.servo == RUDDER){
      servo_rudder.write(payload.pos);
    }else if(payload.servo == FLAPS){
      servo_flaps.write(payload.pos);
    }
  }else if(millis() - lastPayloadTime > MS_BEFORE_SIGNAL_DISCONNECT_SHUTOFF){
    servo_throttle.write(SERVO_MIN);
  }
}
