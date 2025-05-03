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
Building on:
- [Running Jenkins CI with Podman](https://wmcdonald404.co.uk/2025/04/15/jenkins-on-podman.html)
- [Installing Jenkins Configuration as Code](https://wmcdonald404.co.uk/2025/04/23/jenkins-installing-jcasc.html)

We should be about ready to use the [Jenkins Configuration as Code (aka JCasC)](https://www.jenkins.io/projects/jcasc/) to help with these post-deployment steps.

In some scenarios, you may need to include organisational Certificate Authority certificates in order to permit Jenkins instance(s) to access the update center, if any proxies or zero-trust network infrastructure is involved.

# How-to - Manually

First, this is the manual process to configure a CA certificate into the Jenkins keystore.

1. Ensure you have a certificate for your proxy or ZTA infrastructure, see [Exporting Windows Certificates into WSL](https://wmcdonald404.co.uk/2024/05/19/windows-certificates-into-wsl.html), in the correct format (DER is required for JKS keystores)

2. Start your Jenkins instance

    ```
    $ podman run -d -p 8082:8080 -u $UID -v jenkins-data:/var/jenkins_home --name jenkins docker.io/jenkins/jenkins:lts
    ```

3. Create a directory for the certificates

    ```
    $ podman exec -it jenkins bash -c "mkdir /var/jenkins_home/cacerts/; chmod 700 /var/jenkins_home"
    ```

4. Copy the certificate DER into the container

    ```
    $ podman cp ~/certificate.der jenkins:/var/jenkins_home/cacerts/
    ```

5. Copy the existing certificate store certificates into your certificate directory

    ```
    $ podman exec -it jenkins cp /opt/java/openjdk/lib/security/cacerts /var/jenkins_home/cacerts/
    ```

6. Create a new passphrase for your new certificate store

    ```
    $ export HISTCONTROL=ignorespace
    $   TMP_PASS=$(pwgen -C 8 3 | sed 's/ //g')
    ```

7. Replace the default passphrase on the certificate store

    ```
    $ podman exec -e TMP_PASS=$TMP_PASS -it jenkins keytool -storepasswd -storepass changeit -new $TMP_PASS -keystore /var/jenkins_home/cacerts/cacerts
    ```

8. Import the additional CA certificate

    ```
    $ podman exec -e TMP_PASS=$TMP_PASS -it jenkins keytool -import -trustcacerts -alias 'Cloudflare Root CA' -file /var/jenkins_home/cloudflare.der -keystore /var/jenkins_home/cacerts/cacerts -storepass $TMP_PASS -noprompt
    ```

9. Stop and start the jenkins container

    ```
    $ podman stop jenkins && wait && podman start jenkins
    ```

10. Check the logs.

    ```
    $ podman logs jenkins
    ```

# How-to - Using a Kubernetes spec and Podman pods

Now a more efficient, quicker method.

1. Again, ensure you have a certificate for your proxy or ZTA infrastructure, see [Exporting Windows Certificates into WSL](https://wmcdonald404.co.uk/2024/05/19/windows-certificates-into-wsl.html), in the correct format (DER is required for JKS keystores)

2. Set a temporary password

    ```
    $ echo $(pwgen -C 8 3 | sed 's/ //g')
    ```

3. Create a Pod spec.

    ```
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
        command: ['sh', '-c', 'sleep 5 && echo "Setting up CA certificates..." && echo "mkdir cacerts..."; mkdir -p /var/jenkins_home/cacerts/ &&  echo "copy cacerts..."; cp /opt/java/openjdk/lib/security/cacerts /var/jenkins_home/cacerts/ && echo "replace default keystore passphrase..."; keytool -storepasswd -storepass changeit -new \$TMP_PASS -keystore /var/jenkins_home/cacerts/cacerts && echo "import CA cert..."; keytool -import -trustcacerts -alias "Root CA cert" -file /var/jenkins_home/cert.der -keystore /var/jenkins_home/cacerts/cacerts -storepass \$TMP_PASS -noprompt']
        volumeMounts:
        - name: jenkins-home-pvc
          mountPath: /var/jenkins_home
        - name: cert.der
          mountPath: /var/jenkins_home/cert.der
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
        - name: cert.der
          mountPath: /var/jenkins_home/cert.der
        env:
        - name: JAVA_OPTS
          value: -Djavax.net.ssl.trustStore=/var/jenkins_home/cacerts/cacerts -Djavax.net.ssl.trustStorePassword=foVahqu8eeDu7ohfAequ8ohx
        - name: TMP_PASS
          value: foVahqu8eeDu7ohfAequ8ohx
      volumes:
      - name: jenkins-home-pvc
        persistentVolumeClaim:
          claimName: jenkins-home
      - name: cert.der
        hostPath:
          path: /home/wmcdonald/cert.der
          type: File
    EOF
    ```

4. Playback the pod specification to create the pod

  ```
  $ podman play kube jenkins-spec.yaml
  ```

# References

- [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Handle initContainer for Pods](https://github.com/containers/podman/issues/6480)