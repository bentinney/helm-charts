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
