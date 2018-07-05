# DSE on Kubernetes with Local Persistent Storage
This demo shows how to run a DSE cluster on Kubernetes using statefulsets with local persistant storage. As of this writing using local storage with statefulsets is in BETA. This is not intended for production use. 

Install 3 Ubuntu servers/VMs

Install Docker+Kubernetes on all VMs (as root): https://kubernetes.io/docs/tasks/tools/install-kubeadm/
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
* To start using your cluster, you need to run this (as a regular user):
```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
* Install K8s networking: 
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

* Check installation: 
```
kubectl get pods --all-namespaces
```

* Join other Kubernets Nodes (Run on the other Ubuntu VMs as root)
```
kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
```

* Check nodes on Kubernetes Master:
```
kubectl get nodes
```

* Enable master to run pods:
```
kubectl taint nodes --all node-role.kubernetes.io/master-`
```

# Setup DSE Docker Image (as root on master)
This requires a free account from academy.datastax.com

Download and configure DSE docker image:
* `git clone https://github.com/datastax/docker-images`
* Update yaml files as required in `config-templates/DSE/6.0.0/`

Build local DSE docker image:
* `./gradlew buildServerImage -PserverVersion=6.0 -PopscenterVersion=6.5 -PstudioVersion=6.0 -PdownloadUsername=<your_DataStax_Acedemy_username> -PdownloadPassword=<your_DataStax_Acedemy_passwd>`
* `./gradlew buildImages -PdownloadUsername=<your_DataStax_Acedemy_username> -PdownloadPassword=<your_DataStax_Acedemy_passwd>`

# Setup Kubernetes persistent storage
For this demo we will be using normal directories for our "persistent disks". Typically you would use mount points for physical local disks, or local disk devices directly for blockStorage. We will be simulating two persistent disks per Kubernetes node.

Run on each Kubernetes node, these will be our persistent disk "mount points":
* `mkdir /mnt/disk0`
* `mkdir /mnt/disk1`

Configure storage class

* Download git repo: 
```
git clone https://github.com/russkatz/dse-k8s-local
```

* Get your kubernetes node's names: 
```
kubectl get nodes
```

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
* Create `datastax` Kubernetes server: 
```
kubectl create service nodeport datastax --tcp=9042:9042
```

* Create `datastax-storage` storage class:
```
kubectl create -f datastax-storage.yaml
```

* Add all of the persistent disks to the storage class:
```
kubectl create -f datastax-node0-pv0.yaml
kubectl create -f datastax-node0-pv1.yaml
kubectl create -f datastax-node1-pv0.yaml
kubectl create -f datastax-node1-pv1.yaml
kubectl create -f datastax-node2-pv0.yaml
kubectl create -f datastax-node2-pv1.yaml
```
* Check disks, You should see six volmues Available:
```
kubectl get persistentvolume
```

# Deploy DSE Cluster

* Create kubernetes statefulset application for datastax: 
```
kubectl create -f datastax-statefulset.yaml
```

* Check on status of statefulset application
```
kubectl describe statefulset.apps/datastax
```

* Check on status of first datastax pod:
```
kubectl describe pod datastax-0
```

* Check persistent volume was bound:
```
kubectl get persistentvolume
```

* Wait a few minutes for the pods to start and DSE to come up:
```
kubectl describe statefulset.apps/datastax
```

* Check DSE cluster:
```
kubectl exec datastax-0 nodetool status
```

* Run CQLSH:
```
kubectl exec -it datastax-0 cqlsh
```

* Local terminal access to pod:
```
kubectl exec -it datastax-0 -- /bin/bash
```

* Scale down (Note how the DSE cluster behaves..):
```
kubectl scale statefulsets datastax --replicas=2
```

* Scale up (Note how the DSE cluster behaves..):
```
kubectl scale statefulsets datastax --replicas=3
```

* Get the port to connec to cqlsh directly through the master:
```
kubectl get service datastax
```

* Note the port listed after 9042. In the example below this is 32731 (yours will be different):
```
NAME       TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
datastax   NodePort   10.98.203.24   <none>        9042:32731/TCP   1h
```

* Connect with a local copy of cqlsh:
```
cqlsh <ip of kubernetes master> <port from above>
```


