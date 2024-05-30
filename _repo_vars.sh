#!/bin/bash

export PROJECT_NAME=${PWD##*/}          # to assign to a variable
export PROJECT_NAME=${PROJECT_NAME:-/}

export DOCKER_IMAGENAME=${PROJECT_NAME}
