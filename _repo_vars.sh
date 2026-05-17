#!/bin/bash

export PROJECT_NAME=${PWD##*/}          # to assign to a variable
export PROJECT_NAME=${PROJECT_NAME:-/}

export RJM_VERSION=$(cat ./VERSION)
export RJM_VERSION_UNDERSCORE=$(cat ./VERSION | tr '.' '_')
export RJM_MAJOR_VERSION=$(echo ${RJM_VERSION%%.*})

export RJM_PYTHON_TEST_IMAGE=python:3.10


export DOCKER_USERNAME=metcarob
export DOCKER_IMAGENAME=${PROJECT_NAME}

export SAAS_USERMANAGEMENT_CONTAINER=metcarob/saas_user_management:0.0.200

export RJM_DOCKERWSCALLER_IMAGE="metcarob/docker-ws-caller:0.7.19"
export RJM_DOCKER_KONG_API_URL="http://tasks.kong:8001"
export RJM_DOCKER_SERVICE_URL=tasks.${RJM_DOCKER_SERVICE_NAME}

export QUASARBUILDIMAGE="metcarob/docker-build-quasar-app:0.0.33"
#could be spa or pwa
QUASARBUILDMODE=pwa
