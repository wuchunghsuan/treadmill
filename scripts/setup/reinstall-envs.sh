#!/bin/bash
#
# Install the envs in .env/init.sh

cp /home/vagrant/.zshrc.backup /home/vagrant/.zshrc
cat /home/vagrant/treadmill/.env/init.sh >> /home/vagrant/.zshrc
