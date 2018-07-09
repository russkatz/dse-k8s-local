# Multi DC 
Each DC in a kubernetes environment will be it's own statefulSet. This allows you to scale each DC independelty of each other. The dc2-statefulset.yaml file will create a DC-2 inside the cluster you already created.

* Create dc2 statefuleSet:
```
kubectl create -f dc2-statefuleset.yaml
```

* Check status of cluster, should see DC-2 join the cluster with a single node.
```
kubectl exec datastax-0 nodetool status
```

* Scale the DC up one node at a time
```
kubectl scale statefulsets dc2 --replicas=2
kubectl exec datastax-0 nodetool status
... wait for node to join ...

kubectl scale statefulsets dc2 --replicas=3
kubectl exec datastax-0 nodetool status
```

