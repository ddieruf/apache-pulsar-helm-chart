# Apache Pulsar chart

This is an opinionated chart for deploying an Apache Pulsar cluster. This readme is just a reference of the chart's global values. The [chart's wiki](https://github.com/ddieruf/apache-pulsar-helm-chart/wiki) is going to provide a lot more explanation.

## Getting Started

To add the repository

```bash
helm repo add ddieruf https://ddieruf.github.io/helm-charts
```

Install the chart

```bash
helm install my-pulsar-cluster ddieruf/apache-pulsar \
  --create-namespace \
  --namespace apache-pulsar
```

## Parameters

### Pulsar global settings

These are global values that all sub charts will inherit




### Image

The container image all components will use

| Name                       | Description                                          | Value                    |
| -------------------------- | ---------------------------------------------------- | ------------------------ |
| `global.image.registry`    | The image registry used by all charts                | `docker.io`              |
| `global.image.repository`  | Component image repository                           | `datastax/lunastreaming` |
| `global.image.tag`         | Component image tag (immutable tags are recommended) | `2.10_2.3`               |
| `global.image.pullPolicy`  | Component image pull policy                          | `IfNotPresent`           |
| `global.image.pullSecrets` | Specify docker-registry secret names as an array     | `[]`                     |


### Secure Communications

Values related to securing the cluster's edge and inter component communicaitons

| Name                                             | Description                                                                                                                            | Value       |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `global.secureClusterEdge`                       | Only allow secure ports to be opened at the edge of the Pulsar cluster (also force TLS in all ingresses)                               | `false`     |
| `global.interComponentTls.enabled`               | Only allow communication over secure ports between all cluster components                                                              | `false`     |
| `global.interComponentTls.tlsSecretName`         | The name of an existing tls secret that includes a JKS store                                                                           | `nil`       |
| `global.interComponentTls.jksPasswordSecretName` | The name of the secret used to create the JKS store in an existing tls secret                                                          | `nil`       |
| `global.interComponentTls.issuerRef`             | IssuerRef is a reference to the issuer of all certificates. Note that each component can have their own issuerRef that overrides this. | `undefined` |


### Observability

Values related to enabling or disabling metrics endpoints and pre-configured dashboards. Note these values override an individual component's metrics settings.
Read more in the [chart wiki](https://github.com/ddieruf/apache-pulsar-helm-chart/wiki)

| Name                                   | Description                                                                                                        | Value  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------ |
| `global.observability.serviceMonitors` | Globally enable all components' metrics scraping by creating service monitors that are discoverable by Prometheus. | `true` |
| `global.observability.dashboards`      | Deploy configmaps with pre-configured dashboards that are discoverable by Grafana.                                 | `true` |


### Tenant, Namespace, and Topic Setup

Specify the initial tenant/namespace/topics created. lobal.pulsarCluster.name is required but tenants, namespaces, and topics are all optional.

| Name                        | Description                             | Value              |
| --------------------------- | --------------------------------------- | ------------------ |
| `global.pulsarCluster.name` | The required name of the Pulsar cluster | `pulsar-cluster-1` |


### Common values

Other common values one would set globally

| Name                       | Description                                                      | Value           |
| -------------------------- | ---------------------------------------------------------------- | --------------- |
| `global.storageClass`      | The storage class used by all sub charts when using persistence. | `nil`           |
| `global.kubeVersion`       | Override Kubernetes version                                      | `""`            |
| `global.clusterDomain`     | Default Kubernetes cluster domain                                | `cluster.local` |
| `global.namespaceOverride` | Override the release namespace                                   | `""`            |
| `global.commonLabels`      | Labels to add to all deployed objects                            | `undefined`     |
| `global.commonAnnotations` | Annotations to add to all deployed objects                       | `{}`            |

