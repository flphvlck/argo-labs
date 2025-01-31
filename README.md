# Argo Labs
Lab environments for testing various Argo projects.

Prerequisites:
  * Up to date versions of: **kubectl**, **openssl**, **yq**, **kind** or **minikube**
  * K8s lab cluster with ports 80 and 443 exposed locally (simulation of direct access to Ingress Controller ports)
    * Kind or RKE2 cluster from https://github.com/flphvlck/k8s-labs
    * or Minikube

```
minikube start --apiserver-port=6443 --addons=ingress --driver=docker --ports=80:80,443:443
kubectl -n ingress-nginx patch deployment ingress-nginx-controller -p '{"spec":{"template":{"spec":{"hostNetwork": true}}}}'
```

## Argo CD
Install lab env with:
```
./argo-cd.sh
```

HTTP and GRPC endpoints are available on `argo-cd.lab.hvlck.xyz` and `argo-cd-grpc.lab.hvlck.xyz`. These domains are resolved to `127.0.0.1`, so you can use them for testing.

Example application (App Of Apps):
```
kubectl apply -f argo-cd/examples/application_apps.yaml
```

## Argo Workflows
Install lab env with:
```
./argo-workflows.sh
```

UI is accessible via `argo-workflows.lab.hvlck.xyz`. The domain is resolved to `127.0.0.1`.

## Argo Rollouts
Install lab env with:
```
kubectl apply -k argo-rollouts
```
