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



- Run the script: 

```bash
./deploy/entrypoint.sh
```

- Check the pods comming up
```bash
NAME                       READY   STATUS              RESTARTS   AGE
cypress-test-cftxq-t5c8t   0/1     ContainerCreating   0          3s
cypress-test-dsvvj-hzbn9   1/1     Running             0          5s
cypress-test-tmm2m-jd9wh   1/1     Running             0          7s
```

- All pods comes in running state
```
Every 2.0s: kubectl get pods                       

NAME                       READY   STATUS    RESTARTS   AGE
cypress-test-cftxq-t5c8t   1/1     Running   0          10s
cypress-test-dsvvj-hzbn9   1/1     Running   0          12s
cypress-test-tmm2m-jd9wh   1/1     Running   0          14s
```

- CPU and Memory used by the pods
```bash
NAME                       CPU(cores)   MEMORY(bytes)   
cypress-test-cftxq-t5c8t   0m           0Mi             
cypress-test-dsvvj-hzbn9   0m           4Mi             
cypress-test-tmm2m-jd9wh   0m           4Mi             
```
- Check the logs of any one pod

```bash
$ kubectl logs -f cypress-test-cftxq-t5c8t

> regiontests@1.0.0 test /apt-agency-api-testing
> npx cypress run --spec 'cypress/integration/**.js' --headless


================================================================================

  (Run Starting)

  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Cypress:    6.8.0                                                                              │
  │ Browser:    Electron 87 (headless)                                                             │
  │ Specs:      1 found (visitMicrosoft.js)                                                        │
  │ Searched:   cypress/integration/**.js                                                          │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘


────────────────────────────────────────────────────────────────────────────────────────────────────
                                                                                                    
  Running:  visitMicrosoft.js                                                               (1 of 1)


  Check Microsoft Website
    ✓ Check Microsoft Website for every region (4613ms)


  1 passing (8s)


  (Results)

  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Tests:        1                                                                                │
  │ Passing:      1                                                                                │
  │ Failing:      0                                                                                │
  │ Pending:      0                                                                                │
  │ Skipped:      0                                                                                │
  │ Screenshots:  0                                                                                │
  │ Video:        true                                                                             │
  │ Duration:     6 seconds                                                                        │
  │ Spec Ran:     visitMicrosoft.js                                                                │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘


  (Video)

  -  Started processing:  Compressing to 32 CRF                                                     
  -  Finished processing: /apt-agency-api-testing/cypress/videos/visitMicrosoft.js.mp    (4 seconds)
                          4                                                                         


================================================================================

  (Run Finished)


       Spec                                              Tests  Passing  Failing  Pending  Skipped  
  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ✔  visitMicrosoft.js                        00:06        1        1        -        -        - │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘
    ✔  All specs passed!                        00:06        1        1        -        -        -  
```