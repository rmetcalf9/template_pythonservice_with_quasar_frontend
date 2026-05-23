#!/bin/bash

echo "templateservicename"

INITAL_DIR=$(pwd)

cd ..
if [[ ! -f ./_repo_vars.sh ]]; then
  echo "_repo_vars.sh dosen't exist - are you in correct directory?"
  cd ${INITAL_DIR}
  exit 1
fi
source ./_repo_vars.sh
cd ${INITAL_DIR}

SAAS_APIAPP_MASTERPASSWORDFORPASSHASH=wefgFvGFt5433e

# 8099 is hard coded in the saas_user_management container (Shared functions)
#  compiled into the webapp in the part where it identifies backend api
#  in this project in saasLinkvisCallapi.js
EXTPORT80FORSECURITY=8099

PYTHON_CMD=python
#if [ E${EXTPYTHONCMD} != "E" ]; then
#  PYTHON_CMD=${EXTPYTHONCMD}
#fi
# We are using venv - see source command velow


#pyCharm will run in project root directory. Check if we are here and if so then change int oservices directory
if [ -d "./services" ]; then
  echo "Changing into services directory"
  cd ./services
fi

source ../.venv/bin/activate


PYTHONVERSIONCHECKSCRIPT="import sys\nprint(\"Python version \" + str(sys.version_info))\nif sys.version_info[0] < 3:\n  exit(1)\nif sys.version_info[0] == 3:\n  if sys.version_info[1] < 6:\n    exit(1)\nexit(0)\n"
printf "${PYTHONVERSIONCHECKSCRIPT}" | ${PYTHON_CMD}
RES=$?
if [ ${RES} -ne 0 ]; then
  echo "Wrong python version - this version won't have all the required libraries"
  echo "Using command ${PYTHON_CMD}"
  echo "you can set enviroment variable EXTPYTHONCMD to make this script use a different python command"
  echo ""
  read -p "Press enter to continue"
  exit 1
fi

if [ E${EXTURL} = "E" ]; then
  echo "EXTURL not set"
  read -p "Press enter to continue"
  exit 1
fi
if [ E${EXTPORT} = "E" ]; then
  echo "EXTPORT not set"
  read -p "Press enter to continue"
  exit 1
fi
if [ E${EXTPORT80} = "E" ]; then
  echo "EXTPORT80 not set"
  read -p "Press enter to continue"
  exit 1
fi

VAULT_DEV_APP_ROLE_LOC="memset/approles/${PROJECT_NAME}_dev"
APIAPP_VAULT_ROLE_ID=$(qvault kv get -mount=kv -field=role_id ${VAULT_DEV_APP_ROLE_LOC})
RES=$?
if [ ${RES} -ne 0 ]; then
  echo "ERROR reading role_id from vault ${VAULT_DEV_APP_ROLE_LOC}"
  echo " maybe you need to do vault login"
  echo " if it doesn't exist it is created by memsetappvaultsetup"
  read -p "Press enter to continue"
  exit 1
fi
APIAPP_VAULT_SECRET_ID=$(qvault kv get -mount=kv -field=secret_id ${VAULT_DEV_APP_ROLE_LOC})
RES=$?
if [ ${RES} -ne 0 ]; then
  echo "ERROR reading secret_id from vault ${VAULT_DEV_APP_ROLE_LOC}"
  echo " it doesn't exist it is created by memsetappvaultsetup"
  read -p "Press enter to continue"
  exit 1
fi

APP_DIR=.

export APIAPP_PROJECT_NAME="${PROJECT_NAME}"
export APIAPP_MODE=DEVELOPER
export APIAPP_JWTSECRET="gldskajld435sFFkfjlkfdsj"
export APIAPP_JWTSKIPSIGNATURECHECK=N
export APIAPP_FRONTEND=_
export APIAPP_APIURL=${EXTURL}:${EXTPORT}/api
export APIAPP_APIDOCSURL=${EXTURL}:${EXTPORT}/apidocs
export APIAPP_FRONTENDURL=${EXTURL}:${EXTPORT}/frontend
export APIAPP_APIACCESSSECURITY=[]
export APIAPP_PORT=8098
##export APIAPP_OBJECTSTORECONFIG="{\"Type\":\"Memory\"}"
export APIAPP_OBJECTSTORECONFIG="{\"Type\": \"SimpleFileStore\",\"BaseLocation\": \"./objectstoredata\"}"
export APIAPP_COMMON_ACCESSCONTROLALLOWORIGIN="http://localhost:8080,http://127.0.0.1:8080"
export APIAPP_VAULT_URL="https://vault.metcarob.com/"
export APIAPP_VAULT_ROLE_ID=${APIAPP_VAULT_ROLE_ID}
export APIAPP_VAULT_SECRET_ID=${APIAPP_VAULT_SECRET_ID}


export APIAPP_VERSION=
if [ -f ${APP_DIR}/VERSION ]; then
  APIAPP_VERSION=${0}-$(cat ${APP_DIR}/VERSION)
fi
if [ -f ${APP_DIR}/../VERSION ]; then
  APIAPP_VERSION=${0}-$(cat ${APP_DIR}/../VERSION)
fi
if [ -f ${APP_DIR}/../../VERSION ]; then
  APIAPP_VERSION=${0}-$(cat ${APP_DIR}/../../VERSION)
fi
if [ E${APIAPP_VERSION} = 'E' ]; then
  echo 'Can not find version file in standard locations'
  exit 1
fi

# Start security service (if not already running)
APIAPP_COMMON_ACCESSCONTROLALLOWORIGIN_FOR_USER_MANAGEMENT="http://localhost:8080, http://127.0.0.1:8080, http://localhost:8099, http://127.0.0.1:8099"
SETUP_JSON_DIR=${INITAL_DIR}
SETUP_JSON_FILENAME="_start_local_saas_user_management_service_config.json"
EXPECTED_TENANT="ensurerightum_${PROJECT_NAME}"
EXTERNAL_VOLUME=""

start_local_saas_user_management_service \
   ${RJM_USERMANAGEMENT_CONTAINER} \
   ${APIAPP_JWTSECRET} \
   ${EXTURL} \
   ${EXTPORT} \
   ${EXTPORT80FORSECURITY} \
   ${SAAS_APIAPP_MASTERPASSWORDFORPASSHASH} \
   "${APIAPP_COMMON_ACCESSCONTROLALLOWORIGIN_FOR_USER_MANAGEMENT}" \
   ${SETUP_JSON_DIR} \
   ${SETUP_JSON_FILENAME} \
   ${EXPECTED_TENANT} \
   "${EXTERNAL_VOLUME}"
RES=$?
if [ ${RES} -ne 0 ]; then
  echo "Error starting security microservice"
  read -p "Press enter to continue"
  echo ""
  exit 1
fi

#Python app reads parameters from environment variables
${PYTHON_CMD} ./src/app.py
RES=$?

if [ $RES -ne 0 ]; then
  echo "Process Errored"
  read -p "Press enter to continue"
fi
