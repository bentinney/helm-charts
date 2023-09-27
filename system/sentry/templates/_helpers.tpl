{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 24 -}}
{{- end -}}

{{- define "postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 24 -}}
{{- end -}}

{{- define "redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 24 -}}
{{- end -}}

{{- define "sentry.kafka.fullname" -}}
{{- printf "%s-%s" .Release.Name "kafka" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set Kafka Confluent host
*/}}
{{- define "sentry.kafka.host" -}}
{{- if .Values.kafka.enabled -}}
{{- template "sentry.kafka.fullname" . -}}
{{- else if and (.Values.externalKafka) (not (kindIs "slice" .Values.externalKafka)) -}}
{{ required "A valid .Values.externalKafka.host is required" .Values.externalKafka.host }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka Confluent port
*/}}
{{- define "sentry.kafka.port" -}}
{{- if and (.Values.kafka.enabled) (.Values.kafka.service.ports.client) -}}
{{- .Values.kafka.service.ports.client }}
{{- else if and (.Values.externalKafka) (not (kindIs "slice" .Values.externalKafka)) -}}
{{ required "A valid .Values.externalKafka.port is required" .Values.externalKafka.port }}
{{- end -}}
{{- end -}}

{{/*
Set Kafka bootstrap servers string
*/}}
{{- define "sentry.kafka.bootstrap_servers_string" -}}
{{- if or (.Values.kafka.enabled) (not (kindIs "slice" .Values.externalKafka)) -}}
{{ printf "%s:%s" (include "sentry.kafka.host" .) (include "sentry.kafka.port" .) }}
{{- else -}}
{{- range $index, $elem := .Values.externalKafka -}}
{{- if $index -}},{{- end -}}{{ printf "%s:%s" $elem.host (toString $elem.port) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "sentry.clickhouse.fullname" -}}
{{- printf "%s-%s" .Release.Name "clickhouse" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "snuba.port" -}}1218{{- end -}}
{{- define "relay.port" -}}3000{{- end -}}
{{- define "symbolicator.port" -}}3021{{- end -}}

{{/*
Set ClickHouse host
*/}}
{{- define "sentry.clickhouse.host" -}}
{{- if .Values.clickhouse.enabled -}}
{{- template "sentry.clickhouse.fullname" . -}}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.host is required" .Values.externalClickhouse.host }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse port
*/}}
{{- define "sentry.clickhouse.port" -}}
{{- if .Values.clickhouse.enabled -}}
{{- default 9000 .Values.clickhouse.clickhouse.tcp_port }}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.tcpPort is required" .Values.externalClickhouse.tcpPort }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse HTTP port
*/}}
{{- define "sentry.clickhouse.http_port" -}}
{{- if .Values.clickhouse.enabled -}}
{{- default 8123 .Values.clickhouse.clickhouse.http_port }}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.httpPort is required" .Values.externalClickhouse.httpPort }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse Database
*/}}
{{- define "sentry.clickhouse.database" -}}
{{- if .Values.clickhouse.enabled -}}
default
{{- else -}}
{{ required "A valid .Values.externalClickhouse.database is required" .Values.externalClickhouse.database }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse Authorization
*/}}
{{- define "sentry.clickhouse.auth" -}}
--user {{ include "sentry.clickhouse.username" . }} --password {{ include "sentry.clickhouse.password" .| quote }}
{{- end -}}

{{/*
Set ClickHouse User
*/}}
{{- define "sentry.clickhouse.username" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- if .Values.clickhouse.clickhouse.configmap.users.enabled -}}
{{ (index .Values.clickhouse.clickhouse.configmap.users.user 0).name }}
  {{- else -}}
default
  {{- end -}}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.username is required" .Values.externalClickhouse.username }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse Password
*/}}
{{- define "sentry.clickhouse.password" -}}
{{- if .Values.clickhouse.enabled -}}
  {{- if .Values.clickhouse.clickhouse.configmap.users.enabled -}}
{{ (index .Values.clickhouse.clickhouse.configmap.users.user 0).config.password }}
  {{- else -}}
  {{- end -}}
{{- else -}}
{{ .Values.externalClickhouse.password }}
{{- end -}}
{{- end -}}

{{/*
Set ClickHouse cluster name
*/}}
{{- define "sentry.clickhouse.cluster.name" -}}
{{- if .Values.clickhouse.enabled -}}
{{ .Release.Name | printf "%s-clickhouse" }}
{{- else -}}
{{ required "A valid .Values.externalClickhouse.clusterName is required" .Values.externalClickhouse.clusterName }}
{{- end -}}
{{- end -}}
