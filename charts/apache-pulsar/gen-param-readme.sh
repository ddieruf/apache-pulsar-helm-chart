#!/bin/bash
set -e
set -o errtrace

~/readme-generator-for-helm/bin/index.js --values ./charts/apache-pulsar/values.yaml --readme ./charts/apache-pulsar/readme.md
