---
title: "Azure Bicep Quickstarts [WIP]"
tags:
- azure
- azurecli
- quickstarts
---

## Overview


## How-to 

1. Log-in

    ```
    wmcdonald@fedora ~ → az login
    ```

wmcdonald@fedora ~ → git clone https://github.com/Azure/azure-quickstart-templates.git ~/workspace/

wmcdonald@fedora ~ → cd ~/workspace/azure-quickstart-templates/quickstarts/microsoft.compute/vm-simple-linux

wmcdonald@fedora ~ → az group create --name rg-demo --location ukwest --tags env=dev dept=clowns

wmcdonald@fedora ~ → az group deployment create --name vm-demo --resource-group rg-demo --template-file azuredeploy.json

wmcdonald@fedora ~ → az group delete --name rg-demo --yes 


## Summary


## Further reading
- [Simple Linux Virtual Machine](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.compute/vm-simple-linux/GettingStarted-linux.md)
- [https://github.com/wmcdonald404/terraform-sandbox-azure](https://github.com/wmcdonald404/terraform-sandbox-azure)