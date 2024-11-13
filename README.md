## GitHub Secrets

Repo -> Settings -> Secrets and variables -> Actions   
Create a "New repository secret" for each secret:  
- Azure Client ID  
- Azure Client Secret  
- Azure Subscription ID  
- Azurre Tenant ID  

## Create a backend storage account and keyvault

Store tfstate files in seperate storage account & container for redundancy and
informational security.

### Save state

```hsl
terraform {
    backend = "azurerm"
    config = {
        resource_group_name = "NAME_HERE"
        storage_account_name = "NAME_HERE"
        container_name = "NAME_HERE"
        key = "NAME_HERE.terraform.tfstate"
    }
}
```

### Get state

```hsl
data "terraform_remote_state" "NAME_HERE" {
    backend = "azurerm"
    config = {
        storage_account_name = "NAME_HERE"
        container_name = "NAME_HERE"
        key = "NAME_HERE.terraform.tfstate"
    }
}
```

## Terraform Workspace

### Create workspaces: dev, stage & prod.  

```hsl
terraform workspace new dev
terraform workspace new stage
terraform workspace new prod
```

### Select workspace

```hsl
terraform workspace select dev
terraform workspace select stage
terraform workspace select prod
```

### Show which workspace you are in

```hsl
terraform workspace show
```

## Github Workflows

Github workflow doesn't work if the resources already exist, why?

## TFSEC

Run powershell as Administrator

```powershell
choco install tfsec
```

## TFLINT

Run powershell as Administrator

```powershell
choco install tflint
```


## Valg av folder structure

### Alternative Two

```
azure-terraform-project/
│
├── modules/
│   ├── networking/
│   ├── app_service/
│   ├── database/
│   ├── storage/
│   └── nn/
│
├── deployments/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   │
│   ├── terraform.tfvars.dev
│   ├── terraform.tfvars.stage
│   └── terraform.tfvars.prod
│
├── global/
│   └── main.tf
│
└── README.md
```

Ryddigste oppsettet å følge etter min mening. Her er det tfvars filene som gjør
den store jobben. I et prosjekt men behov for større grunnleggende endringer burde
nok alt deles inn i egne environment baserte folders.