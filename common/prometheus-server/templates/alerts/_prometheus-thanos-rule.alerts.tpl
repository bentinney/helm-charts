{{- /*
Taken from prometheus-rules/prometheus-kubernetes-rules, since it is used in the common chart and every prometheus needs to have it or the chart will fail
*/}}
{{- define "alertTierLabelOrDefault" -}}
"{{`{{ if $labels.label_alert_tier }}`}}{{`{{ $labels.label_alert_tier}}`}}{{`{{ else }}`}}{{ required "default value is missing" . }}{{`{{ end }}`}}"
{{- end -}}
{{- /*
Use the 'label_alert_service', if it exists on the time series, otherwise use the given default.
Note: The pods define the 'alert-service' label but Prometheus replaces the hyphen with an underscore.
*/}}
{{- define "alertServiceLabelOrDefault" -}}
"{{`{{ if $labels.label_alert_service }}`}}{{`{{ $labels.label_alert_service}}`}}{{`{{ else }}`}}{{ required "default value is missing" . }}{{`{{ end }}`}}"
{{- end -}}
{{- define "alertSupportGroupOrDefault" -}}
"{{`{{ if $labels.ccloud_support_group }}`}}{{`{{ $labels.ccloud_support_group }}`}}{{`{{ else }}`}}{{ required "default value is missing" . }}{{`{{ end }}`}}"
{{- end -}}

{{- $name := index . 0 -}}
{{- $root := index . 1 -}}
groups:
- name: prometheus.alerts
  rules:
  {{- if and $root.Values.alerts.multiplePodScrapes.enabled $root.Values.alerts.thanos.enabled }}
  - alert: PrometheusMultiplePodScrapes
    expr: sum by(pod, namespace, label_alert_service, label_alert_tier, ccloud_support_group) (label_replace((up * on(instance) group_left() (sum by(instance) (up{job=~".*{{ include "prometheus.name" . }}.*pod-sd"}) > 1)* on(pod) group_left(label_alert_tier, label_alert_service) (max without(uid) (kube_pod_labels))) , "pod", "$1", "kubernetes_pod_name", "(.*)-[0-9a-f]{8,10}-[a-z0-9]{5}"))
    for: 30m
    labels:
      service: {{ include "alertServiceLabelOrDefault" "metrics" }}
      support_group: {{ include "alertSupportGroupOrDefault" "observability" }}
      severity: warning
      playbook: docs/support/playbook/kubernetes/target_scraped_multiple_times
      meta: Prometheus is scraping `{{`{{ $labels.pod }}`}}` pods more than once.
    annotations:
      description: Prometheus is scraping `{{`{{ $labels.pod }}`}}` pods in namespace `{{`{{ $labels.namespace }}`}}` multiple times. This is likely caused due to incorrectly placed scrape annotations. <https://{{ include "prometheus.externalURL" . }}/graph?g0.expr={{ urlquery `up * on(instance) group_left() (sum by(instance) (up{kubernetes_pod_name=~"PLACEHOLDER.*"}) > 1)` | replace "PLACEHOLDER" "{{ $labels.pod }}"}}|Affected targets>
      summary: Prometheus scrapes pods multiple times
  {{- end }}
