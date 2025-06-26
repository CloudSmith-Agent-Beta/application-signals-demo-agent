Alarm 2 is triggering an OutOfMemoryError in the java visits service. This will describe the steps to take in order to introduce the error into the service.

To begin, deploy the pet-clinic application from the main branch following the terraform instructions.

The OutOfMemoryError will come from the `visits-service`, which is being run on 3 replica pods in our EKS cluster. The code for the service is in the `spring-petclinic-visits-service` folder, and it is packed into a docker image stored in the `springcommunity/spring-petclinic-visits-service` ECR repository. 

We are going to build a new docker image with the buggy code, upload it to ECR with a distinct tag, and then update the image of one of the `visit-service` pods to the new image.

### Deploy Alarm 2:
#### Upload the new service docker image
1. Switch to the alarm2-deploy branch

    ``` shell
    git checkout alarm2-deploy
    ```
  
2. Set environment variables. These should be set from the terraform deployment, but if not:

    ``` shell
    export ACCOUNT=<Account-Number>
    export REGION=<region>
    export REPOSITORY_PREFIX=${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
    export TAG=OOMError
    ```

3. Build the new docker image

    ``` shell
    ./mvnw clean install -P buildDocker
    ```

    This should build all of the images, including `springcommunity/spring-petclinic-visits-service` with the latest tag. You can run `docker image ls` to check.

4. Tag and push the visits service image
    
    ``` shell
    docker tag springcommunity/spring-petclinic-visits-service:latest ${REPOSITORY_PREFIX}/springcommunity/spring-petclinic-visits-service:${TAG}

    docker push ${REPOSITORY_PREFIX}/springcommunity/spring-petclinic-visits-service:${TAG}
    ```

#### Update the service pod to use the new image
This section is *slighty* less automated.

1. Navigate to the `springcommunity/spring-petclinic-visits-service` repository in ECR. Check that an image with the tag `OOMError`.

2. List your running EKS pods

    ``` shell
    kubectl get pods
    ```

    Find an instance of the visits service - should be of the form `visits-service-java-<1a234b567c>-<12a34>`
    
3. Copy one of the names into an environment variable

    ``` shell
    export POD=<Pod Name>
    ```

4. Pull the pod's yaml definition into a local file

    ``` shell
    kubectl get pod $POD -o yaml > visit-pod.yaml
    ```

5. Edit `visit-pod.yaml` to replace the tags and sha of the image

    - Change `latest` to `OOMError` on lines 85 and 217
    - Copy the digest of the image tagged `OOMError` on the ECR console
    - Change `sha256:<digest>` to the copied digest on line 218
    - Save the file

6. Update the service pod

    ``` shell
    cat visit-pod.yaml | kubectl replace -f -
    ```

The pod is now using the new image! Wait a few minutes for the traffic generator to give requests to the service, and you will see `OutOfMemoryError`s coming from the service.


If you would like to rollback the change, repeat the steps to change the pod's image to the one tagged `latest`.
    