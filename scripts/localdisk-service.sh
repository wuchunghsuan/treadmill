#!/usr/bin/env bash

# Create a img first.
# truncate --size 1G <root-dir>/treadmill.img

sudo TREADMILL_EXE_WHITELIST=/home/vagrant/treadmill/etc/linux.exe.config \
    ./bin/treadmill sproc --cell gaocegege --cgroup . \
    service --root-dir /tmp/treadmill.localdisk.test localdisk \
    --default-read-bps 20M --default-write-bps 20M --default-read-iops 100 --default-write-iops 100
