# kuber-dse
DSE on Kubernetes using statefulsets and local storage

Install 3+ Ubuntu servers/VMs

Install Kubernetes on all VMs (as root): https://kubernetes.io/docs/tasks/tools/install-kubeadm/
```
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-get install -y docker-engine
service docker start
```

Setup Kubernetes Master on first VM
* Copy the JOIN line outputted by this command! (as root): `kubeadm init`
* To start using your cluster, you need to run (as a regular user):
```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
* Install K8s networking: `kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`
* Check installation: `kubectl get pods --all-namespaces`

Join other Kubernets Nodes (Run on the other Ubuntu VMs)
* `kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>`

Check nodes on Kubernetes Master:
* `kubectl get nodes`
* Enable master to run pods: `kubectl taint nodes --all node-role.kubernetes.io/master-`

# Setup DSE Docker Image (as root on master)

Download and configure DSE docker image:
* `git clone https://github.com/datastax/docker-images`
* Update yaml files as required in `config-templates/DSE/6.0.0/`

Build local DSE docker image:
* `./gradlew buildServerImage -PserverVersion=6.0 -PopscenterVersion=6.5 -PstudioVersion=6.0 -PdownloadUsername=<your_DataStax_Acedemy_username> -PdownloadPassword=<your_DataStax_Acedemy_passwd>`
* `./gradlew buildImages -PdownloadUsername=<your_DataStax_Acedemy_username> -PdownloadPassword=<your_DataStax_Acedemy_passwd>`

# Setup Kubernetes persistent storage
For this demo we will be using normal directories for our "persistent disks". Typically you woud use mount points for physical local disks, or a local disk devices directly. We will be simulating two persistent disks per Kubernetes node.

Run on each Kubernetes node:
* `mkdir /mnt/disk0`
* 'mkdir /mnt/disk1`

Configure storage class

* Download git repo: `git clone https://github.com/russkatz/kuber-dse`
* Update nodeAffinity's value to match your node names in `datastax-nodeX-pvX.yaml` files. Each kubernetes node will have two pv yaml files.
```
...
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ip-172-31-9-98 # Update this line to your kubernetes node name
```
