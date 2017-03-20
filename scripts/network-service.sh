#!/usr/bin/env bash

sudo TREADMILL_EXE_WHITELIST=/home/centos/treadmill/etc/linux.exe.config \
./bin/treadmill sproc --cell gaocegege --cgroup . service --root-dir /tmp/treadmill.GHB/ network