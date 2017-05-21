#!/bin/bash
# declare STRING variable
STRING="mosquitto_pub -h localhost -t "
STRING+='"connect" -m "10.80.70.115"'
#print variable on a screen
echo $STRING