# dnscrypt-proxy-docker
DNScrypt-proxy in a container (mostly for research purposes)

# Aim
This image is neither for industrial nor for personal use. If you want a light-weight yet working version of a containerized DNScrypt-proxy, use [klutchell's work](https://github.com/klutchell/dnscrypt-proxy-docker).
This image for research purpose only, using a heavier-weight base image to have better interaction with the container, e.g., shell access, save and store SSL keys for decrypting communication.

# Available docker container bases
We have images based on pure `bookworm` debian, which is around 234 MB once bundled.
On the other hand, we have Wolfi-based images as well, which are not only less vulnerable to many well known attacks but, since Wolfi is a distroless base image, the final size of the container is around 180 MB. By removing further things from the latter and/or using a base with even less tools, you can actually achieve smaller than 15 MB container like [klutchell's work](https://github.com/klutchell/dnscrypt-proxy-docker).

## Tags
Accordingly, we have two tags with two `Dockerfiles`:
 - cslev/dnscrypt-proxy-docker:debian  -- Dockerfile.debian
 - cslev/dnscrypt-proxy-docker:wolfi   -- Dockerfile.wolfi

# How to compile
## Debian-based image
```
sudo docker build -t cslev/dnscrypt-proxy-research:debian . -f Dockerfile.debian
```
## Wolfi-based image
```
sudo docker build -t cslev/dnscrypt-proxy-research:wolfi . -f Dockerfile.wolfi
```

# Usage
To use the container, you have to provide the `dnscrypt-config.toml` file, and attach it as a volume to the container.
Use the `dnscrypt-proxy.toml` in the `config` directory as a template. It already works as it is, and is configured to
 - use all possible DoH servers
 - make the proxy to listen on 0.0.0.0:5053
 - uses random selection of the resolvers, instead of the built-in latency-based load-balancer logic
 - logging is done in a log file instead of standard output.

## docker
Based on these settings, the container should be run from the root directory as follows:
```
sudo docker run -v /etc/localtime:/etc/localtime -v ./config/:/dnscrypt-proxy/config/ -v ./logs:/dnscrypt-proxy/logs cslev/dnscrypt-proxy-research:debian
```

## docker-compose (preferred)
Here, we assume the subnetwork 172.29.1.0/24 is not used by any of your docker stacks.
If yes, amend the below docker-compose file accordingly.
Exposing the port is not necessary and sometimes can clash with your OS' `resolved` application.
Without exposing, the proxy can still be address through the docker bridge, using its IP address we configure in the docker-compose file too.

```
version: "3.6"
services:
  dnscrypt-proxy-research:
    container_name: dnscrypt-proxy-research
    hostname: dnscrypt-proxy-research
    restart: unless-stopped
    image: cslev/dnscrypt-proxy-research:debian
    dns: 9.9.9.9
    ports: 
      - '5053:5053/udp'
    volumes:
      - '/etc/localtime:/etc/localtime:ro'
      - '/etc/timezone:/etc/timezone:ro'
      - '/home/lele/git/dnscrypt-proxy-docker/config:/dnscrypt-proxy/config/'
      - '/home/lele/git/dnscrypt-proxy-docker/logs:/dnscrypt-proxy/logs'
    environment:
      - "TZ=Asia/Singapore"
    networks:
      internal:
        ipv4_address: 172.29.1.2

networks:
  #local network to talk to within the raspberry itself
  internal:
    name: dnscrypt_proxy_research_subnet
    ipam:
      config:
        - subnet: 172.29.1.0/24        
```

# Docker HUB
Images are also available on docker hub, so you can pull them straighaway without compiling them.
See the tags on [https://hub.docker.com/r/cslev/dnscrypt-proxy-research/tag](https://hub.docker.com/r/cslev/dnscrypt-proxy-research/tags)



