#!/bin/bash

sleep 60s

if [[ $(kubectl -n default rollout status deployment/${deploymentName} --timeout 5s) != *"successfully rolled out"* ]];
then
    echo "Deployment ${deploymentName} rolled out has failed"
    kubectl rollout undo deployment/${deploymentName} -n default
else
    echo "Deployment ${deploymentName} rollout success"
fi