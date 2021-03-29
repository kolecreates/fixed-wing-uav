#include <SoftwareSerial.h>
// BT TX connected to digital 10
// BT RX connected to digital 11
SoftwareSerial BT(10, 11);

int LED_PIN = 13;

void setup()
{
  pinMode(LED_PIN, OUTPUT);
  BT.begin(9600);
  BT.println("Test Message From Arduino Uno");
}

char c; //data from other device
void loop()
{
  if(BT.available())
  {
    c=(BT.read());
    if(c=='0')
    {
      digitalWrite(13, LOW);
      BT.println("LED OFF");
    }else if(c=='1')
    {
      digitalWrite(13, HIGH);
      BT.println("LED ON");
    } 
  }
}
