{{/* vim: set filetype=mustache: */}}

{{/*
Determine by the port name if it is meant to be secure

{{ include "common.ports.isSecurePort" (dict "portName" "http" "context" $) }}
*/}}
{{- define "common.ports.isSecurePort" -}}
  {{- if or (eq .portName "https") (contains "ssl" (lower .portName)) (contains "tls" (lower .portName)) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}
