argocd_hosts = {
  dev       = "argocd-k8s.dev.harvest.fr"
  dev_flex  = "argocd.flex-dev.harvest.fr"
  preprod   = "argocd-k8s.preprod.harvest.fr"
  prod      = "argocd.harvest.fr"
  prod_flex = "argocd-flex.harvest.fr"
}

rancher_clusterids = {
  dev       = "c-btmpm"
  preprod   = "c-mtw66"
  prod      = "c-4cv2w"
  dev_flex  = "c-m-qbctwmg7"
  prod_flex = "c-m-h2rkm56h"
}

rancher_projects = {
  agregation = {
    dev_flex  = "p-pk2xh"
    prod_flex = "p-mjz7k"
  }
  o2sm = {
    dev       = "p-82dsv"
    dev_flex  = "p-gxsh8"
    preprod   = "p-5qtm6"
    prod      = "p-57lwd"
    prod_flex = "p-6zbhc"
  }
  observability = {
    dev_flex  = "p-r222v"
    prod_flex = "p-n4bkz"
  }
  quantalys = {
    dev_rci = "p-99g6k"
    preprod = "NA"
    prod    = "NA"
  }
}

argo_notification_teams = {
  "notifications.argoproj.io/subscribe.on-deployed-teams.teams"            = "o2sm-argocd"
  "notifications.argoproj.io/subscribe.on-health-degraded-teams.teams"     = "o2sm-argocd"
  "notifications.argoproj.io/subscribe.on-sync-failed-teams.teams"         = "o2sm-argocd"
  "notifications.argoproj.io/subscribe.on-sync-status-unknown-teams.teams" = "o2sm-argocd"
}

argo_notification_prod_teams = {
  "notifications.argoproj.io/subscribe.on-deployed-teams.teams"            = "o2sm-argocd-prod"
  "notifications.argoproj.io/subscribe.on-health-degraded-teams.teams"     = "o2sm-argocd-prod"
  "notifications.argoproj.io/subscribe.on-sync-failed-teams.teams"         = "o2sm-argocd-prod"
  "notifications.argoproj.io/subscribe.on-sync-status-unknown-teams.teams" = "o2sm-argocd-prod"
}
