#!/bin/bash +ex

source ./common.sh

# NOTES
# Export your public key to your java.net account
# If behind a proxy, you can use corkscrew and dont forget to define http_proxy envionment variable

jvnet_username=$1
closed_username=$2
PROXY_HOST=www-proxy.us.oracle.com
PROXY_PORT=80
export svn_javaee_ri_mirror=/net/gf-hudson.us.oracle.com/scratch/java_re/SPACE/java_re/source-build-components
export gf_hudson_host="gf-hudson.us.oracle.com"

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

rm -rf ee8-ri-source-bundle ; mkdir ee8-ri-source-bundle 
cd ee8-ri-source-bundle

init_aggregator
get_github_tag hk2 2.5.0-b44 https://github.com/javaee/hk2 2.5.0-b44 opensource
get_github_tag jaspic-spec 1.1 https://github.com/javaee/jaspic-spec javax.security.auth.message-api-1.1 opensource
get_github_tag javax.security.jacc-api 1.5 https://github.com/javaee/jacc-spec javax.security.jacc-api-1.5 opensource
get_github_tag javax.persistence 2.2.0-RC3 https://github.com/eclipse/javax.persistence 2.2.0-RC3 opensource
get_github_tag grizzly 2.4.1 https://github.com/javaee/grizzly 2_4_1 opensource
##get_github_tag grizzly-npn 1.7 https://github.com/javaee/grizzly-npn 1_7 opensource
get_github_tag standards.jsr352.jbatch 1.0.2 https://github.com/WASdev/standards.jsr352.jbatch impl-1.0.2 opensouce
get_github_tag tyrus 1.13.1 https://github.com/tyrus-project/tyrus 1.13.1 opensource
get_github_tag weld 3.0.0.Final https://github.com/weld/core 3.0.0.Final opensource
get_noop_tag weld 3.0.0.Final https://github.com/weld/core 3.0.0.Final opensource bundles/osgi
get_github_tag bean-validator 6.0.2.Final https://github.com/hibernate/hibernate-validator 6.0.2.Final opensource
get_github_tag json 1.1 https://github.com/javaee/jsonp jsonp-1.1 opensource
get_github_tag mojarra 2.3.2 https://github.com/javaserverfaces/mojarra 2.3.2 opensource
get_github_tag jettison 1.3.7 https://github.com/codehaus/jettison jettison-1.3.7 opensource
get_github_tag jackson-annotations 2.8.9 https://github.com/FasterXML/jackson-annotations jackson-annotations-2.8.9 opensource
get_github_tag jackson-core 2.8.9 https://github.com/FasterXML/jackson-core jackson-core-2.8.9 opensource
get_github_tag jackson-databind 2.8.9 https://github.com/FasterXML/jackson-databind jackson-databind-2.8.9 opensource
get_github_tag jackson-module-jaxb-annotations 2.8.9 https://github.com/FasterXML/jackson-module-jaxb-annotations jackson-module-jaxb-annotations-2.8.9 opensource
get_github_tag jaxb-ri 2.3.0 https://github.com/javaee/jaxb-v2 2.3.0 opensource
get_github_tag jaxrs 2.1 https://github.com/jax-rs/api 2.1 opensource
get_github_tag jersey 2.26 https://github.com/jersey/jersey 2.26 opensource
get_github_tag jaxb-api 2.3.0 https://github.com/javaee/jaxb-spec 2.3.0 opensource
get_github_tag metro 2.4.0 https://github.com/javaee/metro-wsit WSIT_2_4_0 opensource
get_github_tag jaxws-ri 2.3.0 https://github.com/javaee/metro-jax-ws JAXWS_2_3_0 opensource
#get_git_tag xsom null ssh://rohit.chaware%40oracle.com@alm.oraclecorp.com:2222/caf_javaee_4881/jaxb-xsom null closed
#get_github_tag stax-ex 1.7.7 https://github.com/javaee/metro-stax-ex stax-ex-1.7.7 opensource
get_github_tag mimepull 1.9.7 https://github.com/javaee/metro-mimepull mimepull-1.9.7 opensource
get_github_tag jaxws-api 2.3.0 https://github.com/javaee/jax-ws-spec 2.3.0 opensource
get_github_tag ws-policy 2.5 https://github.com/javaee/metro-policy policy-2.5 opensource
get_github_tag javax.el 3.0.1-b04 https://github.com/javaee/uel-ri javax.el-api-3.0.1-b04 opensource
get_github_tag javax.enterprise.concurrent 1.0 https://github.com/javaee/cu-ri javax.enterprise.concurrent-1.0 opensource
get_github_tag javaee-jsp-api 2.3.3-b02 https://github.com/javaee/javaee-jsp-api javax.servlet.jsp-2.3.3-b02 opensource
get_github_tag javax.servlet.jsp.jstl 1.2.5-b03 https://github.com/javaee/jstl-api 1.2.5-b03 opensource
get_github_tag javax.xml.registry-api 1.0.7 https://github.com/javaee/javax.xml.registry 1.0.7 opensource
get_github_tag javax.ejb 3.2 https://github.com/javaee/javax.ejb 3.2 opensource
get_github_tag javax.transaction-api 1.2.1 https://github.com/javaee/javax.transaction 1.2.1 opensource
get_github_tag javax.resource 1.7 https://github.com/javaee/javax.resource 1.7 opensource
get_github_tag javax.annotation 1.3 https://github.com/javaee/javax.annotation 1.3 opensource
get_github_tag concurrency-ee-spec 1.0 https://github.com/javaee/concurrency-ee-spec javax.enterprise.concurrent-api-1.0 opensource
get_github_tag javax.interceptor 1.2.1 https://github.com/javaee/javax.interceptor 1.2.1 opensource
get_github_tag javax.enterprise.deploy 1.6 https://github.com/javaee/javax.enterprise.deploy 1.6 opensource
get_github_tag javax.management.j2ee 1.1.1 https://github.com/javaee/javax.management.j2ee 1.1.1 opensource
get_github_tag javax.servlet-api 4.0.0 https://github.com/javaee/servlet-spec 4.0.0 opensource
get_github_tag javaee-jsp-api 2.3.2-b01 https://github.com/javaee/javaee-jsp-api javax.servlet.jsp-api-2.3.2-b01 opensource
get_github_tag jstl-api 1.2.1 https://github.com/javaee/jstl-api javax.servlet.jsp.jstl-api-1.2.1 opensource
get_github_tag websocket-spec 1.1 https://github.com/javaee/websocket-spec 1.1 opensource
get_github_tag cdi 2.0 https://github.com/cdi-spec/cdi 2.0 opensource
get_github_tag javax.xml.soap 1.4.0 https://github.com/javaee/javax.xml.soap 1.4.0 opensource
get_github_tag javax.xml.rpc 1.1.1 https://github.com/javaee/javax.xml.rpc 1.1.1 opensource
get_github_tag javax.mail 1.6.0 https://github.com/javaee/javamail JAVAMAIL-1_6_0 opensource
get_github_tag shoal 1.6.51 https://github.com/javaee/shoal shoal-1.6.51 opensource
get_github_tag glassfish 5.0-b24 https://github.com/javaee/glassfish 5.0-b24 opensource
get_scp_tag javaee-ri 8.0 #$svn_closed/glassfish/trunk/javaee-ri 8.0 closed
#get_svn_tag db-derby null $svn_java_net/glassfish~svn/trunk/external/modules/derby/10.10.2.0 null closed
get_github_tag mq 5.1.1-b06 https://github.com/javaee/openmq MQ5.1.1_b06 opensource
get_github_tag gmbal 4.0.0-b001 https://github.com/javaee/gmbal gmbal-4.0.0-b001 opensource
get_github_tag gmbal-pfl 4.0.1-b001 https://github.com/javaee/gmbal-pfl pfl-4.0.1-b001 opensource
get_github_tag glassfish-corba 4.1.1-b001 https://github.com/javaee/glassfish-corba glassfish-corba-4.1.1-b001 opensource
get_github_tag gmbal-management-api 3.2.1-b002 https://github.com/javaee/gmbal-commons management-api-3.2.1-b002 opensource
get_curl_tag commons-fileupload 1.3.3 http://archive.apache.org/dist/commons/fileupload/source/commons-fileupload-1.3.3-src.zip commons-fileupload-1.3.3 opensource
#get_curl_tag apache-ant 1.8.2 http://archive.apache.org/dist/ant/source/apache-ant-1.8.2-src.zip apache-ant-1.8.2 opensource
get_curl_tag org.apache.felix.framework 4.2.1 http://archive.apache.org/dist/felix/org.apache.felix.framework-4.2.1-source-release.zip org.apache.felix.framework-4.2.1 opensource
#get_curl_tag commons-codec 1.7 http://archive.apache.org/dist/commons/codec/commons-codec-current-src.zip commons-codec-1.7 opensource
get_github_tag guava 13.0.1 https://github.com/google/guava v13.0.1 opensource
get_github_tag jline 2.9 https://github.com/jline/jline2 jline-2.9 opensource
#get_github_tag jtype 0.1.0 https://github.com/markhobson/jtype 0.1.0 opensource
#get_svn_tag asm-all 6.0_ALPHA svn+ssh://$jvnet_username@svn.java.net/glassfish~svn/trunk/external/modules/asm/5.0.3/ NA closed
#get_svn_tag antlr 2.7.7 svn+ssh://$jvnet_username@svn.java.net/glassfish~svn/trunk/external/modules/antlr/2.7.7/ NA closed
#get_github_tag jna 3.2.2 https://github.com/java-native-access/jna 3.2.2 opensource
#get_github_tag libpam4j 1.9 https://github.com/kohsuke/libpam4j libpam4j-1.9 opensource
#get_github_tag cal10n 0.7.7 https://github.com/qos-ch/cal10n v_0.7.7 opensource
get_github_tag slf4j 1.7.2 https://github.com/qos-ch/slf4j v_1.7.2 opensource

