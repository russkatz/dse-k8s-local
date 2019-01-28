* Create local docker registry

* Setup insecure repository on every kubernetes node

* Build docker app

 * docker build -t demoapp:latest .
 * docker tag demoapp:latest 172.31.14.34:5000/demoapp:latest
 * docker push 172.31.14.34:5000/demoapp:latest
 

* Create kubernetes deployment

 kubectl apply -f app1.yaml

 [You should now see writes in to demo.table1 on the service datastax]

