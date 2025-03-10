---
title: "Azure Bicep Quickstarts [WIP]"
tags:
- azure
- azurecli
- quickstarts
---

## Overview
A quick run through of provisioning simple VM infrastructure on Azure using Bicep.

## How-to 

1. Log-in

    ```
    wmcdonald@fedora ~ → az login
    ```

2. Clone the [Azure Quickstart templates](https://github.com/Azure/azure-quickstart-templates)

    ```
    wmcdonald@fedora ~ → git clone https://github.com/Azure/azure-quickstart-templates.git ~/workspace/
    ```

3. Switch into the simple Linux VM sample:

    ```
    wmcdonald@fedora ~ → cd ~/workspace/azure-quickstart-templates/quickstarts/microsoft.compute/vm-simple-linux
    ```

4. Create a resource group to place the infrastructure inside

    ```
    wmcdonald@fedora ~ → az group create --name rg-demo --location ukwest --tags env=dev dept=engineering
    ```

5. Run the deployment to create the VM, enter the information when prompted:

    ```
    wmcdonald@fedora vm-simple-linux ±|master|→ az deployment group create --name vm-demo --resource-group rg-demo --template-file azuredeploy.json
    Please provide string value for 'adminUsername' (? for help): az-user
    Please provide securestring value for 'adminPasswordOrKey' (? for help): *********************
    ```

6. The `outputs` from the run will include a hostname for access to the new VM:

    ```
    "outputs": {
        "adminUsername": {
            "type": "String",
            "value": "az-user"
            },
        "hostname": {
            "type": "String",
            "value": "simplelinuxvm-qe2s7ll4mcrzi.ukwest.cloudapp.azure.com"
        },
            "sshCommand": {
            "type": "String",
            "value": "ssh az-user@simplelinuxvm-qe2s7ll4mcrzi.ukwest.cloudapp.azure.com"
        }
    },
    ```

7. Test connectivity

```
wmcdonald@fedora vm-simple-linux ±|master|→ ssh az-user@simplelinuxvm-qe2s7ll4mcrzi.ukwest.cloudapp.azure.com
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
az-user@simplelinuxvm-qe2s7ll4mcrzi.ukwest.cloudapp.azure.com's password: 
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1079-azure x86_64)
az-user@simpleLinuxVM:~$ cat /etc/lsb-release 
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.6 LTS"
```

8. Tear down the infrastructure

    ```
    wmcdonald@fedora ~ → az group delete --name rg-demo --yes 
    ```

## Summary


## Further reading
- [Simple Linux Virtual Machine](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.compute/vm-simple-linux/GettingStarted-linux.md)
- [https://github.com/wmcdonald404/terraform-sandbox-azure](https://github.com/wmcdonald404/terraform-sandbox-azure)