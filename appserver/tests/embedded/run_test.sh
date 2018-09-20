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

test_run_embedded(){
  cd ${WORKSPACE}
  mvn -DskipTests=true clean install
  EMBEDDED_WORKSPACE=${WORKSPACE}/appserver/extras/embedded
  cd ${EMBEDDED_WORKSPACE}/all
  mvn -DskipTests=true clean install | tee ${TEST_RUN_LOG}
  cd ${EMBEDDED_WORKSPACE}/nucleus
  mvn -DskipTests=true clean install | tee -a ${TEST_RUN_LOG}
  cd ${EMBEDDED_WORKSPACE}/web
  mvn -DskipTests=true clean install | tee -a ${TEST_RUN_LOG}
  cd ${WORKSPACE}/appserver/tests/embedded/maven-plugin/remoteejbs
  mvn -DskipTests=true clean verify | tee -a ${TEST_RUN_LOG}
  cd ${WORKSPACE}/appserver/tests/embedded/maven-plugin/mdb
  mvn -DskipTests=true clean verify | tee -a ${TEST_RUN_LOG}
  cd ${WORKSPACE}/appserver/tests/embedded
  mvn -Dbuild=snapshot -Dmaven.test.failure.ignore=true clean verify | tee -a ${TEST_RUN_LOG}
  merge_junits
}

merge_junits(){
  TEST_ID="embedded_all"
  rm -rf ${WORKSPACE}/results || true
  mkdir -p ${WORKSPACE}/results/junitreports
  JUD="${WORKSPACE}/results/junitreports/test_results_junit.xml"
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > ${JUD}
  echo "<testsuites>" >> ${JUD}
  for i in `find . -type d -name "surefire-reports"`
  do    
    ls -d -1 ${i}/*.xml | xargs cat | ${SED} 's/<?xml version=\"1.0\" encoding=\"UTF-8\" *?>//g' >> ${JUD}
  done
  echo "</testsuites>" >> ${JUD}
  ${SED} -i 's/\([a-zA-Z-]\w*\)\./\1-/g' ${JUD}
  ${SED} -i "s/\bclassname=\"/classname=\"${TEST_ID}./g" ${JUD}
}

run_test_id(){
  case ${TEST_ID} in
    embedded_all)
      unzip_test_resources ${WORKSPACE}/bundles/glassfish.zip
   	  test_run_embedded;;
  esac
}

list_test_ids(){
	echo embedded_all
}

OPT=${1}
TEST_ID=${2}
source `dirname ${0}`/../common_test.sh

case ${OPT} in
	list_test_ids )
		list_test_ids;;
	run_test_id )
		trap "copy_test_artifacts ${TEST_ID}" EXIT
    run_test_id ${TEST_ID} ;;
esac
