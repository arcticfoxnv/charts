{{ define "services.deployment" }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "trackableappname" . }}
  annotations:
    linkerd.io/inject: enabled
    {{ if .Values.gitlab.app }}app.gitlab.com/app: {{ .Values.gitlab.app | quote }}{{ end }}
    {{ if .Values.gitlab.env }}app.gitlab.com/env: {{ .Values.gitlab.env | quote }}{{ end }}
  labels:
    app: {{ template "appname" . }}
    track: "{{ .Values.application.track }}"
    tier: "{{ .Values.application.tier }}"
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      annotations:
        linkerd.io/inject: enabled
        checksum/application-secrets: "{{ .Values.application.secretChecksum }}"
        {{ if .Values.gitlab.app }}app.gitlab.com/app: {{ .Values.gitlab.app | quote }}{{ end }}
        {{ if .Values.gitlab.env }}app.gitlab.com/env: {{ .Values.gitlab.env | quote }}{{ end }}
{{- if .Values.podAnnotations }}
{{ toYaml .Values.podAnnotations | indent 8 }}
{{- end }}
      labels:
        app: {{ template "appname" . }}
        track: "{{ .Values.application.track }}"
        tier: "{{ .Values.application.tier }}"
        release: {{ .Release.Name }}
    spec:
      imagePullSecrets:
{{ toYaml .Values.image.secrets | indent 10 }}
      containers:
      - name: {{ .serviceName }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        command:
          - /bin/herokuish
          - procfile
          - start
          - {{ .serviceName }}
        envFrom:
        - configMapRef:
            name: {{ .Release.Name }}-global-config
        {{- if .Values.application.secretName }}
        - secretRef:
            name: {{ .Values.application.secretName }}
        {{- end }}
        env:
        - name: DATABASE_URL
          value: {{ .Values.application.database_url | quote }}
        - name: GITLAB_ENVIRONMENT_NAME
          value: {{ .Values.gitlab.envName }}
        - name: GITLAB_ENVIRONMENT_URL
          value: {{ .Values.gitlab.envURL }}
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ .Release.Name }}-redis
              key: redis-password
{{- if ne .serviceName "worker" }}
        ports:
        - name: "{{ .Values.service.name }}"
          containerPort: {{ .Values.service.internalPort }}
        livenessProbe:
          httpGet:
            path: {{ .Values.livenessProbe.path }}
            port: {{ .Values.service.internalPort }}
            scheme: {{ .Values.livenessProbe.scheme }}
          initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
          timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
        readinessProbe:
          httpGet:
            path: {{ .Values.readinessProbe.path }}
            port: {{ .Values.service.internalPort }}
            scheme: {{ .Values.readinessProbe.scheme }}
          initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
          timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
{{- end }}
        resources:
{{ toYaml .Values.resources | indent 12 }}
{{ end }}
