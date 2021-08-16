#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <SoftwareSerial.h>

// BT TX connected to digital 6
// BT RX connected to digital 7
SoftwareSerial BT(6, 7);

RF24 radio(9, 8); //CE pin, CSN pin
const byte radio_address[6] = "00011";

struct PayloadStruct {
  byte throttle;
  byte left_wing;
  byte right_wing;
  byte rudder;
  byte elevator;
};


PayloadStruct payload;

void setup() {
  BT.begin(9600);
  radio.begin();
  radio.openWritingPipe(radio_address);
  radio.setPayloadSize(sizeof(payload));
  radio.setAutoAck(false);
  radio.setDataRate(RF24_250KBPS);
  radio.setPALevel(RF24_PA_MAX);
  radio.stopListening();
}

void loop() {
  if (BT.available() > 4) {
    payload.throttle = BT.read();
    payload.left_wing = BT.read();
    payload.right_wing = BT.read();
    payload.rudder = BT.read();
    payload.elevator = BT.read();
    radio.write(&payload, sizeof(payload));
  }
}
