# This line allows for using spaces instead of tabs for indentation
.RECIPEPREFIX +=

.DEFAULT_GOAL := all

CONTAINER_TAG=lucasvanlierop/containerization-workshop
CONTAINER_NAME=lucasvanlierop-containerization-workshop

all: build_container

build_container:
    docker build -f Dockerfile -t ${CONTAINER_TAG} .

remove_container:
    docker kill ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}

start_container: build_container remove_container
    docker run \
    -d \
    -p 80:80 \
    --name ${CONTAINER_NAME} \
    -t ${CONTAINER_TAG}

start_dev_container: build_container remove_container
    docker run \
    -v `pwd`/web:/var/www/html \
    -d \
    -p 80:80 \
    --name ${CONTAINER_NAME} \
    -t ${CONTAINER_TAG}

test: start_container
    tests/smoke-test.sh


