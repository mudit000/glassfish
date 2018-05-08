#!/bin/bash -ex

#
#  !! This file is not versioned. !!
#

#
# Platform specifics
#
if [ `uname | grep -i "windows" | wc -l | awk '{print $1}'` -eq 1 ] ; then
  IS_WINDOWS=1
  IS_SOLARIS=0
  IS_LINUX=0
  DEVNULL=nul
  GREP="grep"
  AWK="awk"
  SED="sed"
  BC="bc"
else
  IS_WINDOWS=0

  # Don't decrease current ulimit but set only if trying to increase.
  ULIMIT=8192
  CURRENT_ULIMIT=`ulimit -u`
  if [ ${CURRENT_ULIMIT} -lt ${ULIMIT} ]; then
    if [ -z "${VERBOSE}" ] || [ "${VERBOSE}" = "true" ] ; then
      log_msg "wls-hudson-common.sh: increasing ulimit to ${ULIMIT}"
    fi
    ulimit -u ${ULIMIT} || true
  fi

  DEVNULL=/dev/null

  if [ `uname | grep -i "sunos" | wc -l | awk '{print $1}'` -eq 1 ] ; then
    GREP="ggrep"
    AWK="gawk"
    SED="gsed"
    BC="gbc"
    IS_SOLARIS=1
    IS_LINUX=0

    export PATH=/gf-hudson-tools/bin:${PATH}

  else
    GREP="grep"
    AWK="awk"
    SED="sed"
    BC="bc"
    IS_SOLARIS=0

    if [ `uname | grep -i "linux" | wc -l | awk '{print $1}'` -eq 1 ] ; then
      IS_LINUX=1
    fi
  fi
fi

get_global_version(){
  cat /gf-hudson-tools/build-tools/common/infra-version.txt | ${GREP} -v "^#"
}

#
# sources a common script matching the given pattern
# if GLOBAL_VERSION is defined, source that version of the script
# otherwise, determine the version of the value of _BASH_SOURCE
#
# _BASH_SOURCE will be set by this function.
#  it is available to sourced scripts to locate themselves.
#
# If GLOBAL_VERSION is not defined, and _BASH_SOURCE is not defined, this function will fail.
#
# E.g.
# source /gf-hudson-tools/build-tools/common/base.sh
# import "wls_external_common"
#
# Arg1 - the pattern of the script to source
#
import(){
  local VERSION
  if [ -z "${GLOBAL_VERSION}" ] ; then
    if [ -z "${_BASH_SOURCE}" ] ; then
      echo "ERROR, _BASH_SOURCE var is empty"
      return 1
    fi
    VERSION=`${_BASH_SOURCE} | ${SED} 's/\(.*\)-\(.*\)-.*/\2/'`
  else
    VERSION=${GLOBAL_VERSION}
  fi
  local PATTERN=`echo ${1} | ${SED} s@'-'@'_'@g`
  _BASH_SOURCE=`env | ${GREP} ${PATTERN}_${VERSION}= | cut -d '=' -f2`
  source ${_SOURCE_FILE}
}

