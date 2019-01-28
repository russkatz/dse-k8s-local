* Create local docker registry

```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```
(Rest of readme assumes 172.31.14.34 is your local IP, adjust according)

* Setup insecure repository on every kubernetes node

/etc/docker/daemon.json:
```
{
    "insecure-registries" : [ "172.31.14.34:5000" ]
}
```
```
service restart docker
```

* Build dockerized app

```
docker build -t demoapp:latest .
docker tag demoapp:latest 172.31.14.34:5000/demoapp:latest
docker push 172.31.14.34:5000/demoapp:latest
```

* Create kubernetes deployment

 kubectl apply -f app1.yaml

 [You should now see writes in to demo.table1 on the service datastax]

