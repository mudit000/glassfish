#!/bin/bash
env
export PATH=/gf-hudson-tools/bin:${PATH}
ls ~/.ssh
#cat ~/.ssh/ssh_host_rsa_key.pub >> /scratch/host_ssh/authorized_keys
#rm -rf ${WORKSPACE}/* || true
jps -mv
ls -l ${PARENT_WS_PATH_CONTAINER}/
ls -l ${PARENT_WS_PATH_CONTAINER}/bundles/
scp -o "StrictHostKeyChecking no" ${NFS_PATH}/bundles/gftest.sh .
bash -ex gftest.sh run_test ${TEST_ID}

#chmod 777 ${PARENT_WS_PATH_CONTAINER}/bundles/gftest.sh
#chmod +x ${PARENT_WS_PATH_CONTAINER}/bundles/gftest.sh
#scp -i "/root/.ssh/ssh_host_rsa_key" -v -o "StrictHostKeyChecking no" genie.dash@${PARENT_NODE}:${PARENT_WS_PATH_CONTAINER}/bundles/gftest.sh .
#mkdir -p $WORKSPACE/bundles
#cp -r ${PARENT_WS_PATH_CONTAINER}/bundles/* $WORKSPACE/bundles/
#bash -ex ${PARENT_WS_PATH_CONTAINER}/bundles/gftest.sh run_test ${TEST_ID}
