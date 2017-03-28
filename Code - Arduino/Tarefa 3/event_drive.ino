#include "application.h"

/******** Start: Globals ********/
long int millis_time = 0;
int interval = 0;
int button_listener = 0;
boolean button_pressed = false;
boolean time_exipre = false;
/******** End: Globals ********/

void button_listen(int pin){
    button_listener = digitalRead(pin);
  }

void timer_set(int ms){
    millis_time = millis();
    interval = ms;
  }

void setup() {
  // put your setup code here, to run oncve:
   pinMode(A1,INPUT);
   pinMode(13, OUTPUT);
   init_application();
}

void loop() {
  // put your main code here, to run repeatedly:
  boolean newButtonState = digitalRead(A1);
  if(button_pressed != newButtonState){
      button_pressed = newButtonState;
      button_changed(A1, button_pressed);
    }
  if(millis() >= (millis_time + interval)){
      timer_expired();
    }

}
