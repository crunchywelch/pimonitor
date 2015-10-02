#!/bin/bash

# todo: setup hostname

sudo rpi-update
curl -sLS https://apt.adafruit.com/add | sudo bash
sudo aptitude update
sudo aptitude -y install lirc node chromium x11-xserver-utils unclutter

# setup gpio pins and lirc
echo "dtoverlay=lirc-rpi,gpio_in_pin=27,gpio_out_pin=17" | sudo tee --append /boot/config.txt
echo "lirc_dev" | sudo tee --append /etc/modules
echo "lirc_rpi gpio_in_pin=27 gpio_out_pin=17" | sudo tee --append /etc/modules
sudo cat BN59-01199F.conf > /etc/lirc/lircd.conf
sudo cat hardware.conf > /etc/lirc/hardware.conf
sudo cp monitor.sh /bin
echo "0 8 * * 1,2,3,4,5 root /bin/monitor.sh on >> /dev/null" | sudo tee --append /etc/crontab
echo "0 19 * * 1,2,3,4,5 root /bin/monitor.sh off >> /dev/null" | sudo tee --append /etc/crontab

# setup monitor power settings and kiosk browser
# from https://www.danpurdy.co.uk/web-development/raspberry-pi-kiosk-screen-tutorial/
sudo sed -i 's/^@xscreensaver -no-splash/#@xscreensaver -no-splash/g' /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s off' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s -dpms' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s noblank' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo "@sed -i 's/\"exited_cleanly\": false/\"exited_cleanly\": true/' ~/.config/chromium/Default/Preferences" | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo '@chromium --noerrdialogs --kiosk http://status.packet.net --incognito' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart

# move node.js app over
rsync -avz node ~/
# to start: nohup node node/display_control_sub.js `hostname` &

sudo reboot
