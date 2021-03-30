#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

//create an RF24 object
RF24 radio(9, 8);  // CE, CSN

//address through which two modules communicate.
const byte address[6] = "00001";

bool light_on = false;

const int LED_PIN = 5;

void setup()
{
  pinMode(LED_PIN, OUTPUT);
  
  while (!Serial);
      Serial.begin(9600);
  
  radio.begin();
  
  //set the address
  radio.openReadingPipe(0, address);
  
  //Set module as receiver
  radio.startListening();
}
void loop()
{
  if(radio.available()){
    radio.read(&light_on, sizeof(bool));
  }
  
  if(light_on){
    digitalWrite(LED_PIN, HIGH);
  }else{
    digitalWrite(LED_PIN, LOW);
  }
}
