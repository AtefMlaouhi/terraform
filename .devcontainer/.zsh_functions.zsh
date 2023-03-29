update_kubeconfig_from_rancher () {
  if ! rancher clusters ls &> /dev/null; then
    echo "Please first run 'rancher login https://admin-k8s.harvest.fr -t {bearertoken}' (bearer token from https://admin-k8s.harvest.fr/dashboard/account)"
    return
  fi

  for CLUSTER_NAME in $(rancher cluster ls --format json | jq -r ".Name"); do
    echo "Deleting previous kube context $CLUSTER_NAME..."
    kubectx -d $CLUSTER_NAME
  done

  for CLUSTER_ID in $(rancher cluster ls --format json | jq -r ".ID")
  do
  echo "Importing $CLUSTER_ID..."
    rancher cluster kubeconfig $CLUSTER_ID \
    | yq -e '.clusters[] |= (.cluster.insecure-skip-tls-verify = true)' \
    | yq -e 'del(.clusters[].cluster.certificate-authority-data)' \
    | yq -e 'del(.contexts[] | select(.name | test "[0-9]{3}$"))' \
    | kubectl konfig import --save --stdin
  echo "> done"
  done

  echo "Done !"
}
