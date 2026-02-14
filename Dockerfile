ARG VERSION=0.4.9.5
ARG ALPINE_VERSION=3.23

ARG USER=toruser
ARG UID=1000

ARG DIR=/data

FROM alpine:$ALPINE_VERSION AS preparer-base

RUN apk add --no-cache gnupg curl

ENV KEYS="514102454D0A87DB0767A1EBBE6A0531C18A9179 B74417EDDF22AC9F9E90F49142E86A2A11F48D36"

#RUN curl -s https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf |gpg --import -
RUN gpg --keyserver keys.openpgp.org --recv-keys $KEYS

RUN gpg --list-keys | tail -n +3 | tee /tmp/keys.txt && \
    gpg --list-keys $KEYS | diff - /tmp/keys.txt

FROM preparer-base AS preparer-release

ARG VERSION

ADD https://dist.torproject.org/tor-$VERSION.tar.gz.sha256sum.asc ./
ADD https://dist.torproject.org/tor-$VERSION.tar.gz.sha256sum ./
ADD https://dist.torproject.org/tor-$VERSION.tar.gz ./

RUN gpg --verify tor-$VERSION.tar.gz.sha256sum.asc
RUN sha256sum -c tor-$VERSION.tar.gz.sha256sum
RUN tar -xzf "/tor-$VERSION.tar.gz" && \
    rm  -f   "/tor-$VERSION.tar.gz"

FROM preparer-release AS preparer

FROM alpine:$ALPINE_VERSION AS builder

ARG VERSION

RUN apk add --no-cache libevent-dev openssl-dev zlib-dev build-base

WORKDIR /tor-$VERSION/

COPY  --from=preparer /tor-$VERSION/  ./

RUN ./configure --sysconfdir=/etc --datadir=/var/lib
RUN make -j$(nproc)
RUN make install

RUN ls -la /etc
RUN ls -la /etc/tor
RUN ls -la /var/lib
RUN ls -la /var/lib/tor

FROM alpine:$ALPINE_VERSION AS final

ARG VERSION
ARG USER
ARG UID
ARG DIR

LABEL maintainer="Liz Lightning (@lnliz)"

RUN apk add --no-cache libevent libssl3 zlib

COPY  --from=builder /usr/local/bin/tor*  /usr/local/bin/
COPY  ./torrc-dist /etc/tor/torrc

RUN addgroup -g $UID $USER && \
    adduser -D -u $UID -G $USER -s /bin/sh -h $DIR $USER

RUN mkdir -p /etc/tor && \
    chown "$USER":"$USER" /etc/tor
COPY  --chown=$USER:$USER torrc-dist /etc/tor/torrc


USER $USER

VOLUME /etc/tor
VOLUME /var/lib/tor

EXPOSE 9050 9051 29050 29051

ENTRYPOINT ["tor"]
