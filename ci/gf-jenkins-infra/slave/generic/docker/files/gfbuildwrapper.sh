#! /bin/bash
mkdir -p /scratch/BUILD_AREA
if [ $? -eq 0 ]; then
    cd /scratch/BUILD_AREA
else
   echo "Unable to create directory ${WORKSPACE}"
fi
whoami
ls -l /scratch/
ls -l /scratch/gf-hudson-tools/
ls -l /scratch/gf-hudson-tools/hudson-tools/
ls -l /scratch/gf-hudson-tools/hudson-tools/jobs/
ls -l /scratch/gf-hudson-tools/hudson-tools/jobs/gf-generic-test-job
ls -l /scratch/gf-hudson-tools/hudson-tools/jobs/gf-generic-test-job/bin/

true | which java
java -version | true
shopt -s nocasematch
if [[ ${REDIRECT_STD_ERR} == "true" ]]; then
 /bin/bash -ex ${EXECUTE_SCRIPT} dockertriggered 
else
 /bin/bash -ex ${EXECUTE_SCRIPT} dockertriggered
fi
