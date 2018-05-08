#!/bin/bash -e

if [ "`uname`" == "SunOS" ]
then
	PATCH="/usr/bin/gpatch"
	GREP="/usr/sfw/bin/ggrep"
	SED="/usr/bin/gsed"
else
	PATCH="patch"
	GREP="grep"
fi

get_svn_tag(){
	NAME=$1
	VERSION=$2
	URL=$3
	TAG=$4
	PATH_TO_POM=$6
	echo " "
	echo "--------------------------------"
	echo " get_svn_tag $NAME $VERSION"
	echo "--------------------------------"
	svn export $URL $NAME-$VERSION
	add_module $NAME-$VERSION/$PATH_TO_POM
	echo " "
}
get_scp_tag(){
	NAME=$1
	VERSION=$2
	echo " "
	echo "--------------------------------"
	echo " get_scp_tag $NAME $VERSION"
	echo "--------------------------------"
	scp -r $gf_hudson_host:$svn_javaee_ri_mirror/$NAME-$VERSION .
	add_module $NAME-$VERSION
	echo " "
}
get_git_tag(){
	NAME=$1
	VERSION=$2
	URL=$3
	TAG=$4
	PATH_TO_POM=$6
	echo " "
	echo "--------------------------------"
	echo " get_git_tag $NAME $VERSION"
	echo "--------------------------------"
	git clone $URL $NAME-$VERSION ; cd $NAME-$VERSION ; git checkout $TAG ; rm -rf .git ; cd ..
	add_module $NAME-$VERSION/$PATH_TO_POM
	echo " "
}
get_noop_tag(){
	NAME=$1
	VERSION=$2
	URL=$3
	TAG=$4
	PATH_TO_POM=$6
	echo " "
	echo "--------------------------------"
	echo " get_noop_tag $NAME $VERSION"
	echo "--------------------------------"
	cd $NAME-$VERSION;cd ..
	add_module $NAME-$VERSION/$PATH_TO_POM
	echo " "
}
get_hg_tag(){
	NAME=$1
	VERSION=$2
	URL=$3
	TAG=$4
	PATH_TO_POM=$6
	echo " "
	echo "--------------------------------"
	echo " get_hg_tag $NAME $VERSION"
	echo "--------------------------------"
	echo " "
	hg clone $URL $NAME-$VERSION ; cd $NAME-$VERSION ; hg update $TAG ; rm -rf .hg* ; cd ..
	add_module $NAME-$VERSION/$PATH_TO_POM
	echo " "
}
get_github_tag(){	
	NAME=$1
	VERSION=$2
	URL=$3
	TAG=$4
	PATH_TO_POM=$6
	echo " "
	echo "--------------------------------"
	echo " get_github_tag $NAME $VERSION"
	echo "--------------------------------"
	echo " "
	# Sometime curl exists with code 141, which is code 13 (141-128)
	# Quote from http://curl.haxx.se/mail/archive-2013-01/0006.html
	# I guess the server has shut already down the connection 
	# by the time curl sends the SSL shutdown
	# A workaround has been pushed into curl >= 7.29
	curl -L -k $URL/archive/$TAG.zip > $NAME-$VERSION.zip || true
	unzip $NAME-$VERSION.zip -d $NAME-$VERSION
	rm -rf $NAME-$VERSION.zip $NAME-$VERSION/.git
	add_module $NAME-$VERSION/$PATH_TO_POM
}
get_curl_tag(){
	NAME=$1
	VERSION=$2
	URL=$3
	TAG=$4
	PATH_TO_POM=$5
	echo " "
	echo "--------------------------------"
	echo " get_curl $TAG"
	echo "--------------------------------"
	curl -L -k $URL > $TAG.zip
	unzip $TAG.zip -d $TAG
	rm -rf $TAG.zip
	add_module $TAG
	echo " "
}
generate_pom_install_file(){
	TMP_FILE="/tmp/installations.xml"
	rm -f $TMP_FILE ; touch $TMP_FILE
	ID=1
	for i in $1
	do
		FILE=`echo $i | cut -d ',' -f1`
		POMFILE=`echo $i | cut -d ',' -f2`
		echo "                    <execution>" >> $TMP_FILE
		echo "                        <phase>package</phase>" >> $TMP_FILE
		echo "                        <id>step3-install-$ID</id>" >> $TMP_FILE
		echo "                        <goals>" >> $TMP_FILE
		echo "                            <goal>install-file</goal>" >> $TMP_FILE
		echo "                        </goals>" >> $TMP_FILE
		echo "                        <configuration>" >> $TMP_FILE
		echo "                            <file>$FILE</file>" >> $TMP_FILE
		echo "                            <pomFile>$POMFILE</pomFile>" >> $TMP_FILE
		echo "                        </configuration>" >> $TMP_FILE
		echo "                    </execution>		" >> $TMP_FILE
		ID=$((ID+1))
	done
}
generate_clean_fileset(){
	TMP_FILE="/tmp/cleanfilesets.xml"
	rm -f $TMP_FILE ; touch $TMP_FILE
	echo "                        <filesets>" >> $TMP_FILE
	echo "                          <fileset>" >> $TMP_FILE
	echo '                                <directory>${basedir}</directory>' >> $TMP_FILE
	echo "                                <followSymlinks>false</followSymlinks>" >> $TMP_FILE
	echo "                                <useDefaultExcludes>true</useDefaultExcludes>"  >> $TMP_FILE
	echo "                                <includes>"  >> $TMP_FILE
	INCLUDES=`echo $1 | sed s@','@' '@g`
	for i in $INCLUDES
	do
		echo "                                    <include>$i</include>" >> $TMP_FILE
	done
	echo "                                </includes>"  >> $TMP_FILE
	echo "                                <excludes>"  >> $TMP_FILE
	EXCLUDES=`echo $2 | sed s@','@' '@g`
	for i in $EXCLUDES
	do
		echo "                                    <exclude>$i</exclude>" >> $TMP_FILE
	done
	echo "                                </excludes>"  >> $TMP_FILE
	echo "                          </fileset>" >> $TMP_FILE
	echo "                        </filesets>" >> $TMP_FILE   	
}
generate_ant_wrapper_pom(){
	NAME=$1
	VERSION=$2
	
	# THE FOLLOWING PARAMETERS ARE FILES
	ANTSCRIPT=$3
	ANTTARGET=$4
	KEYSTORE=$5
	INSTALLATIONS=/tmp/installations.xml
	CLEANFILESETS=/tmp/cleanfilesets.xml
	
	VIEW=$NAME-$VERSION/pom.xml
	PREREQUISITE=$NAME-$VERSION/pre-requisite.xml
	rm -f $VIEW $PREREQUISITE
	
echo '<project>' > $VIEW
echo '    <modelVersion>4.0.0</modelVersion>' >> $VIEW
echo '    <groupId>com.oracle.javaee</groupId>' >> $VIEW
echo '    <artifactId>'"$NAME-$VERSION"'</artifactId>' >> $VIEW
echo '    <version>1.0</version>' >> $VIEW
echo '    <packaging>pom</packaging>' >> $VIEW
echo ' ' >> $VIEW
echo '    <!-- some properties to set the classpath manually -->' >> $VIEW
echo '    <properties>' >> $VIEW
echo '        <ant.path>${settings.localRepository}/org/apache/ant/ant/1.9.0/ant-1.9.0.jar</ant.path>' >> $VIEW
echo '        <ant.launcher.path>${settings.localRepository}/org/apache/ant/ant-launcher/1.9.0/ant-launcher-1.9.0.jar</ant.launcher.path>' >> $VIEW
echo '        <ant.bcel.path>${settings.localRepository}/org/apache/ant/ant-apache-bcel/1.9.0/ant-apache-bcel-1.9.0.jar</ant.bcel.path>' >> $VIEW
echo '       <ant.junit.path>${settings.localRepository}/org/apache/ant/ant-junit/1.9.0/ant-junit-1.9.0.jar</ant.junit.path>' >> $VIEW
echo '       <junit.path>${settings.localRepository}/junit/junit/3.8.1/junit-3.8.1.jar</junit.path>' >> $VIEW
echo '        <bcel.path>${settings.localRepository}/bcel/bcel/5.1/bcel-5.1.jar</bcel.path>' >> $VIEW
echo '        <tools.jar.path>${java.home}/../lib/tools.jar</tools.jar.path>' >> $VIEW
echo '        <ant.classpath>${ant.path}:${ant.launcher.path}:${ant.bcel.path}:${bcel.path}:${junit.path}:${ant.junit.path}:${tools.jar.path}</ant.classpath>' >> $VIEW
echo '        <ant.mainClass>org.apache.tools.ant.launch.Launcher</ant.mainClass>' >> $VIEW
echo '    </properties>' >> $VIEW
echo '    <profiles>' >> $VIEW
echo '        <profile>' >> $VIEW
echo '            <id>mac</id>' >> $VIEW
echo '            <activation>' >> $VIEW
echo '                <file>' >> $VIEW
echo '                    <exists>${java.home}/../Classes/classes.jar</exists>' >> $VIEW
echo '                </file>' >> $VIEW
echo '            </activation>' >> $VIEW
echo '            <properties>' >> $VIEW
echo '                <tools.jar.path>${java.home}/../Classes/classes.jar</tools.jar.path>' >> $VIEW
echo '            </properties>' >> $VIEW
echo '        </profile>' >> $VIEW
echo '    </profiles>' >> $VIEW
echo ' ' >> $VIEW
echo '    <build>' >> $VIEW
echo '        <plugins>' >> $VIEW
echo '            <plugin>' >> $VIEW
echo '                <groupId>org.codehaus.mojo</groupId>' >> $VIEW
echo '                <artifactId>exec-maven-plugin</artifactId>' >> $VIEW
echo '                <version>1.2.1</version>' >> $VIEW
echo '                <executions>' >> $VIEW

if [ ! -z $ANTSCRIPT ] && [ -f $ANTSCRIPT ]
then

# we don't use the antrun plugin, we instead spawn a new ant execute
# hence, we write a separate ant script.
echo '<project name="pre-requisite" basedir="." default="default">' >> $PREREQUISITE
echo '    <target name="default">' >> $PREREQUISITE
cat $ANTSCRIPT >> $PREREQUISITE
echo '    </target>' >> $PREREQUISITE
echo '</project>' >> $PREREQUISITE

echo '                    <execution>' >> $VIEW
echo '                        <id>step1-prequisite</id>' >> $VIEW
echo '                        <phase>package</phase>' >> $VIEW
echo '                        <goals>' >> $VIEW
echo '                            <goal>exec</goal>' >> $VIEW
echo '                        </goals>' >> $VIEW
echo '                        <configuration>' >> $VIEW
echo '                            <arguments>' >> $VIEW
echo '                                <argument>-classpath</argument>' >> $VIEW
echo '                                <argument>${ant.classpath}</argument>' >> $VIEW
echo '                                <argument>${ant.mainClass}</argument>' >> $VIEW
echo '                                <argument>-f</argument>' >> $VIEW
echo '                                <argument>pre-requisite.xml</argument>' >> $VIEW
echo '                                <argument>-Dhttp.proxyHost=${http.proxyHost}</argument>' >> $VIEW
echo '                                <argument>-Dhttp.proxyPort=${http.proxyPort}</argument>' >> $VIEW
echo '                                <argument>-Dhttps.proxyHost=${https.proxyHost}</argument>' >> $VIEW
echo '                                <argument>-Dhttps.proxyPort=${https.proxyPort}</argument>' >> $VIEW
echo '                                <argument>-Dmaven.repo.local=${maven.repo.local}</argument>' >> $VIEW
echo '                            </arguments>' >> $VIEW
echo '                        </configuration>' >> $VIEW
echo '                    </execution>' >> $VIEW	
fi

echo '                    <execution>' >> $VIEW
echo '                        <id>step2-exec-ant1</id>' >> $VIEW
echo '                        <phase>package</phase>' >> $VIEW
echo '                        <goals>' >> $VIEW
echo '                            <goal>exec</goal>' >> $VIEW
echo '                        </goals>' >> $VIEW
echo '                        <configuration>' >> $VIEW
echo '                            <arguments>' >> $VIEW
if [ ! -z $KEYSTORE ]
then
	echo "                                <argument>$KEYSTORE</argument>" >> $VIEW
fi
echo '                                <argument>-classpath</argument>' >> $VIEW
echo '                                <argument>${ant.classpath}</argument>' >> $VIEW
echo '                                <argument>${ant.mainClass}</argument>' >> $VIEW
if [ ! -z $ANTTARGET ]
then
	echo "                                <argument>$ANTTARGET</argument>" >> $VIEW
fi
echo '                                <argument>clean</argument>' >> $VIEW
echo '                                <argument>main</argument>' >> $VIEW
echo '                                <argument>mvn.deploy.release.local</argument>' >> $VIEW
echo '                                <argument>-Dhttp.proxyHost=${http.proxyHost}</argument>' >> $VIEW
echo '                                <argument>-Dhttp.proxyPort=${http.proxyPort}</argument>' >> $VIEW
echo '                                <argument>-Dhttps.proxyHost=${https.proxyHost}</argument>' >> $VIEW
echo '                                <argument>-Dhttps.proxyPort=${https.proxyPort}</argument>' >> $VIEW
echo '                                <argument>-Dmaven.repo.local=${maven.repo.local}</argument>' >> $VIEW
echo '                            </arguments>' >> $VIEW
echo '                        </configuration>' >> $VIEW
echo '                    </execution>' >> $VIEW
echo '                </executions>' >> $VIEW
echo '                <configuration>' >> $VIEW
echo '                    <executable>${java.home}/../bin/java</executable>' >> $VIEW
echo '                    <environmentVariables>' >> $VIEW
echo '						  <PATH>${maven.home}/bin:${java.home}/..:${env.PATH}</PATH>' >> $VIEW
echo '                        <JAVA_HOME>${java.home}/..</JAVA_HOME>' >> $VIEW
echo '                    </environmentVariables>' >> $VIEW
echo '                </configuration>' >> $VIEW
echo '            </plugin>' >> $VIEW

if [ ! -z $INSTALLATIONS ] && [ -f $INSTALLATIONS ]
then
echo '            <plugin>' >> $VIEW
echo '                <groupId>org.apache.maven.plugins</groupId>' >> $VIEW
echo '                <artifactId>maven-install-plugin</artifactId>' >> $VIEW
echo '                <version>2.4</version>' >> $VIEW
echo '                <executions>' >> $VIEW

	cat $INSTALLATIONS >> $VIEW
echo '                </executions>' >> $VIEW
echo '            </plugin>'    >> $VIEW
fi

echo '        </plugins>' >> $VIEW
echo '        <pluginManagement>' >> $VIEW
echo '            <plugins>' >> $VIEW
echo '                <plugin>' >> $VIEW
echo '                    <groupId>org.apache.maven.plugins</groupId>' >> $VIEW
echo '                    <artifactId>maven-clean-plugin</artifactId>' >> $VIEW
echo '                    <version>2.5</version>' >> $VIEW
echo '                    <configuration>' >> $VIEW
if [ ! -z $CLEANFILESETS ] && [ -f $CLEANFILESETS ]
then
	cat $CLEANFILESETS >> $VIEW
fi
echo '                    </configuration>' >> $VIEW
echo '                </plugin>' >> $VIEW
echo '            </plugins>' >> $VIEW
echo '        </pluginManagement>' >> $VIEW
echo '    </build>' >> $VIEW
echo ' ' >> $VIEW
echo '    <dependencies>' >> $VIEW
echo '        <dependency>' >> $VIEW
echo '            <groupId>org.apache.ant</groupId>' >> $VIEW
echo '            <artifactId>ant</artifactId>' >> $VIEW
echo '            <version>1.9.0</version>' >> $VIEW
echo '        </dependency>' >> $VIEW
echo '        <dependency>' >> $VIEW
echo '            <groupId>org.apache.ant</groupId>' >> $VIEW
echo '            <artifactId>ant-launcher</artifactId>' >> $VIEW
echo '            <version>1.9.0</version>' >> $VIEW
echo '        </dependency>' >> $VIEW
echo '        <dependency>' >> $VIEW
echo '            <groupId>org.apache.ant</groupId>' >> $VIEW
echo '            <artifactId>ant-junit</artifactId>' >> $VIEW
echo '            <version>1.9.0</version>' >> $VIEW
echo '        </dependency>' >> $VIEW
echo '        <dependency>' >> $VIEW
echo '            <groupId>org.apache.ant</groupId>' >> $VIEW
echo '            <artifactId>ant-apache-bcel</artifactId>' >> $VIEW
echo '            <version>1.9.0</version>' >> $VIEW
echo '        </dependency>' >> $VIEW
echo '    </dependencies>' >> $VIEW
echo '</project>' >> $VIEW	
	rm -rf $INSTALLATIONS $CLEANFILESETS $ANTSCRIPT
}
init_aggregator(){
cat <<EOF > pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.oracle.javaee</groupId>
    <artifactId>ri-source-build</artifactId>
    <version>8.0.0</version>
    <packaging>pom</packaging>
    
    <modules>
EOF
}
add_module(){
	NAME=$1
	echo "        <module>$NAME</module>" >> pom.xml
}
finalize_aggregator(){
cat <<EOF >> pom.xml   
    </modules>
</project>
EOF
	
}
