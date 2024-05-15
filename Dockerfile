ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION
ADD rootfs /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
