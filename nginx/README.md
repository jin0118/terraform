# kind-cluster에서 네트워크 통신 테스트
경로: hostport (맥북) -> container port (kind-cluster의 컨테이너 포트 / Service의 NodePort) 
                        
                  

### (1) kind cluser 설정
```
{
      extra_port_mappings = {
        container_port = "30000"
        host_port      = "30980"
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }
      kubeadm_config_patches = []
}
```
#### 설정 확인: ```docker ps``` 결과에서 ports에 해당함
```
CONTAINER ID   IMAGE                   COMMAND                   CREATED         STATUS             PORTS                                                 NAMES
744eb6b002f6   kindest/node:v1.21.14   "/usr/local/bin/entr…"   9 minutes ago   Up 9 minutes       0.0.0.0:30980->30000/tcp
```

### (2) Service 설정
```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: proxy
  ports:
  - name: name-of-service-port
    protocol: TCP
    port: 80
    nodePort: 30000
    targetPort: http-web-svc
```
#### 설정확인
ContainerPort:NodePort = 80:30000에 해당함
```
$ k get service        
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx-service   NodePort    10.96.128.165   <none>        80:30000/TCP   11m
```

### (3) 통신 확인
```
$ curl 0.0.0.0:30980

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```