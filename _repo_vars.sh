#!/bin/bash

export PROJECT_NAME=${PWD##*/}          # to assign to a variable
export PROJECT_NAME=${PROJECT_NAME:-/}

export DOCKER_IMAGENAME=${PROJECT_NAME}

export SAAS_USERMANAGEMENT_CONTAINER=metcarob/saas_user_management:0.0.200

