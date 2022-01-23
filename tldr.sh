#!/bin/bash

if lspci -n | grep -q '8086:2725' && echo $(uname -r) | grep -q 5.11 ; then sudo rm -f /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm ; sudo rmmod iwlmvm ; sudo rmmod iwlwifi ; sudo modprobe iwlwifi && /bin/bash -c 'while ! nslookup google.com 8.8.8.8 &> /dev/null ; do echo No internet connection. Waiting... ; sleep 10 ; done' ; fi \
  && sudo apt-get -y update \
  && if ! sudo apt-get -y install salt-minion ; then wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltproject.io && sudo sh /tmp/bootstrap-salt.sh ; fi \
  && wget -O framework-laptop-formula-main.zip https://github.com/lightrush/framework-laptop-formula/archive/refs/heads/main.zip && unzip -o framework-laptop-formula-main.zip \
  && sudo salt-call -l error --local --file-root="$(pwd)/framework-laptop-formula-main" state.apply framework-laptop
  
