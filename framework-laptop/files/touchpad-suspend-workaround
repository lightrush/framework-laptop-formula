#!/bin/bash

case "$1" in
    pre)
        /usr/bin/echo "touchpad-suspend-workaround: unloading i2c_hid" | /usr/bin/tee /dev/kmsg
        /usr/sbin/rmmod -s i2c_hid
    ;;
    post)
        /usr/bin/echo "touchpad-suspend-workaround: loading i2c_hid" | /usr/bin/tee /dev/kmsg
        /usr/sbin/modprobe -s i2c_hid
    ;;
esac
