#!/bin/bash
set -euo pipefail

file=$1
declare -A svc_arr

if [ -f "$file" ]
then
    echo "$file found."
    
    while IFS='=' read -r key value
    do
      # Skip comments / empty lines / job services 
      if [[ $key == "#"* ]] || [[ -z $key ]] || [[ $key == "JOB"* ]]; then
        continue;
      fi
     
      #Transform key - Example "AGREEMENT_MANAGEMENT_IMAGE_VERSION" -> "agreement-management"
      SVC_KEY_TRANSFORMED=$(echo $key|  sed 's/_IMAGE_VERSION//g' | sed 's/\_/\-/g' | tr '[:upper:]' '[:lower:]' )
      svc_arr[$SVC_KEY_TRANSFORMED]=$(echo $value | sed 's/\"//g')
      
    done < "$file"
else
  echo "$file not found."
fi

DEPLOYED_SERVICES=$(kubectl get deployments -n $K8S_NAMESPACE | awk '{if (NR!=1) print $1}')
ROLLOUT_ERROR=0

for CURRENT_SVC in $DEPLOYED_SERVICES
do
    if [[ $CURRENT_SVC == "interop-"* ]]; then
        TRANSFORMED_CURRENT_SVC=$(echo $CURRENT_SVC | sed 's/interop-//g' | sed 's/be-//g')

        if [[ ! -v svc_arr[$TRANSFORMED_CURRENT_SVC] ]]; then
          echo  "::warning::WARNING - " $CURRENT_SVC  " currently deployed version " $SVC_VERSION " not in list"
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

        SVC_VERSION=$(kubectl get deployment -n $K8S_NAMESPACE $CURRENT_SVC -o jsonpath='{$.spec.template.spec.containers[:1].image}' | tr \: \\t | awk '{print $2}')

        if [[ ${svc_arr[$TRANSFORMED_CURRENT_SVC]} != $SVC_VERSION ]]; then
          echo "::error::ERROR - " $CURRENT_SVC " currently deployed version " $SVC_VERSION " - expected " ${svc_arr[$TRANSFORMED_CURRENT_SVC]} " - KO "
          ROLLOUT_ERROR=1
        else
          echo "INFO -" $CURRENT_SVC "currently deployed version " $SVC_VERSION
        fi
    fi
done

exit $ROLLOUT_ERROR
