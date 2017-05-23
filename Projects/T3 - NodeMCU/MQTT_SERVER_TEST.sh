#!/bin/bash
#brew services stop mosquitto
#brew services start mosquitto

connect='mosquitto_pub -h localhost -t "connect" -m "10.80.70.'
infos='mosquitto_pub -h localhost -t "infos" -m "10.80.70.'
endC='"'

for i in {0..1}{0..1}{0..9};
do
	echo $connect"$i"$endC;
	echo $infos"$i"" free ""30"$endC
done