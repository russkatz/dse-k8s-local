kubectl create service nodeport datastax --tcp=9042:9042
kubectl create -f datastax-storage.yaml
kubectl create -f datastax-statefulset.yaml
