# Argo Labs

Lab environments for testing various Argo projects.

## Argo CD

Prerequisites:
  * Kind cluster from https://github.com/flphvlck/k8s-labs

Install lab env with:
```
./argo-cd.sh
```

HTTP and GRPC endpoints are available on `argo-cd.lab.hvlck.xyz` and `argo-cd-grpc.lab.hvlck.xyz`. These domains are resolved to `127.0.0.1`, so you can use them for testing.