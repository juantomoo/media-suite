FROM alpine:3.20

ENV TZ=UTC \
    PUID=1000 \
    PGID=1000 \
    WATCH_DIR=/data/downloads \
    OUTPUT_MODE=sidecar \
    DELETE_SOURCE=false

RUN apk add --no-cache bash coreutils tzdata inotify-tools ffmpeg shntool cuetools flac

# Create non-root user matching desired uid/gid
RUN addgroup -g ${PGID} media && \
    adduser -D -G media -u ${PUID} media

WORKDIR /app
COPY convert.sh /app/convert.sh
RUN chmod +x /app/convert.sh

USER media

ENTRYPOINT ["/app/convert.sh"]

