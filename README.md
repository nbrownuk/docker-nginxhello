# Tags and respective `Dockerfile` links

- [`1.18.0`, `1.18`, `stable` *(1.18.0/Dockerfile)*](https://github.com/nbrownuk/docker-nginxhello/blob/master/Dockerfile)

# What is this image?

<img src="https://github.com/nbrownuk/docker-nginxhello/blob/master/screenshot.png" alt="Output" style="zoom:75%;" />

This image is a simple configuration of the [Nginx](https://nginx.org/en/) HTTP server, used for demonstrating the provision of a service from a container running on a Docker host, from containers deployed as service tasks in a Swarm cluster, or as pods in a Kubernetes cluster. The same image can be used for different, distinct workloads, by setting the `COLOR` environment variable to one of Red, Blue or Black (default). Simplistic liveness and readiness endpoints can be accessed at `/healthz/live` and `/healthz/ready`, respectively.

# How to use this image

## Running a container

The content and configuration of Nginx is simplistic, and can be invoked with:

```
$ docker container run --rm -d -p 80:80 -e COLOR=blue nbrown/nginxhello
```

To add the hostname of the Docker host to the served content, set the `NODE_NAME` environment variable for the container:

```
$ docker container run --rm -d -p 80:80 -e NODENAME=$(hostname) nbrown/nginxhello
```

## Running a Swarm service

In order to run a Swarm service, and have each task serve the hostname of the node that the task is scheduled on:

```
$ docker service create --detach=false \
    --publish published=80,target=80 \
    --env COLOR=Red
    --env NODE_NAME="{{.Node.Hostname}}" \
    nbrown/nginxhello
```

## Running a Kubernetes deployment

To have Deployment replicas serve the cluster node's hostname, use the Downward API to retrieve the hostname:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginxhello
  name: nginxhello
spec:
  selector:
    matchLabels:
      app: nginxhello
  template:
    metadata:
      labels:
        app: nginxhello
    spec:
      containers:
      - image: nginxhello
        name: nginxhello
        ports:
        - containerPort: 80
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
```
