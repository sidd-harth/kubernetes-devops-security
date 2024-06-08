#!/bin/bash

echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------........."
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '
echo "PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '" >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc
source ~/.bashrc

apt-get autoremove -y  #removes the packages that are no longer needed
apt-get update
systemctl daemon-reload

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

KUBE_VERSION=1.28.0
apt-get update
apt-get install -y docker.io vim build-essential jq python3-pip kubelet=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubernetes-cni=1.2.0-00 kubeadm=${KUBE_VERSION}-00
pip3 install jc

### UUID of VM 
### comment below line if this Script is not executed on Cloud based VMs
jc dmidecode | jq .[1].values.uuid -r

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
systemctl enable docker
systemctl enable kubelet
systemctl start kubelet

echo ".........----------------#################._.-.-KUBERNETES-.-._.#################----------------........."
rm /root/.kube/config
kubeadm reset -f

# uncomment below line if your host doesnt have minimum requirement of 2 CPU
# kubeadm init --kubernetes-version=${KUBE_VERSION} --ignore-preflight-errors=NumCPU --skip-token-print
kubeadm init --kubernetes-version=${KUBE_VERSION} --skip-token-print

mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

sleep 60

echo "untaint controlplane node"
kubectl taint node $(kubectl get nodes -o=jsonpath='{.items[].metadata.name}') node.kubernetes.io/not-ready:NoSchedule-
kubectl taint node $(kubectl get nodes -o=jsonpath='{.items[].metadata.name}') node-role.kubernetes.io/master:NoSchedule-
kubectl get node -o wide



echo ".........----------------#################._.-.-Java and MAVEN-.-._.#################----------------........."
sudo apt install openjdk-17-jdk -y
java -version
sudo apt install -y maven
mvn -v



echo ".........----------------#################._.-.-JENKINS-.-._.#################----------------........."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
systemctl daemon-reload
systemctl enable jenkins
sudo systemctl start jenkins
#sudo systemctl status jenkins
sudo usermod -a -G docker jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo ".........----------------#################._.-.-COMPLETED-.-._.#################----------------........."
