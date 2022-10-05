
{{/*
Format a collection of yaml values into toml style

Usage: {{- include "common.formatting.formatConfigValues" (dict "configValues" .Values.config "context" $) -}}
*/}}
{{- define "common.formatting.toToml" -}}
  {{- $formattedValues := dict -}}
  {{- $configValues := .configValues -}}
  {{- range $key, $val := $configValues -}}
    {{- if or (eq (typeOf $val) "float64") (eq (typeOf $val) "int") }}
      {{- $_ := set $formattedValues $key (int $val | toString) -}}
    {{- else if (eq (typeOf $val) "string") }}
      {{- $_ := set $formattedValues $key ((toString $val) | replace "\"" "" | trim) -}}
    {{- else }}
      {{- $_ := set $formattedValues $key (toString $val) -}}
    {{- end }}
  {{- end -}}
{{- range $key,$val := $formattedValues }}
{{ printf "%s=%s" $key $val }}
{{- end }}
{{- end -}}