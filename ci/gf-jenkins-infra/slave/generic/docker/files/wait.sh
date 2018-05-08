#!/bin/bash
: ${1?"Usage: $0 <FILE_TO_CHECK>"}
MAX_RETRY_COUNT=24
SLEEP_SEC=5s
CHECK_FILE=$1
attempt=0
while : ; do
  ls -l ${CHECK_FILE}
  result=$?
  [[ ${result} -ne 0 && ${attempt} -lt ${MAX_RETRY_COUNT} ]] ||break
  echo "File still not available.Wait and retry .."
  sleep ${SLEEP_SEC}
  attempt=$((attempt+1))
  echo "Retry Count: ${attempt}"
done
