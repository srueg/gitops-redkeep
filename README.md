# GitOps Config
K8s resources to use with [Argo CD](https://argoproj.github.io/argo-cd/)


## Bootstrap New Cluster
```bash
helm install argocd argo/argo-cd --namespace argocd --values values.yaml --create-namespace --set admin.enabled=true

kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

## Use kubeseal
To encrypt a secret using kubeseal:
```
kubeseal --format=yaml --cert=sealed-secrets.pub < some/secret-plain.yaml > some/secret.yaml
```
