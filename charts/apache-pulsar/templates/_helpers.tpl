{{/* vim: set filetype=mustache: */}}

{{/*
Build the cluster's name

usage: {{- include "cluster.name" $ -}}
*/}}
{{- define "cluster.name" -}}
  {{- if not .Values.global.pulsarCluster.name -}}
    {{- fail "A value for .pulsarCluster.name is required" -}}
  {{- end -}}

  {{- if regexMatch "[^a-zA-Z\\d-_]" .Values.global.pulsarCluster.name }}
    {{- fail "Cluster name can only contain numbers and letters. No spaces or special chars." -}}
  {{- end -}}

  {{- print .Values.global.pulsarCluster.name -}}
{{- end -}}


{{/* =========================================================
                DATA STORE OVERRIDABLES
==========================================================*/}}
{{- define "data-store.config.metadataServiceUri" -}}
  {{- join ";" ((include "metadata-store.client-cluster-addresses" .) | fromJsonArray) -}}
{{- end -}}

{{- define "data-store.stateStoreEnabled" -}}
  {{- "false" -}}
{{/*  and (eq .Values.global.functionWorker.enabled true) (eq .Values.global.functionWorker.stateStorage.enabled true) */}}
{{- end -}}

{{/* =========================================================
                BROKER OVERRIDABLES
==========================================================*/}}
{{- define "broker.config.bookkeeperMetadataServiceUri" -}}
  {{- printf "%s" (join ";" ((include "metadata-store.client-cluster-addresses" .) | fromJsonArray)) -}}
{{- end -}}
{{- define "broker.config.clusterName" -}}
  {{- (include "cluster.name" .) -}}
{{- end -}}
{{- define "broker.config.metadataStoreUrl" -}}
  {{- printf "%s" (join "," ((include "metadata-store.client-cluster-addresses" .) | fromJsonArray)) -}}
{{- end -}}
{{- define "broker.config.configurationMetadataStoreUrl" -}}
  {{- printf "%s" (join "," ((include "metadata-store.client-cluster-addresses" .) | fromJsonArray)) -}}
{{- end -}}
{{- define "broker.config.functionWorkerEnabled" -}}
  {{- "false" -}}
{{/*  {{- eq .Values.global.functionWorker.enabled true -}}*/}}
{{- end -}}

{{/* =========================================================
                PROXY OVERRIDABLES
==========================================================*/}}
{{- define "proxy.config.metadataStoreUrl" -}}
  {{- printf "%s" (join "," ((include "metadata-store.client-cluster-addresses" .) | fromJsonArray)) -}}
{{- end -}}
{{- define "proxy.config.brokerServiceURL" -}}
  {{- printf "%s" (include "broker.binaryAddress" .) -}}
{{- end -}}
{{- define "proxy.config.brokerServiceURLTLS" -}}
  {{- printf "%s" (include "broker.binaryAddress" .) -}}
{{- end -}}
{{- define "proxy.config.brokerWebServiceURL" -}}
  {{- printf "%s" (include "broker.webAddress" .) -}}
{{- end -}}
{{- define "proxy.config.brokerWebServiceURLTLS" -}}
  {{- printf "%s" (include "broker.webAddress" .) -}}
{{- end -}}
{{- define "proxy.config.clusterName" -}}
  {{- printf "%s" (include "cluster.name" .) -}}
{{- end -}}
{{- define "proxy.config.functionWorkerWebServiceURL" -}}
  {{- printf "%s" "" -}}
{{- end -}}
{{- define "proxy.config.functionWorkerWebServiceURLTLS" -}}
  {{- printf "%s" "" -}}
{{- end -}}


