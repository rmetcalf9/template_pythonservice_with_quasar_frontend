# Template Repo

I use templates for my personal projects with standard setup to connect to
my personal app infrastructure.

This Template repo has a simple app with a flask python backend, a quasar frontend, docker image build and codefresh deployment.
I have also extended it for with my standard Terraform setup.

## Pre-deploy setup

Find and replace service name occurrences (templateservicename -> new name):
Start with _repo_vars.sh you will see the new name matches the github reponame.

In _repo_vars.sh delete the line that overrides the project directory to templateservicename

defaulttenant is what the app routes to in url's and what it is registered in
saas_user_management with. Find and replace all defaulttenant occurances

Create the tenenat with this name in usermanagement.

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
 - ./run_all_parts_on_dev_machine.sh - check serverinfo is being read correctly USE 127.0.0.1
 - ./compile_frontend_and_build_container.sh works
 - ./run_localbuild_container.sh works and serverinfo is read correctly

## Deploy Setup

On new infrastructure mainly automatic.
Go to the platform, in the override module under default -> webapp_project_names
add the name of this project.

Run the deploy and it will create the roles and secrets required.
When done head to: asfplatform/deploymentapproles/deploy_webapp_{project_name}
You will get the role_id and secret_id for the template

These get loaded into github goto project -> settings -> secrets and variables -> actions
add
VAULT_ADDR -> https://vault.metcarob.com
VAULT_ROLE_ID -> from above
VAULT_SECRET_ID -> from above

In the repository also goto settings -> actions -> Workflow permissions
and make sure it's read write.

After the first deployment you will see the pacakge in github.
click on it. on the right is package settings
at the bottom you can make it private

## Deploy testing

If the deployment works we should be good!

 - https://api2.metcarob.com/templateservicename/v0/public/web/frontend/#/ works and loads serverinfo
 - curl https://api2.metcarob.com/templateservicename/v0/public/api/info/serverinfo works

Log in to usermanagement - this should work

## Finally

 - Add endpoint to my service monitoring spreadsheet. (At least serverinfo and index pages) https://docs.google.com/spreadsheets/d/18cpQLWf2OrPjCyyzhI3T1_W8q7CQvh3LUjGQvdp2pEc/edit?gid=0#gid=0
