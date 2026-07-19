ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.0.2

# --- Build Stage ---
# Clones deputy + wanted-core as siblings (deputy's go.mod resolves wanted-core
# via a relative replace). The web UI is pre-built and committed (web/dist),
# so no Node toolchain is needed here.
FROM golang:1.26-alpine AS builder

WORKDIR /build
ARG BUILD_VERSION=main
ARG CORE_VERSION=main

RUN apk add --no-cache git
RUN git clone --depth 1 --branch $CORE_VERSION https://gitlab.com/mekops/wanted/wanted-core.git
RUN git clone --depth 1 --branch $BUILD_VERSION https://gitlab.com/mekops/wanted/deputy.git
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
