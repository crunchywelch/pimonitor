#!/bin/bash
sudo /etc/init.d/lirc stop
irrecord -d /dev/lirc0 ~/lircd.conf
