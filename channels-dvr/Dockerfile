ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        chromium \
        procps \
    && curl -fsSL https://getchannels.com/dvr/setup.sh -o /tmp/setup.sh \
    && chmod +x /tmp/setup.sh \
    && mkdir -p /opt \
    && cd /opt \
    && DOWNLOAD_ONLY=1 bash /tmp/setup.sh \
    && apt-get clean \
    && rm -fr \
        /tmp/* \
        /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs /

# Ensure run script is executable
RUN chmod a+x /etc/services.d/channels-dvr/run
