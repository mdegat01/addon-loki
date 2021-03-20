ARG BUILD_FROM

# https://hub.docker.com/r/grafana/loki
# https://github.com/grafana/loki/releases
FROM grafana/loki:2.2.0 as build

# hadolint ignore=DL3006
FROM $BUILD_FROM

# Add Loki
COPY --from=build /usr/bin/loki /usr/bin/loki
RUN set -eux; \
    loki -version;

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
