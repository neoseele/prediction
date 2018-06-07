```sh
gcloud compute instances create prediction \
    --image-family=debian-8 \
    --image-project=debian-cloud \
    --machine-type=g1-small \
    --scopes userinfo-email,cloud-platform \
    --metadata-from-file startup-script=gce/startup-script.sh \
    --zone us-central1-a \
    --tags http-server

gcloud compute instances get-serial-port-output prediction --zone us-central1-a

gcloud compute firewall-rules create default-allow-http-8080 \
    --allow tcp:8080 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow port 8080 access to http-server"

gcloud deployment-manager deployments create deploy-prediction-with-template --config gce/deployment_manager/config.yaml --async
```
