# Cloud Engineering - Assessment 1

## Requirements
- Terraform v1.10.5
- Azure CLI v2.69.0
- PowerShell 7.5.0

**Optional tools:**
- Task v3.41.0

## Setup

Ensure you have the required tools installed. To connect Terraform with Azure, log in using the Azure CLI:

### Azure Credentials
```shell
az login
```

### VM Credentials

To create a user with a password on VMs, follow these steps:

1. Copy the sample `terraform.tfvars` file to create your own:
    ```shell
    cp terraform.tfvars.sample terraform.tfvars
    ```

2. Edit the `terraform.tfvars` file to include your desired username and password. For example:
    ```hcl
    admin_username = "yourusername"
    admin_password = "yourpassword"
    ```

Make sure to use a strong password to enhance security.

## Commands

Initialize your Terraform configuration:
```shell
terraform init
```

Apply the Terraform configuration:
```shell
terraform validate
terraform apply -auto-approve -compact-warnings
```

To destroy the infrastructure managed by Terraform:
```shell
terraform destroy -auto-approve -compact-warnings
```
