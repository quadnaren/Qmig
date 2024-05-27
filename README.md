# Qmigrator Helm

## Visit GitHub On for more information
https://github.com/quadnaren/Qmig

# Pre-requisites
- Qmigrator requires the project information given by vendor
- Poject ID, Name, Login information etc.
- Docker Image registry credentails given by vendor
- Need to set runtime or can be override in values.yaml

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

# Customise Qmigrator
Use values.yaml from this repo, edit as required and use while installing Helm
```
helm install <name> qmigrator/qmig -f values.yaml
```

