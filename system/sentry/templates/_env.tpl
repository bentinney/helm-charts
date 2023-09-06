{{ define "env-vars" -}}
- name: SENTRY_DB_NAME
  value: {{ .Values.postgresql.postgresDatabase }}
- name: SENTRY_POSTGRES_HOST
  value: {{ template "postgresql.fullname" . }}
- name: SENTRY_REDIS_HOST
  value: {{ template "redis.fullname" . }}
- name: SENTRY_REDIS_PORT
  value: "6379"
- name: SENTRY_REDIS_PASSWORD
  valueFrom: { secretKeyRef: { name: {{ template "redis.fullname" . }}, key: redis-password } }
- name: SENTRY_SECRET_KEY
  valueFrom: { secretKeyRef: { name: {{ template "fullname" . }}, key: sentry-secret-key } }
- name: SENTRY_DB_PASSWORD
  valueFrom: { secretKeyRef: { name: {{ template "postgresql.fullname" . }}, key: postgres-password } }
{{- if .Values.emailHost }}
- name: SENTRY_EMAIL_HOST
  value: {{ .Values.emailHost | squote }}
{{- end }}
{{- if .Values.emailPort }}
- name: SENTRY_EMAIL_PORT
  value: {{ .Values.emailPort | squote }}
{{- end }}
{{- if .Values.emailUser }}
- name: SENTRY_EMAIL_USER
  value: {{ .Values.emailUser | squote }}
{{- end }}
{{- if .Values.emailPassword }}
- name: SENTRY_EMAIL_PASSWORD
  value: {{ .Values.emailPassword | squote }}
{{- end }}
{{- if .Values.emailUseSSL }}
- name: SENTRY_EMAIL_USE_SSL
  value: {{ .Values.emailUseSSL | squote }}
{{- end }}
{{- if .Values.emailUseTLS }}
- name: SENTRY_EMAIL_USE_TLS
  value: {{ .Values.emailUseTLS | squote }}
{{- end }}
{{- if .Values.serverEmail }}
- name: SENTRY_SERVER_EMAIL
  value: {{ .Values.serverEmail | squote }}
{{- end }}
{{- if .Values.singleOrganization }}
- name: SENTRY_SINGLE_ORGANIZATION
  value: {{ .Values.singleOrganization | squote}}
{{- end }}
{{- if .Values.githubAppId }}
- name: GITHUB_APP_ID
  value: {{ .Values.githubAppId | squote}}
{{- end }}
{{- if .Values.githubApiSecret }}
- name: GITHUB_API_SECRET
  valueFrom: { secretKeyRef: { name: {{ template "fullname" . }}, key: github-api-secret } }
{{- end }}
{{- if .Values.useSsl }}
- name: SENTRY_USE_SSL
  value: {{ .Values.useSsl | squote}}
{{- end }}
{{- range $key,$val := .Values.extraEnvVars }}
- name: {{ $key | squote }}
  value: {{ $val | squote }}
{{- end }}
{{ end }}
- name: SNUBA
  value: 'http://snuba-api:1218'
- name: SNUBA_SETTINGS
  value: docker
- name: CLICKHOUSE_HOST
  value: clickhouse
- name: CLICKHOUSE_PORT
  value: "9000"
- name: DEFAULT_BROKERS
  value: sentry-kafka:9092
{{- if .Values.geodata.path }}
- name: GEOIP_PATH_MMDB
  value: {{ .Values.geodata.path | quote }}
{{- end }}
- name: SENTRY_URL_PREFIX
  value: {{ .Values.sentryURL | squote }}
- name: RELAY_PORT
  value: "3000"
- name: REDIS_HOST
  value: {{ template "redis.fullname" . }}
- name: REDIS_PORT
  value: "6379"
- name: REDIS_PASSWORD
  valueFrom: { secretKeyRef: { name: {{ template "redis.fullname" . }}, key: redis-password } }
{{ end }}
