#!/usr/bin/env bash
set -euo pipefail

for app in platform/*/application.yaml; do
  name=$(yq eval '.metadata.name' "$app")
  chart=$(yq eval '.spec.source.chart // ""' "$app")
  git_path=$(yq eval '.spec.source.path // ""' "$app")
  repo_url=$(yq eval '.spec.source.repoURL' "$app")
  target_revision=$(yq eval '.spec.source.targetRevision' "$app")

  values_file=$(mktemp)
  yq eval '.spec.source.helm.values // ""' "$app" > "$values_file"

  echo "== $name ($app) =="

  if [[ -n "$git_path" ]]; then
    chart_dir=$(mktemp -d)
    git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$target_revision" "$repo_url" "$chart_dir"
    helm template test "$chart_dir/$git_path" -f "$values_file" > /dev/null
  elif [[ "$repo_url" == http://* || "$repo_url" == https://* ]]; then
    helm repo add "$name" "$repo_url" --force-update > /dev/null
    helm template test "$name/$chart" --version "$target_revision" -f "$values_file" > /dev/null
  else
    helm template test "oci://$repo_url/$chart" --version "$target_revision" -f "$values_file" > /dev/null
  fi

  echo "OK"
done
