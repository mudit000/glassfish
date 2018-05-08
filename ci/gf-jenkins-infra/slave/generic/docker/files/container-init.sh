#!/bin/bash

log_msg(){
  if [ -z "${1}" ] ; then echo "log_msg() - missing 1st argument: msg" ; return 1 ; fi
  (printf "\n### [`TZ=PST8PDT date +"%b %d %Y %T"`] ${1} ###\n")
}

prepend(){
  set +x 2> /dev/null
  while read LINE; do
    echo "[`TZ=PST8PDT date +"%b %d %Y %T"`]" "${LINE}"
  done
  set -x 2> /dev/null
}

log_msg "booting..." >> /var/log/init.log
HOSTNAME=$(hostname)
rm -f /etc/hosts.org /etc/hosts.old
cp -f /etc/hosts /etc/hosts.org
cat /etc/hosts.org | \
sed -e s@"\tlocalhost$"@"\tlocalhost.localdomain localhost"@g \
    > /etc/hosts

#Add us domain name to host. Ignore if explictly mentioned not to do so.
if [ -z ${ADD_US_DOMAIN} ] || [ ${ADD_US_DOMAIN} != "false" ] ; then
   cp -f /etc/hosts /etc/hosts.old
   cat /etc/hosts.old | \
   sed -e s@"\t${HOSTNAME}$"@"\t${HOSTNAME}.us.oracle.com ${HOSTNAME}"@g \
    > /etc/hosts
fi	

log_msg "starting rngd..." >> /var/log/init.log
rngd -r /dev/urandom -o /dev/random >> /var/log/init.log 2>&1

log_msg "starting ntpd" >> /var/log/init.log
/usr/sbin/ntpd -g >> /var/log/init.log 2>&1

log_msg "mount -a ..." >> /var/log/init.log
mount -a >> /var/log/init.log 2>&1

log_msg "starting rpc services..." >> /var/log/init.log
rpcbind >> /var/log/init.log 2>&1
rpc.statd >> /var/log/init.log 2>&1
rpc.rquotad >> /var/log/init.log 2>&1
rpc.mountd >> /var/log/init.log 2>&1
rpc.gssd >> /var/log/init.log 2>&1
rpc.rstatd >> /var/log/init.log 2>&1
rpc.rusersd >> /var/log/init.log 2>&1
rpc.idmapd >> /var/log/init.log 2>&1

log_msg "starting automount..." >> /var/log/init.log
(/sbin/automount -C -O nolock -d -f -t 0 1> >(prepend) 2> >(prepend 1>&2)) >> /var/log/automount.log 2>&1 &
log_msg "starting sendmail..." >> /var/log/init.log
/usr/sbin/sendmail -bd -q1h
log_msg "starting sshd..." >> /var/log/init.log
(/usr/sbin/sshd  -D -e  1> >(prepend) 2> >(prepend 1>&2)) >> /var/log/sshd.log 2>&1 &
log_msg "Wait for mount to complete"
/bin/bash /etc/wait.sh $JAVA_HOME
#Run the wrapper script which calls glassfish build script 
/bin/bash -xe /etc/gfbuildwrapper.sh
