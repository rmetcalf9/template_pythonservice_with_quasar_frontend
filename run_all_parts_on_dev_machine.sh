#!/bin/bash

echo "This script launches all the components on a development machine"

if [ ! -d ../saas_linkvis_connectors ]; then
  echo "Could not find saas_linkvis_connectors repo"
  exit 1
fi
if [ ! -d ../saas_linkvis_connectors/services ]; then
  echo "Could not find saas_linkvis_connectors services dir"
  exit 1
fi
if [ ! -f ../saas_linkvis_connectors/services/run_app_developer.sh ]; then
  echo "Could not find saas_linkvis_connectors services dir"
  exit 1
fi


tmux \
  new-session  "cd ./services ; ./run_app_developer.sh" \; \
  split-window "cd ./frontend ; quasar dev" \; \
  select-layout main-horizontal \; \
  select-pane -t 0 \; \
  ###split-window "cd ./services ; ./insert_test_data.sh"
