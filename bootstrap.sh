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

kubectl apply -f https://raw.githubusercontent.com/weaveworks/flux/master/deploy-helm/flux-helm-release-crd.yaml

helm repo add weaveworks https://weaveworks.github.io/flux
helm repo update

helm install weaveworks/flux \
  --name flux \
  --set helmOperator.create=true \
  --set helmOperator.createCRD=false \
  --set helmOperator.tillerNamespace=$TILLER_NAMESPACE \
  --set git.url=$GIT_REPO \
  --namespace $FLUX_FORWARD_NAMESPACE \
  --wait

if hash fluxctl 2>/dev/null; then
    fluxctl identity
fi
