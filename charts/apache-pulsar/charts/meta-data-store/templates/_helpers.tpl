{{/*
Expand the name of the meta data store chart.
*/}}
{{- define "meta-data-store.name" -}}
  {{- default "meta-data-store" .Values.global.metaDataStore.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified meta data store name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "meta-data-store.fullname" -}}
  {{- if .Values.global.metaDataStore.fullnameOverride -}}
    {{- .Values.global.metaDataStore.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default "meta-data-store" .Values.global.metaDataStore.nameOverride -}}
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
{{- define "meta-data-store.fullname.namespace" -}}
  {{- printf "%s-%s" (include "meta-data-store.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "meta-data-store.serviceAccountName" -}}
  {{- coalesce .Values.serviceAccount.name (include "meta-data-store.name" .) -}}
{{- end -}}

{{/*
Return the proper log Storage Class
*/}}
{{- define "meta-data-store.logPersistence.storageClass" -}}
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
{{- define "meta-data-store.persistence.storageClass" -}}
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

 usage: {{ include "meta-data-store.quorum-instance-address" (dict "instanceIndex" 0 "instanceNamePrefix" "meta-data-store-statefulset" "context" $) }}
 */}}
{{- define "meta-data-store.quorum-instance-address" -}}
  {{- $instanceIndex := .instanceIndex -}}
  {{- $instanceNamePrefix := .instanceNamePrefix -}}
  {{- printf "%s-%d.%s.%s.svc.%s:%d:%d" $instanceNamePrefix
                                  $instanceIndex
                                  (printf "%s-headless" (include "meta-data-store.name" .context))
                                  (include "common.names.namespace" .context)
                                  .context.Values.global.clusterDomain
                                  (.context.Values.global.metaDataStore.service.ports.server | int)
                                  (.context.Values.global.metaDataStore.service.ports.leaderElection | int) -}}
{{- end -}}

{{/*
 Create the name of the headless service account to use in the format: {pod-hostname}.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port}
For more information about headless services with statefulsets and K8s DNS - https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id

 usage: {{ include "meta-data-store.client-instance-address" (dict "instanceIndex" 0 "instanceNamePrefix" "meta-data-store-statefulset" "context" $) }}

 Todo: ternary should be choosing the clientTls port but need to figure out proper communications with TLS
 */}}
{{- define "meta-data-store.client-instance-address" -}}
  {{- $instanceIndex := .instanceIndex -}}
  {{- $instanceNamePrefix := .instanceNamePrefix -}}
  {{- printf "%s-%d.%s.%s.svc.%s:%d" $instanceNamePrefix
                                  $instanceIndex
                                  (printf "%s-headless" (include "meta-data-store.name" .context))
                                  (include "common.names.namespace" .context)
                                  .context.Values.global.clusterDomain
                                  (((eq (include "common.tls.require-secure-inter" .context) "true") | ternary .context.Values.global.metaDataStore.service.ports.client .context.Values.global.metaDataStore.service.ports.client ) | int)
                                   -}}
{{- end -}}

{{/*
 Get a dict of all meta data server addresses for quorum (headless) communications

 usage: {{ include "meta-data-store.server-cluster-addresses" $ }}
 returns:
  {
    0: {pod-hostname}-0.{headless-service-name}.{namespace}.svc.{cluster-domain}:{server-port}:{leader-election-port},
    1: {pod-hostname}-1.{headless-service-name}.{namespace}.svc.{cluster-domain}:{server-port}:{leader-election-port},
    2: {pod-hostname}-2.{headless-service-name}.{namespace}.svc.{cluster-domain}:{server-port}:{leader-election-port}
    ...
  }
 */}}
{{- define "meta-data-store.quorum-cluster-addresses" -}}
  {{- $addresses := dict -}}
  {{- $replicas := (default 0 (.Values.global.metaDataStore.replicas | int)) -}}
  {{- $nonPersistentReplicas := (default 0 (.Values.global.metaDataStore.nonPersistentReplicas | int)) -}}
  {{- $totalServers := add $replicas $nonPersistentReplicas -}}

  {{- range $i := until $replicas -}}
    {{- $address := (include "meta-data-store.quorum-instance-address" (dict "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset" (include "meta-data-store.name" $)) "context" $)) }}
    {{- $_ := set $addresses (toString $i) $address }}
  {{- end -}}

  {{- $i := 0 }}
  {{- range $r := untilStep $replicas ($totalServers | int) 1 -}}
    {{- $address := (include "meta-data-store.quorum-instance-address" (dict "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset-non-persistent" (include "meta-data-store.name" $)) "context"
    $)) -}}
    {{- $_ := set $addresses (toString $r) $address }}
    {{- $i = (add $i 1) -}}
  {{- end -}}

  {{- $addresses | toJson -}}
{{- end -}}

{{/*
 Get a list of all meta data server addresses for client communications

 usage: {{ include "meta-data-store.client-cluster-addresses" $ }}
 returns:
  [
    {pod-hostname}-0.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port},
    {pod-hostname}-1.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port},
    {pod-hostname}-2.{headless-service-name}.{namespace}.svc.{cluster-domain}:{client-port}
    ...
  ]
 */}}
{{- define "meta-data-store.client-cluster-addresses" -}}
  {{- $addresses := list -}}
  {{- $replicas := (default 0 (.Values.global.metaDataStore.replicas | int)) -}}
  {{- $nonPersistentReplicas := (default 0 (.Values.global.metaDataStore.nonPersistentReplicas | int)) -}}
  {{- $totalServers := add $replicas $nonPersistentReplicas -}}

  {{- range $i := until $replicas -}}
    {{- $address := (include "meta-data-store.client-instance-address" (dict "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset" (include "meta-data-store.name" $)) "context" $)) }}
    {{- $addresses = append $addresses $address }}
  {{- end -}}

  {{- $i := 0 }}
  {{- range $r := untilStep $replicas ($totalServers | int) 1 -}}
    {{- $address := (include "meta-data-store.client-instance-address" (dict "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset-non-persistent" (include "meta-data-store.name" $)) "context" $)) -}}
    {{- $addresses = append $addresses $address }}
    {{- $i = (add $i 1) -}}
  {{- end -}}

  {{- ($addresses | toJson) -}}
{{- end -}}

