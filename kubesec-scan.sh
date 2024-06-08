#!/bin/bash

# using kubesec v2 api
scan_result=$(curl -sSX POST --data-binary @k8s_deployment_service.yaml https://kubesec.io/api/v1/scan)
scan_message=$(curl -sSX POST --data-binary @k8s_deployment_service.yaml https://kubesec.io/api/v1/scan | jq -r '.data[].message')
scan_score=$(curl -sSX POST --data-binary @k8s_deployment_service.yaml https://kubesec.io/api/v1/scan | jq -r '.data[].score')

if [[ $scan_score -ge 9 ]]; then
    echo "Score is $scan_score"
    echo "Kubesec scan message: $scan_message"
    exit 1
else
    echo "Score is $scan_score, which is less than or equal to 5"
    echo "Scanning Kubernetes Resource has failed"
    exit 1;
fi