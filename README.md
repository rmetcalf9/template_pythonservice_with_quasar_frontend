# Template Repo

I use templates for my personal projects with standard setup to connect to
my personal app infrastructure.

This Template repo has a simple app with a flask python backend, a quasar frontend, docker image build and codefresh deployment.
I have also extended it for with my standard Terraform setup.

## Pre-deploy setup

Find and replace service name occurrences (templateservicename -> new name):

 - codefresh.yml TODDO REMOVE
 - Dockerfile
 - run localbuild
 - frontend/saasClientAPI
 - terraform main
 - local_terraform
 - testContainer

Find and replace defaulttenant to the tenant name. E.g. for saas_social I made the default social. This is for when the
frontend connects to usermanagement.

In _repo_vars update the versions of build containers I use:

Run commands in new repo root:
 - mkdir ./services/objectstoredata
 - in /frontend run npm install
 - in /frontend run npm audit fix

 - Check coderelease.props is correct github/gitlab

 - Check the python app requirements are the latest
 - Check the python app dependencies match the test container

Use pycharm to create .venv in the root of repot.
Activate it:

source ../.venv/bin/activate

Then run
```
pip install -r ./services/src/requirements.txt
pip install -r ./services/testContainer/requirements.txt
```


# Pre-DeployTesting

 - ./services/continous_test.sh works
 - ./services/run_app_developer.sh works
 - /frontend run quasar dev works
 - ./run_all_parts_on_dev_machine.sh - check serverinfo is being read correctly
 - ./compile_frontend_and_build_container.sh works
 - ./run_localbuild_container.sh works and serverinfo is read correctly

## Deploy Setup

TODO Setup vault DEPLOY role (Kept in github secrets)

TODO Setup vault RUN role (Kepy in docker secrets)

require policy access to:
memset/deployment/commonsecrets (Not sure if first / required)

create secrets
${PROJECT_NAME}_vault_roleid     (for run role)
${PROJECT_NAME}_vault_secretid    (for run role)

TODO github secrets
VAULT_ROLE_ID   (for deploy role)
VAULT_SECRET_ID  (for deploy role)
VAULT_ADDR

Change clone step in codefresh so it has either github or gitlab.

## Deploy testing

If the deployment works we should be good!

 - https://api.metcarob.com/templateservicename/v0/public/web/frontend/#/ works and loads serverinfo
 - curl https://api.metcarob.com/templateservicename/v0/public/api/info/serverinfo works

## Finally

 - Add endpoint to my service monitoring. (At least serverinfo and index pages)
