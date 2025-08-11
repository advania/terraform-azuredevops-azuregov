locals {
  # Common components.These components have seperate state files and pipelines # can add more components in var.components
  components = toset(var.components)
}

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

            extends:
            template: /pipeline-templates/ado-main-pipeline.yml
            parameters:
                workingDirectory: "$(System.DefaultWorkingDirectory)/${each.value}/terraform"
                backendAzureRmKey: "${each.value}.tfstate"
                backendAzureRmContainerName: "tfstate"
                backendServiceArm: "SC-${var.project_name}-OIDC"
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

            extends:
            template: /pipeline-templates/ado-main-pipeline.yml
            parameters:
                workingDirectory: "$(System.DefaultWorkingDirectory)/${each.key}/terraform"
                backendAzureRmKey: "subscription-vending-${each.key}.tfstate"
                backendAzureRmContainerName: "tfstate"
                backendServiceArm: "SC-${var.project_name}-OIDC"
                backendAzureRmStorageAccountName: "${var.backend_storage_account_name}"
                backendAzureRmResourceGroupName: "${var.backend_resource_group_name}"
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
