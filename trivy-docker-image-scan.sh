#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName 

# Ensure Docker is logged in if the image is private
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Run Trivy scan
docker run --rm -v $WORKSPACE:/root/.cache/aquasec/trivy:0.51.1 aquasec/trivy:0.51.1 image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/aquasec/trivy:0.51.1 aquasec/trivy:0.51.1 image --exit-code 1 --severity CRITICAL --light $dockerImageName

# Trivy scan result processing
exit_code=$?

echo "Exit Code : $exit_code"

# Check scan results
if [[ "${exit_code}" -eq 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1
else 
    echo "Image scanning passed. No CRITICAL vulnerabilities found"
fi
