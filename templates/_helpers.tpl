{{/*
Expand the name of the chart.
*/}}
{{- define "qmig.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "qmig.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "qmig.selectorLabels" -}}
app.kubernetes.io/name: {{ include "qmig.name" . }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "qmig.labels" -}}
helm.sh/chart: {{ include "qmig.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "qmig.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "qmig.deployment.apiVersion" -}}
{{- if semverCompare "<1.9-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "^1.9-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}


{{/*
Define the qmig.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "qmig.namespace" -}}
{{- if .Values.forceNamespace -}}
{{ printf "namespace: %s" .Values.forceNamespace }}
{{- else -}}
{{ printf "namespace: %s" .Release.Namespace }}
{{- end -}}
{{- end -}}


{{/*
Endpoint specification for s3
*/}}
{{- define "qmig.s3.endpoint" -}}
{{- printf "https://s3.%s.amazonaws.com" .Values.aws.s3.region | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Cloud specification
*/}}
{{- define "qmig.cloud" -}}
{{- printf "%s" .Values.cloud | default "azure" -}}
{{- end -}}

{{/*
Construct the name of the ServiceAccount.
*/}}
{{- define "qmig.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- .Values.serviceAccount.name | default "qmig-opr" -}}
{{- else -}}
{{- .Values.serviceAccount.name | default "default" -}}
{{- end -}}
{{- end -}}

{{/*
Ingress controller specification
*/}}
{{- define "qmig.controller.ingressType" -}}
{{- $name := default "external" .Values.controller.ingressType -}}
{{- printf "%s" $name -}}
{{- end -}}

{{/*
All specification for app module
*/}}
{{- define "qmig.app.selectorLabels" -}}
component: {{ .Values.app.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.app.labels" -}}
{{ include "qmig.app.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.app.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.app.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
All specification for eng module
*/}}
{{- define "qmig.eng.selectorLabels" -}}
component: {{ .Values.eng.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.eng.labels" -}}
{{ include "qmig.eng.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.eng.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.eng.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "qmig.eng.env" -}}
- name: POSTGRES_HOST
  value: {{- printf " " -}}{{- include "qmig.db.fullname" . -}}.{{- printf "%s" .Release.Namespace -}}.svc.cluster.local
- name: REDIS_HOST
  value: {{- printf " " -}}{{- include "qmig.msg.fullname" . -}}.{{- printf "%s" .Release.Namespace -}}.svc.cluster.local
- name: POSTGRES_DB
  value:  {{- printf " prjdb%s" .Values.globals.projectId -}}
{{- end -}}


{{/*
All specification for db module
*/}}
{{- define "qmig.db.selectorLabels" -}}
component: {{ .Values.db.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.db.labels" -}}
{{ include "qmig.db.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.db.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.db.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "qmig.db.env" -}}
- name: POSTGRES_DB
  value:  {{- printf " prjdb%s" .Values.globals.projectId -}}
{{- end -}}


{{/*
Define an init-container which checks the DB status
EXAMPLE USAGE: {{ include "airflow.init_container.check_db" (dict "Release" .Release "Values" .Values "volumeMounts" $volumeMounts) }}
*/}}
{{- define "qmig.db.load-db" }}
- name: load-db
  image: "{{ .Values.db.initContainer.loadDB.image.repository }}:{{ .Values.db.initContainer.loadDB.image.tag }}"
  resources:
    {{- toYaml .Values.db.initContainer.loadDB.resources | nindent 4 }}
  command: ['sh', '-c', "cp -f /app/*.sql /sqlconfig 2>/dev/null"]
  volumeMounts:
    - mountPath: /sqlconfig
      name: {{ .volumename }}
      subPath: sqlfile
{{- end }}


{{/*
All specification for msg module
*/}}
{{- define "qmig.msg.selectorLabels" -}}
component: {{ .Values.msg.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.msg.labels" -}}
{{ include "qmig.msg.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.msg.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.msg.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}



{{/*
All specification for asses module
*/}}
{{- define "qmig.asses.selectorLabels" -}}
component: {{ .Values.asses.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.asses.labels" -}}
{{ include "qmig.asses.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.asses.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.asses.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
All specification for convs module
*/}}
{{- define "qmig.convs.selectorLabels" -}}
component: {{ .Values.convs.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.convs.labels" -}}
{{ include "qmig.convs.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.convs.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.convs.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
All specification for migrt module
*/}}
{{- define "qmig.migrt.selectorLabels" -}}
component: {{ .Values.migrt.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.migrt.labels" -}}
{{ include "qmig.migrt.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.migrt.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.migrt.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
All specification for tests module
*/}}
{{- define "qmig.tests.selectorLabels" -}}
component: {{ .Values.tests.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.tests.labels" -}}
{{ include "qmig.tests.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.tests.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.tests.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
All specification for perfs module
*/}}
{{- define "qmig.perfs.selectorLabels" -}}
component: {{ .Values.perfs.name | quote }}
{{ include "qmig.selectorLabels" . }}
{{- end -}}

{{- define "qmig.perfs.labels" -}}
{{ include "qmig.perfs.selectorLabels" . }}
{{ include "qmig.labels" . }}
{{- end -}}

{{- define "qmig.perfs.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.perfs.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}



{{/*
All specification for CSI
*/}}
{{- define "qmig.diskCSI.parameters" -}}
{{- if eq "aws" .Values.cloud -}}
parameters:
  type: gp2
  fsType: ext4
{{- else if eq "gcp" .Values.cloud  -}}
parameters:
  type: pd-balanced
{{- else if eq "azure" .Values.cloud   -}}
parameters:
  skuName: "StandardSSD_ZRS"
{{- end -}}
{{- end -}}

{{/*
All specification for CSI
*/}}
{{- define "qmig.diskCSI.provisioner" -}}
{{- if eq "aws" .Values.cloud -}}
{{- printf "%s" "ebs.csi.aws.com" | quote | trimSuffix "-" -}}
{{- else if eq "gcp" .Values.cloud -}}
{{- printf "%s" "pd.csi.storage.gke.io" | quote | trimSuffix "-" -}}
{{- else if eq "azure" .Values.cloud -}}
{{- printf "%s" "disk.csi.azure.com" | quote | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
All specification for PVC
*/}}
{{- define "qmig.pv.shared" -}}
{{- printf "%s-%s" .Release.Name "shared" | quote | trimSuffix "-" -}}
{{- end -}}


