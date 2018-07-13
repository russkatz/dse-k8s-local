#DSE with local storage using portworx

After Docker and Kubernetes is installed:

* Every Kubernetes node must have at least 1 unused and unmounted disk drive. 
* Install Portworx 1.4 (https://docs.portworx.com/scheduler/kubernetes/install.html):
```
kubectl apply -f 'https://install.portworx.com/1.4/?c=px-cluster-a1966fe8-25aa-4e23-9c5d-25284bc75f07&kbver=1.11.0&f=true&stork=true&b=true'
```

* Get the Portworx pod names
```
kubectl get pods -o wide -n kube-system -l name=portworx
```

* View Portworx pod logs
```
kubectl logs -n kube-system portworx-<xxx>
```

* Monitor Portworx and wait for cluster to be up
```
PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
```

* Create DSE service
```
kubectl create service nodeport datastax --tcp=9042:9042
```

* Create Portworx storage group for datastax
```
kubectl create -f datastax-storage.yaml
```

* Launch DSE node using Portworx storage
```
kubectl create -f datastax-statefulset.yaml
```

* View DSE logs. As of this writing Portworx storage fails when libaio is enabled
```
kubectl exec -it datastax-0 "tail -f /var/log/cassandra/system.log"
```
