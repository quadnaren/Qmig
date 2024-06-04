# Qmigrator Helm

## Visit GitHub On for more information
https://github.com/quadnaren/Qmig

# Pre-requisites
- Project information given by vendor like Poject ID, Name, Login information etc.
- Docker Image registry credentails given by vendor

> [!NOTE]
Above parameters requires in secret creation. Check secret & imageCredentials section of values.yaml

## Required namespace or create own
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

## Enable Airflow DataMigration
> You need to pass extra flag for enabling the airflow
```
  --set airflow.enabled=true --set airflow.secret.data.airflow_password="passxxxx"
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