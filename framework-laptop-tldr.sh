#!/bin/bash

sudo apt-get -y update && sudo apt-get -y upgrade \
  && if ! sudo apt-get -y install salt-common ; then wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltproject.io && sudo sh /tmp/bootstrap-salt.sh ; fi \
  && wget -O framework-laptop-formula-main.zip https://github.com/lightrush/framework-laptop-formula/archive/refs/heads/main.zip && unzip -o framework-laptop-formula-main.zip \
  && sudo salt-call -l error --local --file-root="$(pwd)/framework-laptop-formula-main" state.apply framework-laptop
