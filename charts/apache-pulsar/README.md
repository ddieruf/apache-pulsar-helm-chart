This will be where everything gets explained. It's too early to do it.

## Components

| Supported       | To Do                  |
|-----------------|------------------------|
| Meta Data Store | Data Store             |
 |                 | Pulsar Broker          |
|                 | Pulsar Proxy           |
|                 | DS Bastion             |
|                 | DS Admin Console       |
|                 | DS Burnell             |
|                 | DS Beam                |
|                 | Pulsar Websocket       |
|                 | Pulsar Function Worker |
|                 | Auto Recovery          |
|                 | Pulsar SQL             |
|                 | Zoonavigator           |

## Features

| Supported                  | To Do                  |
|----------------------------|------------------------|
| Unit testing               | Edge TLS               |
| Inter-chart communications | Inter-component TLS    |
| Generate parameters readme | Integration testing    |
|                            | Component certificates |

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
| `global.interComponentTls.enabled` | Only allow communication over secure ports between all cluster components                                | `false`         |

