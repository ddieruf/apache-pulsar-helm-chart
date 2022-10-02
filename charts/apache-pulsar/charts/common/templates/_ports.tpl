{{/* vim: set filetype=mustache: */}}

{{/*
Determine by the port name if it is meant to be secure

{{ include "common.ports.isSecurePort" (dict "portName" "http" "context" $) }}
*/}}
{{- define "common.ports.isSecurePort" -}}
  {{- if or (eq .portName "https") (contains "ssl" (lower .portName)) (contains "tls" (lower .portName)) -}}
    {{- true -}}
  {{- else -}}
    {{- false -}}
  {{- end -}}
{{- end -}}

{{/*
Filter container ports for either secure only or non-secure only

{{ include "common.ports.containerPorts" (dict "secureOnly" true "ports" .Values.containerPorts "context" $) }}
*/}}
{{- define "common.ports.containerPorts" -}}
  {{- $containerPorts := dict -}}

  {{- range $key, $val := .ports -}}
    {{- $isSecurePort := (eq (include "common.ports.isSecurePort" (dict "portName" $key "context" $.context)) "true") -}}

    {{- if or (and $.secureOnly $isSecurePort) (and (not $.secureOnly) (not $isSecurePort)) -}}
      {{- $_ := set $containerPorts $key $val -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $containerPorts)) -}}
ports:
    {{- range $key, $val := $containerPorts }}
  - name: "{{ $key }}"
    containerPort: {{ $val }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{/*
Filter container ports for either secure only or non-secure only

{{ include "common.ports.servicePorts" (dict "secureOnly" true "serviceValues" .Values.service "context" $) }}
*/}}
{{- define "common.ports.servicePorts" -}}
ports:
  {{- range $key, $val := $.serviceValues.ports }}
    {{- $isSecurePort := (eq (include "common.ports.isSecurePort" (dict "portName" $key "context" $.context)) "true") -}}

    {{- if or (and $.secureOnly $isSecurePort) (and (not $.secureOnly) (not $isSecurePort)) }}
  - name: "{{ $key }}"
    port: {{ $val }}
    targetPort: "{{ $key }}"
    protocol: TCP
    {{- if $.serviceValues.type }}
        {{- if (and (or (eq $.serviceValues.type "NodePort") (eq $.serviceValues.type "LoadBalancer")) (index $.serviceValues.nodePorts $key)) }}
    nodePort: {{ index $.serviceValues.nodePorts $key }}
        {{- else if eq $.serviceValues.type "ClusterIP" }}
    nodePort: null
        {{- end }}
    {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}