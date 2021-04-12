#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <Servo.h>

RF24 radio(A1, A0); //CE pin, CSN pin
const byte radio_address[6] = "00001";

Servo servo_left_wing;
Servo servo_right_wing;
Servo servo_rudder;
Servo servo_elevator;
Servo servo_throttle;

const int ESC_MIN_PULSE_WIDTH_MS = 1000;
const int ESC_MAX_PULSE_WIDTH_MS = 2000;

byte throttle_pos;
byte left_wing_pos;
byte right_wing_pos;
byte rudder_pos;
byte elevator_pos;

struct PayloadStruct {
  byte throttle;
  byte left_wing;
  byte right_wing;
  byte rudder;
  byte elevator;
};

PayloadStruct payload;

const unsigned int MS_BEFORE_SIGNAL_LOSS = 2000;
unsigned long lastPayloadTime = 0;

void setup() {

   servo_throttle.attach(10, ESC_MIN_PULSE_WIDTH_MS, ESC_MAX_PULSE_WIDTH_MS);
   servo_left_wing.attach(9);
   servo_right_wing.attach(6);
   servo_rudder.attach(5);
   servo_elevator.attach(3);

   resetPositions();

   radio.begin();
   radio.openReadingPipe(0, radio_address);
   radio.setPayloadSize(sizeof(payload));
   radio.setAutoAck(false);
   radio.setDataRate(RF24_250KBPS);
   radio.setPALevel(RF24_PA_MAX);
   radio.startListening();
}

void loop() {
  if(radio.available()){
    radio.read(&payload, sizeof(payload));
    lastPayloadTime = millis();
    
    if(throttle_pos != payload.throttle){
      throttle_pos = payload.throttle;
      servo_throttle.write(throttle_pos);
    }
    
    if(left_wing_pos != payload.left_wing){
      left_wing_pos = payload.left_wing;
      servo_left_wing.write(left_wing_pos);
    }
    
    if(right_wing_pos != payload.right_wing){
      right_wing_pos = payload.right_wing;
      servo_right_wing.write(right_wing_pos);
    }
    
    if(rudder_pos != payload.rudder){
      rudder_pos = payload.rudder;
      servo_rudder.write(rudder_pos);
    }
    
    if(elevator_pos != payload.elevator){
      elevator_pos = payload.elevator;
      servo_elevator.write(elevator_pos);
    }
    
  }else if(millis() - lastPayloadTime > MS_BEFORE_SIGNAL_LOSS){
    resetPositions();
  }
}

void resetPositions(){
  throttle_pos = 0;
  left_wing_pos = 90;
  right_wing_pos = 90;
  rudder_pos = 90;
  elevator_pos = 90;
  
  servo_throttle.write(throttle_pos);
  servo_left_wing.write(left_wing_pos);
  servo_right_wing.write(right_wing_pos);
  servo_rudder.write(rudder_pos);
  servo_elevator.write(elevator_pos);
}
