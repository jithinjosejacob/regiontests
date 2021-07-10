
#!/bin/bash
# This script is for running cypress

# stop execution if any error happens
set -e

NS="${CYPRESS_NS:-training}"

## Install dependencies to run j2 command
pip install j2cli[yaml]
# manually place the j2 dependancy file
chmod +x ./deploy/j2


## Running j2 command to setup variables in the yaml
j2 deploy/cypress-test.j2 > deploy/cypress-test.yaml
# Declare an array of all target regions to run the test
# regions = ("au "us")
declare -a regions="${CYPRESS_testTypes}"

touch deploy/cypress-all-region-test.yaml
# Prepare the test pods for all the regions
for val in ${regions[@]}; do
   echo "Here"
   echo $val
   sed -i "/name: CYPRESS_testType/{n;s/.*/              value: "$val"/}" deploy/cypress-test.yaml
   # cat deploy/cypress-test.yaml >> deploy/cypress-all-region-test.yaml
done
