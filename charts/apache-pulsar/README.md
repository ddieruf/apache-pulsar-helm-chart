# Apache Pulsar chart

This is an opinionated chart for deploying an Apache Pulsar cluster. It is dependent on the upstream [Pulsar project](https://pulsar.apache.org) and adds in components that enhance a cluster's usability and management.

The chart follows Helm's recommended patterns of using sub-charts as discrete parts of an overall chart. The chart also takes -heavy- influence from [Bitnami's common library](https://github.com/bitnami/charts/tree/master/bitnami/common) and template 
structures.

Each component of the cluster is a sub-chart. Where all the specifics are held about that component. Think of each sub-chart as a domain of knowledge. The overall (parent) chart manages the orchestration of how a Pulsar cluster is configured and the choreography of its deployment. Some values apply to the overall cluster and some values apply only to an individual component. It's a goal of this chart to establish those boundaries.

Production-grade Pulsar clusters have a huge amount of configurations. Quite a few are very low level and until you know exactly how the cluster will be consumed, the defaults are just fine. But 
how can you make the distinction between safe defaults and needed customization? This chart attempts to approach a cluster's deployment in a different way from [today's official pulsar helm](https://pulsar.apache.org/docs/helm-overview). There are 4 notable differences

## 1 Life Cycle Management

When installing or upgrading a helm chart, the return code from the helm command should reflect if the cluster is actually working. With Pulsar, this is an easy thing to know (produce and consume 
successfully) but a very difficult thing to debug due to some many components. Instead of tyring to install a full cluster and then testing for success, this chart approaches the deploment on a 
component-by-component basis. It uses a combination of helm hooks and the [k8s-wait-for](https://github.com/groundnuty/k8s-wait-for) project to create a lifecycle flow. To complete a given 
lifecycle stage, tests on the components created during that stage must pass. Then either next stage is started or the deployment stops and returns a non-zero result. Leaving all objects created 
in-tact for debugging.

## 2 Secure Communications

In general the two most popular choices made when deploying Pulsar are weather to require secure (TLS) communications at the edge (proxy, broker, administration, beam, etc) and weather to 
require secure (TLS) communications between components within the cluster. Pulsar has provisions for both but adapting certificates to each component's nuances gets complicated quickly. Where 
should the lime be drawn between internal cluster authorities and use of default trust stores? This chart makes a clear distinction by requiring an existing certificate issuer - there are no 
provisions to create an internal authority. But this introduces different complexities around know exactly what each component needs to request a certificate be created. So each component has a 
certificate request template pre-configured, with a global issuer. An example of this is subject alternate names. Each component in this chart defines a certificate request object with SAN's already 
configured.

Two key disciplines in this chart are immutability and bare minimum configurations. Trust stores are a good example of bare minimum configuration. Instead of defaulting to the operating system's 
store and then adding custom items to it, this chart expects the certificate issuer to provide a fully built (very specific) JKS trust store. In turn all component JVM's are configured to only use 
that store.

Of course not everyone wants this kind of certificate management. It's not uncommon for the certificates in a Pulsar cluster to be issued externally by a system that has no connection to Pulsar's 
deployment. So, this chart provides the ability to use an existing TLS secret and JKS store, overriding certificate creation completely.

## 3 Component Charts

A production-grade Pulsar cluster is not just one deployable. A side effect of being a distributed system (cloud-native) is managing different deployable components that make up the intended 
solution. Helm is a perfect fit for such work. Proxy, broker, data store, and meta data store are good examples of different deployable working together. But each have their own nuances and each 
deserve their own chart. There is a balance between maintaining a collection of stand alone individual charts and a single chart with one huge values file. This chart weighs the two by using Helm's 
sub-chart feature. It comes with a significant amount of value inheritance structure and template overriding, while still maintaining each component's best practices.

Some components need knowledge of how other components are configured (or addressed). Some components need to influence how other components are deployed. The parent chart (named `apache-pulsar`) 
has the ability read and override each sub-charts values. Also, the parent chart can create template functions with the same name as a sub-char's functions to override its return value.

### Deployment Choreography

The parent chart's purpose is to choreograph a Pulsar cluster's deployment. Making sure component-to-component dependencies are honored and exposing "global" configurations that all sub-charts 
should use. Additionally, the parent chart is a single interface for configuring all components. It's common for someone new to Pulsar to only configure the cluster-wide values and over time get 
deeper and deeper into each component's individual values. The parent chart can grow with your needs over time.

## 4 Deployment Stability

As mentioned above, this chart attempts a stage-based deployment approach. Expecting each stage to pass before continuing on to the next. Failed deployments are usually a result of mis-configured 
components or mis-aligned features. An example is the adminServer flag in the data-store component. Its readiness probes assume the adminServer is enabled and pings an endpoint that would only 
work if the server is running. If the adminServer is disabled the probe would not work, thus never marking the pod as healthy. Turning the server on or off is a simple config value, but 
reconfiguring the probe is an involved values change. It's a false negative due to a mis-aligned feature and should be caught before deployment.

This chart uses the [helm-unittest](https://github.com/quintush/helm-unittest/blob/master/README.md) project to overcome potential mis-configurments and logical mis-alignments. Each K8s 
object in a component has a set of tests that are run prior to creating a Helm release. Unlike Helm's testing, these tests are not Kubernetes aware. They put the values in a specific state and ensure 
templating has created well-formed yaml with expected values. A secondary step is taken after the tests pass to do a dry-run in Helm. This is Kubernetes aware and will validate each object's configuration against the given K8's current context version.

> Note it is beyond the scope of this chart to guarantee  a Pulsar cluster's stability once deployed. Helm is about deploying and upgrading.

## Components Currently Supported

| Supported       | To Do (in no particular order) |
|-----------------|--------------------------------|
| Meta Data Store | Zoo Navigator                  |
 | Data Store      | Pulsar Broker                  |
|                 | Pulsar Proxy                   |
|                 | DS Bastion                     |
|                 | DS Admin Console               |
|                 | DS Burnell                     |
|                 | DS Beam                        |
|                 | Pulsar Websocket               |
|                 | Pulsar Function Worker         |
|                 | Auto Recovery                  |
|                 | Pulsar SQL                     |

## Feature Set Currently Supported

| Supported                         | To Do                                         |
|-----------------------------------|-----------------------------------------------|
| Chart Unit testing                | Edge TLS (encryption)                         |
| Manage Inter-chart configurations | Integration testing (ie: cluster validations) |
| Generate parameters readme        | Observability (metrics)                       |
| Inter-component TLS (encryption)  | Authentications                               |
| Component certificates            | Authorizations                                |
| Cluster Lifecycle                 |                                               |

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

## Cluster Component Values

View the readme of each sub-chart component to see values.

### Data Store

Refer to the [Data Store sub-chart](./charts/data-store/readme.md) for details.

### Meta Data Store

Refer to the [Meta Data Store sub-chart](./charts/meta-data-store/readme.md) for details.

## Parameters

### Pulsar global settings

These are global values that all sub charts will inherit

| Name                               | Description                                                                                              | Value           |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------- | --------------- |
| `global.imageRegistry`             | The image registry used by all charts.                                                                   | `docker.io`     |
| `global.imagePullSecrets`          | A collection of image pull secrets used to retrieve images.                                              | `[]`            |
| `global.storageClass`              | The storage class used by all sub charts when using persistence.                                         | `local-path`    |
| `global.kubeVersion`               | Override Kubernetes version                                                                              | `""`            |
| `global.clusterDomain`             | Default Kubernetes cluster domain                                                                        | `cluster.local` |
| `global.namespaceOverride`         | Override the release namespace                                                                           | `""`            |
| `global.commonLabels`              | Labels to add to all deployed objects                                                                    | `undefined`     |
| `global.commonAnnotations`         | Annotations to add to all deployed objects                                                               | `{}`            |
| `global.secureClusterEdge`         | Only allow secure ports to be opened at the edge of the Pulsar cluster (also force TLS in all ingresses) | `false`         |
| `global.interComponentTls.enabled` | Only allow communication over secure ports between all cluster components                                | `true`          |

