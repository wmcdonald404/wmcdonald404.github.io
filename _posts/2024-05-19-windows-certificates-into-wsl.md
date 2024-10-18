---
title: Exporting Windows Certificates into WSL
tags:
- windows
- certificates
- wsl
---

## Overview
This post outlines a simple process to export certificates from the Windows certificate store and import into a WSL2 instance.

## Background
Enterprises will typically have default mechanisms to generate and distribute certificates to end-user compute (EUC) devices for 3rd party products, for example corporate proxy infrastructure or other security or network based services. 

These systems are usually set up to cover the majority of common end-user use cases but not necessarily slightly more niche system usage required by developers or administrators. In this situation integrations work seamlessly for browsers and OOTB Windows systems but won't automatically extend into local VMs, Docker Desktop containers or WSL instances.

This describes a simple mechanim to pull individual certificates (for example, root CA certificates) from Windows and import them into the WSL certificate store. In this example WSL2 running Ubuntu 24.04 but this would be easily adapted for other WSL targets.

## How-to

### Windows
On your Windows system:

TODO: Step to indentify the proxy cert from properties other than its `<CERT ID>` 

1. Check the path to the root CA certificate in the Windows certificate on your laptop
    ```
    PS C:\Users\Will> Get-ChildItem -Path Cert:\LocalMachine\Root\<CERT ID> | Select-Object -Property *
    ```
2. Verify the Issuer and Subject.

3. Set the location of the existing proxy root CA certificate in the Windows certificate store
    ```
    PS C:\Users\Will> $proxycert = Get-ChildItem -Path Cert:\LocalMachine\Root\<CERT ID>
    ```
4. Export the certificate as [type CERT](https://learn.microsoft.com/en-us/powershell/module/pki/export-certificate?view=windowsserver2022-ps#-type):

    > `CERT`: A `.cer` file format which contains a single DER-encoded certificate. This is the default value for one certificate.
    ```
    PS C:\Users\Will> Export-Certificate -Cert $proxycert -FilePath $Env:USERPROFILE\Downloads\proxy.der -Type CERT
    ```

### WSL
In your WSL2 instance:

1. Convert the DER-encoded certificate to a PEM and place into the local root CA trust staging directory
    ```
    will@ubuntu:~$ sudo openssl x509 -inform der \
      -in /mnt/c/Users/<user.name>/Downloads/proxy.der \
      -out /usr/local/share/ca-certificates/proxy.crt
    ```
  
    ***Notes:*** 
    
    - Change the `<user.name>` in `/mnt/c/Users/<user.name>/Downloads` as needed.
    - The file placed into `/usr/local/share/ca-certificates/` **MUST** have a .crt extension.
    - `sudo` escalation for root user permission is _not required_ for the OpenSSL certificate encoding conversion, but is required in order to output the resultant file to the /usr/local/share/ca-certificates directory.

2. Update the root Certificate Authorities
    ```
    will@ubuntu:~$ sudo update-ca-certificates
    Updating certificates in /etc/ssl/certs...
    rehash: warning: skipping ca-certificates.crt,it does not contain exactly one certificate or CRL
    1 added, 0 removed; done.
    Running hooks in /etc/ca-certificates/update.d...
    done.
    ```

3. Check that the certificate’s been linked in /etc/ssl/certs
    ```
    will@ubuntu:~$ ll /etc/ssl/certs/proxy.pem
    lrwxrwxrwx 1 root root 44 May 15 10:46 /etc/ssl/certs/proxy.pem -> /usr/local/share/ca-certificates/proxy.crt
    ```

## Further reading
- [Microsoft Windows - Certificate Stores](https://learn.microsoft.com/en-us/windows-hardware/drivers/install/certificate-stores)
- [Powershell - Export-Certificate](https://learn.microsoft.com/en-us/powershell/module/pki/export-certificate?view=windowsserver2022-ps)
- [Ubuntu - Install a root CA certificate in the trust store](https://ubuntu.com/server/docs/install-a-root-ca-certificate-in-the-trust-store)