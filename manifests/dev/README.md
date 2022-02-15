# Running Using Minikube

## Start Kubernetes Cluster
```sh
minikube start
```

## Build [Auth Docker](https://github.com/TheoticTech/distnode-auth/blob/main/Dockerfile) with Minikube Docker Registry
```sh
# Connect to Minikube Docker Registry
eval $(minikube docker-env)

# Build image
docker build -t distnode/auth:latest .
```

## Minikube Deployment
```sh
kubectl apply -f ./manifests/dev
```

## Tunnel Service for Localhost Access
```sh
minikube service distnode-auth-service # look for the service at 127.0.0.1
```
