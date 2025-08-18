
resource "azuredevops_variable_group" "shared_pipeline_variables" {
  project_id   = azuredevops_project.this.id
  name         = "SharedPipelineVariables"
  description  = "Shared pipeline variables for api keys f.x"
  allow_access = true

  variable { # dummy variable, api won't allow empty variable groups
    name  = "example"
    value = "example"
  }

}
#Create pipeline yml file for each workload
resource "azuredevops_git_repository_file" "workload_pipeline_yml" {
  for_each = local.components

  repository_id       = azuredevops_git_repository.infra.id
  file                = "${each.value}/pipeline/${each.value}.yml"
  overwrite_on_create = true
  content             = <<-EOT
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - ${each.value}/terraform/*

resources:
  repositories:
  - repository: pipeline-templates
    type: git
    name: ado-pipeline-templates
    
extends:
  template: ado-main-pipeline.yml@pipeline-templates
  parameters:
    workingDirectory: "$(System.DefaultWorkingDirectory)/${each.value}/terraform"
    backendAzureRmKey: "${each.value}.tfstate"
    backendAzureRmContainerName: "tfstate"
    backendServiceArm: "SC-AzureGovernance-OIDC"
    backendAzureRmStorageAccountName: "${var.backend_storage_account_name}"
    backendAzureRmResourceGroupName: "${var.backend_resource_group_name}"
EOT

  branch         = "refs/heads/main"
  commit_message = "init component deployment pipelines"

  lifecycle {
    ignore_changes = [
      commit_message
    ]
  }
}

resource "azuredevops_git_repository_file" "subscription_vending_pipeline_yml" {
  for_each            = var.subscription_vending_map
  repository_id       = azuredevops_git_repository.infra.id
  branch              = "refs/heads/main"
  file                = "subscription-vending/${each.key}/pipeline/vending-${each.key}.yml"
  overwrite_on_create = true
  content             = <<-EOT
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - subscription-vending/${each.key}/terraform/*

resources:
  repositories:
  - repository: pipeline-templates
    type: git
    name: ado-pipeline-templates
  

extends:
  template: ado-main-pipeline.yml@pipeline-templates
  parameters:
    workingDirectory: "$(System.DefaultWorkingDirectory)/subscription-vending/${each.key}/terraform"
    backendAzureRmKey: "subscription-vending-${each.key}.tfstate"
    backendAzureRmContainerName: "tfstate"
    backendServiceArm: "SC-AzureGovernance-OIDC"
    backendAzureRmStorageAccountName: "${var.backend_storage_account_name}"
    backendAzureRmResourceGroupName: "${var.backend_resource_group_name}"
EOT
}

resource "azuredevops_git_repository_file" "subscription_vending_tf_template" {
  for_each            = var.subscription_vending_map
  repository_id       = azuredevops_git_repository.infra.id
  branch              = "refs/heads/main"
  file                = "subscription-vending/${each.key}/terraform/main.tf"
  overwrite_on_create = true
  content             = <<-EOT
         terraform {
  backend "azurerm" {
    use_azuread_auth = true
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}



module "subscription_vending" {
  source                      = "git::https://github.com/advania/terraform-azurerm-azgov-subscription-vending?ref=main"
}
            EOT
}


#Create pipeline objectfor each workload

resource "azuredevops_build_definition" "workload_pipelines" {
  for_each = local.components

  project_id = azuredevops_project.this.id
  name       = "TF-${each.value}"
  path       = "\\${each.value}"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.infra.id
    branch_name = "refs/heads/main"
    yml_path    = "${each.value}/pipeline/${each.value}.yml"
  }
}

resource "azuredevops_build_definition" "subscription_vending_pipelines" {
  for_each = var.subscription_vending_map

  project_id = azuredevops_project.this.id
  name       = "TF-${each.key}"
  path       = "\\subscription-vending"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.infra.id
    branch_name = "refs/heads/main"
    yml_path    = "subscription-vending/${each.key}/pipeline/vending-${each.key}.yml"
  }

}


resource "azuredevops_build_definition" "sync-ado-templates" {
  project_id = azuredevops_project.this.id
  name       = "Sync-ADO-Templates"
  path       = "\\ado-pipeline-templates"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.ado-pipeline-templates.id
    branch_name = "refs/heads/main"
    yml_path    = "sync-ado-templates.yml"
  }
}
