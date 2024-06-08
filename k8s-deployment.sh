#!/bin/bash

sed -i "s#replace#${imageName}#g" k8s_deployment_service.yaml
kubectl -n default get deployment ${deploymentName} &> /dev/null

if [[ $? -ne 0]]; then
     echo "deployment ${deploymentName} not found, creating new deployment"
     kubectl apply -f k8s_deployment_service.yaml -n default
else
      echo "deployment ${deploymentName} found, updating deployment"
      echo "image name - ${imageName}"
      kubectl set image deployment/${deploymentName} ${containerName}=${imageName} -n default
  fi