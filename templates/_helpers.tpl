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
Secret specification
*/}}
{{- define "qmig.secret" -}}
{{- printf "%s" .Values.secret.secretName | default "qmig-secret" -}}
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

{{- define "qmig.eng.env" }}
- name: REDIS_PASS
  valueFrom:
    secretKeyRef:
      name: {{ include "qmig.secret" . }}
      key: REDIS_PASS
- name: PROJECT_NAME
  valueFrom:
    secretKeyRef:
      name: {{ include "qmig.secret" . }}
      key: PROJECT_NAME
- name: POSTGRES_HOST
  value: {{- printf " " -}}{{- include "qmig.db.fullname" . -}}.{{- printf "%s" .Release.Namespace -}}.svc.cluster.local
- name: REDIS_HOST
  value: {{- printf " " -}}{{- include "qmig.msg.fullname" . -}}.{{- printf "%s" .Release.Namespace -}}.svc.cluster.local
{{- end }}

{{- define "qmig.eng.volumeMounts" }}
- mountPath: /mnt/eng
  {{- if and .Values.shared.persistentVolume.subPath (ne (include "qmig.cloud" .) "minikube") }}
  subPath: {{ .Values.shared.persistentVolume.subPath | quote }}
  {{- end }}
  name: {{ .pvcname }}
- mountPath: /mnt/extra
  subPath: {{ .Values.shared.folderPath.extraSubpath | quote}}
  name: {{ .pvcname }}
- mountPath: /mnt/dags
  subPath: {{  .Values.shared.folderPath.dagsSubpath | quote }}
  name: {{ .pvcname }}
- mountPath: /mnt/airflow/logs
  subPath: {{ .Values.shared.folderPath.logsSubpath | quote }}
  name: {{ .pvcname }}
- mountPath: /tmp
  name: {{ .pvctemp }}
{{- end }}

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
- name: POSTGRES_PORT
  value: {{- printf " %s" (default "5432" .Values.db.env.POSTGRES_PORT | toString | quote) }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "qmig.secret" . }}
      key: POSTGRES_PASSWORD
- name: POSTGRES_DB
  value: {{- printf " prjdb%s" (.Values.secret.data.PROJECT_ID | toString) -}}
{{- end -}}


{{- define "qmig.db.volumeMounts" }}
- mountPath: /docker-entrypoint-initdb.d
  name: sqlconfig-sh
- mountPath: /var/lib/postgresql/data
  {{- if and .Values.db.persistentVolume.subPath (ne (include "qmig.cloud" .) "minikube") }}
  subPath: {{ .Values.db.persistentVolume.subPath | quote }}
  {{- end }}
  name: {{ .pvcname }}
- mountPath: /var/run/postgresql
  name: {{ .pvctemp }}
- mountPath: /sqlconfig
  subPath: sqlfile
  name: {{ .pvctemp }}
{{- end }}


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

{{- define "qmig.msg.env" -}}
{{- if .Values.msg.auth.enabled }}
- name: REDIS_PASS
  valueFrom:
    secretKeyRef:
      name: {{ include "qmig.secret" . }}
      key: REDIS_PASS
{{- end }}
{{- end -}}

{{- define "qmig.project.env" -}}
- name: PROJECT_ID
  valueFrom:
    secretKeyRef:
      name: {{ include "qmig.secret" . }}
      key: PROJECT_ID
- name: API_HOST
  value: {{- printf " http://" -}}{{- include "qmig.eng.fullname" . -}}.{{- printf "%s" .Release.Namespace -}}.svc.cluster.local:8080
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

{{- define "qmig.asses.volumeMounts" }}
- mountPath: /mnt/pypod
  {{- if and .Values.shared.persistentVolume.subPath (ne (include "qmig.cloud" .) "minikube") }}
  subPath: {{ .Values.shared.persistentVolume.subPath }}
  {{- end }}
  name: {{ .pvcname }}
- mountPath: /app/tmp
  subPath: "tmp-e"
  name: {{ .pvctemp }}
- mountPath: /tmp
  subPath: "tmp"
  name: {{ .pvctemp }}
{{- end }}


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

