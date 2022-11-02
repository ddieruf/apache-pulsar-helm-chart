{{/* vim: set filetype=mustache: */}}

{{/*
Only allow secure things

Usage:
{{ include "common.tls.require-secure-edge" }}

*/}}
{{- define "common.tls.require-secure-edge" -}}
  {{- default false .Values.global.secureClusterEdge -}}
{{- end -}}

{{/*
Only allow secure things

Usage:
{{ include "common.tls.require-secure-inter" }}

*/}}
{{- define "common.tls.require-secure-inter" -}}
  {{- default false .Values.global.interComponentTls.enabled -}}
{{- end -}}

{{/*
The certs volume mount

Usage:
{{ include "common.tls.volumeMounts.certs" . }}

*/}}
{{- define "common.tls.volumeMounts.certs" -}}
  {{- (dict "name" "certs" "readOnly" true "mountPath" "/pulsar/certs") | toJson -}}
{{- end -}}

{{/*
The jks volume mount

Usage:
{{ include "common.tls.volumeMounts.jks" . }}

*/}}
{{- define "common.tls.volumeMounts.jks" -}}
  {{- (dict "name" "jks" "readOnly" true "mountPath" "/pulsar/jks") | toJson -}}
{{- end -}}

{{/*
Get the needed volumes for TLS certificate

Usage:
{{ include "common.tls.volumes.certs" (dict "tlsSecretName" "component-name-tls" "context" $) .}}

Params:
  - tlsSecretName - String - Required - Name of the TLS secret where the certificate is stored.
*/}}
{{- define "common.tls.volumes.certs" -}}
  {{- $tlsSecretName := .tlsSecretName -}}

  {{- if not $tlsSecretName -}}
    {{- fail "Provide tlsSecretName when using common.tls.volumes.certs" -}}
  {{- end -}}

  {{- (dict "name" "certs" "secret" (dict "secretName" $tlsSecretName "items" (list (dict "key" "ca.crt" "path" "ca.crt") (dict "key" "tls.key" "path" "tls.key") (dict "key" "tls.crt" "path" "tls.crt")))) | toJson -}}
{{- end -}}

{{/*
Get the needed volumes for jks store

Usage:
{{ include "common.tls.volumes.jks-store" (dict "tlsSecretName" "meta-data-store-tls" "context" $) | fromJson }}

Params:
  - volumeName - String - Required - The nanme of the volume
  - tlsSecretName - String - Required - The name of the TLS secret with the jks stores
  - jksPasswordSecretName - String - Optional - The name of the secret object with the jks password that will be attached to disk
  - context - Context - Required - Parent context.
*/}}
{{- define "common.tls.volumes.jks-store" -}}
  {{- $tlsSecretName := .tlsSecretName -}}

  {{- if not $tlsSecretName -}}
    {{- fail "Provide tlsSecretName when using common.tls.volumes.jks-store" -}}
  {{- end -}}
  {{- $stores := (dict "secret" (dict "name" $tlsSecretName "items" (list (dict "key" "truststore.jks" "path" "truststore.jks") (dict "key" "keystore.jks" "path" "keystore.jks")))) -}}

  {{- if not .jksPasswordSecretName -}}
    {{- (dict "name" "jks" "projected" (dict "sources" (list $stores))) | toJson -}}
  {{- else -}}
    {{- $jksPasswordSecretName := .jksPasswordSecretName -}}
    {{- $jksPassword := (dict "secret" (dict "name" $jksPasswordSecretName "items" (list (dict "key" "jks-password" "path" "jks-password")))) -}}
    {{- (dict "name" "jks" "projected" (dict "sources" (list $stores $jksPassword))) | toJson -}}
  {{- end -}}
{{- end -}}
