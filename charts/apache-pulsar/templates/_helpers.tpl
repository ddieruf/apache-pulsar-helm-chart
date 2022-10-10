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
{{- define "data-store.config.zkServers" -}}
  {{- join "," ((include "meta-data-store.client-cluster-addresses" .) | fromJsonArray) -}}
{{- end -}}

{{- define "data-store.stateStoreEnabled" -}}
  {{ "false" }}
{{/*  {{- and (eq .Values.global.functionWorker.enabled true) (eq .Values.global.functionWorker.stateStorage.enabled true) -}}*/}}
{{- end -}}
