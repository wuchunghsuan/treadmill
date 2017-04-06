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
TMPDIR=$(mktemp -d /tmp/treadmill.XXXXXXXXXX)
CELL_NAME=gaocegege

# Clean up local run.
function local-cleanup {
  [ -d "${TMPDIR}" ] && rm -rf ${TMPDIR}
  docker-compose stop
  docker-compose rm -vf
  [ -n "${TMSCHEDULER_PID-}" ] && ps -p ${TMSCHEDULER_PID} > /dev/null && kill ${TMSCHEDULER_PID}
  log "local-up cleanup now."
}
trap local-cleanup INT EXIT

if [[ "$(which docker)" == "" ]]; then
 log "Unable to find docker"
 exit 1
fi

cd ${ROOT}
docker-compose up -d --force-recreate
sleep 1s
./bin/treadmill --debug admin master --cell ${CELL_NAME} server configure localhost -p /mock-parent
./bin/treadmill --debug sproc scheduler ${TMPDIR} &
TMSCHEDULER_PID=$!
cd - > /dev/null

while true; do sleep 1; done
