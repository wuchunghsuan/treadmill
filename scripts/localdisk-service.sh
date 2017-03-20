#!/usr/bin/env bash

# Create a img first.
# truncate --size 1G <root-dir>/treadmill.img

sudo TREADMILL_EXE_WHITELIST=/home/centos/treadmill/etc/linux.exe.config \
    ./bin/treadmill sproc --cell gaocegege --cgroup . \
    service --root-dir /tmp/treadmill.GHB localdisk \
    --default-read-bps 1 --default-write-bps 1 --default-read-iops 1 --default-write-iops 1
