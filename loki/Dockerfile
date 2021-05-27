ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64

# https://hub.docker.com/_/alpine
FROM alpine:3.13.5 as build
# https://github.com/grafana/loki/releases
ENV LOKI_VERSION 2.2.1

RUN set -eux; \
    apk update; \
    apk add --no-cache --virtual .build-deps \
        unzip=6.0-r8 \
        curl=7.77.0-r0 \
        ; \
    APKARCH="$(apk --print-arch)"; \
    case "$APKARCH" in \
        x86_64)  BINARCH='amd64' ;; \
        armhf)   BINARCH='arm' ;; \
        armv7)   BINARCH='arm' ;; \
        aarch64) BINARCH='arm64' ;; \
        *) echo >&2 "error: unsupported architecture ($APKARCH)"; exit 1 ;; \
    esac; \
    curl -J -L -o /tmp/loki.zip \
        "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-${BINARCH}.zip"; \
    unzip /tmp/loki.zip -d /usr/bin; \
    mv /usr/bin/loki-linux-${BINARCH} /usr/bin/loki; \
    chmod a+x /usr/bin/loki; \
    rm /tmp/loki.zip;


# https://github.com/hassio-addons/addon-base/releases
FROM ${BUILD_FROM}:9.2.0

# add Nginx
RUN set -eux; \
    apk update; \
    apk add --no-cache \
        ca-certificates=20191127-r5 \
        nginx=1.18.0-r13 \
        ; \
    update-ca-certificates; \
    nginx -v; \
    rm -f -r /etc/nginx; \
    mkdir -p \
        /var/lib/nginx/tmp/client_body \
        /var/lib/nginx/tmp/fastcgi \
        /var/lib/nginx/tmp/proxy \
        /var/lib/nginx/tmp/scgi \
        /var/lib/nginx/tmp/uwsgi \
        /var/log/nginx \
        /run/nginx \
        ; \
    touch /var/log/nginx/error.log; \
    \
    echo "Add user for Loki"; \
    mkdir -p /data/loki; \
    addgroup -S abc; \
    adduser -u 12345 -h /data/loki -D -S abc -G abc;

# See https://github.com/grafana/loki/issues/1928
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

# Add Loki
COPY --from=build /usr/bin/loki /usr/bin/loki
RUN loki --version

COPY rootfs /
WORKDIR /data/loki

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="mdegat01" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="mdegat01's Home Assistant Add-ons" \
    org.opencontainers.image.authors="mdegat01" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/mdegat01/hassio-addons" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
