#!/bin/bash -e

if [ -z "${JOB_NAME}" ] ; then
  printf "\n\n ${0} - Error, JOB_NAME environment variable is not defined.\n\n"
  exit 1
fi

if [ -z "${BUILD_NUMBER}" ] ; then
  printf "\n\n ${0} - Error, BUILD_NUMBER environment variable is not defined.\n\n"
  exit 1
fi

if [ -z "${HUDSON_URL}" ] ; then
  printf "\n\n ${0} - Error, HUDSON_URL environment variable is not defined.\n\n"
  exit 1
fi

if [ -z "${HUDSON_MASTER_HOST}" ] ; then
  printf "\n\n ${0} - Error, HUDSON_MASTER_HOST environment variable is not defined.\n\n"
  exit 1
fi

PATH=/gf-hudson-tools/bin:${PATH}

#
# platform specifics
#
if [ `uname | grep -i "windows" | wc -l | awk '{print $1}'` -eq 1 ] ; then
  DEVNULL=nul
  GREP="grep"
  AWK="awk"
  SED="sed"
  export PATH=/mksnt/mksnt:$PATH
else
  DEVNULL=/dev/null
  if [ `uname | grep -i "sunos" | wc -l | awk '{print $1}'` -eq 1 ] ; then
    GREP="ggrep"
    AWK="gawk"
    SED="gsed"
  else
    GREP="grep"
    AWK="awk"
    SED="sed"
  fi
fi

# Create the job dir for the current job
INIT_JOB_NAME=`echo ${JOB_NAME} | ${SED} -e s@'\/'@'_'@g -e s@','@'_'@g -e s@'='@'_'@g`
export DATA_DIR="/gf-hudson-tools/jobs-data/${INIT_JOB_NAME}"
if [ ! -d ${DATA_DIR} ] ; then
  mkdir ${DATA_DIR}
else
  # if the job already exist do a cleanup
  # for jobs that are not running.
  for NAME in `ls ${DATA_DIR}` ; do
    if [ -f ${DATA_DIR}/${NAME} ] || [ -d ${DATA_DIR}/${NAME} ]; then
      ID=${NAME##*-}
      ID=${ID%.sh}
      IS_BUILDING=`curl --noproxy ${HUDSON_MASTER_HOST} ${HUDSON_URL}/job/${JOB_NAME}/${ID}/api/xml 2> ${DEVNULL} | ${AWK} 'BEGIN{ RS=">" ; FS="<" } /<\/building/{ print $1 }' | head -1`
      if [ -z "${IS_BUILDING}" ] || [ "${IS_BUILDING}" = "false" ] ; then
        # Why was this a 'rm -rf'?  Changing it to just 'rm -f'.
        #rm -rf ${DATA_DIR}/${NAME} || true
        rm -f ${DATA_DIR}/${NAME} || true
      fi
    fi
  done
fi

# Copy all files under build-tools/wls to the DATA dir
# and provide variables to access them
cd /gf-hudson-tools/hudson-tools/
for SCRIPT in `ls build-tools/wls/*.sh` ; do
  SCRIPT_NAME=`basename ${SCRIPT%.sh}`
  for VERSION_TAG in latest `git tag -l | ${AWK} '{t=$1 ; gsub("_","",t); print t" "$1}' | sort -rn | head -5 | ${AWK} '{print $2}'` ; do
    if [ "${VERSION_TAG}" = "latest" ] ; then
      DATA_DIR_LOCATION="${DATA_DIR}/${SCRIPT_NAME}-latest-${BUILD_NUMBER}.sh"
      cp /gf-hudson-tools/hudson-tools/build-tools/wls/`basename ${SCRIPT}` ${DATA_DIR_LOCATION}
      # export untagged name as latest
      VARNAME=`echo ${SCRIPT_NAME} | ${SED} s@'-'@'_'@g`
      export ${VARNAME}="${DATA_DIR_LOCATION}"
      # export latest
      VARNAME=${VARNAME}_latest
      export ${VARNAME}="${DATA_DIR_LOCATION}"
    else
      DATA_DIR_LOCATION="${DATA_DIR}/${SCRIPT_NAME}-${VERSION_TAG}-${BUILD_NUMBER}.sh"
      git show ${VERSION_TAG}:build-tools/wls/`basename ${SCRIPT}` 1> ${DATA_DIR_LOCATION} || true
      VERSION=`echo ${VERSION_TAG} | ${SED} -e s@'-'@'_'@g -e s@'\.'@'_'@g`
      VARNAME="`echo ${SCRIPT_NAME} | ${SED} s@'-'@'_'@g`_${VERSION}"
      export ${VARNAME}="${DATA_DIR_LOCATION}"
    fi
  done
done
cd - > ${DEVNULL} 2>&1
printf "\n"
