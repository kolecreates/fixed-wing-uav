#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <Servo.h>

RF24 radio(A1, A0); //CE pin, CSN pin
const byte radio_address[6] = "00011";

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

const byte FLAP_TRIM = 70;

const unsigned int MS_BEFORE_SIGNAL_LOSS = 4000;
unsigned long lastPayloadTime = 0;
PayloadStruct payload;

void setup() {

  servo_throttle.attach(10, ESC_MIN_PULSE_WIDTH_MS, ESC_MAX_PULSE_WIDTH_MS);
  servo_left_wing.attach(9);
  servo_right_wing.attach(6);
  servo_rudder.attach(3);
  servo_elevator.attach(5);

  setPositions(0, 90, 90, 90, 90);

  radio.begin();
  radio.openReadingPipe(0, radio_address);
  radio.setPayloadSize(sizeof(payload));
  radio.setAutoAck(false);
  radio.setDataRate(RF24_250KBPS);
  radio.setPALevel(RF24_PA_MAX);
  radio.startListening();
}

void loop() {
  if (radio.available()) {
    radio.read(&payload, sizeof(payload));
    lastPayloadTime = millis();
    setPositions(payload.throttle, payload.left_wing, payload.right_wing, payload.rudder, payload.elevator);
  } else if (millis() - lastPayloadTime > MS_BEFORE_SIGNAL_LOSS) {
    enterLandingMode();
  }
}

void enterLandingMode() {
  setPositions(0, 90 + FLAP_TRIM, 90 - FLAP_TRIM, 90, 90);
}

void setPositions(byte t, byte lw, byte rw, byte r, byte e) {
  if (t == 0) {
    throttle_pos = t;
    servo_throttle.write(throttle_pos);
  }

  if (left_wing_pos != lw) {
    left_wing_pos = lw;
    servo_left_wing.write(left_wing_pos);
  }

  if (right_wing_pos != rw) {
    right_wing_pos = rw;
    servo_right_wing.write(right_wing_pos);
  }

  if (rudder_pos != r) {
    rudder_pos = r;
    servo_rudder.write(rudder_pos);
  }

  if (elevator_pos != e) {
    elevator_pos = e;
    servo_elevator.write(elevator_pos);
  }
}
