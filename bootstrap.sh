#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

function kapply {
    kubectl "$@" --save-config --dry-run --output yaml | kubectl apply -f -
}

export TILLER_NAMESPACE=tiller
export FLUX_FORWARD_NAMESPACE=flux
export GIT_REPO='git@github.com:srueg/gitops-redkeep.git'

kapply create namespace $TILLER_NAMESPACE
kapply create clusterrolebinding tiller-admin --clusterrole cluster-admin --serviceaccount $TILLER_NAMESPACE:default

helm init \
  --tiller-namespace $TILLER_NAMESPACE \
  --override 'spec.template.spec.containers[0].command'='{/tiller,--storage=secret}' \
  --history-max 10 \
  --wait

helm repo add fluxcd https://charts.fluxcd.io
helm repo update

helm upgrade -i flux fluxcd/flux \
  --namespace $FLUX_FORWARD_NAMESPACE \
  --set git.url=$GIT_REPO \
  --set git.readonly=true \
  --set sync.state=secret \
  --wait

if hash fluxctl 2>/dev/null; then
    fluxctl identity
fi

helm upgrade -i flux-helm-operator fluxcd/helm-operator \
  --version 0.3.0 \
  --namespace $FLUX_FORWARD_NAMESPACE \
  --set tillerNamespace=$TILLER_NAMESPACE
