# multi-cloud-vpn

This repository contains an example AWS-Azure-Google Cloud VPN architecture built using Terraform.

## Required Software
- [Terraform](https://www.terraform.io/)

## Configuration

Create a configuration file at `terraform.tfvars` containing values for the variables specified
in `variables.tf`.

Initialize Terraform by running:
```bash
terraform init
```

### AWS Credentials
Before running the build, obtain and configure AWS credentials with permissions to create all of the
required infrastructure. Terraform is configured to load AWS credentials using the
[Default Credential Provider Chain](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html).

### Google Cloud Credentials
Terraform requires Google Cloud credentials for a service account in your target project.
Obtain credentials for a service account with the required permissions and place them at
`~/.config/gcloud/<project-id>.json`.

### Azure Credentials
The build is configured to use Azure credentials from the [CLI](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html).
Log in using `az login`, then optionally change your default subscription using
`az account set --subscription="SUBSCRIPTION_ID"`.

## Performing a Build
Apply the Terraform changes to build the infrastructure:

```bash
terraform apply
```

## License

These modules are made available under the Apache 2.0 license. Copyright © 2020 Silectis, Inc.
