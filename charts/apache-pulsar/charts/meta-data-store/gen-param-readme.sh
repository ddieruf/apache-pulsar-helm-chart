#!/bin/bash
set -e
set -o errtrace

~/readme-generator-for-helm/bin/index.js --values ./charts/apache-pulsar/charts/meta-data-store/values.yaml --readme ./charts/apache-pulsar/charts/meta-data-store/readme.md
