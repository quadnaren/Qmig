# Qmigrator Helm

# Pre-requisites
- Project information from vendor like project ID, Name, Login information, etc.
- Docker Image registry credentials given by the vendor

> [!NOTE]
The above parameters are required for secret. Check the secret & imageCredentials section of values.yaml

## Required namespace or create your own
```
Kubectl create namespace qmig-ns 
Kubectl config set-context --current --namespace=qmig-ns
```

## Install Qmigrator
```
helm repo add qmigrator https://quadnaren.github.io/Qmig
helm repo update
helm install <name> qmigrator/qmig \
  --set secret.data.PROJECT_ID="1234" --set secret.data.PROJECT_NAME="example" \
  --set secret.data.POSTGRES_PASSWORD="xxxx" --set secret.data.REDIS_PASS="xxxx" \
  --set imageCredentials.data.username="userxxxx" --set imageCredentials.data.password="passxxxx"
```

## Ingress Installation
- Qmigrator uses ingress to expose the application
- You may use existing ingress if present in the cluster by updating the properties of
  - app.ingress
  - eng.ingress
  - airflow.ingress
<br>OR 
- Enable the flag of Ingress controller installation within the Helm chart
```
  --set ingressController.enabled=true
```

## Enable Airflow DataMigration
- Pass extra flag for Airflow installation within Helm chart
- Password is mandatory to access the Airflow
```
  --set airflow.enabled=true --set airflow.secret.data.airflow_password="passxxxx"
```

## Data Persistence
- Qmigrator uses shared volume for components like App, Engine & Others
- While Metadata DB (Postgres) & Cache Component have their own
- Override the pre-created PVC from persistentVolume.existingClaim flag in values.yaml
- You may use the existing/default StorageClass for dynamic volume creation

> [!Tip]
Please check the examples for creating custom StorageClass, PV & PVC from this repo & override persistentVolume.existingClaim <br>
More Ref: http://kubernetes.io/docs/user-guide/persistent-volumes/

> [!IMPORTANT]
DO NOT USE ReadWriteMany or Shared Persistent volume given here to the Metadata DB (Postgres) & Cache Component

# Customise Qmigrator
- Use values.yaml from this repo, edit as required, and use while installing Helm
```
helm install <name> qmigrator/qmig -f values.yaml
```

## Examples
### Docker Desktop shared volume (Win)
- Use on Docker Desktop Kubernetes, LocalPath as Windows device path
> See the example/pv-docker-desktop.yaml

### Minikube shared volume (Linux, Win, MacOS, etc.)
- Mount the local path while starting the minikube
- eg. /hostpc on minikube points to {LOCAL_PATH} of device
```
minikube start --mount --mount-string={LOCAL_PATH}:/hostpc
```
> See the example/pv-minikube.yaml

