This directory contains a basic scaffolding to serve as the basis for creating a new component chart for an Apache Pulsar cluster.

Some of the items that need to be implemented are:

  - globalData
  - image
  - pulsarEnv
  - certificateResources
  - config
  - service
  - serviceAccount
  - resources.requests
  - resources.limits
  - livenessProbe
  - readinessProbe
  - podLabels
  - affinity
  - nodeSelector
  - tolerations (that would override the default one)
  - podAnnotations
  - sidecars
  - initContainers
  - extraEnvVars
  - extraEnvVarsCM
  - extraEnvVarsSecret
  - command (which would override the default one)
  - args (which would override the default one)
  - extraVolumes
  - extraVolumeMounts
  - updateStrategy
  - podSecurityContext
  - containerSecurityContext