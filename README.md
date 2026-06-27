# Tor as a Docker container


![Version](https://img.shields.io/github/v/release/lnliz/docker-tor?sort=semver) 
![Docker Pulls Count](https://img.shields.io/docker/pulls/lnliz/tor.svg?style=flat)
![Docker Image Size](https://img.shields.io/docker/image-size/lnliz/tor.svg?style=flat)

Tor service as a docker container, supporting multiple platforms/architectures (armv6, armv7, arm64, amd64)

> The work here was initially based on [lncm/docker-tor](https://github.com/lncm/docker-tor/), but has diverged much since.


## Usage instructions

## Tags

> **NOTE:** For an always up-to-date list see: https://hub.docker.com/r/lnliz/tor/tags

* `v0.4.9.11`
* `v0.4.9.5`
* `v0.4.8.21`




## Running

### Command Line

To run this from the command line you would need to create an example [config file](https://github.com/torproject/tor/blob/master/src/config/torrc.sample.in) or use the [cut down config file](https://raw.githubusercontent.com/lnliz/docker-tor/master/torrc-dist) in this repo.

Then you would need to run:

```bash
docker run --rm -d \
            --network host \
            --name tor \
            -v $PWD/data:/etc/tor \
            -v $PWD/data:/var/lib/tor \
            -v $PWD/run:/var/run/tor \
            lnliz/tor:v0.4.9.11

```
This assumes you have a directory called `data` and a directory called `run` in the current `$PWD`. And the config file `torrc` should live in data.

### Docker-compose

For your convenience, we have a [docker-compose](https://github.com/lnliz/docker-tor/blob/master/docker-compose.yml-dist) file available for you to use too.

```
services:
    tor:
        image: lnliz/tor:v0.4.9.11
        container_name: tor
        volumes:
            - ${PWD}/tor:/etc/tor
            - ${PWD}/tor:/var/lib/tor
            - ${PWD}/tor-run:/var/run/tor
        restart: on-failure
        network_mode: host

    # how to use tor with bitcoind
    bitcoind:
        image: lnliz/bitcoind:v29.0
        volumes:
            - ${PWD}/bitcoin:/.bitcoin
            - ${PWD}/tor:/var/lib/tor
        depends_on:
            - tor

```

The command-line example uses host networking and expects `data` and `run` folders. The Compose example also uses host networking and mounts `tor` and `tor-run`.
A valid torrc is provided but you can mount your own:

```
services:
    tor:
        image: lnliz/tor:v0.4.9.11
        volumes:
            - ./host-directory/torrc:/etc/tor/torrc
```

### Generating Tor Passwords

```bash
docker run --rm \
            --name tor \
            lnliz/tor:v0.4.9.11 \
            --hash-password passwordtogenerate
```



## Maintainer release notes

The GitHub Action takes the Tor version from the git tag, then fetches, verifies, and compiles that upstream release from [dist.torproject.org](https://dist.torproject.org/).

To grab a new version, tag a new release:

Example:

```bash
git tag -s v0.4.9.11+build1
```

Would release `v0.4.9.11` of Tor.

As a maintainer, you should also update the documentation too.

### Environment Variables

> **Note** In order to trigger builds This repository uses the following environment variables:

* `DOCKER_HUB_USER` - the username for Docker Hub
* `DOCKER_USERNAME` - The username for Docker Hub.
* `DOCKER_PASSWORD` - The password for Docker Hub
* `DOCKER_TOKEN` - the token for Docker Hub which can push to this project (not used currently)
* `GITHUB_TOKEN` - The token of the current user (this is added automatically)
* `GITHUB_ACTOR` - The user to log in to docker.pkg.github.com
* `GITHUB_REPOSITORY` - The repository pathname (used for the push to GitHub's package registry)
