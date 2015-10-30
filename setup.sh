#!/bin/bash

# todo: setup hostname

sudo rpi-update
echo "deb http://apt.adafruit.com/raspbian/ wheezy main" | sudo tee --append /etc/apt/sources.list
wget -O - -q https://apt.adafruit.com/apt.adafruit.com.gpg.key | sudo apt-key add -

sudo aptitude update
sudo aptitude purge wolfram-engine
sudo aptitude upgrade
sudo aptitude -y install lirc node x11-xserver-utils unclutter monit midori ntp

# setup gpio pins and lirc
echo "dtoverlay=lirc-rpi,gpio_in_pin=27,gpio_out_pin=17" | sudo tee --append /boot/config.txt
echo "lirc_dev" | sudo tee --append /etc/modules
echo "lirc_rpi gpio_in_pin=27 gpio_out_pin=17" | sudo tee --append /etc/modules
sudo cat BN59-01199F.conf > /etc/lirc/lircd.conf
sudo cat hardware.conf > /etc/lirc/hardware.conf
sudo cp monitor.sh /bin
echo "0 8 * * 1,2,3,4,5 root /bin/monitor.sh on >> /dev/null" | sudo tee --append /etc/crontab
echo "45 7 * * 1,2,3,4,5 root /etc/init.d/lightdm start >> /dev/null"  | sudo tee --append /etc/crontab
echo "0 19 * * 1,2,3,4,5 root /bin/monitor.sh off >> /dev/null" | sudo tee --append /etc/crontab
echo "15 19 * * 1,2,3,4,5 root /etc/init.d/lightdm stop >> /dev/null"  | sudo tee --append /etc/crontab

# setup monitor power settings and kiosk browser
# from https://www.danpurdy.co.uk/web-development/raspberry-pi-kiosk-screen-tutorial/
sudo sed -i 's/^@xscreensaver -no-splash/#@xscreensaver -no-splash/g' /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s off' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s -dpms' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo '@xset s noblank' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo "@sed -i 's/\"exited_cleanly\": false/\"exited_cleanly\": true/' ~/.config/chromium/Default/Preferences" | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo '@rm ~/.config/chromium/SingletonLock' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
#echo '@chromium --noerrdialogs --kiosk http://status.packet.net --incognito' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart
echo '@midori -i 120 -e Fullscreen -p -a http://status.packet.net' | sudo tee --append /etc/xdg/lxsession/LXDE-pi/autostart

# install display_control service file
cp display_control /etc/init.d
ln -s ../init.d/display_control /etc/rc2.d/S01display_control

# move node.js app over
rsync -avz node ~/
# to start: nohup node node/display_control_sub.js `hostname` &

sudo reboot
