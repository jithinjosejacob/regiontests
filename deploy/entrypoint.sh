#!/bin/bash
# This script is for running cypress 
# tests in parallel for all aws regions

set -e

## Setting up service account to run the jobs
#kubectl apply -f deploy/rbac.yaml

# Declare an array of all target regions to run the test
 declare -a regions=("au" "us" "ca")

touch deploy/cypress-all-region-test.yaml
# Prepare the test jobs for all the regions
for val in ${regions[@]}; do
   sed -i "/name: CYPRESS_region/{n;s/.*/              value: "$val"/}" deploy/cypress-test.yaml
   cat deploy/cypress-test.yaml >> deploy/cypress-all-region-test.yaml
done

# Create the cypress test
kubectl create -f deploy/cypress-all-region-test.yaml
rm -rf deploy/cypress-all-region-test.yaml

# Waiting for all job pods to get in running state
kubectl wait --for=condition=Ready pods -l app=cypress-test --request-timeout 5m

# Printing logs for all the pods
kubectl logs -f -l app=cypress-test


# Cleanup
kubectl delete -f deploy/rbac.yaml
kubectl delete jobs -l app=cypress-test
