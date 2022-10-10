# Apache Pulsar Kubernetes Helm Charts

This helm repo is a collection of charts that aid in the deployment of an Apache Pulsar cluster. It's very early days for this effort and everything is in alpha and absolutely will change.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add ddieruf https://ddieruf.github.io/helm-charts
```

You can then run `helm search repo ddieruf` to see the charts.

## Learning more

Visit the read me for each chart to learn more:

- [apache-pulsar](./charts/apache-pulsar/README.md)