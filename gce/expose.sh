#! /bin/bash
# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

REGION=us-central1
ZONE=us-central1-a

GROUP=prediction-group
TEMPLATE=$GROUP-tmpl
MACHINE_TYPE=g1-small
STARTUP_SCRIPT=startup-script.sh
# IMAGE_FAMILY=ubuntu-1604-lts
# IMAGE_PROJECT=ubuntu-os-cloud
IMAGE_FAMILY=debian-9
IMAGE_PROJECT=debian-cloud
SCOPES="userinfo-email,\
logging-write,\
storage-full,\
datastore,\
https://www.googleapis.com/auth/pubsub,\
https://www.googleapis.com/auth/projecthosting"
TAGS=http-server

MIN_INSTANCES=2
MAX_INSTANCES=4
COOL_DOWN_PERIOD=120
TARGET_UTILIZATION=0.8

SERVICE=prediction-service
HC=prediction-hc
PORT=8080

#
# Instance group setup
#

# First we have to create an instance template.
# This template will be used by the instance group
# to create new instances.

# [START create_template]
# gcloud compute instance-templates create $TEMPLATE \
#   --machine-type $MACHINE_TYPE \
#   --scopes $SCOPES \
#   --metadata serial-port-enable=1 \
#   --metadata-from-file startup-script=$STARTUP_SCRIPT \
#   --image-family $IMAGE_FAMILY \
#   --image-project $IMAGE_PROJECT \
#   --tags $TAGS
# [END create_template]

# Create the managed instance group.

# [START create_group]
# gcloud compute instance-groups managed create $GROUP \
#   --base-instance-name $GROUP \
#   --size $MIN_INSTANCES \
#   --template $TEMPLATE \
#   --zone $ZONE
# [END create_group]

# [START create_named_port]
# gcloud compute instance-groups managed set-named-ports $GROUP \
#   --named-ports http:$PORT \
#   --zone $ZONE
# [END create_named_port]

#
# Load Balancer Setup
#

# A complete HTTP load balancer is structured as follows:
#
# 1) A global forwarding rule directs incoming requests to a target HTTP proxy.
# 2) The target HTTP proxy checks each request against a URL map to determine the
#    appropriate backend service for the request.
# 3) The backend service directs each request to an appropriate backend based on
#    serving capacity, zone, and instance health of its attached backends. The
#    health of each backend instance is verified using either a health check.
#
# We'll create these resources in reverse order:
# service, health check, backend service, url map, proxy.

# Create a health check
# The load balancer will use this check to keep track of which instances to send traffic to.
# Note that health checks will not cause the load balancer to shutdown any instances.

# [START create_health_check]
gcloud compute http-health-checks create $HC \
  --request-path /_ah/health \
  --port $PORT
# [END create_health_check]

# Create a backend service, associate it with the health check and instance group.
# The backend service serves as a target for load balancing.

# [START create_backend_service]
gcloud compute backend-services create $SERVICE \
  --global \
  --http-health-checks $HC
# [END create_backend_service]

# [START add_backend_service]
gcloud compute backend-services add-backend $SERVICE \
  --global \
  --instance-group $GROUP \
  --instance-group-zone $ZONE
# [END add_backend_service]

# Create a URL map and web Proxy. The URL map will send all requests to the
# backend service defined above.

# [START create_url_map]
gcloud compute url-maps create $SERVICE-map \
  --default-service $SERVICE
# [END create_url_map]

# [START create_http_proxy]
gcloud compute target-http-proxies create $SERVICE-proxy \
  --url-map $SERVICE-map
# [END create_http_proxy]

# Create a global forwarding rule to send all traffic to our proxy

# [START create_forwarding_rule]
gcloud compute forwarding-rules create $SERVICE-http-rule \
  --global \
  --target-http-proxy $SERVICE-proxy \
  --ports $PORT
# [END create_forwarding_rule]


# [START create_firewall]
gcloud compute firewall-rules create $SERVICE-allow-http-$PORT \
  --allow tcp:$PORT \
  --source-ranges 0.0.0.0/0 \
  --target-tags $TAGS \
  --description "Allow port $PORT access to $TAGS"
# [END create_firewall]
