ARG BUILD_FROM

# hadolint ignore=DL3006
FROM $BUILD_FROM

# https://github.com/grafana/loki/releases
ENV LOKI_VERSION 2.2.0

# Add Loki
RUN set -eux; \
    APKARCH="$(apk --print-arch)"; \
    case "$APKARCH" in \
    x86_64)  BINARCH='amd64' ;; \
    armhf)   BINARCH='arm' ;; \
    armv7)   BINARCH='arm' ;; \
    aarch64) BINARCH='arm64' ;; \
    *) echo >&2 "error: unsupported architecture ($APKARCH)"; exit 1 ;; \
    esac; \
    \
    curl -J -L -o /tmp/loki.zip "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-${BINARCH}.zip"; \
    unzip /tmp/loki.zip -d /usr/bin; \
    mv /usr/bin/loki-linux-${BINARCH} /usr/bin/loki; \
    chmod a+x /usr/bin/loki; \
    loki -version; \
    rm -f /tmp/loki.zip;

# add Nginx
# hadolint ignore=DL3009
RUN set -eux; \
    apk update; \
    apk add --no-cache \
        ca-certificates=20191127-r5 \
        nginx=1.18.0-r13 \
        ; \
    update-ca-certificates; \
    nginx -v; \
    rm -f -r /etc/nginx; \
    mkdir -p /var/log/nginx; \
    touch /var/log/nginx/error.log;

# See https://github.com/grafana/loki/issues/1928
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

COPY rootfs /
RUN set -eux; \
    mkdir -p /data/loki;
WORKDIR /data/loki
