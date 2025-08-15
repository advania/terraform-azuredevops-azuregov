
resource "azuredevops_serviceendpoint_azurerm" "this" {
  service_endpoint_name                  = "SC-AzureGovernance-OIDC"
  project_id                             = azuredevops_project.this.id
  description                            = "Azure Governance Service Connection"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"


  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name
  credentials {
    serviceprincipalid = var.client_id
  }
  lifecycle {
    ignore_changes = [environment]
  }
}

resource "azuredevops_serviceendpoint_github" "this" {
  service_endpoint_name = var.github_service_connection_name
  project_id            = azuredevops_project.this.id
  description           = "GitHub Service Connection"
  auth_personal {
    personal_access_token = var.github_pat
  }
}


