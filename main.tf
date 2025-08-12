locals {
  # Common components.These components have seperate state files and pipelines # can add more components in var.components
  components = toset(var.components)
}

resource "azuredevops_project" "this" {
  name               = var.project_name
  description        = var.project_description
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "time_sleep" "wait_for_project" {
  create_duration = "60s"
}

resource "azuredevops_git_repository" "infra" {
  project_id     = azuredevops_project.this.id
  name           = "infra"
  default_branch = "refs/heads/main"
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = "https://github.com/advania/template-azuredevops-bootstrap"
  }
  depends_on = [time_sleep.wait_for_project]
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
