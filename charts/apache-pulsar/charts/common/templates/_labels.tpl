{{/* vim: set filetype=mustache: */}}
{{/*
Kubernetes standard labels

Use: {{ include "common.lables.standard" (dict "name" "" "context" $ ) }}
*/}}
{{- define "common.labels.standard" -}}
app.kubernetes.io/name: {{ .name | quote }}
helm.sh/chart: {{ (include "common.names.chart" .context)  | quote }}
app.kubernetes.io/instance: {{ .context.Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .context.Release.Service | quote }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector

Use: {{ include "common.lables.matchLabels" (dict "name" "" "context" $ ) }}
*/}}
{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ .name | quote }}
app.kubernetes.io/instance: {{ .context.Release.Name | quote }}
{{- end -}}