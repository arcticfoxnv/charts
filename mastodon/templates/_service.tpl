{{ define "services.service" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ template "fullname" . }}
{{- if .Values.service.annotations }}
  annotations:
{{ toYaml .Values.service.annotations | indent 4 }}
{{- end }}
  labels:
    app: {{ template "appname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.externalPort }}
    targetPort: {{ .Values.service.internalPort }}
    protocol: TCP
    name: {{ .Values.service.name }}
  selector:
    app: {{ template "appname" . }}
    tier: "{{ .Values.application.tier }}"
{{ end }}