ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.0.2

# --- Build Stage ---
# The Supervisor passes BUILD_VERSION as this add-on's own version, which names
# the Deputy tag once prefixed with "v". Library dependencies resolve as ordinary
# Go modules; the web UI is pre-built and committed (web/dist), so no Node
# toolchain is needed here.
FROM golang:1.26-alpine AS builder

WORKDIR /build
ARG BUILD_VERSION=main

RUN apk add --no-cache git
RUN REF="$BUILD_VERSION"; \
    case "$REF" in [0-9]*) REF="v$REF";; esac; \
    git clone --depth 1 --branch "$REF" https://gitlab.com/mekops/wanted/deputy.git
RUN cd deputy && \
    git fetch --tags --depth 1 && \
    CGO_ENABLED=0 go build \
      -ldflags "-X gitlab.com/mekops/wanted/deputy/internal/version.Version=$(git describe --tags --dirty --always)" \
      -o /deputy ./cmd/deputy

# --- Runtime Stage ---
FROM $BUILD_FROM

COPY --from=builder /deputy /usr/bin/deputy
COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 8080

CMD [ "/run.sh" ]
