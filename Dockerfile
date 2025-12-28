ARG VERSION=0.4.8.21
ARG DEBIAN_VERSION=13-slim

ARG USER=toruser
ARG UID=1000

ARG DIR=/data

FROM debian:$DEBIAN_VERSION AS preparer-base

RUN apt update
RUN apt -y install gpg gpg-agent curl

# Add tor key
ENV KEYS="514102454D0A87DB0767A1EBBE6A0531C18A9179 B74417EDDF22AC9F9E90F49142E86A2A11F48D36 7A02B3521DC75C542BA015456AFEE6D49E92B601"

#RUN curl -s https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf |gpg --import -
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys $KEYS 

RUN gpg --list-keys | tail -n +3 | tee /tmp/keys.txt && \
    gpg --list-keys $KEYS | diff - /tmp/keys.txt

FROM preparer-base AS preparer-release

ARG VERSION

ADD https://dist.torproject.org/tor-$VERSION.tar.gz.sha256sum.asc ./
ADD https://dist.torproject.org/tor-$VERSION.tar.gz.sha256sum ./
ADD https://dist.torproject.org/tor-$VERSION.tar.gz ./

RUN gpg --verify tor-$VERSION.tar.gz.sha256sum.asc
RUN sha256sum -c tor-$VERSION.tar.gz.sha256sum
# Extract
RUN tar -xzf "/tor-$VERSION.tar.gz" && \
    rm  -f   "/tor-$VERSION.tar.gz"

FROM preparer-release AS preparer

FROM debian:$DEBIAN_VERSION AS builder

ARG VERSION

RUN apt update
RUN apt -y install libevent-dev libssl-dev zlib1g-dev build-essential

WORKDIR /tor-$VERSION/

COPY  --from=preparer /tor-$VERSION/  ./

RUN ./configure --sysconfdir=/etc --datadir=/var/lib
RUN make -j$(nproc)
RUN make install

RUN ls -la /etc
RUN ls -la /etc/tor
RUN ls -la /var/lib
RUN ls -la /var/lib/tor

FROM debian:$DEBIAN_VERSION AS final

ARG VERSION
ARG USER
ARG UID
ARG DIR

LABEL maintainer="Liz Lightning (@lnliz)"

# Libraries (linked)
COPY  --from=builder /usr/lib /usr/lib
# Copy all the TOR files
COPY  --from=builder /usr/local/bin/tor*  /usr/local/bin/
# torrc config
COPY  ./torrc-dist /etc/tor/torrc

# NOTE: Default GID == UID == 1000
RUN groupadd -g $UID $USER && \
    useradd -m -u $UID -g $USER -s /bin/bash -d $DIR $USER

# Copy default torrc configuration
RUN mkdir -p /etc/tor && \
    chown "$USER":"$USER" /etc/tor
COPY  --chown=$USER:$USER torrc-dist /etc/tor/torrc


USER $USER

VOLUME /etc/tor
VOLUME /var/lib/tor

EXPOSE 9050 9051 29050 29051

ENTRYPOINT ["tor"]
