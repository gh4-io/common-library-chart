{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . }}
app.kubernetes.io/app: {{ printf "%s" .Chart.Annotations.app | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: servarr
{{- end }}

{{/*
Selector labels
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "common.volumeName" -}}
{{- .Values.persistence.volumeName | default ( printf "%s-%s-pv" ( .Release.Namespace ) ( include "common.fullname" . ))  }}
{{- end }}

{{- define "common.volumePath" -}}
{{- .Values.persistence.volumePath | default "/var/snap/microk8s/common/default-storage/" }}
{{- end }}

{{- define "common.pvName" -}}
{{ printf "%s-%s-pv" .Release.Namespace ( include "common.fullname" . ) }}
{{- end }}

{{- define "common.pvcName" -}}
{{ default (printf "%s-pvc" ( include "common.fullname" . )) .Values.persistence.existingClaim }}
{{- end }}

{{/*
Translate .Value.configmap to deployment volumes.
*/}}
{{- define "common.volumeConfigMap" -}}
  {{- if .Values.configMap }}
    {{- if .Values.configMap.existingConfigMap}}
      {{- range $key, $value := .Values.configMap.existingConfigMap }}
- _type: configMap
  configMap:
    name: {{ $key }}
  name: {{ $value.mntName }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{/*
tanslate .Value.configMap to Init Pod
*/}}
{{- define "common.initConfigMap" -}}
  {{- if .Values.configMap }}
    {{- if .Values.configMap.existingConfigMap}}
      {{- range $key, $value := .Values.configMap.existingConfigMap }}
      {{- if eq ( $value.pod | default "primary" ) "init" }}
- name: {{ $value.mntName }}
  mountPath: {{ $value.path }}
  subPath: {{ $value.subPath }}
  readOnly: true
      {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
tanslate .Value.configMap to Primary Pod
*/}}
{{- define "common.primaryConfigMap" -}}
  {{- if .Values.configMap }}
    {{- if .Values.configMap.existingConfigMap}}
      {{- range $key, $value := .Values.configMap.existingConfigMap }}
      {{- if eq ( $value.pod | default "primary" ) "primary" }}
- name: {{ $value.mntName }}
  mountPath: {{ $value.path }}
  subPath: {{ $value.subPath | default nil }}
  readOnly: true
      {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{/*
 {{- $type := ("init" "primary") }}
 {{- if has "init" $type }}
 */}}
