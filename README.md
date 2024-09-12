# Argo Labs
Lab environments for testing various Argo projects.

Prerequisites:
  * Kind cluster from https://github.com/flphvlck/k8s-labs

## Argo CD
Install lab env with:
```
./argo-cd.sh
```

HTTP and GRPC endpoints are available on `argo-cd.lab.hvlck.xyz` and `argo-cd-grpc.lab.hvlck.xyz`. These domains are resolved to `127.0.0.1`, so you can use them for testing.

Example application:
```
kubectl apply -f argo-cd/examples/application_example-app.yaml
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
