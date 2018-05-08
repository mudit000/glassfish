set -e
print_usage()
{
 echo "Usage: $0  <Image Version>"
 echo "Example: $0 v10" 
}	

# Get  image version name to use
if [ $# -lt 1 ]; then
 print_usage
 exit 1
fi

VERSION="${1}"
IMAGE_GRP="gf-jenkins"
IMAGE_SHORT_NAME="generic-slave"
IMAGE_NAME=${IMAGE_GRP}/${IMAGE_SHORT_NAME}:${VERSION}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCK_DIR="${SCRIPT_DIR}/docker"
IMAGE_TAR="/gf-hudson-tools/jenkins-slave/${IMAGE_SHORT_NAME}-${VERSION}.tar"

#rm -rf ${IMAGE_TAR}
if [ -f ${IMAGE_TAR} ]; then
	echo "Seems the image is already built with this version. Please either delete ${IMAGE_TAR} or try with updated version"
	exit 1
fi

echo "Building Image:  ${IMAGE_NAME}"
echo "Docker File Location: ${DOCK_DIR}/Dockerfile"
ARG=""
if  [ ! -z "${DOCKER_ARG}" ]; then
 ARG="${DOCKER_ARG}"
 echo "Build arguments: ${ARG} "
fi
sudo docker build ${ARG} -t ${IMAGE_NAME} ${DOCK_DIR} 
sudo docker images | grep ${IMAGE_SHORT_NAME} | grep ${VERSION}

sudo docker save -o ${IMAGE_TAR} ${IMAGE_NAME}

set +e
commit=`git log -n 1`
echo $commit

echo "Image ${IMAGE_NAME} is saved as ${IMAGE_TAR}"
ls -l ${IMAGE_TAR}