{{- define "qmig.convs.volumeMounts" }}
- mountPath: /mnt/pypod
  {{- if and .Values.shared.persistentVolume.subPath (ne (include "qmig.cloud" .) "minikube") }}
  subPath: {{ .Values.shared.persistentVolume.subPath }}
  {{- end }}
  name: {{ .pvcname }}
- mountPath: /app/tmp
  subPath: "tmp-e"
  name: {{ .pvctemp }}
- mountPath: /tmp
  subPath: "tmp"
  name: {{ .pvctemp }}
{{- end }}

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

{{- define "qmig.migrt.volumeMounts" }}
- mountPath: /mnt/pypod
  {{- if and .Values.shared.persistentVolume.subPath (ne (include "qmig.cloud" .) "minikube") }}
  subPath: {{ .Values.shared.persistentVolume.subPath }}
  {{- end }}
  name: {{ .pvcname }}
- mountPath: /mnt/extra
  subPath: {{ .Values.shared.folderPath.extraSubpath | quote}}
  name: {{ .pvcname }}
- mountPath: /mnt/dags
  subPath: {{  .Values.shared.folderPath.dagsSubpath | quote }}
  name: {{ .pvcname }}
- mountPath: /app/tmp
  subPath: "tmp-e"
  name: {{ .pvctemp }}
- mountPath: /tmp
  subPath: "tmp"
  name: {{ .pvctemp }}
{{- end }}

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

{{- define "qmig.tests.volumeMounts" }}
- mountPath: /mnt/pypod
  {{- if and .Values.shared.persistentVolume.subPath (ne (include "qmig.cloud" .) "minikube") }}
  subPath: {{ .Values.shared.persistentVolume.subPath }}
  {{- end }}
  name: {{ .pvcname }}
- mountPath: /app/tmp
  subPath: "tmp-e"
  name: {{ .pvctemp }}
- mountPath: /tmp
  subPath: "tmp"
  name: {{ .pvctemp }}
{{- end }}



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

{{- define "qmig.perfs.volumeMounts" }}
- mountPath: /mnt/pypod
  {{- if and .Values.shared.persistentVolume.subPath (ne (include "qmig.cloud" .) "minikube") }}
  subPath: {{ .Values.shared.persistentVolume.subPath }}
  {{- end }}
  name: {{ .pvcname }}
- mountPath: /app/tmp
  subPath: "tmp-e"
  name: {{ .pvctemp }}
- mountPath: /tmp
  subPath: "tmp"
  name: {{ .pvctemp }}
{{- end }}

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


{{/*
All specification for PVC
*/}}
{{- define "qmig.shared.volume" }}
- name: {{ .pvcname }}
  {{- if .Values.shared.persistentVolume.enabled }}
  persistentVolumeClaim:
    claimName: {{ if .Values.shared.persistentVolume.existingClaim }}{{ .Values.shared.persistentVolume.existingClaim }}{{ else }}{{ .pvcname }}{{ end }}
  {{- else }}
  emptyDir: {}
  {{- end }}
- name: {{ .pvctemp }}
  emptyDir: {}
{{- end }}

{{/*
Docker specification
*/}}
{{- define "qmig.dockerauth" -}}
{{- printf "%s" .Values.imageCredentials.secretName | default "qmig-docker" -}}
{{- end -}}

{{- define "qmig.dockerSecret" }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" (default "qmigrator.azurecr.io" .Values.imageCredentials.data.registry) .Values.imageCredentials.data.username .Values.imageCredentials.data.password (printf "%s:%s" .Values.imageCredentials.data.username .Values.imageCredentials.data.password | b64enc) | b64enc }}
{{- end }}

{{- define "qmig.dockerauthList" -}}
  {{- $pullSecrets := list }}
  {{- $pullSecrets = append $pullSecrets (include "qmig.dockerauth" .) -}}
  {{- range .imagePullSecrets -}}
    {{- if kindIs "map" . -}}
      {{- $pullSecrets = append $pullSecrets .name -}}
    {{- else -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end }}
  {{- end -}}
  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}
