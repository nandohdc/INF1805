#include "tarefa4.h"
#include "application.h"


void init_application(){
  timer_set(1000);
  button_listen(BUT_PIN);
  button_listen(BUT_PIN1);
  button_listen(BUT_PIN2);
  }

void button_changed(int pin, int v){
    digitalWrite(13,v);
    button_listen(pin);
  }

void timer_expired(){
    digitalWrite(13, LOW);
    timer_set(1000);
  }
