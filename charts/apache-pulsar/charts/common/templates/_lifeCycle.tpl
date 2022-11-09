{{/* vim: set filetype=mustache: */}}

{{/*
A container that waits for all pods within the metadata-store component to have status ready
NOTE: this does not indicate the metadata-store is completely running, onlt that it's pods are running

example: {{ include "common.lifeCycle.metadata-store-statefulset-running" $ }}
*/}}
{{- define "common.lifeCycle.metadata-store-statefulset-running" -}}
- name: metadata-store-statefulset-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
{{/*  env:*/}}
{{/*    - name: WAIT_TIME*/}}
{{/*      value: "20"*/}}
{{/*    - name: DEBUG*/}}
{{/*      value: "1"*/}}
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=metadata-store" | quote }}
{{- end -}}

{{- define "common.lifeCycle.metadata-store-running" -}}
- name: metadata-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "job"
    - {{ printf "%s-initialize-cluster-metadata" (include "metadata-store.name" $) | quote }}
{{- end -}}

{{- define "common.lifeCycle.data-store-running" -}}
- name: data-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=data-store" | quote }}
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

{{- define "common.lifeCycle.broker-statefulset-running" -}}
- name: metadata-store-statefulset-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=broker" | quote }}
{{- end -}}

{{- define "common.lifeCycle.broker-running" -}}
- name: data-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=broker" | quote }}
{{- end -}}

{{- define "common.lifeCycle.proxy-running" -}}
- name: proxy-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  args:
    - "pod"
    - {{ printf "-lapp.kubernetes.io/component=proxy" | quote }}
{{- end -}}