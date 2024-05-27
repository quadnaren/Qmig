# Qmigrator Helm

# Pre-requisites
- Project information given by vendor like Poject ID, Name, Login information etc.
- Docker Image registry credentails given by vendor

> [!NOTES]
Above parameters requires in secret creation. Check secret & imageCredentials section of values.yaml

## Requied namespace or create own
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

## Data Persistence
- Qmigrator use shared volume for components like App, Engine & Others
- While Metadata DB (Postgres) & Cache Component have their own
- Override the pre-created PVC from persistentVolume.existingClaim flag in values.yaml
- You may use the existing/default StorageClass for dynamic volume creation

> [!Tip]
Please check the examples for creating custom StorageClass, PV & PVC from this repo & override persistentVolume.existingClaim <br>
More Ref: http://kubernetes.io/docs/user-guide/persistent-volumes/

> [!IMPORTANT]
DO NOT USE ReadWriteMany or Shared Persitent volume given here to the Metadata DB (Postgres) & Cache Component

# Customise Qmigrator
Use values.yaml from this repo, edit as required and use while installing Helm
```
helm install <name> qmigrator/qmig -f values.yaml
```

## Values.YAML
### Globals
| Property | Description |
| :--- | :--- |
| nameOverride | String to partially override name template (will maintain the release name) |
| secret.secretName | Name for project secret |
| secret.data.PROJECT_ID | ID of project |
| secret.data.PROJECT_NAME | Name of project |
| secret.data.POSTGRES_PASSWORD | Admin Password for metadata DB |
| secret.data.REDIS_PASS | Admin Password for Cache |
| imageCredentials.secretName | Name for docker secret |
| imageCredentials.data.registry | Server/Registry host. Default: qmigrator.azurecr.io |
| imageCredentials.data.username | Username for given docker host |
| imageCredentials.data.password | Password for given docker host |
| serviceAccount.create | Enable creation of ServiceAccount |
| serviceAccount.name | The name of the ServiceAccount to use. |
| serviceAccount.annotations | Additional custom annotations for the ServiceAccount |
| rbac.create | Create Role and RoleBinding |
### Shared Volume
| Property | Description |
| :--- | :--- |
| shared.persistentVolume | PersistentVolume template for Shared volume in QMigrator |
| shared.folderPath.extraSubpath | subpath for Extra folder in a shared volume |
| shared.folderPath.dagsSubpath | subpath for Dag's folder of airflow in a shared volume |
| shared.folderPath.logsSubpath | subpath for logs folder of airflow in a shared volume |
### Ingress Controller
| Property | Description |
| :--- | :--- |
| ingressController.enabled | Whether or not to install the ingressController |
| ingressController.controllerImage.repository | Ingress controller image repository |
| ingressController.controllerImage.tag | Ingress controller image tag/version |
| ingressController.webhookImage.repository | Ingress controller image repository |
| ingressController.webhookImage.tag | Ingress controller image tag/version |
### App Components
| Property | Description |
| :--- | :--- |
| app.name | Name for App component |
| app.replicaCount | Number of App Components replicas |
| app.statefulSet.enabled | Deploy App as statefulset |
| app.image.repository | App component image repository |
| app.image.tag | App component image tag/version |
| app.image.pullPolicy | App component pull policy |
| app.imagePullSecrets | App component pull secrets |
| app.readinessProbe.enabled | Enable readinessProbe on App Component containers |
| app.livenessProbe.enabled | Enable livenessProbe on App Component containers |
| app.annotations | Add extra annotations to the App Component |
| app.podAnnotations | Add extra Pod annotations to the App Component pods |
| app.securityContext | Configure App Component Security Context |
| app.containerSecurityContext | Configure App Component Container Security Context |
| app.tolerations | Tolerations for App Component pods assignment |
| app.affinity | Affinity for App Component pods assignment (evaluated as a template) |
| app.nodeSelector | Node labels for App Component pods assignment |
| app.service.annotations | Additional custom annotations for App Component service |
| app.service.type | App Component service type |
| app.service.port | App Component service HTTP port |
| app.ingress.enabled | Enable ingress record generation |
| ingress.className | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+) |
| app.ingress.annotations | Additional annotations for the Ingress resource |
| app.ingress.host | Default host for the ingress record |
| app.ingress.tls | TLS configuration for additional hostname(s) to be covered with this ingress record |
| app.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| app.autoscaling.enabled | Whether to enable horizontal pod autoscaler |
| app.autoscaling.minReplicas | Configure a minimum amount of pods |
| app.autoscaling.maxReplicas | Configure a maximum amount of pods |
| app.autoscaling.targetCPUUtilizationPercentage | Define the CPU target to trigger the scaling actions (utilization percentage) |
| app.autoscaling.targetMemoryUtilizationPercentage | Define the memory target to trigger the scaling actions (utilization percentage) |
### Engine Components
| Property | Description |
| :--- | :--- |
| eng.name | Name for Engine component |
| eng.replicaCount | Number of Engine component replicas |
| eng.statefulSet.enabled | Deploy App as statefulset |
| eng.image.repository | Engine component image repository |
| eng.image.tag | Engine component image tag/version |
| eng.image.pullPolicy | Engine component pull policy |
| eng.imagePullSecrets | Engine component pull secrets |
| eng.readinessProbe.enabled | Enable readinessProbe on Engine component containers |
| eng.livenessProbe.enabled | Enable livenessProbe on Engine component containers |
| eng.annotations | Add extra annotations to the Engine component |
| eng.podAnnotations | Add extra Pod annotations to the Engine component pods |
| eng.securityContext | Configure Engine component Security Context |
| eng.containerSecurityContext | Configure Engine component Container Security Context |
| eng.tolerations | Tolerations for Engine component pods assignment |
| eng.affinity | Affinity for Engine component pods assignment (evaluated as a template) |
| eng.nodeSelector | Node labels for Engine component pods assignment |
| eng.service.annotations | Additional custom annotations for Engine component service |
| eng.service.type | Engine component service type |
| eng.service.port | Engine component service HTTP port |
| eng.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Engine component pods |
| extraVolumes | Optionally specify an extra list of additional volumes for all the Engine component pods |
| eng.ingress.enabled | Enable ingress record generation |
| ingress.className | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+) |
| eng.ingress.annotations | Additional annotations for the Ingress resource |
| eng.ingress.host | Default host for the ingress record |
| eng.ingress.tls | TLS configuration for additional hostname(s) to be covered with this ingress record |
| eng.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| eng.autoscaling.enabled | Whether to enable horizontal pod autoscaler |
| eng.autoscaling.minReplicas | Configure a minimum amount of pods |
| eng.autoscaling.maxReplicas | Configure a maximum amount of pods |
| eng.autoscaling.targetCPUUtilizationPercentage | Define the CPU target to trigger the scaling actions (utilization percentage) |
| eng.autoscaling.targetMemoryUtilizationPercentage | Define the memory target to trigger the scaling actions (utilization percentage) |
| eng.env | Add extra environment variables for the Engine component pods |
| eng.envSecret | List of secrets with extra environment variables for all the component pods |
### Metadat DB
| Property | Description |
| :--- | :--- |
| db.name | Name for DB component |
| db.replicaCount | Number of DB component replicas |
| db.statefulSet.enabled | Deploy App as statefulset |
| db.image.repository | DB component image repository |
| db.image.tag | DB component image tag/version |
| db.image.pullPolicy | DB component pull policy |
| db.imagePullSecrets | DB component pull secrets |
| db.dbshConfig.stringOverride | Override shell script to be run on the initial time of DB |
| db.annotations | Add extra annotations to the DB component |
| db.podAnnotations | Add extra Pod annotations to the DB component pods |
| db.securityContext | Configure DB component Security Context |
| db.containerSecurityContext | Configure DB component Container Security Context |
| db.tolerations | Tolerations for DB component pods assignment |
| db.affinity | Affinity for DB component pods assignment (evaluated as a template) |
| db.nodeSelector | Node labels for DB component pods assignment |
| db.initContainers.loadDB | Initialize the container of DB to load the db components |
| db.initContainers.image.repository | Load DB image repository |
| db.initContainers.image.tag | Load DB image tag/version |
| db.initContainers.resources | Set Init container requests and limits for different resources like CPU or memory |
| db.persistentVolume | PersistentVolume template for Metadata DB volume |
| db.service.annotations | Additional custom annotations for DB component service |
| db.service.type | DB component service type |
| db.service.port | DB component service HTTP port |
| db.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| db.env | Add extra environment variables for the DB component pods |
| db.envSecret | List of secrets with extra environment variables for all the component pods |
| db.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the DB component pods |
| extraVolumes | Optionally specify an extra list of additional volumes for the all the DB component pods |
### Cache Component
| Property | Description |
| :--- | :--- |
| msg.name | Name for Cache component |
| msg.replicaCount | Number of Cache component replicas |
| msg.statefulSet.enabled | Deploy App as statefulset |
| msg.image.repository | Cache component image repository |
| msg.image.tag | Cache component image tag/version |
| msg.image.pullPolicy | Cache component pull policy |
| msg.imagePullSecrets | Cache component pull secrets |
| msg.args | Args to override Cache component containers in the the deployment(s)/statefulset(s) |
| msg.keyDBConfig.stringOverride | Override shell script to be run on the initial time of Cache |
| msg.annotations | Add extra annotations to the Cache component |
| msg.podAnnotations | Add extra Pod annotations to the Cache component pods |
| msg.securityContext | Configure Cache component Security Context |
| msg.containerSecurityContext | Configure Cache component Container Security Context |
| msg.tolerations | Tolerations for Cache component pods assignment |
| msg.affinity | Affinity for Cache component pods assignment (evaluated as a template) |
| msg.nodeSelector | Node labels for Cache component pods assignment |
| msg.persistentVolume | PersistentVolume template for Cache component volume in QMigrator |
| msg.service.annotations | Additional custom annotations for Cache component service |
| msg.service.type | Cache component service type |
| msg.service.port | Cache component service HTTP port |
| msg.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| msg.master.enabled | Run Cache component as master node |
| msg.auth.enabled | Enabled authentication with password on Cache component |
| msg.env | Add extra environment variables for the Cache component pods |
| msg.envSecret | List of secrets with extra environment variables for all the component pods |
| msg.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Cache component pods |
| msg.extraVolumes | Optionally specify an extra list of additional volumes for the all the Cache component pods |
### Assessment
| Property | Description |
| :--- | :--- |
| asses.name | Name for Assessment |
| asses.image.repository | Assessment image repository |
| asses.image.tag | Assessment image tag/version |
| asses.image.pullPolicy | Assessment pull policy |
| asses.imagePullSecrets | Assessment pull secrets |
| asses.annotations | Add extra annotations to the Assessment |
| asses.podAnnotations | Add extra Pod annotations to the Assessment pods |
| asses.securityContext | Configure Assessment Security Context |
| asses.containerSecurityContext | Configure Assessment Container Security Context |
| asses.tolerations | Tolerations for Assessment pods assignment |
| asses.affinity | Affinity for Assessment pods assignment (evaluated as a template) |
| asses.nodeSelector | Node labels for Assessment pods assignment |
| asses.schedule | Specifies the cron job schedule using the standard cron syntax |
| asses.failedJobsHistoryLimit | How many failed executions to track in history. Default is 1 |
| asses.successfulJobsHistoryLimit | How many successful executions to track in history. Default is 3 |
| asses.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed |
| asses.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled |
| asses.restartPolicy | Restart the container keeping the same Pod in Node |
| asses.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds |
| asses.backoffLimit | Each pod failure is counted towards the specified limit |
| asses.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| asses.env | Add extra environment variables for the Assessment pods |
| asses.envSecret | List of secrets with extra environment variables for all the component pods |
| asses.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Assessment pods |
| asses.extraVolumes | Optionally specify an extra list of additional volumes for the all the Assessment pods |
### Conversion
| Property | Description |
| :--- | :--- |
| convs.name | Name for Conversion |
| convs.image.repository | Conversion image repository |
| convs.image.tag | Conversion image tag/version |
| convs.image.pullPolicy | Conversion pull policy |
| convs.imagePullSecrets | Conversion pull secrets |
| convs.annotations | Add extra annotations to the Conversion |
| convs.podAnnotations | Add extra Pod annotations to the Conversion pods |
| convs.securityContext | Configure Conversion Security Context |
| convs.containerSecurityContext | Configure Conversion Container Security Context |
| convs.tolerations | Tolerations for Conversion pods assignment |
| convs.affinity | Affinity for Conversion pods assignment (evaluated as a template) |
| convs.nodeSelector | Node labels for Conversion pods assignment |
| convs.schedule | Specifies the cron job schedule using the standard cron syntax |
| convs.failedJobsHistoryLimit | How many failed executions to track in history. Default is 1 |
| convs.successfulJobsHistoryLimit | How many successful executions to track in history. Default is 3 |
| convs.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed |
| convs.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled |
| convs.restartPolicy | Restart the container keeping the same Pod in Node |
| convs.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds |
| convs.backoffLimit | Each pod failure is counted towards the specified limit |
| convs.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| convs.env | Add extra environment variables for the Conversion pods |
| convs.envSecret | List of secrets with extra environment variables for all the component pods |
| convs.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Conversion pods |
| convs.extraVolumes | Optionally specify an extra list of additional volumes for the all the Conversion pods |
### Migration
| Property | Description |
| :--- | :--- |
| migrt.name | Name for Migration |
| migrt.image.repository | Migration image repository |
| migrt.image.tag | Migration image tag/version |
| migrt.image.pullPolicy | Migration pull policy |
| migrt.imagePullSecrets | Migration pull secrets |
| migrt.annotations | Add extra annotations to the Migration |
| migrt.podAnnotations | Add extra Pod annotations to the Migration pods |
| migrt.securityContext | Configure Migration Security Context |
| migrt.containerSecurityContext | Configure Migration Container Security Context |
| migrt.tolerations | Tolerations for Migration pods assignment |
| migrt.affinity | Affinity for Migration pods assignment (evaluated as a template) |
| migrt.nodeSelector | Node labels for Migration pods assignment |
| migrt.schedule | Specifies the cron job schedule using the standard cron syntax |
| migrt.failedJobsHistoryLimit | How many failed executions to track in history. Default is 1 |
| migrt.successfulJobsHistoryLimit | How many successful executions to track in history. Default is 3 |
| migrt.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed |
| migrt.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled |
| migrt.restartPolicy | Restart the container keeping the same Pod in Node |
| migrt.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds |
| migrt.backoffLimit | Each pod failure is counted towards the specified limit |
| migrt.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| migrt.env | Add extra environment variables for the Migration pods |
| migrt.envSecret | List of secrets with extra environment variables for all the component pods |
| migrt.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Migration pods |
| migrt.extraVolumes | Optionally specify an extra list of additional volumes for the all the Migration pods |
### Testing
| Property | Description |
| :--- | :--- |
| tests.name | Name for Testing |
| tests.image.repository | Testing image repository |
| tests.image.tag | Testing image tag/version |
| tests.image.pullPolicy | Testing pull policy |
| tests.imagePullSecrets | Testing pull secrets |
| tests.annotations | Add extra annotations to the Testing |
| tests.podAnnotations | Add extra Pod annotations to the Testing pods |
| tests.securityContext | Configure Testing Security Context |
| tests.containerSecurityContext | Configure Testing Container Security Context |
| tests.tolerations | Tolerations for Testing pods assignment |
| tests.affinity | Affinity for Testing pods assignment (evaluated as a template) |
| tests.nodeSelector | Node labels for Testing pods assignment |
| tests.schedule | Specifies the cron job schedule using the standard cron syntax |
| tests.failedJobsHistoryLimit | How many failed executions to track in history. Default is 1 |
| tests.successfulJobsHistoryLimit | How many successful executions to track in history. Default is 3 |
| tests.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed |
| tests.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled |
| tests.restartPolicy | Restart the container keeping the same Pod in Node |
| tests.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds |
| tests.backoffLimit | Each pod failure is counted towards the specified limit |
| tests.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| tests.env | Add extra environment variables for the Testing pods |
| tests.envSecret | List of secrets with extra environment variables for all the component pods |
| tests.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Testing pods |
| tests.extraVolumes | Optionally specify an extra list of additional volumes for the all the Testing pods |
### Performance
| Property | Description |
| :--- | :--- |
| perfs.name | Name for Performance |
| perfs.image.repository | Performance image repository |
| perfs.image.tag | Performance image tag/version |
| perfs.image.pullPolicy | Performance pull policy |
| perfs.imagePullSecrets | Performance pull secrets |
| perfs.annotations | Add extra annotations to the Performance |
| perfs.podAnnotations | Add extra Pod annotations to the Performance pods |
| perfs.securityContext | Configure Performance Security Context |
| perfs.containerSecurityContext | Configure Performance Container Security Context |
| perfs.tolerations | Tolerations for Performance pods assignment |
| perfs.affinity | Affinity for Performance pods assignment (evaluated as a template) |
| perfs.nodeSelector | Node labels for Performance pods assignment |
| perfs.schedule | Specifies the cron job schedule using the standard cron syntax |
| perfs.failedJobsHistoryLimit | How many failed executions to track in history. Default is 1 |
| perfs.successfulJobsHistoryLimit | How many successful executions to track in history. Default is 3 |
| perfs.startingDeadlineSeconds | How many seconds a job is allowed to miss its scheduled start time before it is considered failed |
| perfs.concurrencyPolicy | Handle scenario when concurrent jobs are scheduled |
| perfs.restartPolicy | Restart the container keeping the same Pod in Node |
| perfs.ttlSecondsAfterFinished | Clean up finished Jobs after the specific seconds |
| perfs.backoffLimit | Each pod failure is counted towards the specified limit |
| perfs.resources | Set container requests and limits for different resources like CPU or memory (essential for production workloads) |
| perfs.env | Add extra environment variables for the Performance pods |
| perfs.envSecret | List of secrets with extra environment variables for all the component pods |
| perfs.extraVolumeMounts | Optionally specify an extra list of additional volumeMounts for all the Performance pods |
| perfs.extraVolumes | Optionally specify an extra list of additional volumes for the all the Performance pods |


## Examples
### Docker Desktop shared volume (Win)
> See the example/pv-docker-desktop.yaml
- Use on Docker Desktop Kubernetes, LocalPath as windows device path

### Minikube shared volume (Linux, Win, MacOS etc.)
> See the example/pv-minikube.yaml
- Use on Minikube, LocalPath as local device path
