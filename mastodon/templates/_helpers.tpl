{{/* vim: set filetype=mustache: */}}

{{- define "tlsSecretName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-tls" .Release.Name $name -}}
{{- end -}}
