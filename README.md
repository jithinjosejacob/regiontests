# regiontests
Microsoft Website Region Tests

Prerequisite- You need to have nodejs in your machine to run tests locally
Check node--version and npm --version before starting

##Running Tests locally##
Step1: Clone the repo to your local machine


Step2: Set an environment variable for the region you want to run in below format

CYPRESS_region=au(for AU)
This will open up https://www.microsoft.com/en-au/en-au/

AWS keys are optional, I am using it to pull some data from AWS on runtime.

If you need US Region,set CYPRESS_region=us
This will open up https://www.microsoft.com/en-au/en-us/

If you need CA Region,set CYPRESS_region=ca
This will open up https://www.microsoft.com/en-au/en-ca/

Step3: Navigate to root folder of repo and run npm install

Step4: Run - npm run test(This will trigger tests and open microsoft website specific to that region)



##Run Tests inside Docker##

Step1:Run Command docker-compose up

# Run Test Using Kubernetes

**Note:** We are now not using docker-compose.yml so we can remove it as well.

**Pre-requisites:**

- You need to have an active kuernetes cluster installed and running with `kubectl` commands.

- Run `./deploy/entrypoint.sh`: The test will be automatically performed across the regions and you'll get the logs as [shown here](deploy/logs.txt). 
