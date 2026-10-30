# Tor as a Docker container


![Version](https://img.shields.io/github/v/release/lnliz/docker-tor?sort=semver) 
![Docker Pulls Count](https://img.shields.io/docker/pulls/lnliz/tor.svg?style=flat)
![Docker Image Size](https://img.shields.io/docker/image-size/lnliz/tor.svg?style=flat)

Tor service as a docker container, supporting multiple platforms/architectures (armv6, armv7, arm64, amd64)

> The work here was initially based on [lncm/docker-tor](https://github.com/lncm/docker-tor/), but has diverged much since.


## Usage instructions

## Tags

> **NOTE:** For an always up-to-date list see: https://hub.docker.com/r/lnliz/tor/tags

* `v0.4.9.15`
* `v0.4.9.14`
* `v0.4.9.11`
* `v0.4.9.5`
* `v0.4.8.21`




## Running

### Command Line

Copy the supplied Tor configuration, then run Tor with a private data volume. This publishes the SOCKS port only on the host's loopback address:

```bash
cp torrc-dist torrc
docker run --rm -d \
            --name tor \
            -p 127.0.0.1:9050:9050 \
            -v "$PWD/torrc:/etc/tor/torrc:ro" \
            -v tor-data:/var/lib/tor \
            -v tor-control:/var/run/tor \
            lnliz/tor:v0.4.9.15
```

### Docker-compose

The supplied [Compose file](https://github.com/lnliz/docker-tor/blob/master/docker-compose.yml-dist) runs Tor on a bridge network and publishes SOCKS only to the host's loopback address. Copy `torrc-dist` to `torrc` before starting it.

To connect Bitcoin Core to Tor, put both services on the same Compose network:

```yaml
services:
    tor:
        image: lnliz/tor:v0.4.9.15
        container_name: tor
        volumes:
            - ./torrc:/etc/tor/torrc:ro
            - tor-data:/var/lib/tor
            - tor-control:/var/run/tor
        restart: on-failure
        stop_grace_period: 10m30s

    bitcoind:
        image: lnliz/bitcoind:v29.0
        volumes:
            - ./bitcoin:/.bitcoin
            - tor-control:/var/run/tor:ro
        group_add:
            - "1000"
        depends_on:
            - tor

volumes:
    tor-data:
    tor-control:
```

Set `proxy=tor:9050` and `torcontrol=tor:9051` in Bitcoin Core's `bitcoin.conf`. Tor writes the control cookie to `/var/run/tor/control_auth_cookie`. The shared `tor-control` volume gives Bitcoin Core read access to that cookie without sharing Tor's data directory. The group ID `1000` matches the image's default Tor group; change it if you build the image with a different UID.

You can mount your own `torrc` instead of the supplied one:

```yaml
services:
    tor:
        image: lnliz/tor:v0.4.9.15
        volumes:
            - ./host-directory/torrc:/etc/tor/torrc:ro
```

### Generating Tor Passwords

```bash
docker run --rm \
            --name tor \
            lnliz/tor:v0.4.9.15 \
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
