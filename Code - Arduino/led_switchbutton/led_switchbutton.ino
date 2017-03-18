/* 
 *  Title: Press button for turn on the led.
 *  Author: Fernando Homem da Costa
 */

/*Global variables*/
int switchButton = 8;
int ledPin = 11;
boolean stateButton = LOW;
boolean currentButton = LOW;
boolean stateLed = false;
long currentMillis = 0;

void setup() {
  // put your setup code here, to run once:
  //intialize
  pinMode(switchButton, INPUT);
  pinMode(ledPin, OUTPUT);
}

boolean debounce(boolean last){
    boolean current = digitalRead(switchButton);
    long localMillis = millis();
    if(last != current){
       if(localMillis - currentMillis >= 5){
          current = digitalRead(switchButton);
       }
      }
     return current;
  }

void loop() {
  // put your main code here, to run repeatedly:
  currentMillis = millis();
  currentButton = debounce(stateButton);
  
  if (stateButton == LOW && currentButton == HIGH) {
    stateLed = !stateLed;
  }
   stateButton = currentButton;
   digitalWrite(ledPin, stateLed);
}
