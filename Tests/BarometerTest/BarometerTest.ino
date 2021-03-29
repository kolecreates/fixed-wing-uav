#include <bmp388.h>

float temperature, pressure, altitude;

void setup(){
  Serial.begin(115200);
  Wire.begin();
  bmp388_init();
  Serial.println("Initialized");
}

void loop(){
  if (bmp388_get_measurements(temperature, pressure, altitude))
  {
    Serial.print(temperature);   
    Serial.print(F("*C   "));
    Serial.print(pressure);    
    Serial.print(F("hPa   "));
    Serial.print(altitude);
    Serial.println(F("m"));  
  }
  delay(1000);
}   
