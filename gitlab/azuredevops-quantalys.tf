data "azuredevops_project" "quantalys" {
  name = "Quantalys"
}

resource "azuredevops_variable_group" "quantalys" {
  name       = "dependency-track"
  project_id = data.azuredevops_project.quantalys.project_id

  variable {
    name  = "DependencyTrackUri"
    value = "https://dependency-track-k8s.rci.harvest.fr/api/v1/bom"
  }

  variable {
    name  = "dependency-track-api-endpoint"
    value = "https://dependency-track-k8s.rci.harvest.fr/api/v1/bom"
  }

  variable {
    name      = "DependencyTrackApiKey"
    value     = var.dependencyTrackApiKey
    is_secret = true
  }

  variable {
    name      = "dependency-track-api-key"
    value     = var.dependencyTrackApiKey
    is_secret = true
  }
}

resource "azuredevops_variable_group" "quantalys-DependencyTrack" {
  name       = "DependencyTrack"
  project_id = data.azuredevops_project.quantalys.project_id

  variable {
    name      = "DependencyTrackApiKey"
    value     = var.dependencyTrackApiKey
    is_secret = true
  }

  variable {
    name  = "DependencyTrackUri"
    value = "https://dependency-track-k8s.rci.harvest.fr/api/v1/bom"
  }
}
