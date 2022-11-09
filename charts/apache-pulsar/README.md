# Apache Pulsar chart

This is an opinionated chart for deploying an Apache Pulsar cluster. It is dependent on [DataStax's Luna project](https://github.com/datastax/pulsar) which contributes to the upstream [Pulsar project](https://pulsar.apache.org).

The chart follows Helm's recommended patterns of using sub-charts as discrete parts of an overall chart. The chart also takes -heavy- influence from [Bitnami's common library](https://github.com/bitnami/charts/tree/master/bitnami/common) and template structures.

## Goals

The goals of this chart are:
- Expose every possible configuration value for each supported component
- Prove every component is in an expected state before deploying the next component
- Make the right way the easy way - best practices by default
- Create a simple experience for someone getting started with Apache Pulsar and also offer deep customization for someone going to production

> The [chart's wiki](https://github.com/ddieruf/apache-pulsar-helm-chart/wiki) is going to provide a lot more explanation and direction.

## Chart Design

Each component of the cluster is a sub-chart. Where all the specifics are held about that component. Think of each sub-chart as a domain of knowledge. The overall (parent) chart manages the orchestration of how a Pulsar cluster is configured and the choreography of its deployment. Some values apply to the overall cluster and some values apply only to an individual component. It's a goal of this chart to establish those boundaries.

> Note it is beyond the scope of this chart to guarantee a Pulsar cluster's stability once deployed. Helm is about deploying and upgrading, not long term management. Use observability to manage your cluster long term.

## Getting Started

To add the repository

```bash
helm repo add ddieruf https://ddieruf.github.io/helm-charts
```

### Production

The default values in this chart are meant as a production ready Apache Pulsar cluster (that's where the opinions come in). Multiple instance for high availability and redundancy are used. Secure communications are used. If you would like to install this chart in a development environment, things will need to be altered.

```bash
helm install my-pulsar-cluster ddieruf/apache-pulsar \
  --create-namespace \
  --namespace apache-pulsar
```

### Not production

```bash
helm install my-pulsar-cluster ddieruf/apache-pulsar \
  --create-namespace \
  --namespace apache-pulsar
  -f https://gist.github.com/ddieruf/xxxxxxxx/not-production-values.yaml
```

## Components Currently Supported

| Supported       | To Do (in no particular order) |
|-----------------|--------------------------------|
| Meta Data Store | Zoo Navigator                  |
| Data Store      | Pulsar SQL                     |
| Pulsar Broker   | Auto Recovery                  |
| Pulsar Proxy    | DS Bastion                     |
|                 | DS Admin Console               |
|                 | DS Burnell                     |
|                 | DS Beam                        |
|                 | Pulsar Websocket               |
|                 | Pulsar Function Worker         |

## Feature Set Currently Supported

| Supported                         | To Do                                         |
|-----------------------------------|-----------------------------------------------|
| Chart Unit testing                | Integration testing (ie: cluster validations) |
| Manage Inter-chart configurations | Authentications                               |
| Generate parameters readme        | Authorizations                                |
| Cluster Lifecycle                 |                                               |
| Observability (metrics)           |                                               |
| Inter-component TLS (encryption)  |                                               |
| Component certificates            |                                               |
| External Load Balancers           |                                               |
| Edge TLS (encryption)             |                                               |

## Parameters

### Pulsar global settings

These are global values that all sub charts will inherit

| Name                                             | Description                                                                                                                            | Value           |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `global.imageRegistry`                           | The image registry used by all charts.                                                                                                 | `docker.io`     |
| `global.imagePullSecrets`                        | A collection of image pull secrets used to retrieve images.                                                                            | `[]`            |
| `global.storageClass`                            | The storage class used by all sub charts when using persistence.                                                                       | `nil`           |
| `global.kubeVersion`                             | Override Kubernetes version                                                                                                            | `""`            |
| `global.clusterDomain`                           | Default Kubernetes cluster domain                                                                                                      | `cluster.local` |
| `global.namespaceOverride`                       | Override the release namespace                                                                                                         | `""`            |
| `global.commonLabels`                            | Labels to add to all deployed objects                                                                                                  | `undefined`     |
| `global.commonAnnotations`                       | Annotations to add to all deployed objects                                                                                             | `{}`            |
| `global.secureClusterEdge`                       | Only allow secure ports to be opened at the edge of the Pulsar cluster (also force TLS in all ingresses)                               | `true`          |
| `global.interComponentTls.enabled`               | Only allow communication over secure ports between all cluster components                                                              | `false`         |
| `global.interComponentTls.tlsSecretName`         | The name of an existing tls secret that includes a JKS store                                                                           | `nil`           |
| `global.interComponentTls.jksPasswordSecretName` | The name of the secret used to create the JKS store in an existing tls secret                                                          | `nil`           |
| `global.interComponentTls.issuerRef`             | IssuerRef is a reference to the issuer of all certificates. Note that each component can have their own issuerRef that overrides this. | `undefined`     |


### Observability

Values related to enabling or disabling metrics endpoints and pre-configured dashboards. Note these values override an individual component's metrics settings.
Read more in the [chart wiki](https://github.com/ddieruf/apache-pulsar-helm-chart/wiki)

| Name                                   | Description                                                                                                        | Value  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------ |
| `global.observability.serviceMonitors` | Globally enable all components' metrics scraping by creating service monitors that are discoverable by Prometheus. | `true` |
| `global.observability.dashboards`      | Deploy configmaps with pre-configured dashboards that are discoverable by Grafana.                                 | `true` |


### Tenant, Namespace, and Topic Setup

Specify the initial tenant/namespace/topics created. pulsarCluster.name is required but tenants, namespaces, and topics are all optional.

| Name                        | Description                             | Value              |
| --------------------------- | --------------------------------------- | ------------------ |
| `global.pulsarCluster.name` | The required name of the Pulsar cluster | `pulsar-cluster-1` |

