#!/bin/bash -ex

echo '#!/bin/bash -ex

source common.sh

# NOTES
# Export your public key to your java.net account
# If behind a proxy, you can use corkscrew and dont forget to define http_proxy envionment variable

jvnet_username=$1
closed_username=$2
PROXY_HOST=www-proxy.us.oracle.com
PROXY_PORT=80

svn_java_net=svn+ssh://$jvnet_username@svn.java.net
git_java_net=ssh://$jvnet_username@git.java.net
hg_java_net=ssh://$jvnet_username@hg.java.net
github=https://github.com
orahub=git@orahub.oraclecorp.com

# we cant allow our ssh keys on new mercurial host.
# instead we have plain text password stored on the build nodes :)
svn_closed=https://adc4110351.us.oracle.com/svn

internal_nexus_url=http://gf-maven.us.oracle.com/nexus/content/repositories/gf-internal-release/
export http_proxy=$PROXY_HOST:$PROXY_PORT
export https_proxy=$PROXY_HOST:$PROXY_PORT
git config --global http.sslverify "false"
cp ~/.subversion/servers ~/.subversion/servers.bak
echo "http-proxy-host = $PROXY_HOST" >> ~/.subversion/servers
echo "http-proxy-port = $PROXY_PORT" >> ~/.subversion/servers

rm -rf ee7-ri-source-bundle ; mkdir ee7-ri-source-bundle 
cd ee7-ri-source-bundle

init_aggregator' > pseudo_build.sh

#git clone https://github.com/javaee/glassfish.git
#cd glassfish

present_directory=$(pwd)
cd ~/glassfish/github-glassfish/glassfish/
mvn dependency:list -DexcludeTransitive=true | grep ":.*:.*:.*" | cut -d] -f2- | sed 's/:[a-z]*$//g' | sort -u > $present_directory/dependencylist.txt
mvn -Dhttps.proxyHost=www-proxy.us.oracle.com -Dhttps.proxyPort=80 -DremotePom=org.glassfish.main.distributions:glassfish:4.1.2 versions:compare-dependencies | grep '\->' | sort | uniq > $present_directory/dependencyChanges.txt
cd $present_directory

javac AddSources.java
#java AddSources /home/rohit/glassfish/4.1.2_all/javaee-ri/source-build/ri-source-bundle.sh /home/rohit/glassfish/source-build-5.0/dependencies.txt /home/rohit/glassfish/source-build-5.0/dependencyList.txt
# $1 - Full path to source-list.txt 
# $2 - Full path to recent dependency list
# $3 - Full path to script file to be generated
java -Dpresent_directory=$(pwd) AddSources source-list.txt dependencylist.txt dependencylist412.txt dependencyChanges.txt source-to-GA.txt pseudo_build.sh



