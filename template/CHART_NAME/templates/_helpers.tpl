{{/*
Expand the name of the %%CHART_NAME%% chart.
*/}}
{{- define "%%CHART_NAME%%.name" -}}
  {{- default "%%CHART_NAME%%" .Values.global.%%CHART_NODE_NAME%%.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified %%CHART_NAME%% name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "%%CHART_NAME%%.fullname" -}}
  {{- if .Values.global.%%CHART_NODE_NAME%%.fullnameOverride -}}
    {{- .Values.global.%%CHART_NODE_NAME%%.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default "%%CHART_NAME%%" .Values.global.%%CHART_NODE_NAME%%.nameOverride -}}
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
{{- define "%%CHART_NAME%%.fullname.namespace" -}}
  {{- printf "%s-%s" (include "%%CHART_NAME%%.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "%%CHART_NAME%%.serviceAccountName" -}}
  {{- coalesce .Values.serviceAccount.name (include "%%CHART_NAME%%.name" .) -}}
{{- end -}}

{{/*
Return the proper Storage Class
*/}}
{{- define "%%CHART_NAME%%.logPersistence.storageClass" -}}
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
{{- define "%%CHART_NAME%%.persistence.oneDisk.storageClass" -}}
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

{{- define "%%CHART_NAME%%.persistence.journal.storageClass" -}}
  {{- if .Values.global.storageClass -}}
      {{- if (eq "-" .Values.global.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
      {{- else -}}
          {{- printf "storageClassName: %s" .Values.global.storageClass -}}
      {{- end -}}
  {{- else -}}
    {{- if (eq (.Values.persistence.journal.storageClass | typeOf) "map[string]interface {}") -}}
      {{- printf "storageClassName: %s" (printf "%s-journal" (include "%%CHART_NAME%%.name" $)) -}}
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

{{- define "%%CHART_NAME%%.persistence.ledgers.storageClass" -}}
  {{- if .Values.global.storageClass -}}
      {{- if (eq "-" .Values.global.storageClass) -}}
          {{- printf "storageClassName: \"\"" -}}
      {{- else -}}
          {{- printf "storageClassName: %s" .Values.global.storageClass -}}
      {{- end -}}
  {{- else -}}
    {{- if (eq (.Values.persistence.ledgers.storageClass | typeOf) "map[string]interface {}") -}}
      {{- printf "storageClassName: %s" (printf "%s-ledgers" (include "%%CHART_NAME%%.name" $)) -}}
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

{{- define "%%CHART_NAME%%.persistence.ranges.storageClass" -}}
{{- if .Values.global.storageClass -}}
    {{- if (eq "-" .Values.global.storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
    {{- else -}}
      {{- printf "storageClassName: %s" .Values.global.storageClass -}}
    {{- end -}}
{{- else -}}
    {{- if (eq (.Values.persistence.ranges.storageClass | typeOf) "map[string]interface {}") -}}
      {{- printf "storageClassName: %s" (printf "%s-ranges" (include "%%CHART_NAME%%.name" $)) -}}
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