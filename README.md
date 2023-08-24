# kubernetes-devops-security

## Fork and Clone this Repo

## Clone to Desktop and VM

## NodeJS Microservice - Docker Image -

`docker run -p 8787:5000 siddharth67/node-service:v1`

`curl localhost:8787/plusone/99`

## NodeJS Microservice - Kubernetes Deployment -

`kubectl create deploy node-app --image siddharth67/node-service:v1`

`kubectl expose deploy node-app --name node-service --port 5000 --type ClusterIP`

`curl node-service-ip:5000/plusone/99`

## Talisman Installation

`curl https://thoughtworks.github.io/talisman/install.sh > ~/install-talisman.sh`
`chmod +x ~/install-talisman.sh`
`cd your-git-project`
`~/install-talisman.sh`

## Trivy Scan Image

`docker run --rm -v /:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --light openjdk`

### OPA

command for check docker permission
`kubectl exec -it devsecops-686c546c84-9jfwp -- id`
