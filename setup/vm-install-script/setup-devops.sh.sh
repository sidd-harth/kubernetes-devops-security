#!/bin/bash

set -e

echo "==== [1] Updating system ===="
sudo apt-get update && sudo apt-get upgrade -y

echo "==== [2] Installing Docker ===="
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg-agent

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable"

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Allow Docker for current user
sudo usermod -aG docker $USER

echo "==== [3] Installing Kubernetes tools (kubectl, kubeadm, kubelet) ===="
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "==== [4] Disabling Swap (required by Kubernetes) ===="
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "==== [5] Initializing Kubernetes cluster (single node) ===="
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

echo "==== [6] Configuring kubectl ===="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "==== [7] Installing Calico network plugin ===="
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml

echo "==== [8] Allowing pods on master node ===="
kubectl taint nodes --all node-role.kubernetes.io/master-

echo "==== [9] Installing Maven ===="
sudo apt-get install -y maven

echo "==== [10] Installing Jenkins ===="
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'

sudo apt-get update
sudo apt-get install -y openjdk-11-jdk jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "==== ✅ Installation Complete! ===="
echo "👉 Jenkins URL: http://<your-server-ip>:8080"
echo "🔐 Jenkins initial password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
