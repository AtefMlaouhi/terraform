# Terraform

- [Terraform](#terraform)
  - [Prerequis](#prerequis)
  - [Gitlab](#gitlab)
    - [Configuration](#configuration)
    - [Configurer un nouveau projet gitlab](#configurer-un-nouveau-projet-gitlab)
  - [ArgoCD](#argocd)
    - [Configuration](#configuration-1)
    - [Ajouter un nouveau repository/application](#ajouter-un-nouveau-repositoryapplication)
    - [Importer un repository/application existante](#importer-un-repositoryapplication-existante)

## Prerequis

Pour éviter d'installer tout le tooling, une image docker est disponible pour être utilisée en tant que devcontainer :
* Avoir WSL2 installé ([doc](https://docs.microsoft.com/fr-fr/windows/wsl/install))
* Avoir vscode installé
* Avoir l'extension `Remote - Containers` installée
* Etre connecté au registry docker (`docker login #email harvest#`)
* Ouvrir le répertoire ce répertoire dans vscode & ouvrir le répertoire dans le container (par la notif qui devrait apparaitre)

## Gitlab

### Configuration

Saisir les variables dans le fichier src/.envrc.
```shell
export GITLAB_USERNAME=       # Votre id gitlab (ex: vdeoliveira)
export GITLAB_TOKEN=          # Un Personal Access Tokens avec le scope `api`
export PROJECT_ID=            # L'ID de ce projet (différent du projet sur lequel nous appliquerons les configurations)
```
Le PROJECT_ID servira a définir dans quel projet sera stocké le fichier d'état de Terraform (dans la section Infrastructure/Terraform du projet, ex: https://git.harvest.fr/O2S/o2s-modularisation/fr.harvest.geocoding/-/terraform)

### Configurer un nouveau projet gitlab
- créer le repository dans gitlab et noter son id
- copier un bloc terraform projet (exemple dans le fichier example_gitlab_project.tf)
```hcl
module "gitlab-project-geocoding" {
  source = "./modules/project-app"

  project_name = "fr.harvest.geocoding"                              # Project name
  project_path = "O2S/o2s-modularisation/fr.harvest.geocoding"       # Full project slug (without git.harvest.fr)
  argocd_hosts = local.argocd_all_hosts
}
```
- executer les commandes suivantes

```javascript
direnv allow  // Autorise l'utilisation du fichier .envrc
```

```javascript
terraform init // Vérifie les dépendances manquantes, les télécharge & génère le fichier .lock.hcl
```

```javascript
terraform import module.projet-geocoding.gitlab_project.project <PROJECT_ID>
```

```javascript
terraform import module.projet-geocoding.gitlab_branch_protection.main <PROJECT_ID>:main
```
où `projet-geocoding` au nom du module terraform que vous venez d'ajouter

```javascript
terraform plan // Relecture des modifications en attente
```

```javascript
terraform apply // Relecture des modifications en attente puis application après confirmation
```


## ArgoCD

### Configuration

```shell
argocd login argocd-k8s.dev.harvest.fr --sso --grpc-web
argocd login argocd-k8s.preprod.harvest.fr --sso --grpc-web
argocd login argocd.harvest.fr --sso --grpc-web

argocd login argocd.flex-dev.harvest.fr --sso --grpc-web
argocd login argocd.flex-preprod.harvest.fr --sso --grpc-web
argocd login argocd-tooling-flex.harvest.fr --sso --grpc-web
argocd login argocd-flex.harvest.fr --sso --grpc-web --skip-test-tls
```

### Ajouter un nouveau repository/application

* copier un bloc terraform argocd
```hcl
module "argocd-application-geocoding-api" {
  source = "../modules/argocd-project-app"

  project = {
    name = "o2sm" # project name in ArgoCD
    # is_technical_project = true
  }
  namespace = "geocoding" # Namespace in which applications will be deployed (suffixed by env.name, ex: geocoding-dev)
  app = {
    name = "geocoding-api"                   # Name of the applications that will be created in ArgoCD (suffixed by env.name)
    path = "deploy/fr.harvest.geocoding-api" # Path to the helm package within the repository
  }
  env = {
    # Each element of the envs array will make an ArgoCD application
    envs = [
      {
        name = "dev"
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.o2sm.dev }
        ]
      },
      {
        name = "rci"
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.o2sm.dev }
        ]
      }
    ]
    # use_env_naming   = false    # Whatever to suffix app.name, namespace.name with env name (will also add a values-{env}.yaml)
  }
  repository = {
    create   = true
    url      = "https://git.harvest.fr/O2S/o2s-modularisation/fr.harvest.geocoding.git" # If the repository already exists in ArgoCD, you can omit create/username/password fields
    username = module.gitlab-project-geocoding.read_token.login
    password = module.gitlab-project-geocoding.read_token.value
  }

  providers = {
    argocd.project = argocd.dev-project
    argocd.app     = argocd.dev-app
  }
}

```

```javascript
terraform init // Configure le module que nous venons de copier
```

```javascript
terraform plan // Relecture des modifications en attente
```

```javascript
terraform apply // Relecture des modifications en attente puis application après confirmation
```

### Importer un repository/application existante

* Copier le bloc terraform argocd comme si vous vouliez en créer un nouveau

```javascript
terraform init // Configure le module que nous venons de copier
```

```javascript
terraform plan // Relecture des modifications en attente
```
* Noter les ids des ressources que terraform veut créer, exemple :

```hcl
  # module.argocd-application-geocoding-api.argocd_application.application["dev"] will be created
  + resource "argocd_application" "application" {
      + cascade = true
      + id      = (known after apply)
      + wait    = false

      + metadata {
          + annotations      = {
              + "argocd.argoproj.io/manifest-generate-paths" = "deploy/fr.harvest.geocoding-api"
            }
          + generation       = (known after apply)
          + name             = "geocoding-api-dev"
          + namespace        = "argocd"
          + resource_version = (known after apply)
          + uid              = (known after apply)
        }
        ...
```
Ici l'id est `module.argocd-application-geocoding-api.argocd_application.application["dev"]`, som nom est `geocoding-api-dev` et la ressource est de type `argocd_application`
* On se rend sur la page https://registry.terraform.io/providers/oboukili/argocd/latest/docs
* On cherche la ressource correspondante, ici `argocd_application`
* On cherche la section `import` (ex: https://registry.terraform.io/providers/oboukili/argocd/latest/docs/resources/application#import)
* Dans notre cas, la commande d'import sera donc :
```shell
terraform import 'module.argocd-application-geocoding-api.argocd_application.application["dev"]' geocoding-api-dev
```
* Refaire un `terraform plan`
* Soit il n'y a pas de différences entre la version terraform et la version ArgoCD, soit il y a quelques différences et celles-ci apparaitront dans le diff
* Refaire les mêmes manip avec les autres ressources à importer
