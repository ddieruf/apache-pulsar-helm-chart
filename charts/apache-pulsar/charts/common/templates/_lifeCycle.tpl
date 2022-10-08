{{/* vim: set filetype=mustache: */}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "common.affinities.pods.soft" (dict "component" "FOO" "name" "BAR" "extraMatchLabels" .Values.extraMatchLabels "context" $) -}}
*/}}
{{- define "common.lifeCycle.meta-data-store-ready" -}}
- name: wait-for-all-meta-data-pods
  image: {{ .Values.metaDataStore.image.repository }}:{{ .Values.metaDataStore.image.tag }}
  imagePullPolicy: {{ .Values.metaDataStore.image.pullPolicy }}
  command: ["/bin/bash"]
  args:
    - "-c"
    - "until [[(\"$(echo ruok | nc meta-data-store-statefulset-0.meta-data-store-headless.pulsar.svc.cluster.local 2181)\" == \"imok\")]]; do sleep 3; done;"
{{- end -}}