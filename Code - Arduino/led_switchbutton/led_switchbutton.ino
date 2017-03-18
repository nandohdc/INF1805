/* 
 *  Title: Press button for turn on the led.
 *  Author: Fernando Homem da Costa
 */

/*Global variables*/
int switchButton = 8;
int ledPin = 13;

void setup() {
  // put your setup code here, to run once:
  //intialize
  pinMode(switchButton, INPUT);
  pinMode(ledPin, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  if (digitalRead(switchButton) == HIGH) {
    digitalWrite(ledPin, HIGH);
  }
  else {
    digitalWrite(ledPin, LOW);
  }
}
