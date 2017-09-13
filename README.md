# Tags and respective `Dockerfile` links

- [`1.13.5`, `1.13`, `mainline` *(1.13.5/Dockerfile)*](https://github.com/nbrownuk/docker-nginxhello/blob/mainline/Dockerfile)
- [`1.12.1`, `1.12`, `stable`, `latest` *(1.12.1/Dockerfile)*](https://github.com/nbrownuk/docker-nginxhello/blob/master/Dockerfile)

# What is this image?

This image is a simple configuration of the [Nginx](https://nginx.org/en/) HTTP server, used for demonstrating the provision of a service from a container running on a Docker host, or from containers deployed as service tasks in a Swarm cluster.

# How to use this image

## Running a container

The content and configuration of Nginx is simplistic, and can be invoked with:

```
$ docker container run --rm -d -p 80:80 nbrown/nginxhello
```

To add the hostname of the Docker host to the served content, mount `/etc/hostname` at `/etc/docker-hostname` inside the container:

```
$ docker container run --rm -d -p 80:80 -v /etc/hostname:/etc/docker-hostname:ro nbrown/nginxhello
```

## Running a Swarm service

In order to run a Swarm service, and have each task serve the hostname of the node that the task is scheduled on:

```
$ docker service create --detach=false \
    --publish published=80,target=80 \
    --mount type=bind,src=/etc/hostname,dst=/etc/docker-hostname,ro \
    nbrown/nginxhello
```
