#!/bin/bash -ex
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2017-2018 Oracle and/or its affiliates. All rights reserved.
#
# The contents of this file are subject to the terms of either the GNU
# General Public License Version 2 only ("GPL") or the Common Development
# and Distribution License("CDDL") (collectively, the "License").  You
# may not use this file except in compliance with the License.  You can
# obtain a copy of the License at
# https://oss.oracle.com/licenses/CDDL+GPL-1.1
# or LICENSE.txt.  See the License for the specific
# language governing permissions and limitations under the License.
#
# When distributing the software, include this License Header Notice in each
# file and include the License file at LICENSE.txt.
#
# GPL Classpath Exception:
# Oracle designates this particular file as subject to the "Classpath"
# exception as provided by Oracle in the GPL Version 2 section of the License
# file that accompanied this code.
#
# Modifications:
# If applicable, add the following below the License Header, with the fields
# enclosed by brackets [] replaced by your own identifying information:
# "Portions Copyright [year] [name of copyright owner]"
#
# Contributor(s):
# If you wish your version of this file to be governed by only the CDDL or
# only the GPL Version 2, indicate your decision by adding "[Contributor]
# elects to include this software in this distribution under the [CDDL or GPL
# Version 2] license."  If you don't indicate a single choice of license, a
# recipient has the option to distribute your version of this file under
# either the CDDL, the GPL Version 2 or to extend the choice of license to
# its licensees as provided above.  However, if you add GPL Version 2 code
# and therefore, elected the GPL Version 2 license, then the option applies
# only if the new code is made subject to such option by the copyright
# holder.
#

test_run_sqe_smoke(){
  if [[ -z ${INTERNAL_RELEASE_REPO} ]]; then
    echo "error: INTERNAL_RELEASE_REPO is not set"
    exit 1
  fi
  SPS_HOME=${WORKSPACE}/appserver-sqe; export SPS_HOME
  # MACHINE CONFIGURATION
  pwd
  uname -a
  java -version

  # CLEANUPS
  kill_clean `ps -ef |grep jre|grep -v grep|cut -f4,5 -d" "`
  kill_clean `jps |grep Main |grep -v grep |cut -f1 -d" "`
  kill_clean `ps -ef | grep ${WORKSPACE}/glassfish5/glassfish|grep -v grep`

  curl --noproxy '*' ${INTERNAL_RELEASE_REPO}/com/oracle/glassfish/sqe-smoke/1.0/sqe-smoke-1.0.zip > bundles/sqe-smoke.zip
  unzip bundles/sqe-smoke.zip

  cd ${SPS_HOME}
  ant start-domain v3g-smoke-test stop-domain
  archive_artifacts
}

run_test_id(){
  source `dirname ${0}`/../common_test.sh
  kill_process
  unzip_test_resources ${WORKSPACE}/bundles/glassfish.zip
  test_init
  if [[ ${1} = "sqe_smoke_all" ]]; then
    test_run_sqe_smoke | tee ${TEST_RUN_LOG}
    result=${WORKSPACE}/results/test_resultsValid.xml
    resultGtest=${WORKSPACE}/results/security-gtest-results-valid.xml
  else
    echo "Invalid Test ID"
    exit 1
  fi
  generate_junit_report_sqe ${1} ${result} ${WORKSPACE}/results/test_results_junit.xml
  generate_junit_report_sqe ${1} ${resultGtest} ${WORKSPACE}/results/test_results_gtest_junit.xml
  merge_junit_xmls ${WORKSPACE}/results/test_results_junit.xml ${WORKSPACE}/results/test_results_gtest_junit.xml
  change_junit_report_class_names
}

archive_artifacts(){
  cp ${S1AS_HOME}/domains/domain1/logs/server.log* ${WORKSPACE}/results
  cp ${SPS_HOME}/summaryreport-v3smoke.html ${WORKSPACE}/results/ST-GP-report.html
  cp ${SPS_HOME}/count.txt ${WORKSPACE}/results
  cp ${SPS_HOME}/test_resultsValid.xml ${WORKSPACE}/results
  cp ${TEST_RUN_LOG} ${WORKSPACE}/results/
  find ${SPS_HOME}/reports -name security-gtest-results-valid.xml -exec cp '{}' ${WORKSPACE}/results \; > /dev/null || true
  tar -cvf ${WORKSPACE}/${TEST_ID}-results.tar.gz ${WORKSPACE}/results
}

merge_junit_xmls(){
  JUD_1=${1}
  JUD_2=${2}
  JUD=${WORKSPACE}/results/junitreports/test_results_junit.xml
  rm -f ${JUD} || true
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> ${JUD}
  echo "<testsuites>" >> ${JUD}
  cat ${1} >> ${JUD}
  cat ${2} >> ${JUD}
  echo "</testsuites>" >> ${JUD}
}

generate_junit_report_sqe(){
  printf "\n%s \n\n" "===== GENERATE JUNIT REPORT ====="
  TD=${2}
  JUD=${3}
  TESTSUITE_NAME=${1}

  cat ${TD} | ${AWK} -v suitename=${TESTSUITE_NAME} '
    BEGIN {
      totaltests = 0;
      totalfailures = 0;
      totalerrors = 0;
    }
    function getPropVal(str){
      split(str, a, "=");
      val = a[2];
      # remove quotes
      gsub("\"","",val);
      return val;
    }
     function removeXMLTag(str){
      # remove xml tag quotes
      gsub("</.*>","",str);
      gsub("<.*>","",str);
      gsub(">","",str);
      return str;
    }
    /status value=/ {
      result=getPropVal($0);
      result=removeXMLTag(result);
    }
    /<testsuite>/ {
      getline;
      getline;
            getline;
      testunit=removeXMLTag($0);
      gsub("\"","",testunit);
    }
    /<testcase>/ {
      getline;
      testname=removeXMLTag($0);
      gsub("\"","",testname);
    }
    /<\/testcase>/{
      classname=testunit
      # printing testcase to out
      out = out sprintf(" <testcase classname=\"%s\" name=\"%s\" time=\"0.0\">\n", classname, testname);
      if (result == "fail") {
       out = out "  <failure message=\"NA\" type=\"NA\"/>\n";
       totalfailures++;
      } else if (result == "did_not_run") {
       out = out "  <error message=\"NA\" type=\"NA\"/>\n";
       totalerrors++;
      }
      out = out " </testcase>\n";

      totaltests++;
      result="";
      testname="";
    }
    END {
      printf "<testsuite tests=\"%d\" failures=\"%d\" errors=\"%d\" name=\"%s\">\n", totaltests, totalfailures, totalerrors, suitename;
      printf "%s", out;
      print "</testsuite>"
    }' > ${JUD}
}


list_test_ids(){
  echo sqe_smoke_all
}

kill_clean(){
  if [ ${#1} -ne 0 ] ; then kill -9 $1 ; fi 
}

post_test_run(){
  if [[ $? -ne 0 ]]; then
    archive_artifacts
  fi
  delete_bundle
  cd -
}

OPT=${1}
TEST_ID=${2}

case ${OPT} in
  list_test_ids )
    list_test_ids;;
  run_test_id )
    trap post_test_run EXIT
    run_test_id ${TEST_ID} ;;
esac
