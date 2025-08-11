resource "azuredevops_project" "this" {
  name               = var.project_name
  description        = var.project_description
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}


resource "azuredevops_git_repository" "infra" {
  project_id     = azuredevops_project.this.id
  name           = "infra"
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"
  }
}



#Min reviewers branch policy
resource "azuredevops_branch_policy_min_reviewers" "this" {
  project_id = resource.azuredevops_project.this.id

  enabled  = var.min_reviewers_enabled
  blocking = true



  settings {
    reviewer_count                         = var.min_reviewers_count
    submitter_can_vote                     = true
    last_pusher_cannot_approve             = false
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = false

    scope {
      match_type = "DefaultBranch"
    }
  }
}
