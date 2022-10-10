{{/* vim: set filetype=mustache: */}}

{{- define "common.lifeCycle.meta-data-store-running" -}}
- name: meta-data-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  env:
    - name: WAIT_TIME
      value: "20"
    - name: DEBUG
      value: "1"
  args:
    - "job"
    - "meta-data-store-running"
{{- end -}}

{{- define "common.lifeCycle.data-store-running" -}}
- name: data-store-running
  image: groundnuty/k8s-wait-for:latest
  imagePullPolicy: IfNotPresent
  env:
    - name: WAIT_TIME
      value: "20"
    - name: DEBUG
      value: "1"
  args:
    - "job"
    - "data-store-running"
{{- end -}}
