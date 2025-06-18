Alarm 2 is triggering an OutOfMemoryError in the java visits service. This will cause Faults in the frontend when visits requests are made. This will describe the steps to take in order to introduce the error into the service.

To begin, deploy the pet-clinic application from the main branch following the terraform instructions.

The OutOfMemoryError will come from the `visits-service`, which is defined in the `springcommunity/spring-petclinic-visits-service` ECR repository. 

### Trigger Alarm 2
All deployments of the service are done through GitHub Actions. When a new commit is made on the main branch, the deploy action will update the serivce. 

1. Simply commit the code in the visits service that causes the memory error. 
    - The alarm2.sh script does this easily

    ``` shell
    ./alarm2.sh trigger
    ```

### Rollback Alarm 2
1. Rolling back can be done by reverting the code change in the visits service
    - The alarm2.sh script can also help rollback

    ``` shell
    ./alarm2.sh rollback
    ```


The [`VisitsResource` file](https://github.com/CloudSmith-Agent-Beta/application-signals-demo-agent/blob/main/spring-petclinic-visits-service/src/main/java/org/springframework/samples/petclinic/visits/web/VisitResource.java) is the pertinent file that is changed. Check this file to see if the problematic memory code is currently deployed.