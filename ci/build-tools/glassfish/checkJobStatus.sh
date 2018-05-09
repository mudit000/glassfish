#!/bin/bash

# OS-specific section
if [ `uname | grep -i "sunos" | wc -l | awk '{print $1}'` -eq 1 ] ; then
  GREP="ggrep"
  AWK="gawk"
  SED="gsed"
  BC="gbc"
  export PATH=/gf-hudson-tools/bin:${PATH}
else
  GREP="grep"
  AWK="awk"
  SED="sed"
  BC="bc"
fi

export GREP AWK SED BC

checkStatus(){
  TEST_ID=$1
  STATUS_FILE=$2
  content=$3
  case $TEST_ID in
    findbugs_all)
      resultFile="${WORKSPACE}/test-results/${TEST_ID}/results/findbugs_results/findbugscheck.log";;
    copyright)
      resultFile="${WORKSPACE}/test-results/${TEST_ID}/results/copyright_results/copyrightcheck.log";;
    findbugs_low_priority_all)
      resultFile="${WORKSPACE}/test-results/${TEST_ID}/results/findbugs_low_priority_all_results/findbugscheck.log";;
  esac
  isSuccess=`cat "${resultFile}" | ${GREP} "SUCCESS" || true`
  platform=`cat ${WORKSPACE}/test-results/${TEST_ID}/platform`
  if [ "${isSuccess}" = "" ];then
    echo "${content} ~ Failures:NA,Errors:NA ~ ${platform} ~"  | ${AWK} -F '~' '{print "~",$2,"~",$3,"~","UNSTABLE","~",$5,"~",$7,"~",$8, "~"}' >> ${STATUS_FILE}
  else
    echo "${content} ~ Failures:NA,Errors:NA ~ ${platform} ~" | ${AWK} -F '~' '{print "~",$2,"~",$3,"~","SUCCESS","~",$5,"~",$7,"~", $8, "~"}' >> ${STATUS_FILE}
  fi
}

add_to_test_status(){
  status_file=${WORKSPACE}/test-results/test-status.txt
  rm ${status_file}.tmp > /dev/null || true  
  AGG_JUD="${WORKSPACE}/test-results/test_results_junit.xml"
  rm ${AGG_JUD} > /dev/null || true 
  echo "<testsuites>" >> $AGG_JUD
  IFS=$'\n'
  if [ -f ${status_file} ] ; then
    for i in `cat ${status_file}`
    do
     test_id=`echo ${i} | ${SED} 's/ ~ */~/g' | cut -d'~' -f2`
      isTestSuccess=`echo $i | ${GREP} "SUCCESS" || true`
      if [ "${isTestSuccess}" != "" ];then
        #echo $test_id       
        case ${test_id} in
          findbugs_all)
            checkStatus ${test_id} ${status_file}.tmp ${i};;
          findbugs_low_priority_all)
            checkStatus ${test_id} ${status_file}.tmp ${i};;
          copyright)
            checkStatus ${test_id} ${status_file}.tmp ${i};;
          *)
            set_job_status ${test_id} ${status_file}.tmp ${i}
            aggregate_downstream_junit_xml ${test_id};;
        esac
      else
        platform=`cat ${WORKSPACE}/test-results/${test_id}/platform`
        echo "${i} ~ Failures:NA,Errors:NA ~ ${platform} ~" | ${AWK} -F '~' '{print "~",$2,"~",$3,"~",$4,"~",$5,"~",$7,"~",$8,"~"}'  >> ${status_file}.tmp
      fi
    done
  fi
  echo "</testsuites>" >> $AGG_JUD
  mv ${status_file}.tmp ${status_file}
}

set_job_status(){
  TEST_ID="${1}"
  statusFile="${2}"
  statusLine="${3}"
  JUD="${WORKSPACE}/test-results/${TEST_ID}/results/junitreports/test_results_junit.xml"
  isFailure=`cat ${JUD} | ${GREP} -aE "<failure ((type)*|(message)*)" || true `
  isError=`cat ${JUD} | ${GREP} -aE "<error ((type)*|(message)*)" || true`
  numFail=`cat ${JUD} | ${GREP} -acE "<failure ((type)*|(message)*)" || true`
  numError=`cat ${JUD} | ${GREP} -acE "<error ((type)*|(message)*)" || true`
  status="PASSED"
  platform=`cat ${WORKSPACE}/test-results/${TEST_ID}/platform`
  if [ "${isFailure}" = "" -a "${isError}" = "" ];then
    echo "${statusLine} ~ Failures:0,Errors:0 ~ ${platform} ~" | ${AWK} -F '~' '{print "~",$2,"~",$3,"~","SUCCESS","~",$5,"~",$7,"~",$8,"~"}' >> ${statusFile}
  else
    echo "${statusLine} ~ Failures:${numFail},Errors:${numError} ~ ${platform} ~"  | ${AWK} -F '~' '{print "~",$2,"~",$3,"~","UNSTABLE","~",$5,"~",$7,"~",$8,"~"}' >> ${statusFile}
  fi
}

aggregate_downstream_junit_xml(){
  TEST_ID="${1}"
  JUD="${WORKSPACE}/test-results/${TEST_ID}/results/junitreports/test_results_junit.xml"
  AGG_JUD="${WORKSPACE}/test-results/test_results_junit.xml"
  cat ${JUD} | ${SED} '/<\?xml version/d' | ${SED} '/<testsuites>/d' | ${SED} '/<\/testsuites>/d' >>${AGG_JUD}
}

add_to_test_status
