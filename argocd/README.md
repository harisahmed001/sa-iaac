# Image App

This application uploads image to s3, stores the url to mongodb and cache it to redis.

## Run

Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Port Forwarding
```bash
kubectl get services -n argocd
kubectl port-forward service/argocd-server -n argocd 8080:443
```

Login Secret
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Configuration
```yml
project: default
source:
  repoURL: 'https://github.com/harisahmed001/sa-iaac'
  path: helm-chart
  targetRevision: HEAD
  helm:
    valueFiles:
      - values.yaml
    parameters:
      - name: envs.MONGO_DB
        value: testasdasd
destination:
  server: 'https://kubernetes.default.svc'
syncPolicy:
  automated: {}
  syncOptions:
    - CreateNamespace=true
    - Validate=false
```

