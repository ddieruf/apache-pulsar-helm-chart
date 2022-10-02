{{/*
Expand the name of the meta data store chart.
*/}}
{{- define "meta-data-store.name" -}}
  {{- default "meta-data-store" .Values.global.dataStore.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified meta data store name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "meta-data-store.fullname" -}}
  {{- if .Values.global.dataStore.fullnameOverride -}}
    {{- .Values.global.dataStore.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default "meta-data-store" .Values.global.dataStore.nameOverride -}}
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
  {{- printf "%s-service" (default (include "meta-data-store.fullname" .) .Values.serviceAccount.name) -}}
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
 Create the name of the service account to use

 usage: {{ include "meta-data-store.instance-address" (dict "instanceIndex" 0 "context" $) }}
 */}}
{{- define "meta-data-store.instance-address" -}}
  {{- $instanceIndex := .instanceIndex -}}
  {{- printf "%s-%d.%s.pod.%s:%d" (include "meta-data-store.name" .context)
                                  $instanceIndex
                                  (include "common.names.namespace" .context)
                                  .context.Values.global.clusterDomain
                                  (.context.Values.global.metaDataStore.service.ports.server | int) -}}
{{- end -}}

{{/*
 usage: {{ include "meta-data-store.cluster-addresses" $ }}
 */}}
{{- define "meta-data-store.cluster-addresses" -}}
  {{- $adresses := list -}}
  {{- $replicas := (default 0 (.Values.global.metaDataStore.replicas | int)) -}}
  {{- $nonPersistentReplicas := (default 0 (.Values.global.metaDataStore.nonPersistentReplicas | int)) -}}
  {{- $totalServers := add $replicas $nonPersistentReplicas -}}

  {{- range $i := untilStep 0 $replicas 1 -}}
    {{- $adresses = append $adresses (include "meta-data-store.instance-address" (dict "instanceIndex" $i "context" $)) -}}
  {{- end -}}

  {{- range $r := untilStep $replicas (sub $totalServers 1 | int) 1 -}}
    {{- $adresses = append $adresses (include "meta-data-store.instance-address" (dict "instanceIndex" $r "context" $)) -}}
  {{- end -}}

  {{- join "," $adresses -}}
{{- end -}}
