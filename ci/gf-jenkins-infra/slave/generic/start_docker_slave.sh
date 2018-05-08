#!/bin/bash
DEFAULT_IMAGE_NAME=ankurhub/generic-slave:latest

if [ $# -gt 0 ] && [ ! -z "$1" ]; then
 IMAGE_NAME=$1
else
 IMAGE_NAME=${DEFAULT_IMAGE_NAME}
fi 

MAX_RETRY_COUNT=2
#Attempt retry if the execution time is less than this(time in miliseconds).
MIN_RUN_TIME=20000

: "${EXECUTE_SCRIPT?EXECUTE_SCRIPT need to be set}"
if [ `uname | grep -i "sunos" | wc -l | awk '{print $1}'` -eq 1 ] ; then
 echo "Executing in Solaris"
 (/bin/bash -c "${EXECUTE_SCRIPT}") 2>&1
else
 HOST=`hostname`
 #DN=`domainname`
 if [ $HOST == blr* ]; then
  DN="idc.oracle.com us.oracle.com"
  dn_opt="--dns-search=idc.oracle.com --dns-search=us.oracle.com"
 else
  DN="us.oracle.com"
  dn_opt="--dns-search=us.oracle.com"
 fi

 export JENKINS_VARS=" -e BUILD_NUMBER=${BUILD_NUMBER} -e BUILD_ID=${BUILD_ID} -e BUILD_DISPLAY_NAME=${BUILD_DISPLAY_NAME} -e JOB_NAME=${JOB_NAME} -e JOB_BASE_NAME=${JOB_BASE_NAME} -e BUILD_TAG=${BUILD_TAG} -e EXECUTOR_NUMBER=${EXECUTOR_NUMBER} -e NODE_NAME=${NODE_NAME} -e WORKSPACE=${WORKSPACE} -e JENKINS_HOME=${JENKINS_HOME} -e JENKINS_URL=${JENKINS_URL} -e BUILD_URL=${BUILD_URL} -e JOB_URL=${JOB_URL} "
 export GLOBAL_ENVS=" -e HUDSON_URL=${HUDSON_URL} -e ANT_HOME=${ANT_HOME} -e GPG_PASSPHRASE=${GPG_PASSPHRASE} -e GRADLE_USER_HOME=${GRADLE_USER_HOME} -e HUDSON_HOME=${HUDSON_HOME} -e HUDSON_MASTER_HOST=${HUDSON_MASTER_HOST} -e JNET_STORAGE_HOST=${JNET_STORAGE_HOST} -e JNET_USER=${JNET_USER} -e MAVEN_3_0_3=${MAVEN_3_0_3} -e MAVEN_3_2_3=${MAVEN_3_2_3} -e MAVEN_3_3_3=${MAVEN_3_3_3} -e NOTIFICATION_FROM=${NOTIFICATION_FROM} -e NOTIFICATION_SENDTO=${NOTIFICATION_SENDTO} -e RE_USER=${RE_USER} -e STORAGE_HOST=${STORAGE_HOST} -e STORAGE_HOST_HTTP=${STORAGE_HOST_HTTP} -e JAVA_HOME=${JAVA_HOME}"


 echo "Executing build through Docker"
 touch /tmp/auto_${BUILD_NUMBER}.log
 attempt=0
 while : ; do
  start_time=`date +%s%3N`
  set +e

  #Customize Docker name
  dock_name=${JOB_NAME}-${BUILD_NUMBER}
  if [[  "${dock_name}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]+$ ]]; then
    if [ ! "$(sudo docker ps -q -f name=${dock_name})" ]; then
      if [ "$(sudo docker ps -aq -f status=exited -f name=${dock_name})" ]; then
        # cleanup
        sudo docker rm ${dock_name}
      fi
    NAME_ARG="--name ${dock_name}"
    fi
  fi

  sudo docker run ${NAME_ARG} --privileged=true ${NAME_ARG} ${GLOBAL_ENVS} ${JENKINS_VARS} ${ENV_PARAMS} -e PATH="$PATH:${JAVA_HOME}/bin:/scratch/mvn/apache-maven-3.5.2/bin"  -e MAVEN_OPTS="${MAVEN_OPTS}"  -e TEST_IDS="${TEST_IDS}" -e EXECUTE_SCRIPT="${EXECUTE_SCRIPT}" -v ${WORKSPACE}:/scratch/BUILD_AREA -v ~/gf-hudson-tools/:/scratch/gf-hudson-tools -v /tmp/auto_${BUILD_NUMBER}.log:/var/log/automount.log -h ${HOST} "${dn_opt}" ${IMAGE_NAME}
  result=$?
  
  set -e
  end_time=`date +%s%3N`
  time_taken=$((end_time - start_time))
  attempt=$((attempt+1))
  [[ ${result} -ne 0 && ${MAX_RETRY_COUNT} -gt ${attempt} && ${time_taken} -lt ${MIN_RUN_TIME} ]] || break 
  echo "Attempt: ${attempt}"
  echo "Result: ${result}"
  echo "TimeTaken: ${time_taken}"
  sleep 60s
 done 

fi

set +e
#Clean up the container
sudo docker ps --filter "status=exited" | grep -v 'CONTAINER' | awk '{print $1}'  | xargs --no-run-if-empty sudo docker rm
exit ${result}
