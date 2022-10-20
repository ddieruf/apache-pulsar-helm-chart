{{/* vim: set filetype=mustache: */}}

{{/*
A container that waits for all pods within the meta-data-store component to have status ready
NOTE: this does not indicate the meta-data-store is completely running, onlt that it's pods are running

example: {{ include "common.lifeCycle.meta-data-store-statefulset-running" $ }}
*/}}
{{- define "common.lifeCycle.meta-data-store-statefulset-running" -}}
- name: meta-data-store-statefulset-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
{{/*  env:*/}}
{{/*    - name: WAIT_TIME*/}}
{{/*      value: "20"*/}}
{{/*    - name: DEBUG*/}}
{{/*      value: "1"*/}}
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=meta-data-store" | quote }}
{{- end -}}

{{- define "common.lifeCycle.meta-data-store-running" -}}
- name: meta-data-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "job"
    - {{ printf "%s-initialize-cluster-meta-data" (include "meta-data-store.name" $) | quote }}
{{- end -}}

{{- define "common.lifeCycle.data-store-running" -}}
- name: data-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=data-store" | quote }}
{{- end -}}

{{- define "common.lifeCycle.data-store-cluster-initialized" -}}
- name: data-store-cluster-initialized
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "job"
    - {{ printf "%s-init-new-cluster" (include "data-store.name" $) | quote }}
{{- end -}}

{{- define "common.lifeCycle.storage-running" -}}
- name: storage-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "job"
    - "stage.1-storage-running"
{{- end -}}

{{- define "common.lifeCycle.cluster-running" -}}
- name: storage-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "job"
    - "-lapp.kubernetes.io/component=life-cycle"
{{- end -}}

{{- define "common.lifeCycle.broker-running" -}}
- name: data-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=broker" | quote }}
{{- end -}}