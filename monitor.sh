#!/bin/bash

# Note that the GPIO numbers that you program here refer to the pins
# of the BCM2835 and *not* the numbers on the pin header. 
# So, if you want to activate GPIO7 on the header you should be 
# using GPIO4 in this script. Likewise if you want to activate GPIO0
# on the header you should be using GPIO17 here.
# reference: http://elinux.org/RPi_Low-level_peripherals#General_Purpose_Input.2FOutput_.28GPIO.29

# GPIO numbers should be from this list
# 0, 1, 4, 7, 8, 9, 10, 11, 14, 15, 17, 18, 21, 22, 23, 24, 25

# get monitor power status
# STATUS = 0 when monitor is ON, 1 when monitor is OFF
echo "23" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio23/direction
STATUS=`cat /sys/class/gpio/gpio23/value`
echo "23" > /sys/class/gpio/unexport

if [ "$1" == 'on' ]; then
	if [ $STATUS == 1 ]; then
		tvservice -p;
		fbset -depth 8;
		fbset -depth 16;
		chvt 6;
		chvt 7;
		sleep 2
		echo "turning monitor ON"
		irsend SEND_ONCE samsung KEY_POWER
	else
		echo "monitor is already ON"
	fi
elif [ "$1" == 'off' ]; then
	if [ $STATUS == 0 ]; then
		tvservice -o
		echo "turning monitor OFF"
		irsend SEND_ONCE samsung KEY_POWER
	else
		echo "monitor is already OFF"
	fi
else
	echo "usage: monitor.sh [on|off]"
fi