get_github_tag javadb 10.13.1.1 https://github.com/javaee/javadb 10.13.1.1 opensource
get_github_tag yasson 1.0 https://github.com/eclipse/yasson 1.0 opensource
get_github_tag java-classmate 1.3.3 https://github.com/FasterXML/java-classmate classmate-1.3.3 opensource
get_github_tag security-soteria 1.0 https://github.com/javaee/security-soteria 1.0 opensource
#get_github_tag repackaged 1.9 https://github.com/javaee/repackaged libpam4j-1.9 opensource



ROOT=`pwd`
PATCHES=$ROOT/../patches

cd $ROOT
mv mojarra-2.3.2 tmp; mv tmp/mojarra-2.3.2 mojarra-2.3.2; rm -rf tmp
echo '                                	<copy file="${basedir}/build.properties.glassfish" tofile="${basedir}/build.properties" />' > /tmp/mojarra-ant-script.xml
echo '                                	<replaceregexp file="${basedir}/build.properties" match="jsf.build.home=(.*)" replace="jsf.build.home=${basedir}" byline="true"/>' >> /tmp/mojarra-ant-script.xml
echo '                                	<replace file="${basedir}/build.properties" token="http.proxy.host=" value="http.proxy.host=${http.proxyHost}"/>' >> /tmp/mojarra-ant-script.xml
echo '                                	<replace file="${basedir}/build.properties" token="http.proxy.port=" value="http.proxy.port=${http.proxyPort}"/>' >> /tmp/mojarra-ant-script.xml
generate_clean_fileset "build.properties,dependencies/**" "build.properties.*"
generate_pom_install_file
#"jsf-api/build/lib/jsf-api-intermediate.jar,jsf-api/pom.xml jsf-ri/build/lib/javax.faces.jar,jsf-ri/pom.xml"
generate_ant_wrapper_pom "mojarra" "2.3.2" /tmp/mojarra-ant-script.xml "" "-Djavax.net.ssl.trustStore=jssecacerts"
cp /net/gf-hudson.us.oracle.com/scratch/java_re/SPACE/java_re/source-build-components/jssecacerts $ROOT/mojarra-2.3.2/

