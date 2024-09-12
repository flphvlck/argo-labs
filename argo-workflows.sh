#!/usr/bin/env bash

DOMAIN="lab.hvlck.xyz"

# custom domain replacement
if [[ "$DOMAIN" != "lab.hvlck.xyz" ]]; then
    sed -i "s/lab.hvlck.xyz/${DOMAIN}/g" argo-workflows/manifests/*.yaml
fi

# install
kubectl apply -k argo-workflows

# secret for ingress
if ! kubectl -n argo-workflows get secret argo-workflows-ingress-tls &>/dev/null; then
    openssl req -new -x509 -nodes -out tls.crt -keyout tls.key -days 3650 -subj "/CN=argo-workflows.${DOMAIN}"
    kubectl -n argo-workflows create secret tls argo-workflows-ingress-tls --cert=tls.crt --key=tls.key
    rm tls.crt tls.key
fi

# get token to access argo-workflow
ARGO_WORKFLOWS_ADMIN_TOKEN=$(kubectl -n argo-workflows get secret argo-workflows-admin-token -o jsonpath="{.data.token}" | base64 -d; echo)

# print info
echo "############################"
echo "##"
echo "## ARGO WORKFLOWS WEB UI: https://argo-workflows.${DOMAIN}"
echo "## ARGO WORKFLOWS TOKEN: \"Bearer ${ARGO_WORKFLOWS_ADMIN_TOKEN}\""
echo "##"
echo "############################"
