# Build arguments (must be before FROM for global scope)
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:7.3.3

###############################################################################
# Stage 1: Build OpenClaw from source
###############################################################################
FROM node:22-bookworm AS openclaw-builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Bun (required for OpenClaw build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Enable pnpm
RUN corepack enable

WORKDIR /build

# Clone OpenClaw source (from fork with telegram threading fix)
# OPENCLAW_REF can be a tag (v2026.3.24), branch (main), or 40-char commit SHA
ARG OPENCLAW_REF=main
ARG OPENCLAW_REPO=https://github.com/mekenthompson/openclaw.git
# Cache-bust: bump this value to force a fresh git clone when OPENCLAW_REF is a branch
ARG OPENCLAW_CACHEBUST=2
RUN set -ex; \
    if echo "${OPENCLAW_REF}" | grep -qE '^[0-9a-f]{7,40}$'; then \
        echo "Cloning OpenClaw at commit ${OPENCLAW_REF}"; \
        git clone --filter=blob:none --no-checkout "${OPENCLAW_REPO}" . \
        && git checkout "${OPENCLAW_REF}"; \
    else \
        echo "Cloning OpenClaw at ref ${OPENCLAW_REF}"; \
        git clone --depth 1 --branch "${OPENCLAW_REF}" "${OPENCLAW_REPO}" .; \
    fi \
    && git rev-parse HEAD > /build/.openclaw-commit \
    && rm -rf .git

# Install dependencies
RUN pnpm install --no-frozen-lockfile

# Build OpenClaw
RUN OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build:docker \
    && OPENCLAW_PREFER_PNPM=1 pnpm ui:build

# Install additional packages if specified (power-user feature)
ARG OPENCLAW_DOCKER_APT_PACKAGES=""
RUN if [ -n "$OPENCLAW_DOCKER_APT_PACKAGES" ]; then \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $OPENCLAW_DOCKER_APT_PACKAGES && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*; \
    fi

###############################################################################
# Stage 2: Create final addon image
###############################################################################
# Re-declare BUILD_FROM for this stage
ARG BUILD_FROM
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
        nginx-light \
        git \
        curl \
        ca-certificates \
        procps \
        unzip \
        ffmpeg \
        ripgrep \
        tmux \
        jq \
        mesa-vulkan-drivers \
        openssh-client \
    && apt-get clean \
    && rm -rf /tmp/* /var/cache/* /var/lib/apt/lists/*

# Install Chromium and dependencies for Playwright (power-user feature enabled by default)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        chromium \
        chromium-sandbox \
        fonts-liberation \
        fonts-noto-color-emoji \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libatspi2.0-0 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libdrm2 \
        libgbm1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libx11-6 \
        libxcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxkbcommon0 \
        libxrandr2 \
        xdg-utils \
    && apt-get clean \
    && rm -rf /tmp/* /var/cache/* /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean \
    && rm -rf /tmp/* /var/cache/* /var/lib/apt/lists/*

# Install age for encrypted secret backups
RUN curl -fsSL -o /tmp/age.tar.gz "https://dl.filippo.io/age/v1.2.1?for=linux/amd64" \
    && tar -xzf /tmp/age.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm /tmp/age.tar.gz

# Enable pnpm and Bun for runtime
RUN corepack enable \
    && curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Copy OpenClaw from builder
WORKDIR /app
COPY --from=openclaw-builder /build /app

# Set environment for production
ARG OPENCLAW_REF
ENV OPENCLAW_REF=${OPENCLAW_REF}
ENV NODE_ENV=production
# Explicit bundled plugin directory — upstream best practice.
# Bypasses isSourceCheckoutRoot() .git detection and dist-runtime symlink path.
# Uses compiled dist/extensions/ directly, preventing "escapes package directory"
# validation errors on gateway startup.
ENV OPENCLAW_BUNDLED_PLUGINS_DIR=/app/dist/extensions
ENV PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0

# Create node user and set permissions
RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node \
    && chown -R node:node /app


# Install qmd as node user (will be preserved to persistent storage on first boot)
USER node
ENV HOME=/home/node
RUN curl -fsSL https://bun.sh/install | bash \
    && /home/node/.bun/bin/bun install -g "https://github.com/tobi/qmd#785bbcf"
USER root
ENV HOME=/root

# Clean up default nginx config and prepare temp dir
RUN rm -rf /etc/nginx/sites-enabled /etc/nginx/conf.d /var/log/nginx \
    && mkdir -p /tmp/nginx

# Copy root filesystem (S6 overlay scripts + nginx config)
COPY rootfs /

# Set up persistent directories
RUN mkdir -p /data/openclaw-config /data/openclaw-workspace /data/openclaw-home \
    && chown -R node:node /data/openclaw-*

# Health check
HEALTHCHECK --start-period=300s --interval=30s --timeout=10s --retries=5 \
    CMD curl --fail http://localhost:18789/health || exit 1

# Build arguments for labels
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
    io.openclaw.ref="${OPENCLAW_REF}" \
    maintainer="mekenthompson" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="mekenthompson" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
