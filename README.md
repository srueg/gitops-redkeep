# GitOps Config
K8s resources to use with [fluxcd Flux](https://github.com/fluxcd/flux)


## Bootstrap New Cluster
```bash
./bootstrap.sh

export TILLER_NAMESPACE=tiller
export FLUX_FORWARD_NAMESPACE=flux
```

## Use kubeseal
To encrypt a secret using kubeseal:
```
kubeseal --format=yaml --cert=sealed-secrets.pub < some/secret-plain.yaml > some/secret.yaml
```
