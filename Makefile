# This line allows for using spaces instead of tabs for indentation
.RECIPEPREFIX +=

.DEFAULT_GOAL := all

SHELL=/bin/bash

CONTAINER_TAG=lucasvanlierop/containerization-workshop
CONTAINER_NAME=lucasvanlierop-containerization-workshop

all: build_container_image

build_container_image:
    docker build -f Dockerfile -t ${CONTAINER_TAG} .

start_container: build_container_image
    docker run \
    -d \
    -p 80:80 \
    --name ${CONTAINER_NAME} \
    -t ${CONTAINER_TAG}

start_dev_container: build_container_image
    docker run \
    -v `pwd`/web:/var/www/html \
    -d \
    -p 80:80 \
    --name ${CONTAINER_NAME} \
    -t ${CONTAINER_TAG}

test: start_container
    tests/smoke-test.sh
    docker kill ${CONTAINER_NAME};
    docker rm ${CONTAINER_NAME}
