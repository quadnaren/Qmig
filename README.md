# Qmigrator Helm

## Visit GitHub On for more information
https://github.com/quadnaren/Qmig

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

## If Airflow enabled in Qmigrator
- Pass additional param to install command
```
  --set airflow.enabled=true --set airflow.secret.data.airflow-password="passxxxx"
```
