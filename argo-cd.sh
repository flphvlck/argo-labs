#!/usr/bin/env bash

DOMAIN="lab.hvlck.xyz"

# necessary commands
for COMMAND in kubectl openssl yq; do
    if ! command -v "$COMMAND" >/dev/null; then
        echo "$COMMAND not found." 1>&2
        exit 1
    fi
done

# custom domain replacement
if [[ "$DOMAIN" != "lab.hvlck.xyz" ]]; then
    sed -i "s/lab.hvlck.xyz/${DOMAIN}/g" argo-cd/manifests/*.yaml
fi

# install manifests
kubectl apply -k argo-cd

# secret for ingreses
if ! kubectl -n argo-cd get secret argo-cd-ingress-tls &>/dev/null; then
    openssl req -new -x509 -nodes -out tls.crt -keyout tls.key -days 3650 -subj "/CN=argo-cd.${DOMAIN}"
    kubectl -n argo-cd create secret tls argo-cd-ingress-tls --cert=tls.crt --key=tls.key
    rm tls.crt tls.key
fi

# workaround for https://github.com/argoproj/argo-cd/issues/17150 - creates custom kubeconfig for later use with argocd cluster add command
CURRENT_CONTEXT=$(kubectl config current-context)
if [[ "$CURRENT_CONTEXT" =~ ^(kind-lab1|rke2-lab|minikube)$ ]]; then
    kubectl config --kubeconfig=kubeconfig set-credentials workaround-admin --token="$(kubectl -n argo-cd get secret workaround-admin-token -o jsonpath="{.data.token}" | base64 -d)"
   if [[ "$CURRENT_CONTEXT" == "rke2-lab" ]]; then
        SERVER=$(yq -r ".clusters[] | select(.name == \"default\") | .cluster.server" "$KUBECONFIG")
    else
        SERVER=$(yq -r ".clusters[] | select(.name == \"${CURRENT_CONTEXT}\") | .cluster.server" ~/.kube/config)
    fi
    kubectl -n argo-cd get secret workaround-admin-token -o jsonpath="{.data.ca\.crt}" | base64 -d > cacert.pem
    kubectl --kubeconfig=kubeconfig config set-cluster "$CURRENT_CONTEXT" --server="$SERVER" --certificate-authority=cacert.pem --embed-certs
    kubectl --kubeconfig=kubeconfig config set-context "$CURRENT_CONTEXT" --user=workaround-admin --cluster="$CURRENT_CONTEXT"
    kubectl --kubeconfig=kubeconfig config use-context "$CURRENT_CONTEXT"
    rm cacert.pem
fi

# get Argo CD admin password
kubectl -n argo-cd rollout status deployment argocd-server -w
ARGOCD_ADMIN_PASSWORD=$(kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)

# print info
echo "############################"
echo "##"
echo "## ARGO-CD ADMIN PASSWORD: ${ARGOCD_ADMIN_PASSWORD}"
echo "## ARGO-CD WEB UI: https://argo-cd.${DOMAIN}"
echo "## ARGO-CD CLI: argocd login argo-cd-grpc.${DOMAIN}"
echo "##"
echo "## ADD CLUSTER TO ARGO-CD: argocd cluster add ${CURRENT_CONTEXT} --kubeconfig=kubeconfig --in-cluster"
echo "##"
echo "############################"
