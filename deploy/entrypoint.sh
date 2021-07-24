#!/bin/bash
# This script is for running cypress

#set -e

NS="training"

## Install dependencies to run j2 command
#python3 -m ensurepip
#pip3 install --no-cache --upgrade pip setuptools
pip install j2cli[yaml]

chmod +x ./deploy/j2

#Exporting default values for the given variables
CYPRESS_sharedSecret="${CYPRESS_sharedSecret:-default}"
#CYPRESS_requestApiKey="${CYPRESS_requestApiKey:-default}"
CYPRESS_onboardingUrl="${CYPRESS_onboardingUrl:-default}"
CYPRESS_apiUrl="${CYPRESS_apiUrl:-default}"
CYPRESS_apiHostUrl="${CYPRESS_apiHostUrl:-default}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-default}"
AWS_REGION="${AWS_REGION:-default}"
AWS_ACCESS_KEY_ID_2="${AWS_ACCESS_KEY_ID_2:-default}"
AWS_SECRET_ACCESS_KEY_2="${AWS_SECRET_ACCESS_KEY_2:-default}"

# Declare an array of all target regions to run the test
declare -a regions=("AU" "BU")
touch deploy/cypress-all-region-test.yaml

# Prepare the test pods YAML for all the regions
for val in ${regions[@]}; do
   ## Running j2 command to setup variables in the yaml
   export CYPRESS_reasonName=${val}
   ./deploy/j2/j2 deploy/cypress-test.j2 >> deploy/cypress-all-region-test.yaml
   echo >> deploy/cypress-all-region-test.yaml
done

# Create the cypress test
kubectl create -f deploy/cypress-all-region-test.yaml -n $NS
rm -rf deploy/cypress-all-region-test.yaml
echo

# Waiting for the test to get completed
echo "Waiting for all test pods to get completed .........."
declare -a array=$( kubectl get pods -n $NS -l run=cypress-test-unique -o=jsonpath="{range .items[*]}{.metadata.name}{'\t'}" )
RETRIES=15
for i in ${array[@]}; do
   while ([ "$( kubectl get pods $i -n $NS -o=jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' )" != "Completed" ] || [ "$( kubectl get pods $i -n $NS -o=jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' )" != "Error" ]); do
      kubectl get pods -n $NS
      echo "Waiting for \"$i\" to get completed ... $RETRIES retries left."
      sleep 10
      #kubectl describe pod -n $NS -l run=cypress-test-unique
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
   if [ "$( kubectl get pods $i -n $NS -o=jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}' )" != "0" ] || [ "$( kubectl get pods $i -n $NS -o=jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}' )" == "Error" ]; then
      if [ ${head} == "true" ]; then
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
kubectl delete jobs -n $NS -l run=cypress-test-unique
rm -rf deploy/cypress-test.yaml
if [ "${INDEX}" != "1" ];then
   echo "Some cypress tests failed please check the above logs for the details"
   exit 1
fi
