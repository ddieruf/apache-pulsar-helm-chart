{{/*
Expand the name of the broker chart.
*/}}
{{- define "broker.name" -}}
  {{- default "broker" .Values.global.broker.nameOverride | trunc 63 | trimSuffix "-" -}}
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

{{- define "broker.isAtEdge" -}}
  {{/*  (eq .Values.global.proxy.enabled false)*/}}
  {{- "true" -}}
{{- end -}}

{{/*
Decide if the broker should require secure communications.

The decision tree is:
Is the proxy enabled (which makes the broker an internal component)
  N - Evaluate common.tls.require-secure-edge
  Y - Evaluate common.tls.require-secure-inter

Usage: {{ include "broker.tls.require-secure" $ }}
*/}}
{{- define "broker.tls.require-secure" -}}
  {{- (or
          (and (eq (include "broker.isAtEdge" .) "true") (eq (include "common.tls.require-secure-edge" .) "true"))
          (eq (include "common.tls.require-secure-inter" .) "true")) -}}
{{- end -}}

{{/* Broker web scheme */}}
{{- define "broker.webScheme" -}}
  {{- ((eq (include "broker.tls.require-secure" .) "true") | ternary (print "https") (print "http") ) -}}
{{- end -}}

{{/* Broker binary scheme */}}
{{- define "broker.binaryScheme" -}}
  {{- ((eq (include "broker.tls.require-secure" .) "true") | ternary (print "pulsar+ssl") (print "pulsar") ) -}}
{{- end -}}

{{/* Broker web port */}}
{{- define "broker.webPort" -}}
  {{- ((eq (include "broker.tls.require-secure" .) "true") | ternary .Values.global.broker.service.ports.https .Values.global.broker.service.ports.http ) -}}
{{- end -}}

{{/* Broker binary port */}}
{{- define "broker.binaryPort" -}}
  {{- ((eq (include "broker.tls.require-secure" .) "true") | ternary .Values.global.broker.service.ports.pulsarSsl .Values.global.broker.service.ports.pulsar ) -}}
{{- end -}}

{{/*
 Create the name of the service account to use in the format: {pod-hostname}.{service-name}.{namespace}.svc.{cluster-domain}:{binary(Ssl)-port}
For more information about headless services with statefulsets and K8s DNS - https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id

 usage: {{ include "broker.binary-instance-address" (dict "instanceIndex" 0 "instanceNamePrefix" "broker-statefulset" "context" $) }}
 */}}
{{- define "broker.binary-instance-address" -}}
  {{- $instanceIndex := .instanceIndex -}}
  {{- $instanceNamePrefix := .instanceNamePrefix -}}
  {{- printf "%s-%d.%s.%s.svc.%s:%d" $instanceNamePrefix
                                  $instanceIndex
                                  (printf "%s-service" (include "broker.name" .context))
                                  (include "common.names.namespace" .context)
                                  .context.Values.global.clusterDomain
                                  (((eq (include "broker.tls.require-secure" .context) "true") | ternary .context.Values.global.broker.service.ports.pulsarSsl .context.Values.global.broker.service.ports.pulsar ) | int)
                                   -}}
{{- end -}}

{{/*
 Create the name of the service account to use in the format: {pod-hostname}.{service-name}.{namespace}.svc.{cluster-domain}:{http(s)-port}
For more information about headless services with statefulsets and K8s DNS - https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id

 usage: {{ include "broker.web-instance-address" (dict "instanceIndex" 0 "instanceNamePrefix" "broker-statefulset" "context" $) }}
 */}}
{{- define "broker.web-instance-address" -}}
  {{- $instanceIndex := .instanceIndex -}}
  {{- $instanceNamePrefix := .instanceNamePrefix -}}
  {{- printf "%s-%d.%s.%s.svc.%s:%d" $instanceNamePrefix
                                  $instanceIndex
                                  (printf "%s-service" (include "broker.name" .context))
                                  (include "common.names.namespace" .context)
                                  .context.Values.global.clusterDomain
                                  (((eq (include "broker.tls.require-secure" .context) "true") | ternary .context.Values.global.broker.service.ports.https .context.Values.global.broker.service.ports.http ) | int)
                                   -}}
{{- end -}}

{{/*
 Get a list of all broker server addresses for client communications

 usage: {{ include "broker.web-cluster-addresse" $ }}
 returns:
  [
    {pod-hostname}-0.{service-name}.{namespace}.svc.{cluster-domain}:{http(s)-port},
    {pod-hostname}-1.{service-name}.{namespace}.svc.{cluster-domain}:{http(s)-port},
    {pod-hostname}-2.{service-name}.{namespace}.svc.{cluster-domain}:{http(s)-port}
    ...
  ]
 */}}
{{- define "broker.web-cluster-addresses" -}}
  {{- $addresses := list -}}
  {{- $replicas := (default 0 (.Values.global.broker.replicas | int)) -}}

  {{- range $i := until $replicas -}}
    {{- $address := (include "broker.web-instance-address" (dict "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset" (include "broker.name" $)) "context" $)) }}
    {{- $addresses = append $addresses $address }}
  {{- end -}}

  {{- ($addresses | toJson) -}}
{{- end -}}

{{/*
 Get a list of all broker server addresses for binary communications

 usage: {{ include "broker.binary-cluster-addresse" $ }}
 returns:
  [
    {pod-hostname}-0.{service-name}.{namespace}.svc.{cluster-domain}:{binary(Ssl)-port},
    {pod-hostname}-1.{service-name}.{namespace}.svc.{cluster-domain}:{binary(Ssl)-port},
    {pod-hostname}-2.{service-name}.{namespace}.svc.{cluster-domain}:{binary(Ssl)-port}
    ...
  ]
 */}}
{{- define "broker.binary-cluster-addresses" -}}
  {{- $addresses := list -}}
  {{- $replicas := (default 0 (.Values.global.broker.replicas | int)) -}}

  {{- range $i := until $replicas -}}
    {{- $address := (include "broker.binary-instance-address" (dict "instanceIndex" $i "instanceNamePrefix" (printf "%s-statefulset" (include "broker.name" $)) "context" $)) }}
    {{- $addresses = append $addresses $address }}
  {{- end -}}

  {{- ($addresses | toJson) -}}
{{- end -}}
