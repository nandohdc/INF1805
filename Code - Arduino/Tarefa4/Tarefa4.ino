#include "application.h"
//#include "TimerService.h"

/******** Start: Globals ********/
long int millis_time = 0;
int interval = 0;
int button_listener = 0;
boolean interesseTimer = false;
boolean vecButtons[3]={false,false,false};
boolean button_pressed = false;
boolean time_exipre = false;
/******** End: Globals ********/

void pciSetup(byte pin)
{
    *digitalPinToPCMSK(pin) |= bit (digitalPinToPCMSKbit(pin));
    PCIFR  |= bit (digitalPinToPCICRbit(pin));
    PCICR  |= bit (digitalPinToPCICRbit(pin));
}


ISR (PCINT1_vect) // handle pin change interrupt for A0 to A5 here
 {
    //digitalWrite(12, !digitalRead(A1));
 }  

void button_listen(int pin){
    button_listener = digitalRead(pin);
    vecButtons[pin-1] = true;
  }

void timer_set(int ms){
    millis_time = millis();
    interval = ms;
    interesseTimer = true;
  }

void setup() {
  // put your setup code here, to run oncve:
 pinMode(LED_PIN, OUTPUT);
 pinMode(BUT_PIN, INPUT);
 pinMode(BUT_PIN1, INPUT);
 pinMode(BUT_PIN2, INPUT);
 pciSetup(A1);
 pciSetup(A2);
 pciSetup(A3);
 init_application();
}

void loop() {
  // put your main code here, to run repeatedly:
  /*
  boolean newButtonState = digitalRead(A1);
  if(button_pressed != newButtonState){
      button_pressed = newButtonState;
      button_changed(A1, button_pressed);
    }*/
}
