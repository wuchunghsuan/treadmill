#!/usr/bin/env bash

sudo yum -y update
sudo yum -y install java wget git

# treadmill services deps
sudo yum -y install ipset iptables bridge-utils libcgroup-tools lvm2*

# treadmill build deps
sudo yum -y group install "Development Tools"
sudo yum -y install python-devel ntp krb5-server krb5-libs krb5-devel
sudo yum -y install epel-release
sudo yum -y install python-pip python34 python34-devel mercurial openssl-devel

# install pip deps
pip install -r requirements.txt
