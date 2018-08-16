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
gcloud compute instance-templates create $TEMPLATE \
  --machine-type $MACHINE_TYPE \
  --scopes $SCOPES \
  --metadata serial-port-enable=1 \
  --metadata-from-file startup-script=$STARTUP_SCRIPT \
  --image-family $IMAGE_FAMILY \
  --image-project $IMAGE_PROJECT \
  --tags $TAGS
# [END create_template]

# Create the managed instance group.

# [START create_group]
gcloud compute instance-groups managed create $GROUP \
  --base-instance-name $GROUP \
  --size $MIN_INSTANCES \
  --template $TEMPLATE \
  --zone $ZONE
# [END create_group]

# [START create_named_port]
gcloud compute instance-groups managed set-named-ports $GROUP \
  --named-ports http:$PORT \
  --zone $ZONE
# [END create_named_port]

