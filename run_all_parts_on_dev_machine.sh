#!/bin/bash

echo "This script launches all the components on a development machine"

if [[ ! -f ./VERSION ]]; then
  echo "VERSION dosen't exist - are you in correct directory?"
  exit 1
fi

tmux \
  new-session  "cd ./services ; ./run_app_developer.sh" \; \
  split-window "cd ./frontend ; quasar dev" \; \
  select-layout main-horizontal \; \
  select-pane -t 0 \; \
  ###split-window "cd ./services ; ./insert_test_data.sh"
