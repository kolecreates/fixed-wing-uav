#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <SoftwareSerial.h>

// BT TX connected to digital 6
// BT RX connected to digital 7
SoftwareSerial BT(6, 7);

RF24 radio(9, 8); //CE pin, CSN pin
const byte radio_address[6] = "00001";

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
  Serial.begin(9600);
  BT.begin(9600);
  radio.begin();
  radio.setAutoAck(false);
  radio.setPayloadSize(sizeof(payload));
  radio.setDataRate(RF24_250KBPS);
  radio.openWritingPipe(radio_address);
  radio.stopListening();
}

String payload_string = "";

void loop() {
  while(BT.available()){
    char c = BT.read();
    if(c == '\n'){
      payload.servo = static_cast<ServoEnum>(payload_string.charAt(0) - '0');
      payload.pos = payload_string.substring(1).toInt();
      radio.write(&payload, sizeof(payload));
      Serial.print(payload.servo);
      Serial.print(payload.pos);
      Serial.println();
      payload_string = "";
    }else{
      payload_string.concat(c);
    }
  }
}
