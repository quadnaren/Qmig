# Qmigrator Helm

## Requied namespace or set own
```
Kubectl create namespace qmig-ns 
Kubectl config set-context --current --namespace=qmig-ns
```

## Install Qmigrator
```
helm repo add qmigrator https://quadnaren.github.io/Qmig
helm repo update
helm install <name> qmigrator/qmig
```

# Customise
Edit values.yaml and use for deployment
```
helm install <name> qmigrator/qmig -f values.yaml
```

## Examples
### Docker Desktop shared file
See the example/pv-docker-desktop.yaml for create mounted pv on local desktop

### Minikube shared file
See the example/pv-minikube.yaml for create mounted pv on local device