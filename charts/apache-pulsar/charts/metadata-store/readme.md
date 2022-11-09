# Pulsar Meta Data Store

Pulsar creates its own version of Zookeeper but follows the general principles of Zookeeper administration. There are noticeably less config values
to choose from because Pulsar can make assumptions from it's own configuration.

## Startup Flow

As the helm chart starts a pulsar based Zookeeper instance there is work done to get it's configuration ready. One of the jobs of this chart is to
make configuration straight forward and do the work of converting the desired values into a format that Pulsar Zookeeper understands. The chart also
manages things like converting multiple replicas into a quorum of servers, and exposing the option for some of the members of that quorum to not have
persistent disks attached (more on that below).

1. Write the provided values in `.config` into a configmap that uses a preferred prefix label
2. Attach that configmap to each zookeeper instance
3. Use `scripts/apply-config-from-env.py` python script (provided in the Pulsar container) as a container arg, to convert the attached env values into `conf/zookeeper.conf`
4. Use `scripts/generate-zookeeper-config.sh` script (provided in the Pulsar container) as a container arg, to append the addresses of each zookeeper in the quorum into `conf/zookeeper.conf`
5. Start the Pulsar Zookeeper instance, providing the location of the conf file

## Configuration

Given the version tag of Pulsar container being used in this chart, the labels and values within the `.config` area should follow Pulsar's options. Refer to [Pulsar's Zookeeper documentation](https://pulsar.apache.org/docs/next/reference-configuration-zookeeper) for more.

*Note* - this chart does not assume any default values in `.config`. They are left blank. By doing this, default values of Pulsar Zookeeper are respected.

*Note* - the use of the prefix "PULSAR_PREFIX_" with some values. This is used so when `scripts/apply-config-from-env.py` runs, these values will be converted into Zookeeper conf.

## Non persistent instances

In a highly available Pulsar cluster, a single Zookeeper instance becomes a failure point. Naturally one would start multiple instances to overcome this. But as a meta data store, each Zookeeper instance has it's own disk and holds it's own values. To create a compliance between Zookeeper wanting quorum and Pulsar brokers always working with the same configurations, the chart offers an option to configure Zookeeper with no attached persistent volumes. Instead using a local folder that will follow the lifecycle of it's instance. Refer to the [zookeeper-non-persistent-quorum](../../../examples/add-ons/zookeeper-non-persistent-quorum.yaml) example to see this in action.

## Services

The chart makes a distinction between types of traffic by separating the "[tls]client" traffic into a configurable service object and a [headless](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) service for "leader election" and "sever" traffic. This is considered a best practice when deploying Zookeeper in kubernetes. [Here](https://kubernetes.io/docs/tutorials/stateful-application/zookeeper/) is an example.

## Leader Election

To facilitate leader election but still provision for pod scheduling, the FQDN of each instance is used as the quorum address. The A records in Kubernetes DNS resolve the FQDNs to the Pods' IP addresses. If Kubernetes reschedules the Pods, it will update the A records with the Pods' new IP addresses, but the A records names will not change.

## Parameters

### Image parameters

| Name                | Description                                          | Value                    |
| ------------------- | ---------------------------------------------------- | ------------------------ |
| `image.registry`    | Component image registry                             | `""`                     |
| `image.repository`  | Component image repository                           | `datastax/lunastreaming` |
| `image.tag`         | Component image tag (immutable tags are recommended) | `2.10_2.3`               |
| `image.pullPolicy`  | Component image pull policy                          | `IfNotPresent`           |
| `image.pullSecrets` | Specify docker-registry secret names as an array     | `[]`                     |


### Pulsar Environment Configuration

| Name                             | Description                                                                                           | Value                                                                                                                                                                                                                                      |
| -------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `pulsarEnv.confPath`             | The full path where configuration files are held                                                      | `/pulsar/conf`                                                                                                                                                                                                                             |
| `pulsarEnv.gc`                   | A collection of JVM settings garbage collection settings                                              | `["-XX:+UseG1GC","-XX:MaxGCPauseMillis=10","-XX:+ParallelRefProcEnabled","-XX:+UnlockExperimentalVMOptions","-XX:+DoEscapeAnalysis","-XX:ParallelGCThreads=32","-XX:ConcGCThreads=32","-XX:G1NewSizePercent=50","-XX:+DisableExplicitGC"]` |
| `pulsarEnv.mem`                  | A collection of JVM memory settings                                                                   | `["-Xms2g","-Xmx2g","-XX:MaxDirectMemorySize=4g"]`                                                                                                                                                                                         |
| `pulsarEnv.loggingLevels.root`   | Applies the pulsar.log.root.level JVM option                                                          | `error`                                                                                                                                                                                                                                    |
| `pulsarEnv.loggingLevels.pulsar` | Applies the PULSAR_LOG_LEVEL env var                                                                  | `error`                                                                                                                                                                                                                                    |
| `pulsarEnv.extraOpts`            | A collection of extra options to be passed to the jvm. Format each as the entire key/value            | `["-Dzookeeper.tcpKeepAlive=true","-Dzookeeper.clientTcpKeepAlive=true","-Dpulsar.allocator.exit_on_oom=true","-Dio.netty.recycler.maxCapacity.default=1000","-Dio.netty.recycler.linkCapacity=1024","-Dlog4j2.formatMsgNoLookups=true"]`  |
| `pulsarEnv.extraClasspath`       | A collection of extra paths for the pulsar classpath. Include just the folder or file path from root. | `[]`                                                                                                                                                                                                                                       |
| `pulsarEnv.stopTimeout`          | Time to wait for an instance to stop before getting forceful                                          | `5`                                                                                                                                                                                                                                        |


### Component configuration

Configure meta data store settings. Refer to the [project's documentation](https://pulsar.apache.org/docs/next/reference-configuration-zookeeper) for a full spec.

> Note, the values not documented here are set by the parent chart

| Name                                   | Description                                                                                                                                                                                                                                                                              | Value   |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `config.tickTime`                      | The tick is the basic unit of time in ZooKeeper, measured in milliseconds and used to regulate things like heartbeats and timeouts. tickTime is the length of a single tick.                                                                                                             | `2000`  |
| `config.initLimit`                     | The maximum time, in ticks, that the leader ZooKeeper server allows follower ZooKeeper servers to successfully connect and sync. The tick time is set in milliseconds using the tickTime parameter.                                                                                      | `10`    |
| `config.syncLimit`                     | The maximum time, in ticks, that a follower ZooKeeper server is allowed to sync with other ZooKeeper servers. The tick time is set in milliseconds using the tickTime parameter.                                                                                                         | `5`     |
| `config.admin.enableServer`            | Enable administrative interface.                                                                                                                                                                                                                                                         | `true`  |
| `config.admin.serverPort`              | The port at which the admin listens.                                                                                                                                                                                                                                                     | `8080`  |
| `config.autopurge.snapRetainCount`     | In ZooKeeper, auto purge determines how many recent snapshots of the database stored in dataDir to retain within the time interval specified by autopurge.purgeInterval (while deleting the rest).                                                                                       | `3`     |
| `config.autopurge.purgeInterval`       | The time interval, in hours, by which the ZooKeeper database purge task is triggered. Setting to a non-zero number will enable auto purge; setting to 0 will disable. Read this guide before enabling auto purge.                                                                        | `1`     |
| `config.forceSync`                     | Requires updates to be synced to media of the transaction log before finishing processing the update. If this option is set to 'no', ZooKeeper will not require updates to be synced to the media. WARNING: it's not recommended to run a production ZK cluster with forceSync disabled. | `""`    |
| `config.maxClientCnxns`                | The maximum number of client connections. Increase this if you need to handle more ZooKeeper clients.                                                                                                                                                                                    | `60`    |
| `config.sslQuorum`                     | Enable Quorum TLS on each node                                                                                                                                                                                                                                                           | `nil`   |
| `config.portUnification`               | Specifies that the client port should accept SSL connections (using the same configuration as the secure client port).                                                                                                                                                                   | `false` |
| `config.metricsProvider.className`     | Metrics provider class name                                                                                                                                                                                                                                                              | `nil`   |
| `config.metricsProvider.httpPort`      | Metrics port                                                                                                                                                                                                                                                                             | `8000`  |
| `config.metricsProvider.exportJvmInfo` | Include JVM info with metrics                                                                                                                                                                                                                                                            | `true`  |
| `config.extraConfigValues`             | Additional config values                                                                                                                                                                                                                                                                 | `{}`    |


### Certificate Resources

Configure the component's certificate

| Name                                                            | Description                                                                                                                                           | Value |
| --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `certificateResources.tlsSecretName`                            |                                                                                                                                                       | `nil` |
| `certificateResources.jksPasswordSecretName`                    |                                                                                                                                                       | `nil` |
| `certificateResources.certificateRequest`                       | Refer to the [CertificateSpec](https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec) for more info about these values. |       |
| `certificateResources.certificateRequest.renewBefore`           | How long before the currently issued certificate’s expiry cert-manager should renew the certificate. Default is 2/3 of the duration.                  | `nil` |
| `certificateResources.certificateRequest.duration`              | The requested ‘duration’ (i.e. lifetime) of the Certificate. Default is 90 days                                                                       | `nil` |
| `certificateResources.certificateRequest.subject.organizations` | Organizations to be used on the Certificate                                                                                                           | `[]`  |
| `certificateResources.certificateRequest.privateKey`            | Options to control private keys used for the Certificate                                                                                              | `{}`  |
| `certificateResources.certificateRequest.issuerRef`             | IssuerRef is a reference to the issuer for this certificate                                                                                           | `{}`  |


### Service parameters

Meta Data Store application controller service parameters

| Name                                          | Description                                                                                | Value  |
| --------------------------------------------- | ------------------------------------------------------------------------------------------ | ------ |
| `service.ports.server`                        | Meta Data Store server service port                                                        | `2888` |
| `service.ports.leaderElection`                | Meta Data Store leader election service port                                               | `3888` |
| `service.ports.client`                        | Meta Data Store client service port                                                        | `2181` |
| `service.ports.clientTls`                     | Meta Data Store secure client service port                                                 | `2182` |
| `service.annotations`                         | Additional custom annotations for Beam application controller service                      | `nil`  |
| `service.extraPorts`                          | Extra ports to expose (normally used with the `sidecar` value)                             | `[]`   |
| `serviceAccount.create`                       | Specifies whether a ServiceAccount should be created                                       | `true` |
| `serviceAccount.name`                         | The name of the ServiceAccount to use.                                                     | `""`   |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                             | `true` |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`. | `{}`   |
| `podDisruptionBudget.enabled`                 | Enable the disruption budget                                                               | `true` |
| `podDisruptionBudget.maxUnavailable`          | When enabled the maximum allowed unavailable for matchLabel objects                        | `nil`  |
| `podDisruptionBudget.minAvailable`            | When enabled the minimum allowed unavailable for matchLabel objects                        | `2`    |


### Other Parameters

| Name                                    | Description                                                                                                                                                                                   | Value                                             |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `metricsServiceMonitor`                 | Enable component metrics scraping by creating a service monitor that is discoverable by Prometheus.                                                                                           | `false`                                           |
| `podManagementPolicy`                   | StatefulSet controller supports relax its ordering guarantees while preserving its uniqueness and identity guarantees. There are two valid pod management policies: OrderedReady and Parallel | `Parallel`                                        |
| `updateStrategy.type`                   | Meta Data Store statefulset strategy type                                                                                                                                                     | `RollingUpdate`                                   |
| `updateStrategy.rollingUpdate`          | Meta Data Store statefulset rolling update configuration parameters                                                                                                                           | `{}`                                              |
| `podLabels`                             | Extra labels for Meta Data Store pods                                                                                                                                                         | `{}`                                              |
| `podAnnotations`                        | Extra annotations for Meta Data Store pods                                                                                                                                                    | `{}`                                              |
| `hostAliases`                           | Meta Data Store pods host aliases                                                                                                                                                             | `[]`                                              |
| `hostNetwork`                           | Specify if host network should be enabled for Meta Data Store pods                                                                                                                            | `false`                                           |
| `hostIPC`                               | Specify if host IPC should be enabled for Meta Data Store pods                                                                                                                                | `false`                                           |
| `schedulerName`                         | Name of the k8s scheduler (other than default)                                                                                                                                                | `""`                                              |
| `affinity`                              | Affinity for pod assignment                                                                                                                                                                   | `{}`                                              |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                           | `""`                                              |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                      | `hard`                                            |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                                                                     | `""`                                              |
| `nodeAffinityPreset.key`                | Node label key to match Ignored if `affinity` is set.                                                                                                                                         | `""`                                              |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set.                                                                                                                                     | `[]`                                              |
| `nodeSelector`                          | Node labels for pod assignment                                                                                                                                                                | `{}`                                              |
| `tolerations`                           | Tolerations for pod assignment                                                                                                                                                                | `[]`                                              |
| `topologySpreadConstraints`             | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template                                                                      | `[]`                                              |
| `terminationGracePeriodSeconds`         | Seconds the pod needs to gracefully terminate                                                                                                                                                 | `60`                                              |
| `priorityClassName`                     | Name of the existing priority class to be used by Meta Data Store pods                                                                                                                        | `""`                                              |
| `podSecurityContext.enabled`            | Enable security context for the pods                                                                                                                                                          | `true`                                            |
| `podSecurityContext.fsGroup`            | Set Meta Data Store pod's Security Context fsGroup                                                                                                                                            | `1001`                                            |
| `containerSecurityContext.enabled`      | Enable Meta Data Store containers' Security Context                                                                                                                                           | `true`                                            |
| `containerSecurityContext.runAsUser`    | Set Meta Data Store containers' Security Context runAsUser                                                                                                                                    | `1001`                                            |
| `containerSecurityContext.runAsNonRoot` | Set Meta Data Store containers' Security Context runAsNonRoot                                                                                                                                 | `true`                                            |
| `containerCommand`                      | Override the container image ENTRYPOINT. Leave blank to use image default (if set)                                                                                                            | `["sh","-c","exec /pulsar/bin/pulsar zookeeper"]` |
| `containerArgs`                         | Override the container image CMD. Leave blank to use image default (if set)                                                                                                                   | `[]`                                              |
| `extraEnvVars`                          | Extra environment variables to add to the provisioning pod                                                                                                                                    | `[]`                                              |
| `extraEnvVarsCM`                        | ConfigMap with extra environment variables                                                                                                                                                    | `""`                                              |
| `extraEnvVarsSecret`                    | Secret with extra environment variables                                                                                                                                                       | `""`                                              |
| `initContainers`                        | Add additional Add init containers to the Meta Data Store pod(s)                                                                                                                              | `[]`                                              |
| `containerPorts.server`                 | Meta Data Store server container port                                                                                                                                                         | `2888`                                            |
| `containerPorts.leaderElection`         | Meta Data Store leader election container port                                                                                                                                                | `3888`                                            |
| `containerPorts.client`                 | Meta Data Store client container port                                                                                                                                                         | `2181`                                            |
| `containerPorts.clientTls`              | Meta Data Store secure client container port                                                                                                                                                  | `2182`                                            |


### Persistence parameters

| Name                             | Description                                                                                                     | Value                           |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `persistence.mountPath`          | Mount path to store meta data                                                                                   | `/pulsar/data/zookeeper`        |
| `persistence.mountPathForGlobal` | Mount path of the global data store (where snapshots are stored)                                                | `/pulsar/data/global-zookeeper` |
| `persistence.size`               | PVC storage size                                                                                                | `5Gi`                           |
| `persistence.storageClass`       | PVC Storage Class for Kafka data volume                                                                         | `nil`                           |
| `persistence.existingClaim`      | A manually managed Persistent Volume and Claim                                                                  | `""`                            |
| `persistence.accessModes`        | Persistent Volume Access Modes                                                                                  | `["ReadWriteOnce"]`             |
| `persistence.annotations`        | Annotations for the PVC                                                                                         | `{}`                            |
| `persistence.selector`           | Selector to match an existing Persistent Volume. If set, the PVC can't have a PV dynamically provisioned for it | `{}`                            |
| `logPersistence.mountPath`       | Mount path of Pulsar home                                                                                       | `/pulsar/logs`                  |
| `logPersistence.size`            | PVC storage size                                                                                                | `5Gi`                           |
| `logPersistence.storageClass`    | PVC Storage Class for Kafka data volume                                                                         | `nil`                           |
| `logPersistence.existingClaim`   | A manually managed Persistent Volume and Claim                                                                  | `""`                            |
| `logPersistence.accessModes`     | Persistent Volume Access Modes                                                                                  | `["ReadWriteOnce"]`             |
| `logPersistence.annotations`     | Annotations for the PVC                                                                                         | `{}`                            |
| `logPersistence.selector`        | Selector to match an existing Persistent Volume. If set, the PVC can't have a PV dynamically provisioned for it | `{}`                            |


### Pod Liveness & Readyness

| Name                                 | Description                                                                                        | Value                             |
| ------------------------------------ | -------------------------------------------------------------------------------------------------- | --------------------------------- |
| `livenessProbe.enabled`              | Enable livenessProbe on Meta Data Store containers                                                 | `true`                            |
| `livenessProbe.exec.command`         | Process to monitor for readiness                                                                   | `["/pulsar/probes/liveness.sh"]`  |
| `livenessProbe.periodSeconds`        | Period seconds for readinessProbe                                                                  | `20`                              |
| `livenessProbe.timeoutSeconds`       | Timeout seconds for readinessProbe                                                                 | `5`                               |
| `livenessProbe.failureThreshold`     | Failure threshold for readinessProbe                                                               | `5`                               |
| `livenessProbe.successThreshold`     | Success threshold for readinessProbe                                                               | `1`                               |
| `livenessProbe.initialDelaySeconds`  | Delay before running probe                                                                         | `5`                               |
| `readinessProbe.enabled`             | Enable readinessProbe on Meta Data Store containers                                                | `true`                            |
| `readinessProbe.exec.command`        | Process to monitor for readiness                                                                   | `["/pulsar/probes/readiness.sh"]` |
| `readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                                  | `25`                              |
| `readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                               | `2`                               |
| `readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                               | `1`                               |
| `readinessProbe.initialDelaySeconds` | Delay before running probe                                                                         | `5`                               |
| `readinessProbe.timeoutSeconds`      | Seconds to allow probe to run                                                                      | `5`                               |
| `startupProbe.enabled`               | Enable startupProbe on Meta Data Store containers                                                  | `false`                           |
| `startupProbe.exec.command`          | Process to monitor for readiness                                                                   | `["/pulsar/probes/startup.sh"]`   |
| `startupProbe.periodSeconds`         | Period seconds for readinessProbe                                                                  | `2`                               |
| `startupProbe.failureThreshold`      | Failure threshold for readinessProbe                                                               | `10`                              |
| `lifecycleHooks`                     | lifecycleHooks for the Meta Data Store container to automate configuration before or after startup | `{}`                              |
| `resources.limits`                   | The resources limits for the container                                                             | `{}`                              |
| `resources.requests.memory`          | The requested memory resources for the container                                                   | `1Gi`                             |
| `resources.requests.cpu`             | The requested cpu resources for the container                                                      | `0.3`                             |
| `extraVolumes`                       | Optionally specify extra list of additional volumes for the Meta Data Store pod(s)                 | `[]`                              |
| `extraVolumeMounts`                  | Optionally specify extra list of additional volumeMounts for the Meta Data Store container(s)      | `[]`                              |
| `sidecars`                           | Add additional sidecar containers to the Meta Data Store pod(s)                                    | `[]`                              |

