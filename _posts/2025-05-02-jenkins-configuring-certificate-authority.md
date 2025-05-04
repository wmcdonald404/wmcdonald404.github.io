---
title: "Installing a CA Root Certificate in Jenkins"
tags:
- containers
- jenkins
- podman
- certificate
---

* TOC
{:toc}

# Overview
Building on what we learned with:
- [Running Jenkins CI with Podman](https://wmcdonald404.co.uk/2025/04/15/jenkins-on-podman.html)
- [Installing Jenkins Configuration as Code](https://wmcdonald404.co.uk/2025/04/23/jenkins-installing-jcasc.html)

We should be about ready to use the [Jenkins Configuration as Code (aka JCasC)](https://www.jenkins.io/projects/jcasc/) to help with these post-deployment steps.

In some scenarios, you may need to include organisational Certificate Authority certificates in order to permit Jenkins instance(s) to access the update center, if any proxies or zero-trust network infrastructure is involved.

# How-to - Manually

First, this is the manual process to configure a CA certificate into the Jenkins keystore.

1. Ensure you have a certificate for your proxy or ZTA infrastructure, see [Exporting Windows Certificates into WSL](https://wmcdonald404.co.uk/2024/05/19/windows-certificates-into-wsl.html), in the correct format (DER is required for JKS keystores)

2. Start your Jenkins instance

    ```shell
    $ podman run -d -p 8082:8080 -u $UID -v jenkins-data:/var/jenkins_home --name jenkins docker.io/jenkins/jenkins:lts
    ```

3. Create a directory for the certificates

    ```shell
    $ podman exec -it jenkins bash -c "mkdir /var/jenkins_home/cacerts/; chmod 700 /var/jenkins_home"
    ```

4. Copy the certificate DER into the container

    ```shell
    $ podman cp ~/certificate.der jenkins:/var/jenkins_home/cacerts/
    ```

5. Copy the existing certificate store certificates into your certificate directory

    ```shell
    $ podman exec -it jenkins cp /opt/java/openjdk/lib/security/cacerts /var/jenkins_home/cacerts/
    ```

6. Create a new passphrase for your new certificate store

    ```shell
    $ export HISTCONTROL=ignorespace
    $   TMP_PASS=$(pwgen -C 8 3 | sed 's/ //g')
    ```

7. Replace the default passphrase on the certificate store

    ```shell
    $ podman exec -e TMP_PASS=$TMP_PASS -it jenkins keytool -storepasswd -storepass changeit -new $TMP_PASS -keystore /var/jenkins_home/cacerts/cacerts
    ```

8. Import the additional CA certificate

    ```shell
    $ podman exec -e TMP_PASS=$TMP_PASS -it jenkins keytool -import -trustcacerts -alias 'Root CA Certificate' -file /var/jenkins_home/certificate.der -keystore /var/jenkins_home/cacerts/cacerts -storepass $TMP_PASS -noprompt
    ```

9. Stop and start the jenkins container

    ```shell
    $ podman stop jenkins && wait && podman start jenkins
    ```

10. Check the logs.

    ```shell
    $ podman logs jenkins
    ```

# How-to - Using a Kubernetes spec and Podman pods

Now a more efficient, quicker method.

1. Again, ensure you have a certificate for your proxy or ZTA infrastructure, see [Exporting Windows Certificates into WSL](https://wmcdonald404.co.uk/2024/05/19/windows-certificates-into-wsl.html), in the correct format (DER is required for JKS keystores)

2. Set a temporary password

    ```shell
    $ echo $(pwgen -C 8 3 | sed 's/ //g')
    ```

3. Create a Pod spec.

    ```shell
    $ cat <<EOF > ~/jenkins-spec.yaml
    # Save the output of this file and use kubectl create -f to import
    # it into Kubernetes.
    #
    # Created with podman-5.4.2
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        app: jenkins
      name: jenkins
    spec:
      initContainers:
      - name: init
        env:
        - name: TMP_PASS
          value: foVahqu8eeDu7ohfAequ8ohx
        image: docker.io/jenkins/jenkins:lts
        command: ['sh', '-c', 'sleep 5 && echo "Setting up CA certificates..." && echo "mkdir cacerts..."; mkdir -p /var/jenkins_home/cacerts/ &&  echo "copy cacerts..."; cp /opt/java/openjdk/lib/security/cacerts /var/jenkins_home/cacerts/ && echo "replace default keystore passphrase..."; keytool -storepasswd -storepass changeit -new \$TMP_PASS -keystore /var/jenkins_home/cacerts/cacerts && echo "import CA cert..."; keytool -import -trustcacerts -alias "Root CA cert" -file /var/jenkins_home/certificate.der -keystore /var/jenkins_home/cacerts/cacerts -storepass \$TMP_PASS -noprompt']
        volumeMounts:
        - name: jenkins-home-pvc
          mountPath: /var/jenkins_home
        - name: certificate.der
          mountPath: /var/jenkins_home/certificate.der
      containers:
      - name: controller
        image: docker.io/jenkins/jenkins:lts
        ports:
        - containerPort: 8080
          hostPort: 8080
        securityContext:
          runAsGroup: 1000
          runAsUser: 1000
        volumeMounts:
        - name: jenkins-home-pvc
          mountPath: /var/jenkins_home
        - name: certificate.der
          mountPath: /var/jenkins_home/certificate.der
        env:
        - name: JAVA_OPTS
          value: -Djavax.net.ssl.trustStore=/var/jenkins_home/cacerts/cacerts -Djavax.net.ssl.trustStorePassword=foVahqu8eeDu7ohfAequ8ohx
        - name: TMP_PASS
          value: foVahqu8eeDu7ohfAequ8ohx
      volumes:
      - name: jenkins-home-pvc
        persistentVolumeClaim:
          claimName: jenkins-home
      - name: certificate.der
        hostPath:
          path: /home/wmcdonald/certificate.der
          type: File
    EOF
    ```

4. Playback the pod specification to create the pod

    ```
    $ podman kube play jenkins-spec.yaml
    ```

# How-to - Using Kubernetes secrets and Podman secrets
In the first iteration using a Kubernetes specification to define our pod, we have secrets in the clear. This is **obviously** not a good idea.

We can use Podman secrets mapped to Kubernetes secrets in our specification to improve this.

1. First, set a random password and extrapolate the base64 equivalent password and corresponding `JAVA_OPTS`:

    ```shell
    $  JKS_PASSWORD=$(pwgen -C 8 3 | sed 's/ //g')
    $  BASE64_JKS_PASSWORD=$(echo $JKS_PASSWORD | base64 -w0)
    $  BASE64_JAVA_OPTS=$(echo "-Djavax.net.ssl.trustStore=/var/jenkins_home/cacerts/cacerts -Djavax.net.ssl.trustStorePassword=$JKS_PASSWORD" | base64 -w0)
    ```

2. Create a secret specification

    ```shell
    $ cat <<EOF > ~/jenkins-secrets.yaml
    apiVersion: v1
    data:
      jks-pass: $BASE64_JKS_PASSWORD
      java-opts: $BASE64_JAVA_OPTS
    kind: Secret
    metadata:
      creationTimestamp: null
      name: jenkins-secrets
    EOF
    ```

3. Play that specification to create the secrets

    ```shell
    $ podman kube play ~/jenkins-secrets.yaml
    ```

4. Create a new container specification including references to our new secrets

    ```shell
    $ cat <<EOF > ~/jenkins-spec.yaml
    # Save the output of this file and use kubectl create -f to import
    # it into Kubernetes.
    #
    # Created with podman-5.4.2
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        app: jenkins
      name: jenkins
    spec:
      initContainers:
      - name: init
        env:
        - name: JKS_PASS
          valueFrom:
            secretKeyRef:
              name: jenkins-secrets
              key: jks-pass
        image: docker.io/jenkins/jenkins:lts
        command: ['sh', '-c']
        args:
        - sleep 5 && 
          echo "Setting up CA certificates..." && 
          echo "mkdir cacerts..."; 
          mkdir -p /var/jenkins_home/cacerts/ && 
          echo "copy cacerts..."; 
          cp /opt/java/openjdk/lib/security/cacerts /var/jenkins_home/cacerts/ && 
          echo "replace default keystore passphrase..."; 
          keytool -storepasswd -storepass changeit -new \$JKS_PASS -keystore /var/jenkins_home/cacerts/cacerts && 
          echo "import CA cert...";
          keytool -import -trustcacerts -alias 'Root CA Certificate' -file /var/jenkins_home/certificate.der -keystore /var/jenkins_home/cacerts/cacerts -storepass \$JKS_PASS -noprompt;
          echo \$JKS_PASS > \$JENKINS_HOME/secrets/initialJKSPassword
        volumeMounts:
        - name: jenkins-home-pvc
          mountPath: /var/jenkins_home
        - name: certificate.der
          mountPath: /var/jenkins_home/certificate.der
      containers:
      - name: controller
        image: docker.io/jenkins/jenkins:lts
        ports:
        - containerPort: 8080
          hostPort: 8080
        securityContext:
          runAsGroup: 1000
          runAsUser: 1000
        volumeMounts:
        - name: jenkins-home-pvc
          mountPath: /var/jenkins_home
        env:
        - name: JAVA_OPTS
          valueFrom:
            secretKeyRef:
              name: jenkins-secrets
              key: java-opts
      volumes:
      - name: jenkins-home-pvc
        persistentVolumeClaim:
          claimName: jenkins-home
      - name: certificate.der
        hostPath:
          path: /home/wmcdonald/certificate.der
          type: File
    EOF
    ```

5. Play that specification to create the container

    ```shell
    $ podman kube play ~/jenkins-spec.yaml
    ```

6. Clean-up the shell variables and the on-disk secret

    ```shell
    $ unset JKS_PASSWORD BASE64_JKS_PASSWORD BASE64_JAVA_OPTS
    ```

# References

- [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Handle initContainer for Pods](https://github.com/containers/podman/issues/6480)
- [Podman secrets: a better way to pass environment variables to containers](https://martincarstenbach.com/2022/12/19/podman-secrets-a-better-way-to-pass-environment-variables-to-containers/)
- [Storing sensitive data using Podman secrets: Which method should you use?](https://www.redhat.com/en/blog/podman-kubernetes-secrets)