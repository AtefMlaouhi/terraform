terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.10.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "16.6.0"
    }
  }
}
