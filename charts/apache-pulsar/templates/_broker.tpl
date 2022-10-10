{{/* vim: set filetype=mustache: */}}

{{- define "broker.web-cluster-addresses" -}}
  {{- list "broker-0:8080" "broker-1:8080" -}}
{{- end -}}

{{- define "broker.binary-cluster-addresses" -}}
  {{- list "broker-0:6650" "broker-1:6650" -}}
{{- end -}}