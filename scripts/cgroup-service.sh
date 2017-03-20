#!/usr/bin/env bash

# Create a img first.
# truncate --size 1G <root-dir>/treadmill.img

sudo TREADMILL_EXE_WHITELIST=/home/centos/treadmill/etc/linux.exe.config \
./bin/treadmill sproc --cell gaocegege --cgroup . service --root-dir /tmp/treadmill.GHB/ cgroup
