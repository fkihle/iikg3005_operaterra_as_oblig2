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

## Plan with user defined tfvars file

```hsl
terraform plan -var-file="dev.tfvars"
```