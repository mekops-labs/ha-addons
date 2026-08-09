ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.0.2

# --- Build Stage ---
# Clones deputy + sheriff-proto as siblings, which is what a replace in deputy's
# go.mod resolves against while a protocol change is unreleased. The web UI is
# pre-built and committed (web/dist), so no Node toolchain is needed here.
FROM golang:1.26-alpine AS builder

WORKDIR /build
ARG BUILD_VERSION=main
ARG PROTO_VERSION=main

RUN apk add --no-cache git
RUN git clone --depth 1 --branch $PROTO_VERSION https://gitlab.com/mekops/wanted/sheriff-proto.git
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
