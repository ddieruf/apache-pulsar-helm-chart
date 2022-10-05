This will be where everything gets explained

## Parameters

### Pulsar global settings

These are global values that all sub charts will inherit

| Name                               | Description                                                                                              | Value           |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------- | --------------- |
| `global.imageRegistry`             | The image registry used by all charts.                                                                   | `docker.io`     |
| `global.imagePullSecrets`          | A collection of image pull secrets used to retrieve images.                                              | `[]`            |
| `global.storageClass`              | The storage class used by all sub charts when using persistence.                                         | `default`       |
| `global.kubeVersion`               | Override Kubernetes version                                                                              | `""`            |
| `global.clusterDomain`             | Default Kubernetes cluster domain                                                                        | `cluster.local` |
| `global.namespaceOverride`         | Override the release namespace                                                                           | `""`            |
| `global.commonLabels`              | Labels to add to all deployed objects                                                                    | `undefined`     |
| `global.commonAnnotations`         | Annotations to add to all deployed objects                                                               | `{}`            |
| `global.secureClusterEdge`         | Only allow secure ports to be opened at the edge of the Pulsar cluster (also force TLS in all ingresses) | `false`         |
| `global.interComponentTls.enabled` | Only allow communication over secure ports between all cluster components                                | `false`         |

