#This dockerfile builds a container image with python and rednose installed so we can test
# another built container.
# it it is designed to be launched and linked to the running container to preform the tests

FROM python:3.11-slim

MAINTAINER Robert Metcalf

COPY ./requirements.txt /requirements.txt
COPY ./run_tests_with_wait.sh /run_tests_with_wait.sh
COPY ./test /test

RUN pip install --no-cache-dir -r /requirements.txt


# Test this out locally:
# docker build . -t tmp
# docker run -e TESTPARAM_EXPECTED_CONTAINER_VERSION=0.0.127 -e TESTPARAM_ENDPOINTURL=http://${HOSTNAME}:8095 -e TESTPARAM_THROUGHKONG=False tmp:latest /run_tests_with_wait.sh
