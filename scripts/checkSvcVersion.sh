#!/bin/bash
set -euo pipefail

file=$1
# check that the images YAML file exists
if [[ ! -f "$file" ]]; then
  echo "Error: $file not found."
  exit 1
fi

ROLLOUT_ERROR=0

# query Kubernetes cluster for deployment names and their container images excluding headers
kubectl get deployments -n "$K8S_NAMESPACE" --no-headers \
  -o custom-columns=NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image | \
while read -r NAME IMAGE; do

  # only process deployments starting with interop-
  [[ $NAME != interop-* ]] && continue

  # extract tag from IMAGE column (after the last ':')
  CURRENT_VERSION=${IMAGE##*:}

  # strip 'interop-' and 'be-' prefixes to match YAML keys
  TRANSFORMED=$(echo "$NAME" | sed 's/^interop-//; s/^be-//')

  # retrieve expected tag from YAML using yq; empty if not found
  EXPECTED=$(yq e ".images.microservices.\"$TRANSFORMED\".tag // \"\"" "$file")

  # warn and skip if service is not listed in the YAML
  if [[ -z "$EXPECTED" ]]; then
    echo "::warning::WARNING - $NAME current version $CURRENT_VERSION not in list"
    continue
  fi

        # TODO: refactor using readiness
        # kubectl rollout status --watch=false -n $K8S_NAMESPACE deployment/$CURRENT_SVC > /dev/null
        # SVC_ROLLOUT_STATUS=$?
        #
        # if [[ ! $SVC_ROLLOUT_STATUS  -eq 0 ]]; then
        #   # Service not ready
        #   echo  "::error::Error - Deployment" $CURRENT_SVC "not ready:" $(kubectl rollout status -n $K8S_NAMESPACE deployment/$CURRENT_SVC)
        #   ROLLOUT_ERROR=1
        # fi

  # compare current and expected versions
  if [[ "$CURRENT_VERSION" != "$EXPECTED" ]]; then
    echo "::error::ERROR - $NAME current deployed version: $CURRENT_VERSION - expected: $EXPECTED - KO"
    ROLLOUT_ERROR=1
  else
    echo "INFO - $NAME current deployed version: $CURRENT_VERSION - OK"
  fi

done

exit $ROLLOUT_ERROR
