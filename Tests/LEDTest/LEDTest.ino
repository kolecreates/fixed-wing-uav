int LED_PIN = 3;

void setup() {
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  analogWrite(LED_PIN, 50);
  delay(1000);
  analogWrite(LED_PIN, 0);
  delay(1000);
}
