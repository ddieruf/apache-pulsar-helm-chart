{{/*
Expand the name of the meta data store chart.
*/}}
{{- define "metadata-store.name" -}}
  {{- .Values.global.metadataStore.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified meta data store name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metadata-store.fullname" -}}
  {{- if .Values.global.metadataStore.fullnameOverride -}}
    {{- .Values.global.metadataStore.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default "metadata-store" .Values.global.metadataStore.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Create a fully qualified app name adding the installation's namespace.
*/}}
{{- define "metadata-store.fullname.namespace" -}}
  {{- printf "%s-%s" (include "metadata-store.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "metadata-store.serviceAccountName" -}}
  {{- coalesce .Values.serviceAccount.name (include "metadata-store.name" .) -}}
{{- end -}}

{{/*
Return the proper log Storage Class
*/}}
{{- define "metadata-store.logPersistence.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .Values.global -}}
    {{- if .Values.global.storageClass -}}
        {{- if (eq "-" .Values.global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else -}}
            {{- printf "storageClassName: %s" .Values.global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.logPersistence.storageClass -}}
              {{- if (eq "-" .Values.logPersistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else -}}
                  {{- printf "storageClassName: %s" .Values.logPersistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.logPersistence.storageClass -}}
        {{- if (eq "-" .Values.logPersistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else -}}
            {{- printf "storageClassName: %s" .Values.logPersistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}


{{/*
Return the proper Storage Class
*/}}
{{- define "metadata-store.persistence.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .Values.global -}}
    {{- if .Values.global.storageClass -}}
        {{- if (eq "-" .Values.global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else -}}
            {{- printf "storageClassName: %s" .Values.global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.persistence.storageClass -}}
              {{- if (eq "-" .Values.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else -}}
                  {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.persistence.storageClass -}}
        {{- if (eq "-" .Values.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else -}}
            {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
 Create the name of the headless service account to use in the format: {pod-hostname}.{headless-service-name}.{namespace}.svc.{cluster-domain}:{server-port}:{leader-election-port}
For more information about headless services with statefulsets and K8s DNS - https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id

 usage: {{ include "metadata-store.quorum-instance-address" (dict "instanceIndex" 0 "instanceNamePrefix" "metadata-store-statefulset" "serverPort" 123 "leaderElectionPort" 567 "context" $) }}
 */}}
{{- define "metadata-store.quorum-instance-address" -}}
  {{- $instanceIndex := .instanceIndex -}}
  {{- $instanceNamePrefix := .instanceNamePrefix -}}
  {{- printf "%s-%d.%s.%s.svc.%s:%d:%d" $instanceNamePrefix
                                  $instanceIndex
                                  (printf "%s-headless" (include "metadata-store.name" .context))
                                  (include "common.names.namespace" .context)
                                  .context.Values.global.clusterDomain
                                  .serverPort
                                  .leaderElectionPort -}}
{{- end -}}

{{/*
 Create the name of the headless service account to use in the format: {pod-hostname}.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port}
For more information about headless services with statefulsets and K8s DNS - https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id

 usage: {{ include "metadata-store.client-instance-address" (dict "instanceIndex" 0 "instanceNamePrefix" "metadata-store-statefulset" "clientPort" 123 "context" $) }}
*/}}
{{- define "metadata-store.client-instance-address" -}}
  {{- $instanceIndex := .instanceIndex -}}
  {{- $instanceNamePrefix := .instanceNamePrefix -}}
  {{- printf "%s-%d.%s.%s.svc.%s:%d" $instanceNamePrefix
                                  $instanceIndex
                                  (printf "%s-headless" (include "metadata-store.name" .context))
                                  (include "common.names.namespace" .context)
                                  .context.Values.global.clusterDomain
                                  .clientPort
                                   -}}
{{- end -}}

{{/*
 Get a dict of all meta data server addresses for quorum (headless) communications

 usage: {{ include "metadata-store.server-cluster-addresses" $ }}
 returns:
  {
    0: {pod-hostname}-0.{headless-service-name}.{namespace}.svc.{cluster-domain}:{server-port}:{leader-election-port},
    1: {pod-hostname}-1.{headless-service-name}.{namespace}.svc.{cluster-domain}:{server-port}:{leader-election-port},
    2: {pod-hostname}-2.{headless-service-name}.{namespace}.svc.{cluster-domain}:{server-port}:{leader-election-port}
    ...
  }
 */}}
{{- define "metadata-store.quorum-cluster-addresses" -}}
  {{- $addresses := dict -}}
  {{- $replicas := (default 0 (.Values.global.metadataStore.replicas | int)) -}}
  {{- $nonPersistentReplicas := (default 0 (.Values.global.metadataStore.nonPersistentReplicas | int)) -}}
  {{- $totalServers := add $replicas $nonPersistentReplicas -}}
  {{- $serverCount := 1 -}} {{/* This holds a 1 based index of each zerver instance*/}}
  {{- $serverPort := .Values.global.metadataStore.service.ports.server | int -}}
  {{- $leaderElectionPort := .Values.global.metadataStore.service.ports.leaderElection | int -}}

  {{- range $i := until $replicas -}} {{/* The count starts at zero to track the indexx of each statfulset index*/}}
    {{- $address := (include "metadata-store.quorum-instance-address" (dict "serverPort" $serverPort "leaderElectionPort" $leaderElectionPort "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset" (include "metadata-store.name" $)) "context" $)) }}
    {{- $_ := set $addresses (toString $serverCount) $address }}
    {{- $serverCount = (add $serverCount 1) -}}
  {{- end -}}

  {{- $i := 0 }} {{/* This holds a zero based index of each statefulset instance*/}}
  {{- range $r := untilStep $replicas ($totalServers | int) 1 -}}
    {{- $address := (include "metadata-store.quorum-instance-address" (dict "serverPort" $serverPort "leaderElectionPort" $leaderElectionPort "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset-non-persistent" (include "metadata-store.name" $)) "context" $)) -}}
    {{- $_ := set $addresses (toString $serverCount) $address }}
    {{- $serverCount = (add $serverCount 1) -}}
    {{- $i = (add $i 1) -}}
  {{- end -}}

  {{- $addresses | toJson -}}
{{- end -}}

{{/*
 Get a list of all meta data server addresses for client communications

 usage: {{ include "metadata-store.client-cluster-addresses" $ }}
 returns:
  [
    {pod-hostname}-0.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port},
    {pod-hostname}-1.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port},
    {pod-hostname}-2.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port}
    ...
  ]
 */}}
{{- define "metadata-store.client-cluster-addresses" -}}
  {{- $addresses := list -}}
  {{- $replicas := (default 0 (.Values.global.metadataStore.replicas | int)) -}}
  {{- $nonPersistentReplicas := (default 0 (.Values.global.metadataStore.nonPersistentReplicas | int)) -}}
  {{- $totalServers := add $replicas $nonPersistentReplicas -}}
  {{- $clientPort := (((eq (include "common.tls.require-secure-inter" .) "true") | ternary .Values.global.metadataStore.service.ports.clientTls .Values.global.metadataStore.service.ports.client ) | int) -}}

  {{- range $i := until $replicas -}}
    {{- $address := (include "metadata-store.client-instance-address" (dict "clientPort" $clientPort "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset" (include "metadata-store.name" $)) "context" $)) }}
    {{- $addresses = append $addresses $address }}
  {{- end -}}

  {{- $i := 0 }}
  {{- range $r := untilStep $replicas ($totalServers | int) 1 -}}
    {{- $address := (include "metadata-store.client-instance-address" (dict "clientPort" $clientPort "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset-non-persistent" (include "metadata-store.name" $)) "context" $)) -}}
    {{- $addresses = append $addresses $address }}
    {{- $i = (add $i 1) -}}
  {{- end -}}

  {{- ($addresses | toJson) -}}
{{- end -}}

{{/*
 Check the local chart value for enabling service monitor and check the parent charnt's global value. Also validate that a port has been set for metrics.

 usage: {{ (eq (include "metadata-store.metrics-enabled" $) "true") }}
 returns: "true|false"
*/}}
{{- define "metadata-store.metrics-enabled" -}}
  {{- $enabled := (or (eq .Values.metricsServiceMonitor true) (eq .Values.global.observability.serviceMonitors true)) -}}

  {{- if and $enabled (not (index .Values "config" "metricsProvider.httpPort")) -}}
    {{- fail "A value for .config.metricsProvider.httpPort is required when metrics are enabled" -}}
  {{- end -}}

  {{- $enabled -}}
{{- end -}}

{{/*
 Add specific zookeeper client TLS values

 usage: {{ include "metadata-store.zookeeper.client" $ }}
 returns: map
*/}}
{{- define "metadata-store.zookeeper.client" -}}
  {{- $clientConfig := list -}}

  {{- $clientConfig = append $clientConfig "-Dzookeeper.client.secure=true" -}}
  {{- $clientConfig = append $clientConfig "-Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty" -}}

  {{- $clientConfig = append $clientConfig "-Dzookeeper.ssl.trustStore.type=JKS" -}}
  {{- $clientConfig = append $clientConfig "-Dzookeeper.ssl.trustStore.location=/pulsar/jks/truststore.jks" -}}
  {{- $clientConfig = append $clientConfig "-Dzookeeper.ssl.trustStore.passwordPath=/pulsar/jks/jks-password" -}}

  {{- $clientConfig = append $clientConfig "-Dzookeeper.ssl.keyStore.type=JKS" -}}
  {{- $clientConfig = append $clientConfig "-Dzookeeper.ssl.keyStore.location=/pulsar/jks/keystore.jks" -}}
  {{- $clientConfig = append $clientConfig "-Dzookeeper.ssl.keyStore.passwordPath=/pulsar/jks/jks-password" -}}

  {{- $clientConfig | toJson -}}
{{- end -}}