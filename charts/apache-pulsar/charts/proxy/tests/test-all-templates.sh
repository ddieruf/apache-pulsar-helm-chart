#!/bin/bash
set -e
set -o errtrace
#set -x #echo all commands

#######################################
#       Notes
#######################################

# It' assumed this script is being run from root. pushd/popd are being used per test suite to overcome oddities with how the `helm unittest` command acts

#######################################
#       Script Globals
#######################################

cmdBase="helm unittest . -3"

#######################################
#       Tests
#######################################
pushd "./charts/apache-pulsar"
  cmd="${cmdBase}"
  for file in $(find ./charts/proxy/tests -name '*.yaml'); do
    cmd="${cmd} -f ${file}"
  done

  eval "${cmd}"
popd
