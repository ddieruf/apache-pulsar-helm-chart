{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common.names.name" -}}
  {{- fail "This value is not available, use the specific component's naming" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.names.fullname" -}}
  {{- fail "This value is not available, use the specific component's naming" -}}
{{- end -}}

{{/*
Create a fully qualified app name adding the installation's namespace.
*/}}
{{- define "common.names.fullname.namespace" -}}
  {{- fail "This value is not available, use the specific component's naming" -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "common.names.namespace" -}}
{{- if .Values.global.namespaceOverride -}}
{{- .Values.global.namespaceOverride -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Allow the release domain to be overridden
*/}}
{{- define "common.names.domain" -}}
{{- if .Values.global.clusterDomain -}}
{{- .Values.global.clusterDomain -}}
{{- else -}}
{{- "cluster.local" -}}
{{- end -}}
{{- end -}}
