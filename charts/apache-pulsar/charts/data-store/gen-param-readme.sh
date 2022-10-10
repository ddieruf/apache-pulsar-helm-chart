#!/bin/bash
set -e
set -o errtrace

~/readme-generator-for-helm/bin/index.js --values ./charts/apache-pulsar/charts/data-store/values.yaml --readme ./charts/apache-pulsar/charts/data-store/readme.md
