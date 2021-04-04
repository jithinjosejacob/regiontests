#!/bin/bash
# This script is for running cypress 
# tests in parallel for all aws regions

set -e 

NS="training"

## Install dependencies to run j2 command
apt-get update && apt-get install -y --no-install-recommends python-pip
pip install j2

## Exporting default values for the given variables
export CYPRESS_requestApiKey="${CYPRESS_requestApiKey:-default}"
export CYPRESS_onboardingUrl="${CYPRESS_onboardingUrl:-default}"
export CYPRESS_apiUrl="${CYPRESS_apiUrl:-default}"
export CYPRESS_apiHostUrl="${CYPRESS_apiHostUrl:-default}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-default}"
export AWS_REGION="${AWS_REGION:-default}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-default}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-default}"
export AWS_REGION="${AWS_REGION:-default}"

## Running j2 command to setup variables in the yaml
j2 cypress-test.j2 > cypress-test.yaml

# Declare an array of all target regions to run the test
declare -a regions=("au" "us" "ca" "au" "us")

touch deploy/cypress-all-region-test.yaml
# Prepare the test pods for all the regions
for val in ${regions[@]}; do
   sed -i "/name: CYPRESS_region/{n;s/.*/          value: "$val"/}" deploy/cypress-test.yaml
   cat deploy/cypress-test.yaml >> deploy/cypress-all-region-test.yaml
done

# Create the cypress test
kubectl create -f deploy/cypress-all-region-test.yaml -n $NS
rm -rf deploy/cypress-all-region-test.yaml
echo 

# Waiting for the test to get completed
echo "Waiting for all test pods to get completed .........."
declare -a array=$( kubectl get pods -n $NS -l run=cypress-test-unique -o=jsonpath="{range .items[*]}{.metadata.name}{'\t'}" )
RETRIES=50
for i in ${array[@]}; do
   while ([ "$( kubectl get pods $i -n $NS -o=jsonpath='{.status.phase}' )" != "Succeeded" ]); do
      echo "Waiting for \"$i\" to get completed ... $RETRIES retries left."
      sleep 10
      RETRIES=$((RETRIES-1))
      if [ $RETRIES == "0" ]; then break; fi
   done
      if [ $RETRIES == "0" ]; then break; fi
done

## printing the falied test pods
INDEX=1
head="true"
FAILED_TESTS=()
PASSED_TESTS=()
for i in ${array[@]}; do
   if [ "$( kubectl get pods $i -n $NS -o=jsonpath='{.status.phase}' )" != "Succeeded" ]; then
      if [ ${head} == "true" ]; then
         echo
         echo "Failed test pods are:"
         head="false"
      fi
      echo "${INDEX}. $i"
      INDEX=$((INDEX+1))
      FAILED_TESTS+=($i)
   else
      PASSED_TESTS+=($i)
   fi
done

## printing the logs
if [ "${INDEX}" == "1" ];then
   echo "Congratulations all tests ran successfully!!!"
   echo "Printing Logs for all the tests...."
   for i in ${array[@]}; do
         kubectl logs $i -n $NS -c cypress-test
   done   
else
   echo "LOGS OF PASSED TESTS ................"
   for i in ${PASSED_TESTS[@]}; do
         kubectl logs $i -n $NS -c cypress-test
   done
   echo "LOGS OF FAILED TESTS .............."
   for i in ${FAILED_TESTS[@]}; do
         kubectl logs $i -n $NS -c cypress-test
   done
fi

# Cleanup the test pods
kubectl delete pods -n $NS -l run=cypress-test-unique
rm -rf deploy/cypress-test.yaml
if [ "${INDEX}" != "1" ];then
   echo "Some cypress tests failed please check the above logs for the details"
   exit 1
fi
