#!/usr/bin/env bash

# Usage:
#       local-up.sh Start the standalone server.

# Timestamped log, e.g. log "server created".
#
# Input:
#   $1 Log string.
function log {
  echo -e "[`TZ=Asia/Shanghai date`] ${1}"
}

ROOT=$(dirname "${BASH_SOURCE}")/..
TMPDIR="/tmp/treadmill.server.local"
if [ ! -d "${TMPDIR}" ]; then
    sudo mkdir -p ${TMPDIR}
    sudo chown ${USER} -R ${TMPDIR}
fi

# Parameters to the cli.
CELL_NAME="gaocegege"
TREADMILL_WHITELIST="/home/vagrant/treadmill/etc/linux.exe.config"
CPU_USAGE=40%
CPU_CORES=3
MEM=4096M
MEM_CORE=512M
DEFAULT_READ_BPS=20M
DEFAULT_WRITE_BPS=20M
DEFAULT_READ_IOPS=100
DEFAULT_WRITE_IOPS=100

# Clean up local run.
function server-cleanup {
  [ -n "${CLEANUP_PID-}" ] && ps -p ${CLEANUP_PID} > /dev/null \
    && sudo kill ${CLEANUP_PID}
  # Kill app config manager.
  [ -n "${APP_CFG_MGR_PID-}" ] && ps -p ${APP_CFG_MGR_PID} > /dev/null \
    && sudo kill ${APP_CFG_MGR_PID}
  # Kill event daemon.
  [ -n "${EVENT_DAEMON_PID-}" ] && ps -p ${EVENT_DAEMON_PID} > /dev/null \
    && sudo kill ${EVENT_DAEMON_PID}
  # Kill server-related processes.
  [ -n "${LOCALDISK_SERVICE_PID-}" ] && ps -p ${LOCALDISK_SERVICE_PID} > /dev/null \
    && sudo kill ${LOCALDISK_SERVICE_PID}
  [ -n "${CGROUP_SERVICE_PID-}" ] && ps -p ${CGROUP_SERVICE_PID} > /dev/null \
    && sudo kill ${CGROUP_SERVICE_PID}
  [ -n "${NETWORK_SERVICE_PID-}" ] && ps -p ${NETWORK_SERVICE_PID} > /dev/null \
    && sudo kill ${NETWORK_SERVICE_PID}
  [ -n "${SERVER_PID-}" ] && ps -p ${SERVER_PID} > /dev/null && sudo kill ${SERVER_PID}
  [ -n "${SUPERVISOR_PID-}" ] && ps -p ${SUPERVISOR_PID} > /dev/null \
    && sudo kill ${SUPERVISOR_PID}
  # Remove the temp directory.
  [ -d "${TMPDIR}" ] && sudo rm -rf ${TMPDIR}
  log "server-up cleanup now."
}
trap server-cleanup INT EXIT

cd ${ROOT}

log "Start installation."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
        ./bin/treadmill admin install \
        --config ./etc/linux.exe.config node \
        --install-dir ${TMPDIR}

# Init cgroup?
log "Initialize cgroup fs."
sudo ./bin/treadmill sproc --cell ${CELL_NAME} cgroup \
    init --cpu ${CPU_USAGE} \
    --cpu-cores ${CPU_CORES} \
    --mem ${MEM} \
    --mem-core ${MEM_CORE}

# Run Server process.
# confifure a server first?
# ./bin/treadmill --debug admin master --cell ${CELL_NAME} server configure localhost -p /mock-parent &
# sleep 3s
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

sleep 5s
# Run event daemon.
log "Start event daemon process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    eventdaemon --approot ${TMPDIR} &
EVENT_DAEMON_PID=$!

# Run app events.
log "Start app events process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    appevents ${TMPDIR}/appevents &

# Run supervisor.
log "Start supervisor process."
sudo s6-supervise ${TMPDIR}/init/supervisor &
SUPERVISOR_PID=$!
#sudo /usr/local/bin/s6-svscan ${TMPDIR}/running &
sleep 1s

# Run cleanup.
log "Start cleanup process."
#sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
#    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
#    cleanup --approot ${TMPDIR} &
sudo s6-supervise ${TMPDIR}/init/cleanup &
CLEANUP_PID=$!
sleep 1s

# Run appcfgmgr.
log "Start app config manager process."
sudo TREADMILL_EXE_WHITELIST=${TREADMILL_WHITELIST} \
    ./bin/treadmill sproc --cell ${CELL_NAME} --cgroup . \
    appcfgmgr --approot ${TMPDIR} &
APP_CFG_MGR_PID=$!

# Run rrdcached
sudo rrdcached -l unix:/tmp/treadmill.rrd -p /tmp/treadmill.rrd.pid &

cd - > /dev/null
echo ${TMPDIR}
while true; do sleep 1; done
