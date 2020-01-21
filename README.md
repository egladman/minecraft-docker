# minecraft-docker

This is a sample project used to better familiarize myself with Docker. This is a reimagining of one of my older projects: [egladman/minutemen](https://github.com/egladman/minutemen).

Built on top of Alpine Linux, `minecraft-docker` is a lightweight containerized variant of Minecraft Jave Edition. By favoring a smaller base image such as `alpine`, we're able to reduce the dependency footprint on system libraries that the underlying container was built on. The fewer dependencies lessens the chance of introducing security vulnerabilities and exploits.

## Development

### Dependencies

- docker
  - [Fedora Installation](https://docs.docker.com/install/linux/docker-ce/fedora/)

### Build

```
docker build .
```

### Administration

**Note:** Check the official docker docs for additional info

Check for running containers

```
docker container ps
```

Connect to a running container

```
docker exec -it <container-id> bash
```
