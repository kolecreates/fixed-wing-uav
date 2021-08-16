#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <SoftwareSerial.h>

// BT TX connected to digital 6
// BT RX connected to digital 7
SoftwareSerial BT(6, 7);

RF24 radio(9, 8); //CE pin, CSN pin
const byte radio_address[6] = "00011";

byte payload;

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
  if (BT.available() > 0) {
    payload = BT.read();
    radio.write(&payload, sizeof(payload));
  }
}
