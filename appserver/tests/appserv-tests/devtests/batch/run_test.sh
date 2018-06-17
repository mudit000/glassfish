#!/bin/bash -ex
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2017 Oracle and/or its affiliates. All rights reserved.
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

list_test_ids(){
  echo batch_all
}

test_run(){
  $S1AS_HOME/bin/asadmin start-domain
  $S1AS_HOME/bin/asadmin start-database
  cd $APS_HOME/devtests/batch
  PROXY_HOST=`echo ${http_proxy} | cut -d':' -f2 | ${SED} 's/\/\///g'`
  PROXY_PORT=`echo ${http_proxy} | cut -d':' -f3 | ${SED} 's/\///g'`
  ANT_OPTS="${ANT_OPTS} \
  -Dhttp.proxyHost=${PROXY_HOST} \
  -Dhttp.proxyPort=${PROXY_PORT} \
  -Dhttp.noProxyHosts='127.0.0.1|localhost|*.oracle.com' \
  -Dhttps.proxyHost=${PROXY_HOST} \
  -Dhttps.proxyPort=${PROXY_PORT} \
  -Dhttps.noProxyHosts='127.0.0.1|localhost|*.oracle.com'"
  export ANT_OPTS
  echo "ANT_OPTS=${ANT_OPTS}"
  ant $TARGET | tee $TEST_RUN_LOG
  $S1AS_HOME/bin/asadmin stop-database
  $S1AS_HOME/bin/asadmin stop-domain   
}

run_test_id(){
  unzip_test_resources $WORKSPACE/bundles/glassfish.zip
  cd `dirname $0`
  test_init
  get_test_target $1
  #run the actual test function
  test_run
  generate_junit_report $1
  change_junit_report_class_names
}

get_test_target(){
	case $1 in
		batch_all )
			TARGET=all
			export TARGET;;
	esac

}

OPT=$1
TEST_ID=$2
source `dirname $0`/../../../common_test.sh
case $OPT in
  list_test_ids )
    list_test_ids;;
  run_test_id )
    trap "copy_test_artifects ${TEST_ID}" EXIT
    run_test_id $TEST_ID ;;
esac
