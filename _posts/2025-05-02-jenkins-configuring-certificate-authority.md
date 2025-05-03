---
title: "Jenkins with CA Root certificate"
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
 
# How-to 

1. Ensure you have a certificate for your proxy or ZTA infrastructure, see [Exporting Windows Certificates into WSL](https://wmcdonald404.co.uk/2024/05/19/windows-certificates-into-wsl.html), in the correct format (DER is required for JKS keystores)

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