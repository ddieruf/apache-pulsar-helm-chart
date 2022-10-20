{{/* vim: set filetype=mustache: */}}

{{/*
Build the cluster's name

usage: {{- include "cluster.name" $ -}}
*/}}
{{- define "cluster.name" -}}
  {{- print .Release.Name -}}
{{- end -}}


{{/* =========================================================
                DATA STORE OVERRIDABLES
==========================================================*/}}
{{- define "data-store.config.metadataServiceUri" -}}
  {{- join ";" ((include "meta-data-store.client-cluster-addresses" .) | fromJsonArray) -}}
{{- end -}}

{{- define "data-store.stateStoreEnabled" -}}
  {{- "false" -}}
{{/*  {{- and (eq .Values.global.functionWorker.enabled true) (eq .Values.global.functionWorker.stateStorage.enabled true) -}}*/}}
{{- end -}}

{{/* =========================================================
                BROKER OVERRIDABLES
==========================================================*/}}
{{- define "broker.config.bookkeeperMetadataServiceUri" -}}
  {{- printf "zk+hierarchical://%s" (join ";" ((include "meta-data-store.client-cluster-addresses" .) | fromJsonArray)) -}}
{{- end -}}
{{- define "broker.config.clusterName" -}}
  {{- (include "cluster.name" .) -}}
{{- end -}}
{{- define "broker.config.metadataStoreUrl" -}}
  {{- printf "%s" (join "," ((include "meta-data-store.client-cluster-addresses" .) | fromJsonArray)) -}}
{{- end -}}
{{- define "broker.config.configurationMetadataStoreUrl" -}}
  {{- printf "%s" (join "," ((include "meta-data-store.client-cluster-addresses" .) | fromJsonArray)) -}}
{{- end -}}
{{- define "broker.config.functionWorkerEnabled" -}}
  {{- "false" -}}
{{/*  {{- eq .Values.global.functionWorker.enabled true -}}*/}}
{{- end -}}