cd $ROOT

for d in */ ; do 
	if [ ! -f $d/pom.xml ]; then
            echo $d doesnt have pom.xml 
	    for s in $(pwd)/$d*/ ; do
		echo $s contents moved 	
		mv $s* $(pwd)/$d
		rm -rf $s
	    done			
fi
done

cd $ROOT/tyrus-1.13.1 ; patch -p1 -i $PATCHES/tyrus.patch 
cd $ROOT/slf4j-1.7.2 ; patch -p0 -i $PATCHES/sl4j.patch
cd $ROOT/glassfish-corba-4.1.1-b001 ; patch -p0 -i $PATCHES/glassfish-corba.patch
cd $ROOT/guava-13.0.1 ; patch -p0 -i $PATCHES/guava.patch

cd $ROOT

mv jaxrs-2.1/jaxrs-api/* jaxrs-2.1 ; rm -rf jaxrs-2.1/jaxrs-api/

mv metro-2.4.0/wsit/* metro-2.4.0 ; rm -rf metro-2.4.0/wsit

mv websocket-spec-1.1/api/* websocket-spec-1.1/ ; rm -rf websocket-spec-1.1/api/

mv mq-5.1.1-b06/mq/* mq-5.1.1-b06/ ; rm -rf mq-5.1.1-b06/mq/

#mv jna-3.2.2/jnalib/* jna-3.2.2/ ; rm -rf jna-3.2.2/jnalib/

mv jaxws-ri-2.3.0/jaxws-ri/* jaxws-ri-2.3.0/ ; rm -rf jaxws-ri-2.3.0/jaxws-ri

mv jaxws-api-2.3.0/api/* jaxws-api-2.3.0/ ; rm -rf jaxws-api-2.3.0/api

mv jaxb-ri-2.3.0/jaxb-ri/* jaxb-ri-2.3.0/ ; rm -rf jaxb-ri-2.3.0/jaxb-ri

finalize_aggregator

cp ../TLDA_OSCL_SCSL_Licensees_License_Notice.txt .
cp ../build.sh . ; chmod +x ./build.sh
cp ../README.txt .
cd ..  
rm -f ee8-ri-source-bundle.zip
zip -r ee8-ri-source-bundle.zip ee8-ri-source-bundle
