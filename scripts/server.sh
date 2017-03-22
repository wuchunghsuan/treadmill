#!/usr/bin/env bash

# Usage:
#       local-up.sh Start the standalone scheduler.

# Timestamped log, e.g. log "cluster created".
#
# Input:
#   $1 Log string.
function log {
  echo -e "[`TZ=Asia/Shanghai date`] ${1}"
}

ROOT=$(dirname "${BASH_SOURCE}")/..
TMPDIR=$(mktemp -d /tmp/treadmill.server.XXXXXXXXXX) || exit 1

# Parameters to the cli.
CELL_NAME="gaocegege"
TREADMILL_WHITELIST="/home/centos/treadmill/etc/linux.exe.config"
CPU_USAGE=40%
CPU_CORES=1
MEM=1024M
MEM_CORE=1024M
DEFAULT_READ_BPS=1
DEFAULT_WRITE_BPS=1
DEFAULT_READ_IOPS=1
DEFAULT_WRITE_IOPS=1

# Clean up local run.
function server-cleanup {
  # Kill event daemon.
  [ -n "${EVENT_DAEMON_PID-}" ] && ps -p ${EVENT_DAEMON_PID} > /dev/null \
    && sudo kill ${EVENT_DAEMON_PID}
  # Kill server-related processes.
  [ -n "${LOCALDISK_SERVICE_PID-}" ] && ps -p ${LOCALDISK_SERVICE_PID} > /dev/null \
    && sudo kill ${LOCALDISK_SERVICE_PID}
  [ -n "${CGROUP_SERVICE_PID-}" ] && ps -p ${CGROUP_SERVICE_PID} > /dev/null \
    && kill ${CGROUP_SERVICE_PID}
  [ -n "${NETWORK_SERVICE_PID-}" ] && ps -p ${NETWORK_SERVICE_PID} > /dev/null \
    && kill ${NETWORK_SERVICE_PID}
  [ -n "${SERVER_PID-}" ] && ps -p ${SERVER_PID} > /dev/null && sudo kill ${SERVER_PID}

  # Remove the temp directory.
  [ -d "${TMPDIR}" ] && sudo rm -rf ${TMPDIR}

  log "server-up cleanup now."
}
trap server-cleanup INT EXIT

cd ${ROOT}
# Init cgroup?
log "Initialize cgroup fs."
sudo ./bin/treadmill sproc --cell ${CELL_NAME} cgroup \
    init --cpu ${CPU_USAGE} \
    --cpu-cores ${CPU_CORES} \
    --mem ${MEM} \
    --mem-core ${MEM_CORE} &
sleep 3s

# Run Server process.
# confifure a server first?
./bin/treadmill --debug admin master --cell ${CELL_NAME} server configure localhost -p /mock-parent &
sleep 3s
log "The root of the server is ${TMPDIR}, start server process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    init --approot ${TMPDIR} &
SERVER_PID=$!

# Run localdisk service process.
# Create a img first.
truncate --size 1G ${TMPDIR}/treadmill.img
log "Start localdisk service process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    service --root-dir ${TMPDIR} localdisk \
    --default-read-bps ${DEFAULT_READ_BPS} \
    --default-write-bps ${DEFAULT_WRITE_BPS} \
    --default-read-iops ${DEFAULT_READ_IOPS} \
    --default-write-iops ${DEFAULT_WRITE_IOPS} &
LOCALDISK_SERVICE_PID=$!

# Run cgroup service process.
log "Start cgroup service process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    service --root-dir ${TMPDIR} \
    cgroup &
CGROUP_SERVICE_PID=$!

# Run network service process.
log "Start network service process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    service --root-dir ${TMPDIR} \
    network &
NETWORK_SERVICE_PID=$!

# Run event daemon.
log "Start event daemon process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    eventdaemon --approot ${TMPDIR} &
EVENT_DAEMON_PID=$!

cd - > /dev/null

while true; do sleep 1; done
