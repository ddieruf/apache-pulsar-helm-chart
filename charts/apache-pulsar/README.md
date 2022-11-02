# Apache Pulsar chart

This is an opinionated chart for deploying an Apache Pulsar cluster. It is dependent on the upstream [Pulsar project](https://pulsar.apache.org) and adds in components that enhance a cluster's usability and management.

The chart follows Helm's recommended patterns of using sub-charts as discrete parts of an overall chart. The chart also takes -heavy- influence from [Bitnami's common library](https://github.com/bitnami/charts/tree/master/bitnami/common) and template structures.

## Goals

The goals of this chart are:
- Expose every possible configuration value for each supported component
- Prove every component is in an expected state before existing
- Make the right way the easy way - best practices by default
- Create a simple experience for someone getting started with Apache Pulsar and also offer deep customization for someone going to production

> The [chart's wiki](https://github.com/ddieruf/apache-pulsar-helm-chart/wiki) is going to provide a lot more explanation and direction.

## Chart Design

Each component of the cluster is a sub-chart. Where all the specifics are held about that component. Think of each sub-chart as a domain of knowledge. The overall (parent) chart manages the orchestration of how a Pulsar cluster is configured and the choreography of its deployment. Some values apply to the overall cluster and some values apply only to an individual component. It's a goal of this chart to establish those boundaries.

> Note it is beyond the scope of this chart to guarantee a Pulsar cluster's stability once deployed. Helm is about deploying and upgrading, not long term management. Use observability to manage your cluster long term.

## Getting Started

The default values in this chart are meant as a production ready Apache Pulsar cluster (that's where the opinions come in). Multiple instance for high availability and redundancy are used. Secure 
communications are used. If you would like to install this chart in a development environment, things will need to be altered.

```bash
helm repo add ddieruf https://ddieruf.github.io/helm-charts
```

```bash
helm upgrade -i pulsar ddieruf/apache-pulsar \
  --create-namespace \
  --namespace pulsar \
  -f ./values.yaml
```

## Components Currently Supported

| Supported       | To Do (in no particular order) |
|-----------------|--------------------------------|
| Meta Data Store | Zoo Navigator                  |
| Data Store      | Pulsar SQL                     |
| Pulsar Broker   | Pulsar Proxy                   |
|                 | DS Bastion                     |
|                 | DS Admin Console               |
|                 | DS Burnell                     |
|                 | DS Beam                        |
|                 | Pulsar Websocket               |
|                 | Pulsar Function Worker         |
|                 | Auto Recovery                  |

## Feature Set Currently Supported

| Supported                         | To Do                                         |
|-----------------------------------|-----------------------------------------------|
| Chart Unit testing                | Edge TLS (encryption)                         |
| Manage Inter-chart configurations | Integration testing (ie: cluster validations) |
| Generate parameters readme        | Authentications                               |
| Cluster Lifecycle                 | Authorizations                                |
| Observability (metrics)           |                                               |
| Inter-component TLS (encryption)  |                                               |
| Component certificates            |                                               |
