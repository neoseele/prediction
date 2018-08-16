# Deploy

## Via deployment-manager

```sh
gcloud deployment-manager deployments create deploy-prediction-with-template --config gce/deployment_manager/config.yaml --async
```

## Via script

```sh
# creates the managed instance group
./deploy.sh

# expose the app via HTTP LB
./expose.sh
```
