SET character_set_server = '{{ .Values.character_set_server }}';
SET collation_server = '{{ .Values.collation_server }}';
{{- $dbs := coalesce .Values.databases (list .Values.name) }}
{{- range $dbs }}
CREATE DATABASE IF NOT EXISTS {{ . }};
{{- end }}

{{- if and .Values.global.dbUser .Values.global.dbPassword (not (hasKey .Values.users (default "" .Values.global.dbUser))) (not .Values.custom_initdb_configmap) }}
CREATE USER IF NOT EXISTS {{ .Values.global.dbUser }};
GRANT ALL PRIVILEGES ON {{ .Values.name }}.* TO {{ .Values.global.dbUser }} IDENTIFIED BY '{{ include "db_password" . }}';
{{- end }}

{{- range $username, $values := .Values.users }}
    {{- $username := default $username $values.name }}
    {{- if not $values.password }}
-- Skipping user {{ $username }} without password
    {{- else }}
CREATE USER IF NOT EXISTS '{{ $username }}';
ALTER USER '{{ $username }}' IDENTIFIED BY '{{ $values.password }}'
{{- if $values.limits }}
  WITH
{{- range $k, $v := $values.limits }}
    {{ $k | upper }} {{ $v }}
{{- end }}
{{- end }};
        {{- range $values.grants }}
GRANT {{ . }} TO '{{ $username }}';
        {{- end }}
    {{- end }}
{{- end }}
