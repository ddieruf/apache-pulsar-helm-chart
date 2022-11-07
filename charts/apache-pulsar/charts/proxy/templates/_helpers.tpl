{{/*
Expand the name of the proxy chart.
*/}}
{{- define "proxy.name" -}}
  {{- .Values.global.proxy.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified proxy name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "proxy.fullname" -}}
  {{- if .Values.global.proxy.fullnameOverride -}}
    {{- .Values.global.proxy.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default "proxy" .Values.global.proxy.nameOverride -}}
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
{{- define "proxy.fullname.namespace" -}}
  {{- printf "%s-%s" (include "proxy.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "proxy.serviceAccountName" -}}
  {{- coalesce .Values.serviceAccount.name (include "proxy.name" .) -}}
{{- end -}}

{{/*
Return the proper Storage Class
*/}}
{{- define "proxy.logPersistence.storageClass" -}}
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

{{/* Proxy web scheme */}}
{{- define "proxy.webScheme" -}}
  {{- if eq (include "common.tls.require-secure-edge" .) "true" -}}
    {{- print "https" -}}
  {{- else -}}
    {{- print "http" -}}
  {{- end -}}
{{- end -}}

{{/* Proxy binary scheme */}}
{{- define "proxy.binaryScheme" -}}
  {{- if eq (include "common.tls.require-secure-edge" .) "true" -}}
    {{- print "pulsar+ssl" -}}
  {{- else -}}
    {{- print "pulsar" -}}
  {{- end -}}
{{- end -}}

{{/* Proxy web port */}}
{{- define "proxy.webPort" -}}
  {{- if eq (include "common.tls.require-secure-edge" .) "true" -}}
    {{- .Values.global.proxy.service.ports.https -}}
  {{- else -}}
    {{- .Values.global.proxy.service.ports.http -}}
  {{- end -}}
{{- end -}}

{{/* Proxy binary port */}}
{{- define "proxy.binaryPort" -}}
  {{- if eq (include "common.tls.require-secure-edge" .) "true" -}}
    {{- .Values.global.broker.service.ports.pulsarSsl -}}
  {{- else -}}
    {{- .Values.global.broker.service.ports.pulsar -}}
  {{- end -}}
{{- end -}}

{/* Proxy web address */}}
{{- define "proxy.webAddress" -}}
  {{- printf "%s://%s.%s.svc.%s:%d"
                        (include "proxy.webScheme" .)
                        (printf "%s-service" (include "proxy.name" .))
                        (include "common.names.namespace" .)
                        (include "common.names.domain" .)
                        (include "proxy.webPort" . | int)  -}}
{{- end -}}

{{/* Proxy binary address */}}
{{- define "proxy.binaryAddress" -}}
  {{- if .Values.global.proxy.dnsName -}}
    {{- printf "%s://%s:%d"
                        (include "proxy.binaryScheme" .)
                        .Values.global.proxy.dnsName
                        (include "proxy.binaryPort" . | int)  -}}
  {{- else -}}
    {{- printf "%s://%s.%s.svc.%s:%d"
                        (include "proxy.binaryScheme" .)
                        (printf "%s-service" (include "proxy.name" .))
                        (include "common.names.namespace" .)
                        (include "common.names.domain" .)
                        (include "proxy.binaryPort" . | int)  -}}
  {{- end -}}
{{- end -}}

{{/*
 Check the local chart value for enabling service monitor and check the parent chart's global value. Also validate that a port has been set for metrics.

 usage: {{ (eq (include "proxy.metrics-enabled" $) "true") }}
 returns: "true|false"
*/}}
{{- define "proxy.metrics-enabled" -}}
  {{- $enabled := (or (eq .Values.metricsServiceMonitor true) (eq .Values.global.observability.serviceMonitors true)) -}}
  {{- $enabled -}}
{{- end -}}