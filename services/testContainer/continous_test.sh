#!/bin/bash

echo 'continous test for testContainer'
echo 'e.g. sudo ./continous_test.sh wip'
echo ' you must run localbuild container. templateservicename defaults to port 8095'

export TESTPARAM_EXPECTED_CONTAINER_VERSION=$(cat ../../VERSION)
export TESTPARAM_ENDPOINTURL=http://localhost:8095
export TESTPARAM_THROUGHKONG="False"

if [ $# -eq 0 ]; then
  until ack -f --python ./test | entr -d python3 -m pytest; do sleep 1; done
else
  if [ $# -eq 1 ]; then
    echo "Testing ${1}"
    until ack -f --python ./test | entr -d python3 -m pytest -a ${1}; do sleep 1; done
  else
    echo "Testing ${1} with verbose option (Single Run)"
    python3 -m pytest -v -a ${1}
  fi
fi
