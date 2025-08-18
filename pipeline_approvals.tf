

resource "azuredevops_environment" "prod" {
  project_id = azuredevops_project.this.id
  name       = "prod"
}


data "azuredevops_group" "project_build_service_accounts" {
  name = "Project Collection Build Service Accounts"
}

resource "azuredevops_git_permissions" "repo_push" {
  project_id    = azuredevops_project.this.id
  repository_id = azuredevops_git_repository.infra.id # or omit for project-level

  principal = data.azuredevops_group.project_build_service_accounts.descriptor

  permissions = {
    PolicyExempt            = "Allow"
    PullRequestBypassPolicy = "Allow"
    GenericContribute       = "Allow"
    CreateBranch            = "Allow"
    CreateTag               = "Allow"
  }
}


/*
# Create environment, add approvers and check approval before deploying TF to prod environments
data "azuredevops_group" "approval_group" {
  project_id = azuredevops_project.this.id
  name       = var.pipeline_approval_team_name
}

resource "azuredevops_check_approval" "env_prod_approval" {
  project_id           = azuredevops_project.this.id
  target_resource_id   = azuredevops_environment.prod.id
  target_resource_type = "environment"

  requester_can_approve      = true
  minimum_required_approvers = 1
  approvers                  = [data.azuredevops_group.approval_group.origin_id]
}



 Get the Project Collection Build Service account

*/
