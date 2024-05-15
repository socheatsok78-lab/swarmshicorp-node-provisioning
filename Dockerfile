ARG ALPINE_VERSION=latest
FROM alpine:$ALPINE_VERSION
RUN apk add --no-cache bash
ADD rootfs /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
