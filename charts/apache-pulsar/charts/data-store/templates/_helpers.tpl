{{/*
Expand the name of the data store chart.
*/}}
{{- define "data-store.name" -}}
  {{- default "data-store" .Values.global.dataStore.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified data store name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "data-store.fullname" -}}
  {{- if .Values.global.dataStore.fullnameOverride -}}
    {{- .Values.global.dataStore.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default "data-store" .Values.global.dataStore.nameOverride -}}
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
{{- define "data-store.fullname.namespace" -}}
  {{- printf "%s-%s" (include "data-store.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "data-store.serviceAccountName" -}}
  {{- coalesce .Values.serviceAccount.name (include "data-store.name" .) -}}
{{- end -}}

{{/*
Return the proper Storage Class
*/}}
{{- define "data-store.logPersistence.storageClass" -}}
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
{{- define "data-store.persistence.oneDisk.storageClass" -}}
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
        {{- if .Values.persistence.oneDisk.storageClass -}}
              {{- if (eq "-" .Values.persistence.oneDisk.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else -}}
                  {{- printf "storageClassName: %s" .Values.persistence.oneDisk.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.persistence.oneDisk.storageClass -}}
        {{- if (eq "-" .Values.persistence.oneDisk.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else -}}
            {{- printf "storageClassName: %s" .Values.persistence.oneDisk.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "data-store.persistence.journal.storageClass" -}}
  {{- if .Values.global.storageClass -}}
      {{- if (eq "-" .Values.global.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
      {{- else -}}
          {{- printf "storageClassName: %s" .Values.global.storageClass -}}
      {{- end -}}
  {{- else -}}
    {{- if (eq (.Values.persistence.journal.storageClass | typeOf) "map[string]interface {}") -}}
      {{- printf "storageClassName: %s" (printf "%s-journal" (include "data-store.name" $)) -}}
    {{- else -}}
      {{- if .Values.persistence.journal.storageClass -}}
            {{- if (eq "-" .Values.persistence.journal.storageClass) -}}
                {{- printf "storageClassName: \"\"" -}}
            {{- else -}}
                {{- printf "storageClassName: %s" .Values.persistence.journal.storageClass -}}
            {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "data-store.persistence.ledgers.storageClass" -}}
  {{- if .Values.global.storageClass -}}
      {{- if (eq "-" .Values.global.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
      {{- else -}}
          {{- printf "storageClassName: %s" .Values.global.storageClass -}}
      {{- end -}}
  {{- else -}}
    {{- if (eq (.Values.persistence.ledgers.storageClass | typeOf) "map[string]interface {}") -}}
      {{- printf "storageClassName: %s" (printf "%s-ledgers" (include "data-store.name" $)) -}}
    {{- else -}}
      {{- if .Values.persistence.ledgers.storageClass -}}
        {{- if (eq "-" .Values.persistence.ledgers.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else -}}
            {{- printf "storageClassName: %s" .Values.persistence.ledgers.storageClass -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "data-store.persistence.ranges.storageClass" -}}
{{- if .Values.global.storageClass -}}
    {{- if (eq "-" .Values.global.storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
    {{- else -}}
      {{- printf "storageClassName: %s" .Values.global.storageClass -}}
    {{- end -}}
{{- else -}}
    {{- if (eq (.Values.persistence.ranges.storageClass | typeOf) "map[string]interface {}") -}}
      {{- printf "storageClassName: %s" (printf "%s-ranges" (include "data-store.name" $)) -}}
    {{- else -}}
      {{- if .Values.persistence.ranges.storageClass -}}
        {{- if (eq "-" .Values.persistence.ranges.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
        {{- else -}}
          {{- printf "storageClassName: %s" .Values.persistence.ranges.storageClass -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}