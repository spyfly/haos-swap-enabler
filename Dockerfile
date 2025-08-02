ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.3
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install required system utilities
RUN apk add --no-cache \
    util-linux \
    e2fsprogs \
    parted \
    lsblk \
    blkid

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
