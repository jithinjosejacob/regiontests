Scenario 1) Tests finishing off before the retry of 50

Run - npm run test

Currently tests takes only 5 seconds to complete in every pod.

After 5 seconds test run will complete

After 5 seconds, pods needs to exit out, and show the corresponding status,its probably a pass scenario.

We dont have to wait until the retry limit of 50

  (Run Finished)


       Spec                                              Tests  Passing  Failing  Pending  Skipped  
  ┌────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ✔  visitMicrosoft.js                        00:05        1        1        -        -        - │
  └────────────────────────────────────────────────────────────────────────────────────────────────┘
    ✔  All specs passed!                        00:05        1        1        -        -        - 


Scenario 2) Tests running after the retry limit

Currently retry is set to 50

Change the retry limit of deploy script from 50 to 1

And run npm run go

This will open up Microsoft site and wait for 2 mins in the test(visitMicrosoftAndWait.js test)

Expecting pod to exit out before the run even completes
