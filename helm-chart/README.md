# Image App

This application uploads image to s3, stores the url to mongodb and cache it to redis.

## Run

Helm Plugins
```bash
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/jkroepke/helm-secrets
```

Chart Install
```bash
helm secrets upgrade -f ./secrets.yml -f ./values.yaml imageapp ./
```
