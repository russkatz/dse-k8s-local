kubectl create service nodeport opscenter --tcp=8888:8888
kubectl create -f opsc-statefulset.yaml
