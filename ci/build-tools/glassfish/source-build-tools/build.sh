#!/bin/bash
# Copyright (c) 2012 Oracle and/or its affiliates. All rights reserved.

if [ -z "$MAVEN_OPTS" ]
then
	MAVEN_OPTS="-Xmx4096m -XX:MaxPermSize=1024m"
	export MAVEN_OPTS
fi

MY_HTTP_PROXYHOST=
MY_HTTP_PROXYPORT=
MY_HTTPS_PROXYHOST=
MY_HTTPS_PROXYPORT=

OPTS="-Dmaven.test.skip=true \
      -Dgpg.passphrase=glassfish \
      -Dmaven.javadoc.skip=true \
      -Dmaven.deploy.skip=true \
      -Dgpg.skip=true \
      -Dsource.skip=true \
      -Dcheckstyle.skip=true \
      -Dhttp.proxyHost=${MY_HTTP_PROXYHOST} \
      -Dhttp.proxyPort=${MY_HTTP_PROXYPORT}  \
      -Dhttps.proxyHost=${MY_HTTPS_PROXYHOST} \
      -Dhttps.proxyPort=${MY_HTTPS_PROXYPORT} -Pfinal,staging"

MVN=`which mvn`
if [ $? -ne 0 ]
then
	set -x
	echo "ERROR 'mvn' not found in the PATH"
	set +x
	exit 1
fi

if [ ${#} -eq 0 ]
then
	USERARGS="clean install"
else
	USERARGS="$*"
fi

$MVN $OPTS $USERARGS
