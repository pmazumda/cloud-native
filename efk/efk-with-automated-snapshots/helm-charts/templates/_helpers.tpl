{{/*
Assign schedule for cronjob based on user provided values in default values YAML
*/}}

{{- define "efk.cronschedule" -}}
{{- if (eq .Values.backup.snapshot.schedule "hourly") -}}
schedule: "@hourly"
{{- else if (eq .Values.backup.snapshot.schedule "daily") -}}
schedule: "@daily"
{{- else if (eq .Values.backup.snapshot.schedule "weekly") -}}
schedule: "@daily"
{{- else if (eq .Values.backup.snapshot.schedule "monthly") -}}
schedule: "@daily"
{{- else if (eq .Values.backup.snapshot.schedule "yearly") -}}
schedule: "@daily"
{{- else if (eq .Values.backup.snapshot.schedule "custom") -}}
schedule: {{ .Values.backup.snapshot.cronSchedule | quote -}}
{{- end }}
{{- end }}

{{/*
Backup all indices. 
*/}}
{{ define "efk.allIndices" }}
command:
- /bin/bash
args:
- -c
- 'curl -s -i -k -u "elastic:$(</mnt/elastic/es-basic-auth/elastic)" -XPUT "https://{{ .Release.Name }}-es-http:9200/_snapshot/{{ .Values.backup.repository.name }}/{{ .Release.Name }}-{{ .Values.backup.snapshot.format }}" | tee /dev/stderr | grep "200 OK"'
{{- end }}

{{/*
Backup  given indexes.
*/}}
{{- define "efk.givenIndices" }}
command:
- /bin/bash
args:
- -c
- |
  curl -s -i -k -u "elastic:$(</mnt/elastic/es-basic-auth/elastic)" -XPUT "https://{{ .Release.Name }}-es-http:9200/_snapshot/{{ .Values.backup.repository.name }}/{{ .Release.Name }}-{{ .Values.backup.snapshot.format }}?wait_for_completion=true" -H 'Content-Type: application/json' -d'{  "indices": {{ .Values.backup.snapshot.indices | quote }},  "ignore_unavailable": true,  "include_global_state": true,  "metadata": {    "taken_by": "es-snapshotter",    "taken_because": "cronjob-scheduled"  }}' | tee /dev/stderr | grep "200 OK"
{{- end }}

{{/*
Check for all-indices or a given index only. 
*/}}
{{- define "efk.selectIndices" -}}
{{- if (eq .Values.backup.snapshot.indices "all") -}}
{{ include "efk.allIndices" . | indent 12 -}}
{{ else }}
{{- include "efk.givenIndices" . | indent 12 }}
{{- end }}
{{- end }}