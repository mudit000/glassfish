#!/bin/bash

LOCAL_GF_GIT_REPO="${GF_ROOT}/.git"
export PATH=/gf-hudson-tools/bin:${PATH}

# Incremental workspace cleanup
# Keep GlassFish (Git repository)
# Keep repository (Maven local repository)
for file in `ls ${WORKSPACE}`
do
  if [ "${file}" != "." ] && [ "${file}" != ".." ] \
    && [ "${file}" != "GlassFish" ] && [ "${file}" != "repository" ] \
    && [ "${file}" != "debug.log" ]; then
    rm -rf ${file}
  fi
done

# Prune the local repository of the in-house groupIds
# To ensure local dependencies are built
if [ -d "${WORKSPACE}/repository" ] ; then
  rm -rf "${WORKSPACE}/repository/org/glassfish"
  rm -rf "${WORKSPACE}/repository/com/sun"
fi

# Incremental fetch
# I.e git clone the first time
#     git pull otherwise
# if [ "$(ls -A ${LOCAL_GF_GIT_REPO})" ]; then
#   cd ${GF_ROOT}
#   git pull origin master
# else
#   pwd
#   id
#   ls -l
#   git clone ${GF_WORKSPACE_URL_SSH} /scratch/gf-code
#  ls	 
#  ls /scratch/gf-code
#   cd ${GF_ROOT}
# fi

/bin/bash -ex /scratch/BUILD_AREA/glassfish/ci/build-tools/glassfish/gfbuild.sh build_re_dev 2>&1
cp /scratch/gf-hudson-tools/hudson-tools/build-tools/glassfish/retry_config $CONTAINER_WORKSPACE/retry_config
#if [ -z "${JENKINS_HOME}" ] && [ -z "${JENKINS_URL}" ]; then
# LINUX_LARGE_POOL="POOL-1-LINUX-LARGE"
# SOLARIS_POOL="solaris-sparc"
# test_ids=`/bin/bash -ex .${GF_ROOT}/appserver/tests/gftest.sh list_test_ids ${1} | sed s/security_all/security_all\=$SOLARIS_POOL/g |sed s/findbugs_all/findbugs_all\=$LINUX_LARGE_POOL/g | sed s/findbugs_low_priority_all/findbugs_low_priority_all\=$LINUX_LARGE_POOL/g`
#else
  #test_ids=`ql_gf_full_profile_all`
#fi  




bash -ex /scratch/gf-hudson-tools/hudson-tools/build-tools/trigger_and_block.sh ql_gf_full_profile_all
cp -r /scratch/free-folder/test-results ${CONTAINER_WORKSPACE}/
bash -ex /scratch/gf-hudson-tools/hudson-tools/build-tools/glassfish/checkJobStatus.sh
