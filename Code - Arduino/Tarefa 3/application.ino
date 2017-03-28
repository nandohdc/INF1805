#include "event_driven.h"
void init_application(){
  timer_set(1000);
  button_listen(A1);
  }

void button_changed(int pin, int v){
    digitalWrite(13,v);
    button_listen(A1);
  }

void timer_expired(){
    digitalWrite(13, LOW);
  }
