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

