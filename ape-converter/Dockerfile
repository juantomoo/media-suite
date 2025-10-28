FROM debian:bookworm-slim

ENV TZ=UTC \
    PUID=1000 \
    PGID=1000 \
    WATCH_DIR=/data/downloads \
    OUTPUT_MODE=sidecar \
    DELETE_SOURCE=false

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       bash coreutils tzdata inotify-tools ffmpeg shntool cuetools flac \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user matching desired uid/gid
RUN groupadd -g ${PGID} media || true && \
    useradd -m -u ${PUID} -g ${PGID} media || true

WORKDIR /app
COPY convert.sh /app/convert.sh
RUN chmod +x /app/convert.sh

USER media

ENTRYPOINT ["/app/convert.sh"]

