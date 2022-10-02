#!/bin/bash
set -e
set -o errtrace

~/readme-generator-for-helm/bin/index.js --values ./luna-chart/charts/meta-data-store/values.yaml --readme ./luna-chart/charts/meta-data-store/readme.md
