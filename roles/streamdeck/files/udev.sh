#!/bin/bash -xe

echo "Adding udev rules and reloading"
sudo tee /etc/udev/rules.d/70-streamdeck.rules << EOF
SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess", SYMLINK+="streamdeck"
EOF
sudo udevadm trigger
