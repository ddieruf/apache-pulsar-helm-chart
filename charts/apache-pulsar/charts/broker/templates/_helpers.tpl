{{/*
Expand the name of the broker chart.
*/}}
{{- define "broker.name" -}}
  {{- .Values.global.broker.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified broker name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "broker.fullname" -}}
  {{- if .Values.global.broker.fullnameOverride -}}
    {{- .Values.global.broker.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default "broker" .Values.global.broker.nameOverride -}}
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
{{- define "broker.fullname.namespace" -}}
  {{- printf "%s-%s" (include "broker.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "broker.serviceAccountName" -}}
  {{- coalesce .Values.serviceAccount.name (include "broker.name" .) -}}
{{- end -}}

{{/*
Return the proper Storage Class
*/}}
{{- define "broker.logPersistence.storageClass" -}}
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

{{/* Broker web scheme */}}
{{- define "broker.webScheme" -}}
  {{- ((eq (include "common.tls.require-secure-inter" .) "true") | ternary (print "https") (print "http") ) -}}
{{- end -}}

{{/* Broker binary scheme */}}
{{- define "broker.binaryScheme" -}}
  {{- ((eq (include "common.tls.require-secure-inter" .) "true") | ternary (print "pulsar+ssl") (print "pulsar") ) -}}
{{- end -}}

{{/* Broker web port */}}
{{- define "broker.webPort" -}}
  {{- ((eq (include "common.tls.require-secure-inter" .) "true") | ternary .Values.global.broker.service.ports.https .Values.global.broker.service.ports.http ) -}}
{{- end -}}

{{/* Broker binary port */}}
{{- define "broker.binaryPort" -}}
  {{- ((eq (include "common.tls.require-secure-inter" .) "true") | ternary .Values.global.broker.service.ports.pulsarSsl .Values.global.broker.service.ports.pulsar ) -}}
{{- end -}}

{{/* Broker web address */}}
{{- define "broker.webAddress" -}}
  {{- printf "%s://%s.%s.svc.%s:%d"
                        (include "broker.webScheme" .)
                        (printf "%s-service-headless" (include "broker.name" .))
                        (include "common.names.namespace" .)
                        (include "common.names.domain" .)
                        (include "broker.webPort" . | int)  -}}
{{- end -}}

{{/* Broker binary address */}}
{{- define "broker.binaryAddress" -}}
  {{- printf "%s://%s.%s.svc.%s:%d"
                        (include "broker.binaryScheme" .)
                        (printf "%s-service-headless" (include "broker.name" .))
                        (include "common.names.namespace" .)
                        (include "common.names.domain" .)
                        (include "broker.binaryPort" . | int)  -}}
{{- end -}}

{{/*
 Check the local chart value for enabling service monitor and check the parent charnt's global value. Also validate that a port has been set for metrics.

 usage: {{ (eq (include "broker.metrics-enabled" $) "true") }}
 returns: "true|false"
*/}}
{{- define "broker.metrics-enabled" -}}
  {{- $enabled := (or (eq .Values.metricsServiceMonitor true) (eq .Values.global.observability.serviceMonitors true)) -}}
  {{- $enabled -}}
{{- end -}}