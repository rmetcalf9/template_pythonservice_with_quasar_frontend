# Template Repo

I use templates for my personal projects with standard setup to connect to
my personal app infrastructure.

This Template repo has a simple app with a flask python backend, a quasar frontend, docker image build and codefresh deployment.
I have also extended it for with my standard Terraform setup.

## Usage

Find and replace service name occurrences (templateservicename -> new name):

 - codefresh.yml
 - Dockerfile
 - run localbuild
 - frontend/saasClientAPI
 - terraform main
 - local_terraform
 - testContainer

In codefresh.yml update the versions of build containers I use:
 - RJM_BUILDQUASARAPP_IMAGE
 - RJM_DOCKERWSCALLER_IMAGE

Run commands in new repo root:
 - mkdir /services/objectstoredata
 - in /frontend run npm install
 - in /frontend run npm audit fix

## Testing

 - ./services/continous_test.sh works
 - ./services/run_app_developer.sh works
 - /frontend run quasar dev works
 - ./run_all_parts_on_dev_machine.sh - check serverinfo is being read correctly
 - ./compile_frontend_and_build_container.sh works
 - ./run_localbuild_container.sh works
 

