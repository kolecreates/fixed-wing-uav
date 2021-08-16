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

const byte COMMAND_TAKE_OFF = 1;
const byte COMMAND_CRUISE = 2;
const byte COMMAND_LAND = 3;
const byte COMMAND_ROLL_LEFT = 4;
const byte COMMAND_ROLL_RIGHT = 5;
const byte COMMAND_PITCH_UP = 6;
const byte COMMAND_PITCH_DOWN = 7;
const byte COMMAND_THROTTLE_UP = 8;
const byte COMMAND_THROTTLE_DOWN = 9;
const byte COMMAND_KILL = 10;
const byte COMMAND_PING = 11;

const byte ROLL_TRIM = 20;
const byte ROLL_RUDDER_TRIM = 10;
const byte FLAP_TRIM = 70;
const byte PITCH_TRIM = 20;
const byte THROTTLE_TRIM = 20;

const unsigned int MS_BEFORE_SIGNAL_LOSS = 4000;
unsigned long lastPayloadTime = 0;
byte payload;

void setup() {

  servo_throttle.attach(10, ESC_MIN_PULSE_WIDTH_MS, ESC_MAX_PULSE_WIDTH_MS);
  servo_left_wing.attach(9);
  servo_right_wing.attach(6);
  servo_rudder.attach(5);
  servo_elevator.attach(3);

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

    if (payload == COMMAND_TAKE_OFF) {
      setPositions(170, 90 + FLAP_TRIM, 90 - FLAP_TRIM, 90, 90);
    } else if (payload == COMMAND_CRUISE) {
      setPositions(110, 90, 90, rudder_pos, elevator_pos);
    } else if (payload == COMMAND_LAND) {
      enterLandingMode();
    } else if (payload == COMMAND_ROLL_LEFT) {
      setPositions(throttle_pos, 90, right_wing_pos - ROLL_TRIM, rudder_pos - ROLL_RUDDER_TRIM, elevator_pos);
    } else if (payload == COMMAND_ROLL_RIGHT) {
      setPositions(throttle_pos, left_wing_pos + ROLL_TRIM, 90, rudder_pos + ROLL_RUDDER_TRIM, elevator_pos);
    } else if (payload == COMMAND_PITCH_UP) {
      setPositions(throttle_pos, left_wing_pos, right_wing_pos, rudder_pos, elevator_pos + PITCH_TRIM);
    } else if (payload == COMMAND_PITCH_DOWN) {
      setPositions(throttle_pos, left_wing_pos, right_wing_pos, rudder_pos, elevator_pos - PITCH_TRIM);
    } else if (payload == COMMAND_THROTTLE_UP) {
      setPositions(throttle_pos + THROTTLE_TRIM, left_wing_pos, right_wing_pos, rudder_pos, elevator_pos);
    } else if (payload == COMMAND_THROTTLE_DOWN) {
      setPositions(throttle_pos - THROTTLE_TRIM, left_wing_pos, right_wing_pos, rudder_pos, elevator_pos);
    } else if (payload == COMMAND_KILL) {
      enterLandingMode();
    }

  } else if (millis() - lastPayloadTime > MS_BEFORE_SIGNAL_LOSS) {
    enterLandingMode();
  }
}

void enterLandingMode() {
  setPositions(0, 90 + FLAP_TRIM, 90 - FLAP_TRIM, 90, 90);
}

void setPositions(byte t, byte lw, byte rw, byte r, byte e) {
  if (t == 0) {
    throttle_pos = clampByte(t, 0, 180);
    servo_throttle.write(throttle_pos);
  }

  if (left_wing_pos != lw) {
    left_wing_pos = clampByte(lw, 20, 160);
    servo_left_wing.write(left_wing_pos);
  }

  if (right_wing_pos != rw) {
    right_wing_pos = clampByte(rw, 20, 160);
    servo_right_wing.write(right_wing_pos);
  }

  if (rudder_pos != r) {
    rudder_pos = clampByte(r, 10, 170);
    servo_rudder.write(rudder_pos);
  }

  if (elevator_pos != e) {
    elevator_pos = clampByte(e, 10, 170);
    servo_elevator.write(elevator_pos);
  }
}

byte clampByte(byte b, byte minb, byte maxb) {
  if (b > maxb) {
    return maxb;
  }

  if (b < minb) {
    return minb;
  }

  return b;
}
