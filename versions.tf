terraform {

  required_providers {

    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}


