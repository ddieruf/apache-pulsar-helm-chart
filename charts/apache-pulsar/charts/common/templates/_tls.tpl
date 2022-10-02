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
The jksPassword volume mount

Usage:
{{ include "common.tls.volumeMounts.jksPassword" . }}

*/}}
{{- define "common.tls.volumeMounts.jksPassword" -}}
  {{- (dict "name" "jksPassword" "readOnly" true "mountPath" "/pulsar") | toJson -}}
{{- end -}}

{{/*
The jksStore volume mount

Usage:
{{ include "common.tls.volumeMounts.jksStore" . }}

*/}}
{{- define "common.tls.volumeMounts.jksStore" -}}
  {{- (dict "name" "jksStore" "readOnly" true "mountPath" "/pulsar") | toJson -}}
{{- end -}}

{{/*
Get the needed volumes for TLS certs

Usage:
{{ include "common.tls.volumes.certs" (dict "certificateSecretName" "component-name-tls" "context" $) .}}

Params:
  - certificateSecretName - String - Required - Name of the TLS secret where the certificate is stored.
*/}}
{{- define "common.tls.volumes.certs" -}}
  {{- $certificateSecretName := .certificateSecretName -}}

  {{- if not $certificateSecretName -}}
    {{- fail "Provide certificateSecretName when using common.certs.volume" -}}
  {{- end -}}

  {{- (dict "name" "certs" "secret" (dict "secretName" $certificateSecretName "items" (list (dict "key" "ca.crt" "path" "ca.crt") (dict "key" "key.crt" "path" "key.crt") (dict "key" "cer.crt"
  "path" "cer.crt")))) | toJson -}}
{{- end -}}

{{/*
Get the needed volumes for TLS jksStore

Usage:
{{ include "common.tls.volumes.jksStore" (dict "certificateSecretName" "component-name-tls" "context" $) .}}

Params:
  - certificateSecretName - String - Required - Name of the TLS secret where the certificate is stored.
  - context - Context - Required - Parent context.
*/}}
{{- define "common.tls.volumes.jksStore" -}}
  {{- $certificateSecretName := .certificateSecretName -}}

  {{- if not $certificateSecretName -}}
    {{- fail "Provide certificateSecretName when using common.certs.volume" -}}
  {{- end -}}

  {{- (dict "name" "jksStore" "secret" (dict "secretName" $certificateSecretName "items" (list (dict "key" "truststore.jks" "path" "truststore.jks") (dict "key" "keystore.jks" "path" "keystore.jks")))) | toJson -}}
{{- end -}}

{{/*
Get the needed volumes for jksPassword

Usage:
{{ include "common.tls.volumes.jksPassword" (dict "jksPasswordSecretName" "component-name-jks" "context" $) .}}

Params:
  - jksPasswordSecretName - String - Optional - If JKS is included (includeJks=true) then this is required. The name of the opaque secret used to create the JKS stores.
  - context - Context - Required - Parent context.

If including JKS the provided jksPasswordSecretName needs to have a data of "jks-password".

*/}}
{{- define "common.tls.volumes.jksPassword" -}}
  {{- $jksPassSecretName := .jksPasswordSecretName -}}

  {{- if not $jksPassSecretName -}}
    {{- fail "Provide jksPassSecretName when using common.tls.volumes.jksPassword" -}}
  {{- end -}}

  {{- (dict "name" "jksPassword" "secret" (dict "secretName" $jksPassSecretName "items" (list (dict "key" "jks-password" "path" "jks-password")))) | toJson -}}
{{- end -}}