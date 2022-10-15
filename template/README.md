This directory contains a basic scaffolding to serve as the basis for creating a new component chart for an Apache Pulsar cluster.

Some of the items that need to be implemented are:

* globalData
* image
* pulsarEnv
* certificateResources
* config
* service
* serviceAccount
* resources.requests
* resources.limits
* livenessProbe
* readinessProbe
* podLabels
* affinity
* nodeSelector
* tolerations (that would override the default one)
* podAnnotations
* sidecars
* initContainers
* extraEnvVars
* extraEnvVarsCM
* extraEnvVarsSecret
* command (which would override the default one)
* args (which would override the default one)
* extraVolumes
* extraVolumeMounts
* updateStrategy
* podSecurityContext
* containerSecurityContext

To aid in getting started quickly the following shortcut values can be replaced throughout the provided chart template files:

* %%CHART_NAME%% - the chart name all lowercase as kabob
* %%CHART_NODE_NAME%% - the alias name the chart will inherit from parent when added as a dependencies
* %%PROJECT_DOCUMENTATION_URL%% - url to the project this chart is implementing
* %%IMAGE_NAME%% - full image address ie: IMAGE_REPO/IMAGE_NAME
* %%IMAGE_TAG%% - image tag ie: latest
* %%SERVICE_PORT_UNSECURE_NAME%% - ie: client
* %%SERVICE_PORT_UNSECURE_PORT%% - ie: 8080
* %%SERVICE_PORT_SECURE_NAME%% - ie: clientTls
* %%SERVICE_PORT_SECURE_PORT%% - ie: 8081
* %%CONTAINER_COMMAND%% - assuming sh -c as a prefix, this is the command to run ie: /pulsar/bin/pulsar xxxx
* %%PERSISTENCE_MOUNT_PATH%% - the path in the container to mount as "data" ie: /pulsar/data
* %%LOG_PERSISTENCE_MOUNT_PATH%% - the path in the container to mount as "logs" ie: /pulsar/logs
