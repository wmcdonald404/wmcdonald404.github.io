---
title: "Azure CLI Basics"
tags:
- azure
- azurecli
- sso
---

## Overview
A quick aide memoire on getting the Azure CLI set up. I frequently jump between AWS and Azure, and traditional on-prem phsycial and virtual infrastructure. If a few months have elapsed, I might not have the current CLI muscle memory, so this is just a quick reference reminder.

## Installation
Unless you need the absolute bleeding-edge support, I'd suggest sticking with your vendor-supplied package for Azure CLI if you're working from a current distro.

```
wmcdonald@fedora ~ → cat /etc/fedora-release 
Fedora release 41 (Forty One)
wmcdonald@fedora ~ → az -v
azure-cli                         2.70.0

core                              2.70.0
telemetry                          1.1.0

Dependencies:
msal                            1.31.2b1
azure-mgmt-resource               23.1.1

Python location '/usr/bin/python3.9'
Config directory '/home/wmcdonald/.azure'
Extensions directory '/home/wmcdonald/.azure/cliextensions'

Python (Linux) 3.9.21 (main, Feb 10 2025, 00:00:00) 
[GCC 14.2.1 20250110 (Red Hat 14.2.1-7)]

Legal docs and information: aka.ms/AzureCliLegal


Your CLI is up-to-date.
```

## How-to 

1. Log-in

    ```
    wmcdonald@fedora ~ → az login
    ```

2. View all available Azure accounts
    
    ```
    wmcdonald@fedora ~ → az account list
    ```

3. View currently configured account

    ```
    wmcdonald@fedora ~ → az account show
    ```

4. Switch to a specific account

    ```
    wmcdonald@fedora ~ → az account set -s <azure-account-uuid>
    ```

5. You can now create, list and delete resources using the CLI

    ```
    wmcdonald@fedora ~ → az group create --name rg-demo --location ukwest --tags env=prod dept=finance
    {
        "id": "/subscriptions/<subscription-uuid>/resourceGroups/rg-demo",
        "location": "ukwest",
        "managedBy": null,
        "name": "rg-demo",
        "properties": {
            "provisioningState": "Succeeded"
        },
        "tags": {
            "dept": "finance",
            "env": "prod"
        },
        "type": "Microsoft.Resources/resourceGroups"
    }
    ```

## Summary
That's it, dead simple. Next we'll move on to deploying stuff, and you can choose Terraform, or Bicep, see the [Further reading](#further-reading) section

## Further reading
- [Simple Linux Virtual Machine](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.compute/vm-simple-linux/GettingStarted-linux.md)
- [https://github.com/wmcdonald404/terraform-sandbox-azure](https://github.com/wmcdonald404/terraform-sandbox-azure)