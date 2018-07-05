# kuber-dse
DSE on Kubernetes using statefulsets and local storage

Install 3+ Ubuntu servers/VMs

Install Kubernetes on all VMs:
* apt-get update && apt-get install -y apt-transport-https curl
* curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
* cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
* deb http://apt.kubernetes.io/ kubernetes-xenial main
* EOF
* apt-get update
* apt-get install -y kubelet kubeadm kubectl
* apt-get install -y docker-engine

Setup Kubernetes Master on first VM
* #Copy the JOIN line outputted by this command!
* kubeadm init
* #Installs K8s networking
* kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
* kubectl get pods --all-namespaces

Join other Kubernets Nodes (Run on the other Ubuntu VMs)
