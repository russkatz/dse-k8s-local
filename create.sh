kubectl create service nodeport datastax --tcp=9042:9042
kubectl create -f datastax-storage.yaml
kubectl create -f datastax-node0-pv0.yaml
kubectl create -f datastax-node0-pv1.yaml
kubectl create -f datastax-node1-pv0.yaml
kubectl create -f datastax-node1-pv1.yaml
kubectl create -f datastax-node2-pv0.yaml
kubectl create -f datastax-node2-pv1.yaml
kubectl create -f datastax-statefulset.yaml