## Values.YAML
### Globals
| Property | Description | Default | 
| :--- | :--- | :--- | 
| nameOverride | String to partially override name template (will maintain the release name) | "" | 
| clusterDomain | Kubernetes Cluster Domain | "cluster.local" | 
| secret.secretName | Name for project secret | "" (name: qmig-secret) | 
| secret.data.PROJECT_ID | ID of project | null | 
| secret.data.PROJECT_NAME | Name of project | null | 
| secret.data.POSTGRES_PASSWORD | Admin Password for metadata DB | null | 
| secret.data.REDIS_PASS | Admin Password for Cache | null | 
| imageCredentials.secretName | Name for docker secret | "" (name: qmig-docker) | 
| imageCredentials.data.registry | Server/Registry host. | qmigrator.azurecr.io | 
| imageCredentials.data.username | Username for given docker host | null | 
| imageCredentials.data.password | Password for given docker host | null | 
### Shared Volume
| Property | Description | Default | 
| :--- | :--- | :--- | 
| shared.persistentVolume.enabled | If false, use emptyDir | true | 
| shared.persistentVolume.accessModes | How should the volume be accessible in App | ReadWriteMany | 
| shared.persistentVolume.annotations | Persistent Volume Claim annotations | {} | 
| shared.persistentVolume.existingClaim | Name of PVC created manually before volume | "" | 
| shared.persistentVolume.subPath | Subdirectory of data Persistent Volume to mount | "" | 
| shared.persistentVolume.size | Persistent Volume size | 5Gi | 
| shared.persistentVolume.storageClass | Persistent Volume Storage Class | "" (Default from Kubernetes) | 
| shared.persistentVolume.volumeBindingMode | Persistent Volume Binding Mode | "" (Default from Kubernetes) | 
| shared.folderPath.extraSubpath | subpath for Extra folder in a shared volume | "extra" | 
| shared.folderPath.dagsSubpath | subpath for Dag's folder of airflow in a shared volume | "dags" | 
| shared.folderPath.logsSubpath | subpath for logs folder of airflow in a shared volume | "logs" | 
### Ingress Controller
| Property | Description | Default | 
| :--- | :--- | :--- | 
| ingressController.enabled | Whether or not to install the ingressController | false | 
| ingressController.controllerImage.repository | Ingress controller image repository | qmigrator.azurecr.io/ingress-nginx/controller | 
| ingressController.controllerImage.tag | Ingress controller image tag/version | "v1.9.4" | 
| ingressController.webhookImage.repository | Ingress controller image repository | qmigrator.azurecr.io/ingress-nginx/kube-webhook-certgen | 
| ingressController.webhookImage.tag | Ingress controller image tag/version | "v20231011-8b53cabe0" | 
| ingressController.imagePullSecrets | Ingress Controller component pull secrets | {} | 
| ingressController.isDefaultClass | Set Ingress class as default to cluster | true | 
### Service Account
| Property | Description | Default | 
| :--- | :--- | :--- | 
| serviceAccount.create | Enable creation of ServiceAccount | true | 
| serviceAccount.name | The name of the ServiceAccount to use | "" (name: qmig-opr) | 
| serviceAccount.annotations | Additional custom annotations for the ServiceAccount | {} | 
| rbac.create | Create Role and RoleBinding | true | 
### App Components
| Property | Description | Default | 
| :--- | :--- | :--- | 
| app.name | Name for App component | "app" | 
| app.replicas | Number of App Components replicas | 1 | 
| app.image.repository | App component image repository | "qmigrator.azurecr.io/qubeapp" | 
| app.image.tag | App component image tag/version | "q1002" | 
| app.image.pullPolicy | App component pull policy | "IfNotPresent" | 
| app.imagePullSecrets | App component pull secrets | {} | 
| app.readinessProbe.enabled | Enable readinessProbe on App Component containers | true | 
| app.livenessProbe.enabled | Enable livenessProbe on App Component containers | true | 
| app.annotations | Add extra annotations to the App Component | {} | 
| app.podAnnotations | Add extra Pod annotations to the App Component pods | {} | 
| app.securityContexts.pod | default security context for App Component pods | {} | 
| app.securityContexts.container | default security context for App Component containers | {} | 
| app.tolerations | Tolerations for App Component pods assignment | {} | 
| app.affinity | Affinity for App Component pods assignment (evaluated as a template) | {} | 
| app.nodeSelector | Node labels for App Component pods assignment | {} | 
| app.service.annotations | Additional custom annotations for App Component service | {} | 
| app.service.type | App Component service type | ClusterIP | 
| app.service.port | App Component service HTTP port | 4200 | 
| app.ingress.enabled | Enable ingress record generation | true | 
| app.ingress.className | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+) | "" (From Kubernetes) | 
| app.ingress.annotations | Additional annotations for the Ingress resource | {} | 
| app.ingress.host | Default host for the ingress record | "" | 
| app.ingress.tls | TLS configuration for additional hostname(s) to be covered with this ingress record | {} | 
| app.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| app.autoscaling.enabled | Whether to enable horizontal pod autoscaler | true | 
| app.autoscaling.minReplicas | Configure a minimum amount of pods | 1 | 
| app.autoscaling.maxReplicas | Configure a maximum amount of pods | 2 | 
| app.autoscaling.targetCPUUtilizationPercentage | Define the CPU target to trigger the scaling actions (utilization percentage) | 80 | 
| app.autoscaling.targetMemoryUtilizationPercentage | Define the memory target to trigger the scaling actions (utilization percentage) | 80 | 
### Engine Components
| Property | Description | Default | 
| :--- | :--- | :--- | 
| eng.name | Name for Engine component | "eng" | 
| eng.replicas | Number of Engine component replicas | 1 | 
| eng.image.repository | Engine component image repository | "qmigrator.azurecr.io/qubeeng" | 
| eng.image.tag | Engine component image tag/version | "q836" | 
| eng.image.pullPolicy | Engine component pull policy | "IfNotPresent" | 
| eng.imagePullSecrets | Engine component pull secrets | {} | 
| eng.readinessProbe.enabled | Enable readinessProbe on Engine component containers | true | 
| eng.livenessProbe.enabled | Enable livenessProbe on Engine component containers | true | 
| eng.annotations | Add extra annotations to the Engine component | {} | 
| eng.podAnnotations | Add extra Pod annotations to the Engine component pods | {} | 
| eng.securityContexts.pod | default security context for Engine component pods | {} | 
| eng.securityContexts.container | default security context for Engine component containers | {} | 
| eng.tolerations | Tolerations for Engine component pods assignment | {} | 
| eng.affinity | Affinity for Engine component pods assignment (evaluated as a template) | {} | 
| eng.nodeSelector | Node labels for Engine component pods assignment | {} | 
| eng.service.annotations | Additional custom annotations for Engine component service | {} | 
| eng.service.type | Engine component service type | ClusterIP | 
| eng.service.port | Engine component service HTTP port | 8080 | 
| eng.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Engine component pods | [] | 
| eng.extraVolumes | Optionally specify an extra list of additional volumes for all the Engine component pods | [] | 
| eng.ingress.enabled | Enable ingress record generation | true | 
| eng.ingress.className | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+) | "" (From Kubernetes) | 
| eng.ingress.annotations | Additional annotations for the Ingress resource | {} | 
| eng.ingress.host | Default host for the ingress record | "" | 
| eng.ingress.tls | TLS configuration for additional hostname(s) to be covered with this ingress record | {} | 
| eng.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| eng.autoscaling.enabled | Whether to enable horizontal pod autoscaler | true | 
| eng.autoscaling.minReplicas | Configure a minimum amount of pods | 1 | 
| eng.autoscaling.maxReplicas | Configure a maximum amount of pods | 2 | 
| eng.autoscaling.targetCPUUtilizationPercentage | Define the CPU target to trigger the scaling actions (utilization percentage) | 80 | 
| eng.autoscaling.targetMemoryUtilizationPercentage | Define the memory target to trigger the scaling actions (utilization percentage) | 80 | 
| eng.env | Add extra environment variables for the Engine component pods | [] | 
| eng.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
### Metadata Database
| Property | Description | Default | 
| :--- | :--- | :--- | 
| db.name | Name for DB component | "db" | 
| db.replicas | Number of DB component replicas | 1 | 
| db.image.repository | DB component image repository | "postgres" (hub.docker.com) | 
| db.image.tag | DB component image tag/version | "14.2" | 
| db.image.pullPolicy | DB component pull policy | "IfNotPresent" | 
| db.imagePullSecrets | DB component pull secrets | {} | 
| db.dbshConfig.stringOverride | Override shell script to be run on the initial time of DB | "" | 
| db.annotations | Add extra annotations to the DB component | {} | 
| db.podAnnotations | Add extra Pod annotations to the DB component pods | {} | 
| db.securityContexts.pod | default security context for DB Component pods | {} | 
| db.securityContexts.container | default security context for DB Component containers | {} | 
| db.tolerations | Tolerations for DB component pods assignment | {} | 
| db.affinity | Affinity for DB component pods assignment (evaluated as a template) | {} | 
| db.nodeSelector | Node labels for DB component pods assignment | {} | 
| db.initContainers.image.repository | Load DB image repository | "qmigrator.azurecr.io/qmigdb-ini" | 
| db.initContainers.image.tag | Load DB image tag/version | "1164" | 
| db.initContainers.resources | Set Init container requests and limits for different resources like CPU or memory | 
| db.persistentVolume.enabled | If false, use emptyDir | true | 
| db.persistentVolume.accessModes | How should the volume be accessible in App | ReadWriteOnce | 
| db.persistentVolume.annotations | Persistent Volume Claim annotations | {} | 
| db.persistentVolume.existingClaim | Name of PVC created manually before volume | "" | 
| db.persistentVolume.subPath | Subdirectory of data Persistent Volume to mount | "" | 
| db.persistentVolume.size | Persistent Volume size | 5Gi | 
| db.persistentVolume.storageClass | Persistent Volume Storage Class | "" (Default from Kubernetes) | 
| db.persistentVolume.volumeBindingMode | Persistent Volume Binding Mode | "" (Default from Kubernetes) | 
| db.service.annotations | Additional custom annotations for DB component service | {} | 
| db.service.type | DB component service type | "ClusterIP" | 
| db.service.port | DB component service HTTP port | 5432 | 
| db.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| db.env | Add extra environment variables for the DB component pods | [JDBC_PARAMS] | 
| db.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| db.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the DB component pods | [] | 
| db.extraVolumes | Optionally specify an extra list of additional volumes for all the DB component pods | [] | 
### Cache Components
| Property | Description | Default |
| :--- | :--- | :--- |
| msg.name | Name for Cache component | "msg" | 
| msg.replicas | Number of Cache component replicas | 1 | 
| msg.image.repository | Cache component image repository | "eqalpha/keydb" | 
| msg.image.tag | Cache component image tag/version | "x86_64_v6.3.4" | 
| msg.image.pullPolicy | Cache component pull policy | IfNotPresent | 
| msg.imagePullSecrets | Cache component pull secrets | {} | 
| msg.args | Args to override Cache component containers | [] | 
| msg.keyDBConfig.stringOverride | Override shell script to be run on the initial time of Cache | "" | 
| msg.annotations | Add extra annotations to the Cache component | {} | 
| msg.podAnnotations | Add extra Pod annotations to the Cache component pods | {} | 
| msg.securityContexts.pod | default security context for Cache Component pods | {} | 
| msg.securityContexts.container | default security context for Cache Component containers | {} | 
| msg.tolerations | Tolerations for Cache component pods assignment | {} | 
| msg.affinity | Affinity for Cache component pods assignment (evaluated as a template) | {} | 
| msg.nodeSelector | Node labels for Cache component pods assignment | {} | 
| msg.persistentVolume.enabled | If false, use emptyDir | true | 
| msg.persistentVolume.accessModes | How should the volume be accessible in App | ReadWriteOnce | 
| msg.persistentVolume.annotations | Persistent Volume Claim annotations | {} | 
| msg.persistentVolume.existingClaim | Name of PVC created manually before volume | "" | 
| msg.persistentVolume.subPath | Subdirectory of data Persistent Volume to mount | "" | 
| msg.persistentVolume.size | Persistent Volume size | 5Gi | 
| msg.persistentVolume.storageClass | Persistent Volume Storage Class | "" (Default from Kubernetes) | 
| msg.persistentVolume.volumeBindingMode | Persistent Volume Binding Mode | "" (Default from Kubernetes) | 
| msg.service.annotations | Additional custom annotations for Cache component service | {} | 
| msg.service.type | Cache component service type | "ClusterIP" | 
| msg.service.port | Cache component service HTTP port | 6378 | 
| msg.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| msg.master.enabled | Run Cache component as master node | true | 
| msg.auth.enabled | Enabled authentication with password on Cache component | true | 
| msg.env | Add extra environment variables for the Cache component pods | [] | 
| msg.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| msg.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Cache component pods | [] | 
| msg.extraVolumes | Optionally specify an extra list of additional volumes for all the Cache component pods | [] | 
### Assessment
| Property | Description | Default |
| :--- | :--- | :--- |
| asses.name | Name for Assessment | "asses" | 
| asses.image.repository | Assessment image repository | "qmigrator.azurecr.io/webassotp" | 
| asses.image.tag | Assessment image tag/version | "992" | 
| asses.image.pullPolicy | Assessment pull policy | "IfNotPresent" | 
| asses.imagePullSecrets | Assessment pull secrets | {} | 
| asses.annotations | Add extra annotations to the Assessment | {} | 
| asses.podAnnotations | Add extra Pod annotations to the Assessment pods | {} | 
| asses.securityContexts.pod | default security context for Assessment pods | {} | 
| asses.securityContexts.container | default security context for Assessment containers | {} | 
| asses.tolerations | Tolerations for Assessment pods assignment | {} | 
| asses.affinity | Affinity for Assessment pods assignment (evaluated as a template) | {} | 
| asses.nodeSelector | Node labels for Assessment pods assignment | {} | 
| asses.schedule | Specifies the cron job schedule using the standard cron syntax | "*/10 * * * *" | 
| asses.failedJobsHistoryLimit | How many failed executions to track in history. | 2 | 
| asses.successfulJobsHistoryLimit | How many successful executions to track in history. | 3 | 
| asses.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed | 500 | 
| asses.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled | Forbid | 
| asses.restartPolicy | Restart the container keeping the same Pod in Node | Never | 
| asses.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds | 600 | 
| asses.backoffLimit | Each pod failure is counted towards the specified limit | 2 | 
| asses.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| asses.env | Add extra environment variables for the Assessment pods | [] | 
| asses.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| asses.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Assessment pods | [] | 
| asses.extraVolumes | Optionally specify an extra list of additional volumes for all the Assessment pods | [] | 
### Conversion
| Property | Description | Default |
| :--- | :--- | :--- |
| convs.name | Name for Conversion | "convs" | 
| convs.image.repository | Conversion image repository | "qmigrator.azurecr.io/webconvotp" | 
| convs.image.tag | Conversion image tag/version | "993" | 
| convs.image.pullPolicy | Conversion pull policy | "IfNotPresent" | 
| convs.imagePullSecrets | Conversion pull secrets | {} | 
| convs.annotations | Add extra annotations to the Conversion | {} | 
| convs.podAnnotations | Add extra Pod annotations to the Conversion pods | {} | 
| convs.securityContexts.pod | default security context for Conversion pods | {} | 
| convs.securityContexts.container | default security context for Conversion containers | {} | 
| convs.tolerations | Tolerations for Conversion pods assignment | {} | 
| convs.affinity | Affinity for Conversion pods assignment (evaluated as a template) | {} | 
| convs.nodeSelector | Node labels for Conversion pods assignment | {} | 
| convs.schedule | Specifies the cron job schedule using the standard cron syntax | "*/10 * * * *" | 
| convs.failedJobsHistoryLimit | How many failed executions to track in history. | 2 | 
| convs.successfulJobsHistoryLimit | How many successful executions to track in history. | 2 | 
| convs.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed | 500 | 
| convs.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled | Forbid | 
| convs.restartPolicy | Restart the container keeping the same Pod in Node | Never | 
| convs.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds | 600 | 
| convs.backoffLimit | Each pod failure is counted towards the specified limit | 2 | 
| convs.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| convs.env | Add extra environment variables for the Conversion pods | [] | 
| convs.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| convs.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Conversion pods | [] | 
| convs.extraVolumes | Optionally specify an extra list of additional volumes for all the Conversion pods | [] | 
### Migration
| Property | Description | Default |
| :--- | :--- | :--- |
| migrt.name | Name for Migration | "migrt" | 
| migrt.image.repository | Migration image repository | "qmigrator.azurecr.io/webdmotp" | 
| migrt.image.tag | Migration image tag/version | "994" | 
| migrt.image.pullPolicy | Migration pull policy | "IfNotPresent" | 
| migrt.imagePullSecrets | Migration pull secrets | {} | 
| migrt.annotations | Add extra annotations to the Migration | {} | 
| migrt.podAnnotations | Add extra Pod annotations to the Migration pods | {} | 
| migrt.securityContexts.pod | default security context for Migration pods | {} | 
| migrt.securityContexts.container | default security context for Migration containers | {} | 
| migrt.tolerations | Tolerations for Migration pods assignment | {} | 
| migrt.affinity | Affinity for Migration pods assignment (evaluated as a template) | {} | 
| migrt.nodeSelector | Node labels for Migration pods assignment | {} | 
| migrt.schedule | Specifies the cron job schedule using the standard cron syntax | "*/10 * * * *" | 
| migrt.failedJobsHistoryLimit | How many failed executions to track in history. | 2 | 
| migrt.successfulJobsHistoryLimit | How many successful executions to track in history. | 2 | 
| migrt.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed | 500 | 
| migrt.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled | "Forbid" | 
| migrt.restartPolicy | Restart the container keeping the same Pod in Node | "Never" | 
| migrt.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds | 600 | 
| migrt.backoffLimit | Each pod failure is counted towards the specified limit | 2 | 
| migrt.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| migrt.env | Add extra environment variables for the Migration pods | [] | 
| migrt.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| migrt.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Migration pods | [] | 
| migrt.extraVolumes | Optionally specify an extra list of additional volumes for all the Migration pods | [] | 
### Testing
| Property | Description | Default |
| :--- | :--- | :--- |
| tests.name | Name for Testing | "tests" | 
| tests.image.repository | Testing image repository | "qmigrator.azurecr.io/webtestotp" | 
| tests.image.tag | Testing image tag/version | "971" | 
| tests.image.pullPolicy | Testing pull policy | "IfNotPresent" | 
| tests.imagePullSecrets | Testing pull secrets | {} | 
| tests.annotations | Add extra annotations to the Testing | {} | 
| tests.podAnnotations | Add extra Pod annotations to the Testing pods | {} | 
| tests.securityContexts.pod | default security context for Testing pods | {} | 
| tests.securityContexts.container | default security context for Testing containers | {} | 
| tests.tolerations | Tolerations for Testing pods assignment | {} | 
| tests.affinity | Affinity for Testing pods assignment (evaluated as a template) | {} | 
| tests.nodeSelector | Node labels for Testing pods assignment | {} | 
| tests.schedule | Specifies the cron job schedule using the standard cron syntax | "*/10 * * * *" | 
| tests.failedJobsHistoryLimit | How many failed executions to track in history. | 2 | 
| tests.successfulJobsHistoryLimit | How many successful executions to track in history. | 2 | 
| tests.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed | 500 | 
| tests.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled | "Forbid" | 
| tests.restartPolicy | Restart the container keeping the same Pod in Node | "Never" | 
| tests.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds | 600 | 
| tests.backoffLimit | Each pod failure is counted towards the specified limit | 2 | 
| tests.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| tests.env | Add extra environment variables for the Testing pods | [] | 
| tests.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| tests.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Testing pods | [] | 
| tests.extraVolumes | Optionally specify an extra list of additional volumes for all the Testing pods | [] | 
### Performance
| Property | Description | Default |
| :--- | :--- | :--- |
| perfs.name | Name for Performance | "perfs" | 
| perfs.image.repository | Performance image repository | "qmigrator.azurecr.io/webperfotp" | 
| perfs.image.tag | Performance image tag/version | "985" | 
| perfs.image.pullPolicy | Performance pull policy | "qmigrator.azurecr.io/webperfotp" | 
| perfs.imagePullSecrets | Performance pull secrets | {} | 
| perfs.annotations | Add extra annotations to the Performance | {} | 
| perfs.podAnnotations | Add extra Pod annotations to the Performance pods | {} | 
| perfs.securityContexts.pod | default security context for Performance pods | {} | 
| perfs.securityContexts.container | default security context for Performance containers | {} | 
| perfs.tolerations | Tolerations for Performance pods assignment | {} | 
| perfs.affinity | Affinity for Performance pods assignment (evaluated as a template) | {} | 
| perfs.nodeSelector | Node labels for Performance pods assignment | {} | 
| perfs.schedule | Specifies the cron job schedule using the standard cron syntax | "*/10 * * * *" | 
| perfs.failedJobsHistoryLimit | How many failed executions to track in history. | 2 | 
| perfs.successfulJobsHistoryLimit | How many successful executions to track in history. | 2 | 
| perfs.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed | 500 | 
| perfs.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled | Forbid | 
| perfs.restartPolicy | Restart the container keeping the same Pod in Node | Never | 
| perfs.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds | 600 | 
| perfs.backoffLimit | Each pod failure is counted towards the specified limit | 2 | 
| perfs.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| perfs.env | Add extra environment variables for the Performance pods | [] | 
| perfs.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| perfs.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Performance pods | [] | 
| perfs.extraVolumes | Optionally specify an extra list of additional volumes for all the Performance pods | [] | 
### Airflow Global
| Property | Description | Default |
| :--- | :--- | :--- |
| airflow.enabled | Name for Airflow | false | 
| airflow.name | Name for Airflow | "airflow" | 
| airflow.uid | User id for Airflow | "106665" | 
| airflow.gid | group id for Airflow | "106966" | 
| airflow.image.repository | Airflow image repository | "qmigrator.azurecr.io/qmigair" | 
| airflow.image.tag | Airflow image tag/version | "2.8.4-ofjv-lvs" | 
| airflow.image.pullPolicy | Airflow pull policy | "IfNotPresent" | 
| airflow.imagePullSecrets | Airflow pull secrets | {} | 
| airflow.rbac.create | Create Role and RoleBinding | true | 
| airflow.baseUrl | Base URL of Airflow Webserver | http://0.0.0.0:8080/airflow | 
| airflow.config | Config settings to go into the mounted airflow.cfg | | 
| airflow.airflowLocalSettings | file as a string (can be templated) | ~ | 
| airflow.podTemplate | is a templated string containing the contents of `pod_template_file.yaml` used for KubernetesExecutor workers | ~ | 
| airflow.webserverConfig | string (can be templated) will be mounted into the Airflow Webserver | ~ | 
| airflow.securityContexts.pod | Detailed default security context for Airflow Pods | {} | 
| airflow.securityContexts.container | Detailed default security context for Airflow Container | {} | 
| airflow.tolerations | Tolerations for Airflow pods | {} | 
| airflow.affinity | Affinity for Airflow pods (evaluated as a template) | {} | 
| airflow.nodeSelector | Node labels for Airflow pods | {} | 
| airflow.ingress.enabled | Enable ingress record generation | true | 
| airflow.ingress.className | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+) | "" (From Kubernetes) | 
| airflow.ingress.annotations | Additional annotations for the Ingress resource | {} | 
| airflow.ingress.host | Default host for the ingress record | "" | 
| airflow.ingress.tls | TLS configuration for additional hostname(s) to be covered with this ingress record | {} | 
| airflow.env | Add extra environment variables for the Airflow pods | [] | 
| airflow.envSecret | List of secrets with extra environment variables for all the component pods | [] | 
| airflow.secret.secretName | Name for project secret | "" (name: qmig-air-secret) | 
| airflow.secret.data.airflow_secret_key | Random generated key for webserver | null | 
| airflow.secret.data.airflow_fernet_key | Random generated key for airflow | null | 
| airflow.secret.data.airflow_password | Airflow login password | null | 
| airflow.secret.data.connection | Connection string for Airflow metadata DB | null | 
### Airflow Webserver
| Property | Description | Default |
| :--- | :--- | :--- |
| airflow.webserver.replicas | Number of Airflow Webserver replicas | 1 | 
| airflow.webserver.safeToEvict | This setting tells Kubernetes that its ok to evict | true | 
| airflow.webserver.annotations | Add extra annotations to the Airflow Webserver | {} | 
| airflow.webserver.podAnnotations | Add extra Pod annotations to the Airflow Webserver pods | {} | 
| airflow.webserver.securityContexts.pod | default security context for Webserver pods | {} | 
| airflow.webserver.securityContexts.container | default security context for Webserver containers | {} | 
| airflow.webserver.livenessProbe | livenessProbe on Airflow webserver | 
| airflow.webserver.readinessProbe | readinessProbe on Airflow webserver | 
| airflow.webserver.startupProbe | startupProbe on Airflow webserver | 
| airflow.webserver.command | Command to use when running the Airflow webserver | {} | 
| airflow.webserver.args | Args to use when running the Airflow webserver | ["bash", "-c", "exec airflow webserver"] | 
| airflow.webserver.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
| airflow.webserver.service.annotations | Additional custom annotations for Airflow Webserver service | {} | 
| airflow.webserver.service.type | Airflow Webserver service type | "ClusterIP" | 
| airflow.webserver.service.port | Airflow Webserver service HTTP port | 8080 | 
### Airflow Scheduler
| Property | Description | Default |
| :--- | :--- | :--- |
| airflow.scheduler.replicas | Number of Airflow Scheduler replicas | 1 | 
| airflow.scheduler.safeToEvict | This setting tells Kubernetes that its ok to evict | true | 
| airflow.scheduler.annotations | Add extra annotations to the Airflow Scheduler | {} | 
| airflow.scheduler.podAnnotations | Add extra Pod annotations to the Airflow Scheduler pods | {} | 
| airflow.scheduler.securityContexts.pod | default security context for Scheduler pods | {} | 
| airflow.scheduler.securityContexts.container | default security context for Scheduler containers | {} | 
| airflow.scheduler.livenessProbe | livenessProbe on Airflow Scheduler | 
| airflow.scheduler.readinessProbe | readinessProbe on Airflow Scheduler | 
| airflow.scheduler.startupProbe | startupProbe on Airflow Scheduler | 
| airflow.scheduler.command | Command to use when running the Airflow scheduler | ~ | 
| airflow.scheduler.args | Args to use when running the Airflow scheduler | ["bash", "-c", "exec airflow scheduler"] | 
| airflow.scheduler.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
### Airflow Worker
| Property | Description | Default |
| :--- | :--- | :--- |
| airflow.worker.safeToEvict | This setting tells Kubernetes that its ok to evict | true | 
| airflow.worker.annotations | Add extra annotations to the Airflow Worker | {} | 
| airflow.worker.podAnnotations | Add extra Pod annotations to the Airflow Worker pods | {} | 
| airflow.worker.securityContexts.pod | default security context for Worker pods | {} | 
| airflow.worker.securityContexts.container | default security context for Worker containers | {} | 
| airflow.worker.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
### Init-container to wait migration
| Property | Description | Default |
| :--- | :--- | :--- |
| airflow.waitForMigrations.enabled | Whether to create init container to wait for db migrations | true | 
| airflow.waitForMigrations.safeToEvict | This setting tells Kubernetes that its ok to evict | true | 
| airflow.waitForMigrations.annotations | Add extra annotations to the waitForMigrations | {} | 
| airflow.waitForMigrations.podAnnotations | Add extra Pod annotations to the waitForMigrations pods | {} | 
| airflow.waitForMigrations.securityContexts.container | default security context for waitForMigrations containers | {} | 
| airflow.waitForMigrations.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
### Airflow Create User Job
| Property | Description | Default |
| :--- | :--- | :--- |
| airflow.createUserJob.safeToEvict | This setting tells Kubernetes that its ok to evict | true | 
| airflow.createUserJob.annotations | Add extra annotations to the createUserJob | {} | 
| airflow.createUserJob.podAnnotations | Add extra Pod annotations to the createUserJob pods | {} | 
| airflow.createUserJob.securityContexts.pod | default security context for createUserJob pods | {} | 
| airflow.createUserJob.securityContexts.container | default security context for createUserJob containers | {} | 
| airflow.createUserJob.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
### Airflow DB Migration Job
| Property | Description | Default |
| :--- | :--- | :--- |
| airflow.migrateDatabaseJob.enabled | Whether to create init container to wait for db migrations | true | 
| airflow.migrateDatabaseJob.safeToEvict | This setting tells Kubernetes that its ok to evict | true | 
| airflow.migrateDatabaseJob.annotations | Add extra annotations to the migrateDatabaseJob | {} | 
| airflow.migrateDatabaseJob.podAnnotations | Add extra Pod annotations to the migrateDatabaseJob pods | {} | 
| airflow.migrateDatabaseJob.securityContexts.pod | default security context for migrateDatabaseJob pods | {} | 
| airflow.migrateDatabaseJob.securityContexts.container | default security context for migrateDatabaseJob containers | {} | 
| airflow.migrateDatabaseJob.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) | 
