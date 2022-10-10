{{/* vim: set filetype=mustache: */}}

{{/*
Build the cluster's name

usage: {{- include "cluster.name" $ -}}
*/}}
{{- define "cluster.name" -}}
  {{- print .Release.Name -}}
{{- end -}}
