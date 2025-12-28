# Tor as a Docker container


[![Build on push](https://github.com/lnliz/docker-tor/workflows/Docker%20build%20on%20push/badge.svg)](https://github.com/lnliz/docker-tor/actions?query=workflow%3A%22Docker+build+on+push%22)
[![Build on tag deploy](https://github.com/lnliz/docker-tor/workflows/Docker%20build%20on%20tag/badge.svg)](https://github.com/lnliz/docker-tor/actions?query=workflow%3A%22Docker+build+on+tag%22)
![Version](https://img.shields.io/github/v/release/lnliz/docker-tor?sort=semver) 
![Docker Pulls Count](https://img.shields.io/docker/pulls/lnliz/tor.svg?style=flat)

Tor service as a docker container, supporting multiple platforms/architectures (armv6, armv7, arm64, amd64)

> The work here was initially based on [lncm/docker-tor](https://github.com/lncm/docker-tor/), but has diverged much since.


## Usage instructions

## Tags

> **NOTE:** For an always up-to-date list see: https://hub.docker.com/r/lnliz/tor/tags

* `latest`
* `0.4.8.21`
* `0.4.8.17`




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
            lnliz/tor:0.4.8.21

```
This assumes you have a directory called `data` and a directory called `run` in the current `$PWD`. And the config file `torrc` should live in data.

### Docker-compose

For your convenience, we have a [docker-compose](https://github.com/lnliz/docker-tor/blob/master/docker-compose.yml-dist) file available for you to use too.

```
version: "3.8"

services:
    tor:
        image: lnliz/tor:0.4.8.21
        container_name: tor
        volumes:
            - ${PWD}/tor:/etc/tor
            - ${PWD}/tor:/var/lib/tor
            - ${PWD}/tor-run:/var/run/tor
        restart: on-failure

    # how to use tor with bitcoind
    bitcoind:
        image: lnliz/bitcoind:v29.0
        volumes:
            - ${PWD}/bitcoin:/.bitcoin
            - ${PWD}/tor:/var/lib/tor
        depends_on:
            - tor

```

By default this uses host networking and requires `data` and `run` folders to be created.
A valid torrc is provided but you can mount your own:

```
services:
    tor:
        image: lnliz/tor:0.4.8.21
        volumes:
            - ./host-directory/torrc:/etc/tor/torrc
```

### Generating Tor Passwords

```bash
docker run --rm \
            --name tor \
            lnliz/tor:0.4.7.21 \
            --hash-password passwordtogenerate
```



## Maintainer release notes

The github action takes in the current tag from [upstream](https://dist.torproject.org/) and then fetches, verifies and compiles this.

To grab a new version simply just tag a new version

Example:

```bash
git tag -s 0.4.8.21
```

Would Release ```0.4.8.21``` of tor.

As a maintainer, you should also update the documentation too.

### Environment Variables

> **Note** In order to trigger builds This repository uses the following environment variables:

* `DOCKER_HUB_USER` - the username for docker hub
* `DOCKER_USERNAME` - The username for dockerhub.
* `DOCKER_PASSWORD` - The password for dockerhub
* `DOCKER_TOKEN` - the token for docker hub which can push to this projecta (not used currently)
* `GITHUB_TOKEN` - The token of the current user (this is added automatically)
* `GITHUB_ACTOR` - The user to login to docker.pkg.github.com
* `GITHUB_REPOSITORY` - The repository pathname (used for the push to githubs package registry)

